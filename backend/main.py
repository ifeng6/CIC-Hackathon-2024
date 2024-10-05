from flask import Flask, request, jsonify
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

bucket_name = "cic-hackathon-24-ai-images"

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
            You are given an ocr output from a grocery store receipt that includes food items and non-food items. 
            Filter the items given to include food items and only food items. A food item is defined as something that can be eaten or drank by humans. For example bread, drinks, and desserts can be considered as items to include.
            Do not include words that aren't English words.
            For each food item, output a valid JSON object where the key is the name of the item and the value is an object containing the quantity and cost.
            Do not include non-food items. Output only the JSON and make sure the JSON is valid syntax. No additional text.
        """

        receipt = '["OS","ity # 12783","W 4th Ave, Vancouver, BC V6K 1N9","Apples @ 21bs 4.72 E","Bluetooth Speaker 179.99","Cookies 9.99","Popcorn 8.99","Ketchup 5.5","Laundry detergent 14.99","Peanut Butter 6.79","Salmon @ 71bs 84.99","Garlic 84.99","Olive 0i1 13.99","Broccoli @ 21bs 10.90","Amazon T-Shirt 59.71","Grapes @ 91bs 9","Milk @ 4L 8.99","eat 307551 APP: = jz8R","ran ID#: 7979661264","erchant ID: 768273","OVS SSC«STBL AT","yausyeaies 12:33:32 1206 206 256 206","U8Z3ZU881549831 /UUU0"]'

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
                {
                    "prompt": prompt,
                    "max_gen_len": 2048,
                    "temperature": 0.25,
                    "top_p": 0.25,
                }
            ),
        }

        response = bedrock_runtime.invoke_model(**kwargs)
        body = json.loads(response["body"].read())
        generated_text = body["generation"]
        print(generated_text)
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
            TableName="cic-hackathon-24",
            Item={
                "user": {"S": str(id)},
                "age": {"S": str(age)},
                "height": {"S": str(height)},
                "weight": {"S": str(weight)},
                "activity_level": {"S": str(activity_level)},
            },
        )

    def get_macros(
        id: int, age: int, height: int, weight: int, activity_level: str
    ) -> dict:
        macros = {  
            "cals": None,
            "protein": None,
            "carbs": None,
            "fats": None,
        }

        return macros


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
