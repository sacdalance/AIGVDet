# Data Setup Instructions

## Required Datasets

### Training Data
- Download from Baiduyun Link (extract code: ra95)
- Extract to: `./data/train/`

### Test Data
**Note:** Training/validation data are frame sequences (PNG), but testing typically needs video files.

**Solutions:**
1. **Reconstruct videos from frames:** Convert frame sequences back to videos for testing
2. **Use alternative video datasets:**
   - FaceForensics++: https://github.com/ondyari/FaceForensics (has videos)
   - Celeb-DF: https://github.com/yuezunli/celeb-deepfakeforensics
   - DFDC: https://dfdc.ai/
3. **Test with frame sequences:** Modify test scripts to work with PNG sequences
4. **Create test split:** Use some frame sequences as test data

### Data Structure
```
data/
├── train/
│   └── trainset_1/
│       ├── 0_real/
│       │   ├── video_00000/
│       │   │   ├── 00000.png
│       │   │   └── ...
│       │   └── ...
│       └── 1_fake/
│           └── ...
├── val/
│   └── val_set_1/
│       └── ... (same structure)
└── test/
    └── testset_1/
        └── ... (same structure)
```

## Docker Usage
```bash
# Mount your data when running containers
docker run -v /path/to/data:/app/data sacdalance/thesis-aigvdet:gpu
```

## Local Development
```bash
# Set environment variable
export AIGVDET_DATA_PATH="/path/to/your/data"
```