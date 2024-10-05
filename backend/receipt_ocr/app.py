import numpy as np
from fastapi import FastAPI, UploadFile
from fastapi.responses import JSONResponse
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
        cleaned_data = cleanText(recognized_text)
        return JSONResponse(content=cleaned_data, status_code=200)
        # return JSONResponse(content={'result': recognized_text}, status_code=200)
    else:
        return {"error": "the uploaded file is not an image"}
    
def cleanText(text):
    text = text.replace("\f", "")
    lines = text.split("\n")
    keywords_to_exclude = [
        "Member", "SUBTOTAL", "TAX", "TOTAL", "CHIP Read",
        "AID", "Seq", "APP#", "VISA", "Resp", "Tran IDs", "Merchant ID", "APPROVED",
        "AMOUNT", "CHANGE", "S TAX", "E TAX", "A TAX", "TOTAL TAX", "TOTAL NUMBER OF ITEMS SOLD",
        "Thank You", "Please Come Again", "Whse", "Trm", "Trn", "OP"
    ]
    
    cleaned_data = [
        line for line in lines if not any(keyword in line for keyword in keywords_to_exclude)
    ]

    removed_first_chars = []
    for item in cleaned_data:
        removed_first_chars.append(item[1:])

    final_cleaned_data = []
    for item in removed_first_chars:
        for i in range(len(item)):
            if item[i].isalpha():
                final_cleaned_data.append(item[i:])
                break
        
    return final_cleaned_data

