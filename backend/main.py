from flask import Flask, request, jsonify, Response
import boto3
import json
from dotenv import load_dotenv
from flask_cors import CORS
import os
import base64
from collections import defaultdict
import requests
from fuzzy_json import loads

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
        userId = request.form["userId"]
        receiptId = request.form["receiptId"]
        print(request.files)
        if "file" not in request.files:
            return jsonify({"error": "No file part"}), 400

        image_file = request.files["file"]
        if image_file.filename == "":
            return jsonify({"error": "No selected file"}), 400

        print(image_file)
        response = requests.post(
            "http://localhost:8000/ocr/", files={"file": image_file}
        )
        print(response.text)

        system_prompt = """
            You are a helpful AI assistant who is an expert in identifying whether or not an item is food. You are given a text scan of an entire grocery store receipt that includes food items and non-food items.
            Filter the items to ONLY include food items which are items that can be eaten or drank by humans.
            For each food item, output a valid JSON object where the key is the name of the food item and the value is an object containing the quantity and cost.
            Output only the JSON and make sure the JSON is valid syntax. No additional text. Do not include items that are not on the receipt.
        """

        # receipt = "/ OS\nCity # 12783\n2285 W 4th Ave, Vancouver, BC V6K 1N9\nB7 Member 832547236\nE 3577445 Apples @ 2 4.72 E\n0623616 Bluetooth Speaker @ 1 179.99\n1826395 Cookies 9.99\n6315178 Bananas @ 3 8.99\n9144381 Ketchup 5.5\n1929371 Detergent 14.99\n1553553 Peanut Butter @ 1 6.79\n7963654 Salmon @ 7 84.99\n0052418 Pasta @ 1 84.99\n0902672 Olives @ 10 13.99\n4872088 Broccoli @ 2 10.90\n0882442 Television 559.71\n4238639 Grapes @ 91bs 9\n2546682 Milk @ 4 8.99\n0083199 0.00\nSUBTOTAL 503.54\nTAX 12.93\neee TOTAL HY\nXXXXXXXXKKXX CHIP Read\nAID: 261X1FpSvpMm\nSeat 307551 APP: = jz8R\nVISA Resp: APPROVED\nTran ID#: 7979661264\nMerchant ID: 768273\nAPPROVED - Purchase\nAMOUNT : 516.47\n10/05/2024 12:33:32 1206 206 256 206\n“OVS SSC«STBL AT\nCHANGE 0.00\nTAX 12.93\nTOTAL TAX 12.93\nTOTAL NUMBER OF ITEMS SOLD= 15\nWyausyeaies 12:33:32 1206 206 256 206\n2U8Z3ZU881549831 /UUU0\nOP: 206 NAME: SCO LANE #206\nThank You.\nPlease Come Again\nWhse: 1206 Trm: 206 Trn: 256 OP: 206\nItems Sold : 15\nB7 10/05/2024 12:33:32\n\f"

        prompt = f"""
            <|begin_of_text|>
            <|start_header_id|>system<|end_header_id|>
            {system_prompt}
            <|eot_id|>
            <|start_header_id|>receipt<|end_header_id|>
            {response.text}
            <|eot_id|>
            <|start_header_id|>assistant<|end_header_id|>
        """
        # kwargs = Key Word Arguments
        kwargs = {
            "modelId": "us.meta.llama3-2-1b-instruct-v1:0",
            "contentType": "application/json",
            "accept": "application/json",
            "body": json.dumps(
                {
                    "prompt": prompt,
                    "max_gen_len": 1024,
                    "temperature": 0.0,
                    "top_p": 0.2,
                }
            ),
        }

        response = bedrock_runtime.invoke_model(**kwargs)
        body = json.loads(response["body"].read())
        generated_text = body["generation"]

        system_prompt_nutrient = """
            You are a helpful AI assistant who is knowledgable in food nutrition. Given a list of food items formatted as a JSON,
            output a JSON object that includes the nutrients including protein, fats, carbohydrates, and calories in amounts.
            Also include the quantity of the item and also predict the number of days until the food item expires. Do not include items that are not considered as food.
            Only output the JSON and no additional text. Above all, the JSON syntax must be valid and correct. 

            Here is an example of how each object must be formatted:
            "name": {
                "quantity":
                "cost":
                "days_left":
                "nutrients": {
                    "protein":
                    "fats":
                    "carbohydrates":
                    "calories":
                    }
                }
            }

            Above all, the JSON syntax must be valid.
            There must be commas between each object and the entire object must be wrapped around curly brackets.
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
                {
                    "prompt": prompt_nutrient,
                    "max_gen_len": 2048,
                    "temperature": 0.0,
                    "top_p": 0.2,
                }
            ),
        }

        nutrient_response = bedrock_runtime.invoke_model(**kwargs_nutrient)
        body = loads(nutrient_response["body"].read())
        nutrient_information = body["generation"]
        print("nutrient_information", nutrient_information)
        all_items = loads(nutrient_information)

        items = []
        macros = defaultdict(int)
        cost = 0
        for name, fields in all_items.items():
            curr = {}
            curr["name"] = name
            # image_url = generate_image(name)
            # curr["image_url"] = image_url
            curr["quantity"] = fields.get("quantity")
            curr["days_left"] = fields.get("days_left")
            items.append(curr)

            for macro_name, macro_value in fields.get("nutrients").items():
                macros[macro_name] += macro_value

            cost += float(fields.get("cost"))

        add_receipt_to_db(
            receipt_id=receiptId, user_id=userId, items=items, macros=macros, cost=cost
        )
        add_items_to_db(user_id=userId, items=items)

        return {"items": items, "macros": macros}


@app.route("/user", methods=["POST"])
def create_profile():
    if request.method == "POST":
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
    macros["cals"] = calculate_calories(age, height, weight, activity_level)  # calories
    macros["protein"] = calculate_protein(weight)  # kg
    macros["carbs"] = calculate_carbs(macros["cals"])  # g
    macros["fats"] = calculate_fats(macros["cals"])  # g
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
        "veryhigh": 1.725,
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


# Return true if the receipt is successfully added to the database
def add_receipt_to_db(
    receipt_id: int, user_id: int, items: list, macros: object, cost
) -> bool:
    try:
        dyanmodb.put_item(
            TableName="receipts",
            Item={
                "receipts": {"S": str(receipt_id)},
                "user": {"S": str(user_id)},
                "items": {"S": str(items)},
                "macros": {"M": macros},
                "cost": {"S": str(cost)},
            },
        )
        return True
    except Exception as e:
        print(e)
        return False


# Return true if the receipt is successfully added to the database
def add_items_to_db(user_id: int, items: list) -> bool:
    try:
        for item in items:
            dyanmodb.put_item(
                TableName="items",
                Item={
                    "items": {"S": str(user_id)},
                    "name": {"S": str(item["name"])},
                    "quantity": {"S": str(item["quantity"])},
                    "days_left": {"S": str(item["days_left"])},
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
            item.pop("receipts", None)
            item.pop("user", None)
        return jsonify(items)


@app.route("/get_items", methods=["GET"])
def get_items():
    if request.method == "GET":
        response = dyanmodb.scan(TableName="items")

        items = response.get("Items", [])
        for item in items:
            item.pop("items", None)
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
            ExpiresIn=36000,
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
        ExpiresIn=36000,
    )
    return url


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
