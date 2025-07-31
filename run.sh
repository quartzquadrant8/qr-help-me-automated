#!/bin/bash
set -e

echo "--------------------------------------"
echo "QR Code Content Configuration"
echo "--------------------------------------"

USER_PHONE_NUMBER="$1"

if (( ${#USER_PHONE_NUMBER} == 0 )); then
    echo "Error: Phone number not provided as a command-line argument."
    echo "Usage: ./run.sh <YOUR_PHONE_NUMBER_E.G._+15551234567>"
    exit 1
fi

echo "Phone number provided: ${USER_PHONE_NUMBER}"
echo "Embedding phone number into QR code message..."

ESCAPED_PHONE_NUMBER=$(echo "${USER_PHONE_NUMBER}" | sed 's/[\/&]/\&/g')

sed -i.bak "s|###PHONE_NUMBER_PLACEHOLDER###|tel:${ESCAPED_PHONE_NUMBER}|g" templates/index.html

echo "Phone number embedded. Starting Flask application..."

echo "Activating virtual environment..."
source venv/bin/activate

echo "Verifying Python path: $(which python)"
echo "Verifying Flask installation: $(pip list | grep Flask)"
echo "Listing static files: $(ls static/)"

echo "Starting Flask application..."
export FLASK_APP=app.py
python -m flask run --host=0.0.0.0 --debug
