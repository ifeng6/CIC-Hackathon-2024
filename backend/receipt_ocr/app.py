import numpy as np
from fastapi import FastAPI, UploadFile
from fastapi.responses import JSONResponse
import json

from utils import perform_ocr

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "ocr_api"}

@app.post("/ocr/")
async def ocr_receipt(file: UploadFile):
    # check to ensure that the orginal file is an image
    if file.content_type.startswith("image"):
        image_data = await file.read()
        image_data_array = np.frombuffer(image_data, np.uint8)
        recognized_text = perform_ocr(image_data_array)
        cleaned_text = cleanText(recognized_text)
        # return JSONResponse(content=recognized_text, status_code=200)
        return JSONResponse(content=cleaned_text, status_code=200)
    else:
        return {"error": "the uploaded file is not an image"}
    
def cleanText(text):
    text = text.replace("\f", "")
    lines = text.split("\n")
    data = {
        "items": [],
        "cost": None,
        "quantity": None,
        "date": None
    }

    for line in lines:
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip().lower()
            value = value.strip()
            if "item" in key:
                data["items"].append(value)
            elif "cost" in key:
                data["cost"] = value
            elif "quantity" in key:
                data["quantity"] = value
            elif "date" in key:
                data["date"] = value
        elif ';' in line:
            key, value = line.split(';', 1)
            key = key.strip().lower()
            value = value.strip()
            if "item" in key:
                data["items"].append(value)
            elif "cost" in key:
                data["cost"] = value
            elif "quantity" in key:
                data["quantity"] = value
            elif "date" in key:
                data["date"] = value
        elif '|' in line:
            parts = line.split('|')
            key = parts[0].strip().lower()
            values = [part.strip() for part in parts[1:]]
            if "item" in key:
                data["items"].extend(values)
            elif "cost" in key:
                data["cost"] = values[0] if values else None
            elif "quantity" in key:
                data["quantity"] = values[0] if values else None
            elif "date" in key:
                data["date"] = values[0] if values else None

    return data

