#!/usr/bin/env bash
set -euo pipefail

# Quick 30s vertical assembly template.
# Requires ffmpeg and the asset filenames listed in README.md.

OUT="pinglu_canal_30s_upgraded.mp4"
TMP=".render_tmp"
mkdir -p "$TMP"

clips=(
  "assets/01_sunrise.mp4"
  "assets/02_lock_open.mp4"
  "assets/03_ship.mp4"
  "assets/04_aerial_canal.mp4"
  "assets/05_hub.mp4"
  "assets/06_port.mp4"
  "assets/07_youth.mp4"
)

durations=(3 4 5 5 5 5 3)

for i in "${!clips[@]}"; do
  idx=$(printf "%02d" "$i")
  ffmpeg -y -i "${clips[$i]}" -t "${durations[$i]}" \
    -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30" \
    -an -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
    "$TMP/$idx.mp4"
done

LIST="$TMP/list.txt"
: > "$LIST"
for i in "${!clips[@]}"; do
  idx=$(printf "%02d" "$i")
  echo "file '$PWD/$TMP/$idx.mp4'" >> "$LIST"
done

ffmpeg -y -f concat -safe 0 -i "$LIST" -i assets/music.mp3 \
  -filter_complex "[0:v]subtitles=subtitles.srt:force_style='FontName=Noto Sans CJK SC,FontSize=22,Outline=2,Shadow=0,Alignment=2,MarginV=110'[v];[1:a]atrim=0:30,afade=t=in:st=0:d=0.6,afade=t=out:st=29:d=1[a]" \
  -map "[v]" -map "[a]" -t 30 \
  -c:v libx264 -preset medium -crf 18 -c:a aac -b:a 192k -movflags +faststart \
  "$OUT"

echo "Created $OUT"
