#####################################################################
################# CONVERT DTS TO EAC3 | MKV ###########################
#####################################################################
## HOW TO USE .. PYTHON SOURCE.MKV DEST.MKV --DEBUG 'IF YOU NEED IT'
#####################################################################
import argparse
import subprocess
import json
from tabulate import tabulate
import sys

def get_streams(file_path):
    command = ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_streams', file_path]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        print(f"Error running ffprobe: {result.stderr}")
        sys.exit(1)
    return json.loads(result.stdout)['streams']

def display_streams(streams, stream_type):
    headers = ['Index', 'Codec Type', 'Codec Name', 'Width', 'Height', 'Bit Rate', 'Channels', 'Language']
    table = []
    for idx, stream in enumerate(streams):
        if stream['codec_type'] == 'video':
            width = stream.get('width', 'N/A')
            height = stream.get('height', 'N/A')
            channels = 'N/A'
            language = 'N/A'
        elif stream['codec_type'] == 'audio':
            width = 'N/A'
            height = 'N/A'
            channels = stream.get('channels', 'N/A')
            language = stream.get('tags', {}).get('language', 'N/A') if 'tags' in stream else 'N/A'
        else:
            width = 'N/A'
            height = 'N/A'
            channels = 'N/A'
            language = 'N/A'
        bit_rate = stream.get('bit_rate', 'N/A')
        table.append([idx, stream['codec_type'], stream['codec_name'], width, height, bit_rate, channels, language])
    print(f"\nAvailable {stream_type} Streams:\n")
    print(tabulate(table, headers=headers, tablefmt='pretty'))

def select_stream(streams, stream_type):
    while True:
        try:
            choice = int(input(f"Enter the index of the {stream_type} stream to select: "))
            if 0 <= choice < len(streams):
                return choice
            else:
                print("Invalid index. Please try again.")
        except ValueError:
            print("Please enter a valid integer index.")

def main():
    parser = argparse.ArgumentParser(description='Encode DTS to E-AC3 MKV using ffmpeg and ffprobe.')
    parser.add_argument('input_file', help='Input movie file name')
    parser.add_argument('output_file', help='Output MKV file name')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    args = parser.parse_args()

    input_file = args.input_file
    output_file = args.output_file
    debug = args.debug

    # Get all streams
    streams = get_streams(input_file)

    # Separate video and audio streams
    video_streams = [s for s in streams if s['codec_type'] == 'video']
    audio_streams = [s for s in streams if s['codec_type'] == 'audio']

    if not video_streams:
        print("No video streams found in the input file.")
        sys.exit(1)
    if not audio_streams:
        print("No audio streams found in the input file.")
        sys.exit(1)

    # Display video streams
    display_streams(video_streams, 'Video')

    # User selects video stream
    video_choice = select_stream(video_streams, 'video')
    selected_video_stream = video_streams[video_choice]
    video_stream_idx = selected_video_stream['index']

    # Display audio streams
    display_streams(audio_streams, 'Audio')

    # User selects audio stream
    audio_choice = select_stream(audio_streams, 'audio')
    selected_audio_stream = audio_streams[audio_choice]
    audio_stream_idx = selected_audio_stream['index']

    # Check if the selected audio stream is DTS
    if selected_audio_stream.get('codec_name', '') != 'dts':
        print("The selected audio stream is not DTS. Encoding will not proceed.")
        sys.exit(1)

    # Construct ffmpeg command
    ffmpeg_cmd = [
        'ffmpeg',
        '-i', input_file,
        '-map', f'0:v:{video_choice}',
        '-map', f'0:a:{audio_choice}',
        '-c:v', 'copy',
        '-c:a', 'eac3',
        '-b:a', '512k',
        '-y', output_file
    ]

    if debug:
        print("Running ffmpeg command:")
        print(' '.join(ffmpeg_cmd))

    # Run ffmpeg and capture output
    process = subprocess.Popen(ffmpeg_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    # Parse ffmpeg output for progress
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            if debug:
                print(output.strip())
            if "frame=" in output:
                parts = output.split('time=')
                if len(parts) > 1:
                    progress_info = parts[1].split(' bitrate=')[0].strip()
                    print(f"\rEncoding progress: {progress_info}", end='')
    print("\nEncoding completed.")

if __name__ == '__main__':
    main()
