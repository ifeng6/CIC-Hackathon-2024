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
        return JSONResponse(content=cleaned_text, status_code=200)
    else:
        return {"error": "the uploaded file is not an image"}
    
def cleanText(text):
    text = text.replace("\f", "")
    lines = text.split("\n")
    data = {}

    for line in lines:
        if ':' in line:
            key, value = line.split(':', 1)
            data[key.strip()] = value.strip()
        elif ';' in line:
            key, value = line.split(';', 1)
            data[key.strip()] = value.strip()
        elif '|' in line:
            parts = line.split('|')
            data[parts[0].strip()] = parts[1:]
    return data

