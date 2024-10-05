import argparse
import os

import cv2
import imutils
import pytesseract
from imutils.perspective import four_point_transform


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-i", "--image", type=str, required=True, help="path to input image"
    )
    args = parser.parse_args()

    # check if image with given path exists
    if not os.path.exists(args.image):
        raise Exception("the given image does not exist")

    # load the image, resize and compute ratio
    img_orig = cv2.imread(args.image)
    image = img_orig.copy()
    image = imutils.resize(image, width=500)
    ratio = img_orig.shape[1] / float(image.shape[1])

    # convert the image to grayscale, blur it slightly, and then apply edge dectection 
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(
        gray,
        (
            5,
            5,
        ),
        0,
    )
    edged = cv2.Canny(blurred, 75, 200)
    # cv2.imwrite("edged.jpg", edged)

    # find contours in the edge map and sort them by size in descending order
    contours = cv2.findContours(edged.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = imutils.grab_contours(contours)
    contours = sorted(contours, key=cv2.contourArea, reverse=True)

    # initialize a contour that corresponds to the receipt outline
    receipt_contour = None
    for c in contours:
        # approximate the contour
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        # assume the outline of the receipt is found if the approximated contour has four points
        if len(approx) == 4:
            receipt_contour = approx
            break

    # if the receipt contour is empty
    if receipt_contour is None:
        raise Exception(
            (
                "could not find the receipt outline"
                "look for edge properly"
            )
        )

    # apply a four-point perspective transform to the *original* image to obtain a top-down bird's-eye view of the receipt
    receipt = four_point_transform(img_orig, receipt_contour.reshape(4, 2) * ratio)

    # apply OCR to the receipt image by assuming column data, ensuring the text is *concatenated across the row*
    options = "--psm 6"
    text = pytesseract.image_to_string(
        cv2.cvtColor(receipt, cv2.COLOR_BGR2RGB), config=options
    )
    
    # output the raw output of the OCR process
    print("[RAW OUTPUT]:")
    print("========================")
    print(text)
    print("\n")


if __name__ == "__main__":
    main()
