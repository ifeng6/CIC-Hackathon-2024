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
        return JSONResponse(content={"result": recognized_text}, status_code=200)
    else:
        return {"error": "the uploaded file is not an image"}

