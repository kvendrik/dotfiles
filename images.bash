#!/bin/bash

function gifify() {
  [ -z "$1" ] && echo 'Usage: gifify <file_path>' && return 1
  [ ! -f "$1" ] && echo "File $1 does not exist" && return 1
  ffmpeg -i "$1" -r 10 -vcodec png out-static-%05d.png
  time convert -verbose +dither -layers Optimize -resize 1600x1600\> out-static*.png  GIF:- | gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > "$1.gif"
  rm out-static*.png
}
