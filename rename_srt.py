###########################################################
### RENAME ALL SRT FILES TO MATCH ALL MKV OR MP4 EPISODS ## 
### USAGE PYTHON SCRIPT.PY DEST_FOLDER
################# BY CONNECTED09 #########################
import os
import re
import argparse

def rename_srt_files(folder_path, debug=False):
    try:
        # Get all files in the folder
        files = os.listdir(folder_path)
        
        # Filter out video files and srt files
        video_files = [f for f in files if f.endswith(('.mkv', '.mp4'))]
        srt_files = [f for f in files if f.endswith('.srt')]
        
        # Sort video files by episode number
        video_files.sort(key=lambda x: int(re.search(r'S\d+E(\d+)', x, re.IGNORECASE).group(1)))
        
        # Sort srt files by name (assuming they are in order)
        srt_files.sort()
        
        # Check if the number of srt files matches the number of video files
        if len(srt_files) != len(video_files):
            print(f"Warning: Number of .srt files ({len(srt_files)}) does not match number of video files ({len(video_files)}).")
        
        # Iterate over video files and rename corresponding srt files
        for video_file in video_files:
            # Extract season and episode number from video file name
            match = re.search(r'S(\d+)E(\d+)', video_file, re.IGNORECASE)
            if not match:
                print(f"Skipping {video_file} - no season/episode number found.")
                continue
            
            season_num = match.group(1).zfill(2)  # Ensure two-digit format (e.g., S01)
            episode_num = match.group(2).zfill(2)  # Ensure two-digit format (e.g., E01)
            
            # Find the corresponding srt file
            try:
                srt_file = srt_files[int(episode_num) - 1]  # Assuming srt files are in order
            except IndexError:
                print(f"No corresponding .srt file found for {video_file} (Episode {episode_num}).")
                continue
            
            # Construct new srt file name
            new_srt_name = re.sub(r'\.(mkv|mp4)$', '.srt', video_file)
            
            # Rename the srt file
            old_srt_path = os.path.join(folder_path, srt_file)
            new_srt_path = os.path.join(folder_path, new_srt_name)
            
            # Check if the new name already exists to avoid overwriting
            if os.path.exists(new_srt_path):
                print(f"Skipping {srt_file} - {new_srt_name} already exists.")
                continue
            
            os.rename(old_srt_path, new_srt_path)
            print(f"Renamed {srt_file} to {new_srt_name}")
    
    except Exception as e:
        print(f"An error occurred: {e}")
        if debug:
            raise e

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Rename .srt files to match corresponding .mkv or .mp4 files.")
    parser.add_argument("folder_path", type=str, help="Path to the folder containing .srt and video files.")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode to show full error details.")
    args = parser.parse_args()
    
    # Call the function with the provided folder path
    rename_srt_files(args.folder_path, debug=args.debug)

if __name__ == "__main__":
    main()