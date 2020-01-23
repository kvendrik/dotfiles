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
