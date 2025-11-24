import argparse
import subprocess
import os
import sys

def run_command(command):
    print(f"Running: {command}")
    try:
        subprocess.check_call(command, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Recreate Table 2 results for a specific dataset.")
    parser.add_argument("dataset", help="Name of the dataset (e.g., moonvalley, videocraft, pika, neverends)")
    args = parser.parse_args()

    dataset_name = args.dataset
    
    # Define paths
    # Using /app/data for Docker/Jupyter environment compatibility
    source_video_dir = f"/app/data/test/T2V/{dataset_name}"
    output_rgb_dir = f"/app/data/test/original/T2V/{dataset_name}"
    output_flow_dir = f"/app/data/test/T2V/{dataset_name}_flow"
    
    result_csv = f"/app/data/results/{dataset_name}.csv"
    result_no_cp_csv = f"/app/data/results/{dataset_name}_no_cp.csv"
    
    raft_model = "/app/raft_model/raft-things.pth"
    optical_model = "/app/checkpoints/optical.pth"
    original_model = "/app/checkpoints/original.pth"

    print(f"--- Processing Dataset: {dataset_name} ---")
    
    # Check if source directory exists
    if not os.path.exists(source_video_dir):
        print(f"Error: Source video directory not found: {source_video_dir}")
        print("Please download the test videos and place them in the correct folder.")
        sys.exit(1)

    # Step 1: Prepare Data
    print("\n[Step 1] Preparing Data (Extracting Frames & Generating Optical Flow)...")
    # Note: We use sys.executable to ensure we use the same python interpreter
    cmd_prepare = f'"{sys.executable}" prepare_data.py --source_dir "{source_video_dir}" --output_rgb_dir "{output_rgb_dir}" --output_flow_dir "{output_flow_dir}" --model "{raft_model}"'
    run_command(cmd_prepare)
    
    # Step 2: Run Standard Evaluation
    print("\n[Step 2] Running Standard Evaluation (AIGVDet, Sspatial, Soptical)...")
    cmd_test = f'"{sys.executable}" test.py -fop "{output_flow_dir}" -for "{output_rgb_dir}" -mop "{optical_model}" -mor "{original_model}" -e "{result_csv}"'
    run_command(cmd_test)
    
    # Step 3: Run No-Crop Evaluation
    print("\n[Step 3] Running No-Crop Evaluation (Soptical no cp)...")
    cmd_test_no_cp = f'"{sys.executable}" test.py --no_crop -fop "{output_flow_dir}" -for "{output_rgb_dir}" -mop "{optical_model}" -mor "{original_model}" -e "{result_no_cp_csv}"'
    run_command(cmd_test_no_cp)
    
    print("\n--- Done! ---")
    print(f"Standard Results saved to: {result_csv}")
    print(f"No-Crop Results saved to: {result_no_cp_csv}")

if __name__ == "__main__":
    main()
