# CIC-Hackathon-2024


## running receipt_ocr
```bash
 cd backend/receipt_ocr

docker compose up -d

curl -X 'POST' \
  'http://localhost:8000/ocr/' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@/images/receipt.jpg;type=image/jpeg'
```
