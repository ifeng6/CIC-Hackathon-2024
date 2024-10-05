from flask import Flask, request, jsonify, Response
import boto3
import json
from dotenv import load_dotenv
from flask_cors import CORS
import os
import base64

load_dotenv()

app = Flask(__name__)
CORS(app)

bedrock_runtime = boto3.client(
    service_name="bedrock-runtime",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    aws_session_token=os.getenv("AWS_SESSION_TOKEN"),
)

textract_runtime = boto3.client(
    service_name="textract",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    aws_session_token=os.getenv("AWS_SESSION_TOKEN"),
)

s3 = boto3.client(
    service_name="s3",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    aws_session_token=os.getenv("AWS_SESSION_TOKEN"),
)

dyanmodb = boto3.client(
    service_name="dynamodb",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    aws_session_token=os.getenv("AWS_SESSION_TOKEN"),
)

bucket_name = "users"

activity_levels = ["low", "medium", "high", "veryhigh"]


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


# Receives image file and process with ocr
# Extract food items and their respective information
# Generate images of the food and recipes
@app.route("/upload", methods=["POST"])
def upload():
    if request.method == "POST":
        input = request.json.get("input")

        system_prompt = """
            You are given a text scan of a grocery store receipt that includes food items and non-food items.
            Filter the items to ONLY include food items. A food item is defined as something that is normally eaten or drank by humans.
            For each food item, output a valid JSON object where the key is the name of the food item and the value is an object containing the quantity and cost.
            Some items have a weight instead of quantity.
            Output only the JSON and make sure the JSON is valid syntax. No additional text. Do not include items that are not on the receipt.
        """

        receipt = "City # 12783\n2285 W 4th Ave, Vancouver, BC V6K 1N9\nB7 Member 832547236\nE 3577445 Apples 4.72 E\n0623616 Bluetooth Speaker 179.99\n1826395 Cookies 9.99\n6315178 Bananas @ 3lbs 8.99\n9144381 Ketchup 5.5\n1929371 Laundry detergent 14.99\n1553553 Peanut Butter 6.79\n7963654 Salmon @ 71bs 84.99\n0052418 Bread 6.79\n0902672 Olives 13.99\n4872088 Broccoli 10.90\n0882442 Pasta 8.71\n4238639 Rice 28.90\n2546682 Milk @ 4L 8.99\n0083199 Amazon T-Shirt 25.99\n2864182 Chicken @ 6lbs 22.30\nSUBTOTAL 442.53\nTAX 64.93\neee TOTAL HWE\nXXXXXXXXXXXX CHIP Read\nAID: — 261X1Fp5vpMm\nSegt 307551 APH: + jz8R\nVISA Resp:_ APPROVED\nTran D8: 7979661264\nMerchant ID: 768273\nAPPROVED - Purchase\nAMOUNT : 507.46\n10/05/2024 12:33:32 1206 206 256 206\n“OO VISA «SOT\nCHANGE 0.00\nTAX 64.93\nTOTAL TAX 64.93\nTOTAL NUMBER OF ITEMS SOLD = 16\ndanse 12:33:32 1206 206 256 206\n208232088 1249831 /UUU0\nOP: 206 NAME: SCO LANE #206\nThank You.\nPlease Come Again\nWhse: 1206 Trm: 206 Trn: 256 OP: 206\nItems Sold : 16\nB7 10/05/2024 12:33:32\n\f"

        prompt = f"""
            <|begin_of_text|>
            <|start_header_id|>system<|end_header_id|>
            {system_prompt}
            <|eot_id|>
            <|start_header_id|>receipt<|end_header_id|>
            {receipt}
            <|eot_id|>
            <|start_header_id|>assistant<|end_header_id|>
        """
        # kwargs = Key Word Arguments
        kwargs = {
            "modelId": "us.meta.llama3-2-1b-instruct-v1:0",
            "contentType": "application/json",
            "accept": "application/json",
            "body": json.dumps(
                {"prompt": prompt, "max_gen_len": 1024, "temperature": 0.15, "top_p": 0.2}
            ),
        }

        response = bedrock_runtime.invoke_model(**kwargs)
        body = json.loads(response["body"].read())
        generated_text = body["generation"]

        system_prompt_nutrient = """
            You are a helpful AI assistant who is knowledgable in food nutrition. Given a list of food items formatted as a JSON and their respective quantities,
            output a JSON object that includes the name of the food as well as their nutrients in amount. You can ignore items that have no nutrition or aren't foods.
            Only output the JSON and no additional text.
        """

        prompt_nutrient = f"""
            <|begin_of_text|>
            <|start_header_id|>system<|end_header_id|>
            {system_prompt_nutrient}
            <|eot_id|>
            <|start_header_id|>receipt<|end_header_id|>
            {generated_text}
            <|eot_id|>
            <|start_header_id|>assistant<|end_header_id|>
        """

        kwargs_nutrient = {
            "modelId": "us.meta.llama3-2-1b-instruct-v1:0",
            "contentType": "application/json",
            "accept": "application/json",
            "body": json.dumps(
                {"prompt": prompt_nutrient, "max_gen_len": 1024, "temperature": 0.15, "top_p": 0.2}
            ),
        }

        nutrient_response = bedrock_runtime.invoke_model(**kwargs_nutrient)
        body = json.loads(nutrient_response["body"].read())
        nutrient_information = body["generation"]
        print(nutrient_information)

        return "<p>Upload complete</p>"


@app.route("/user", methods=["POST"])
def create_profile():
    if request.method == "POST" and request.content_type == "application/json":
        id = request.json["id"]
        age = request.json["age"]
        height = request.json["height"]
        weight = request.json["weight"]
        activity_level = request.json["activity_level"].replace(" ", "").lower()

        if activity_level not in activity_levels:
            return jsonify({"error": "Invalid activity level"}), 400

        dyanmodb.put_item(
            TableName="users",
            Item={
                "users": {"S": str(id)},
                "age": {"S": str(age)},
                "height": {"S": str(height)},
                "weight": {"S": str(weight)},
                "activity_level": {"S": str(activity_level)},
            },
        )
        return jsonify(get_macros(id, age, height, weight, activity_level))

def get_macros(
    id: int, age: int, height: int, weight: int, activity_level: str
) -> dict:
    macros = {  
        "cals": None,
        "protein": None,
        "carbs": None,
        "fats": None,
    }
    macros['cals'] = calculate_calories(age, height, weight, activity_level) # calories
    macros['protein'] = calculate_protein(weight) # kg
    macros['carbs'] = calculate_carbs(macros['cals']) # g
    macros['fats'] = calculate_fats(macros['cals']) # g
    return macros

def calculate_calories(age: int, height: int, weight: int, activity_level: str) -> int:
    # Calculate BMR using Harris-Benedict equation
    bmr_male = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
    bmr_female = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
    bmr = (bmr_male + bmr_female) / 2
    activity_factors = {
        "low": 1.2,
        "medium": 1.375,
        "high": 1.55,
        "Very H": 1.725,
    }
    tdee = bmr * activity_factors[activity_level]
    return int(tdee)

def calculate_protein(weight: int) -> int:
    # General recommendation: 1 gram of protein per kilogram of body weight
    return weight

def calculate_carbs(cals: int) -> int:
    # 45-65% of total daily calories
    return int(0.5 * cals)

def calculate_fats(cals: int) -> int:
    # 20-35% of total daily calories
    return int(0.275 * cals)

def add_receipt_to_db(receipt_id: int, user_id: int, items: list, macros: list, cost: int) -> bool:
    try:
        dyanmodb.put_item(
            TableName="recipts",
            Item={
                "receipts": {"S": str(receipt_id)},
                "user": {"S": str(user_id)},
                "items": {"L": items},
                "macros": {"L": macros},
                "cost": {"S": str(cost)},
            },
        )
        return True
    except Exception as e:
        print(e)
        return False
    
@app.route("/get_receipt", methods=["GET"])
def get_receipt():
    if request.method == "GET":
        response = dyanmodb.scan(TableName="receipts")

        items = response.get("Items", [])
        for item in items:
            item.pop('receipts', None)
            item.pop('user', None)
        return jsonify(items)


def generate_image(food_str: str):
    food_str = food_str.lower().replace(" ", "")
    response = s3.list_objects_v2(Bucket=bucket_name)
    objects = response.get("Contents", [])
    food_str_exists = any(obj["Key"] == f"{food_str}.png" for obj in objects)

    if food_str_exists:
        url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket_name, "Key": f"{food_str}.png"},
            ExpiresIn=3600,
        )
        return url

    # otherwise generate the image
    kwargs = {
        "modelId": "amazon.titan-image-generator-v2:0",
        "contentType": "application/json",
        "accept": "application/json",
        "body": f'{{"textToImageParams":{{"text":"{food_str}"}},"taskType":"TEXT_IMAGE","imageGenerationConfig":{{"cfgScale":8,"seed":0,"quality":"standard","width":1024,"height":1024,"numberOfImages":1}}}}',
    }
    response = bedrock_runtime.invoke_model(**kwargs)
    body = json.loads(response["body"].read())
    base64_image_data = body["images"][0]

    image_data = base64.b64decode(base64_image_data)

    object_key = f"{food_str}.png"
    s3.put_object(Body=image_data, Bucket=bucket_name, Key=object_key)
    url = s3.generate_presigned_url(
        "get_object",
        Params={"Bucket": bucket_name, "Key": object_key},
        ExpiresIn=3600,
    )
    return url


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
