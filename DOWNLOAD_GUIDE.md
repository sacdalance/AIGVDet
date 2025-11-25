# Download Data Script - Usage Guide

This Python script downloads all necessary files for AIGVDet:
- **Dataset** (training/validation data)
- **Checkpoints** (original.pth and optical.pth)
- **RAFT Model** (for optical flow computation)

## Quick Start

### Download Everything
```bash
cd AIGVDet
python download_data.py
```

This will download:
- Dataset → `data/` directory
- Checkpoints → `checkpoints/` directory (contains original.pth, optical.pth)
- RAFT model → `raft_model/` directory

## Advanced Usage

### Download Specific Components

**Only dataset:**
```bash
python download_data.py --skip-checkpoints --skip-raft
```

**Only checkpoints:**
```bash
python download_data.py --skip-data --skip-raft
```

**Only RAFT model:**
```bash
python download_data.py --skip-data --skip-checkpoints
```

### Custom Directories

```bash
python download_data.py \
  --data-dir /path/to/data \
  --checkpoint-dir /path/to/checkpoints \
  --raft-dir /path/to/raft_model
```

### Custom Google Drive IDs

```bash
python download_data.py \
  --data-id YOUR_FILE_ID \
  --checkpoint-folder https://drive.google.com/drive/folders/YOUR_FOLDER_ID \
  --raft-file https://drive.google.com/file/d/YOUR_FILE_ID/view
```

## What Gets Downloaded

### 1. Dataset (data/)
- Training and validation data
- Extracted from a zip file
- Default ID: `1YO3qRKbWxOYEm86Vy9QlGMjyi5Q_A6m0`

### 2. Checkpoints (checkpoints/)
- `original.pth` - Pre-trained RGB model
- `optical.pth` - Pre-trained optical flow model
- Folder URL: `https://drive.google.com/drive/folders/18JO_YxOEqwJYfbVvy308XjoV-N6fE4yP`

### 3. RAFT Model (raft_model/)
- `raft_things.pth` - Pre-trained RAFT model for optical flow computation
- File URL: `https://drive.google.com/file/d/1MqDajR89k-xLV0HIrmJ0k-n8ZpG6_suM/view`

## Dependencies

The script will automatically install `gdown` if not present:
```bash
pip install gdown
```

Or install manually:
```bash
pip install gdown
```

## Features

✅ **Auto-install dependencies** - Installs gdown if missing
✅ **Check existing files** - Asks before re-downloading
✅ **Progress indicators** - Shows download progress
✅ **Auto-extract** - Extracts zip files automatically
✅ **Cleanup** - Removes zip files after extraction
✅ **Detailed output** - Shows file sizes and directory contents
✅ **Error handling** - Gracefully handles download failures

## Troubleshooting

### gdown installation fails
```bash
python -m pip install --upgrade pip
pip install gdown
```

### Authentication errors
Some Google Drive files may require authentication. If you get quota errors:
1. Wait a few hours and try again
2. Download manually from the links above
3. Place files in the correct directories

### Download fails mid-way
Re-run the script - it will ask if you want to re-download existing files.

## File Structure After Download

```
AIGVDet/
├── data/
│   ├── train/
│   └── val/
├── checkpoints/
│   ├── original.pth
│   └── optical.pth
└── raft_model/
    └── raft_things.pth
```

## Command Line Options

```
usage: download_data.py [-h] [--data-id DATA_ID] [--data-dir DATA_DIR]
                       [--checkpoint-dir CHECKPOINT_DIR]
                       [--checkpoint-folder CHECKPOINT_FOLDER]
                       [--raft-dir RAFT_DIR] [--raft-file RAFT_FILE]
                       [--skip-data] [--skip-checkpoints] [--skip-raft]

optional arguments:
  -h, --help            show this help message and exit
  --data-id DATA_ID     Google Drive file ID for dataset
  --data-dir DATA_DIR   Directory to save dataset (default: data)
  --checkpoint-dir CHECKPOINT_DIR
                        Directory to save checkpoints (default: checkpoints)
  --checkpoint-folder CHECKPOINT_FOLDER
                        Google Drive folder URL for checkpoints
  --raft-dir RAFT_DIR   Directory to save RAFT model (default: raft_model)
  --raft-file RAFT_FILE
                        Google Drive file URL for RAFT model
  --skip-data           Skip dataset download
  --skip-checkpoints    Skip checkpoint download
  --skip-raft           Skip RAFT model download
```

## Original Shell Script

The original `download_data.sh` is still available if you prefer to use bash:
```bash
bash download_data.sh [FILE_ID]
```

However, the Python version is recommended as it:
- Works on Windows, Linux, and macOS
- Downloads checkpoints and RAFT model automatically
- Has better error handling and progress indicators
