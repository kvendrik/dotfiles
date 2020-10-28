#!/bin/bash

function latest_heic_downloads_to_jpg() {
  local latest_number latest_download output_path find_command_output downloads_path
  latest_number=("${1:-1}")
  downloads_path="$HOME/Downloads"
  output_path="$HOME/Desktop"
  latest_downloads="$(ls -1t $downloads_path/*.HEIC | head -$latest_number)"

  if [ -z "$latest_downloads" ]; then
    echo "No HEICs found in $downloads_path"
    return $?
  fi

  echo "This will convert these HEIC files to JPG."
  echo "$latest_downloads"
  echo -n "Continue? [Y/n] "

  local do_convert
  read -r do_convert

  if [ -n "$do_convert" ] && [[ "$do_convert" != 'y' ]]; then
    echo 'Exiting.'
    exit 0
  fi

  local file_name

  for heic_path in `ls -1t $downloads_path/*.HEIC | head -$latest_number`; do
    file_name="$(basename $heic_path)"
    magick convert "$heic_path" "$output_path/$file_name.jpg"
    trash "$heic_path"
  done

  open -R "$output_path"
}

function gifify() {
  local video_path output_path
  if [ -z "$1" ]; then
    echo "Usage: gifify <video_path> [<output_path>]"
    return
  fi
  video_path="$1"
  output_path="${2:-"$video_path.gif"}"
  echo "\n$video_path -> $output_path\n"
  ffmpeg -i "$video_path" -b 2048k -vf "fps=10,scale=1920:-1" "$output_path"
}

function latest_capture_to_gif() {
  local latest_capture capture_save_path output_path

  capture_save_path="$HOME/Desktop"
  latest_capture="$(ls -1t $capture_save_path/*.mov | head -1)"

  if [ -z "$latest_capture" ]; then
    echo "No capture files found in $capture_save_path"
    return
  fi

  output_path="$latest_capture.gif"

  if gifify "$latest_capture" "$output_path"; then
    open -R "$output_path"
  fi
}
