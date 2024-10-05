from flask import Flask, request, jsonify
import boto3
import json
from dotenv import load_dotenv
from flask_cors import CORS
import os

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


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/upload", methods=["POST"])
def upload():
    if request.method == "POST":
        input = request.json.get("input")

        system_prompt = """
            You are given the output of textual extraction of information of a receipt from a grocery store.
            For all the items in the receipt that are consumable by humans, such as bread or drinks, output in JSON format where the key is the name of the food item
            and the value is the quantity and cost of each food item. The costs will be the numbers right after the food.
            ONLY INCLUDE FOODS ITEMS THAT CAN BE EATEN OR DRANK. ONLY OUTPUT THE JSON YOU GENERATED. NO OTHER TEXT.
        """

        receipt = "=WHOLESALE\nGREEN TOWN $ 5208\n1212, Pine Wood Plaza Or\nGreen Town, CA 34343\n87 Member 585635184442\nE 3081064 BANANAS 1.67 E\nA 7073705 Bluetooth Care 122.34 A\n8143739 Dinning Table 422.99 §\n8523605 Wine Bottle 9.99 E\n8831466 Beer Case 19.90 E\nSUBTOTAL 576.89\nTAX 102.67\n44% TOTAL\nXXXXXXXXXXXX9999 CHIP Read\nAID: — L8G716KSFKGB\nSeq 463882 — APP#: = MAST\nVISA Resp: _ APPROVED\nTran IDs: 2577049117\nMerchant 'ID: 052587\nAPPROVED - Purchase\nAMOUNT : 679.56\n08/19/2021 17:58:17 5208 208 256 208\nOO VTS 67956”\nCHANGE 0.00\nS TAX 9.75% 89.99\nE TAX 7.75% 8.78\nA TAX 2.75% 3.90\nTOTAL TAX 102.67\nTOTAL NUMBER OF ITEMS SOLD = 5\n17:58:17 5208 208 256 208\n2053201443071 1570000\nOP: 208 NAME: SCO LANE #208\nThank You.\nPlease Come Again\nWhse: 5208 Trm: 208 Trn: 256 OP: 208\nItems Sold : 5\nB7 08/19/2021 17:58:17\n\f"
            
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
                {"prompt": prompt, "max_gen_len": 2048, "temperature": 0.5, "top_p": 0.9}
            ),
        }

        response = bedrock_runtime.invoke_model(**kwargs)
        body = json.loads(response["body"].read())
        generated_text = body["generation"]
        print(generated_text)
        return "<p>Upload complete</p>"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
