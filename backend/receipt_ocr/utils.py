import cv2
import imutils
import numpy as np
import pytesseract
from imutils.perspective import four_point_transform


def perform_ocr(img: np.ndarray):
    original_image = cv2.imdecode(img, cv2.IMREAD_COLOR)
    processed_image = original_image.copy()
    processed_image = imutils.resize(processed_image, width=500)
    ratio = original_image.shape[1] / float(processed_image.shape[1])

    # convert the image to grayscale and blur it + edge dection on the recepit
    gray = cv2.cvtColor(processed_image, cv2.COLOR_BGR2GRAY)

    blurred_image = cv2.GaussianBlur(
        gray,
        (
            5,
            5,
        ),
        0,
    )
    edged = cv2.Canny(blurred_image, 75, 200)

    # find contours in the edge map and sort them by size in descending order
    cnts = cv2.findContours(edged.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)
    cnts = sorted(cnts, key=cv2.contourArea, reverse=True)

    # initialize a contour that corresponds to the receipt outline
    receiptCnt = None
    for c in cnts:
        # approximate the contour
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        # if approximated contour has four points, then we can assume we have found the outline of the receipt
        if len(approx) == 4:
            receiptCnt = approx
            break

    # if the receipt contour is empty
    if receiptCnt is None:
        raise Exception(
            (
                "Could not find receipt outline. "
                "Try debugging your edge detection and contour steps."
            )
        )

    # apply a four-point perspective transform to the *original* image to obtain a bird's-eye view of the receipt
    receipt = four_point_transform(original_image, receiptCnt.reshape(4, 2) * ratio)

    # apply OCR to the receipt image by assuming column data
    options = "--psm 6"
    text = pytesseract.image_to_string(
        cv2.cvtColor(receipt, cv2.COLOR_BGR2RGB), config=options
    )
    
    return text
