#!/bin/bash
vagrant up \
&& vagrant rsync \
&& vagrant ssh -- -t  '
cd /sync_folder
find -type f -name "*.mp4" -print0 | xargs -0 -n1 basename | while read -r f; do
  ffmpeg -i "$f" \\
    -crf 30 \\
    -c:v libx264 \\
    -b:v 4000k \\
    -profile:v main \\
    -preset:v veryfast \\
    -c:a libmp3lame \\
    -b:a 128k \\
    -ac 2 \\
    -ar 48000 \\
    "${f}_output.mp4"
done' \
&& vagrant rsync-back \
&& vagrant destroy -f
