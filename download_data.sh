#!/bin/bash
set -e

# Configuration
# Default File ID provided by user, can be overridden by argument
FILE_ID="${1:-1YO3qRKbWxOYEm86Vy9QlGMjyi5Q_A6m0}"
DATA_DIR="/app/data"
ZIP_FILE="${DATA_DIR}/data.zip"

echo "Starting data download setup..."

# 1. Install dependencies if missing
if ! command -v gdown &> /dev/null; then
    echo "Installing gdown..."
    pip install gdown
fi

if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    apt-get update && apt-get install -y unzip
fi

# 2. Check if data already exists
if [ -d "${DATA_DIR}/train" ]; then
    echo "Data directory ${DATA_DIR}/train already exists."
    read -p "Do you want to re-download? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping download."
        exit 0
    fi
fi

# 3. Create data directory
mkdir -p "$DATA_DIR"

# 4. Download file
echo "Downloading data from Google Drive (ID: $FILE_ID)..."
gdown "$FILE_ID" -O "$ZIP_FILE"

# 5. Extract
echo "Extracting data..."
unzip -o "$ZIP_FILE" -d "$DATA_DIR"

# 6. Cleanup
echo "Cleaning up zip file..."
rm "$ZIP_FILE"

echo "Data setup complete!"
ls -F "$DATA_DIR"
