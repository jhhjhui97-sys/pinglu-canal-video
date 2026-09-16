#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/real output

LOCK_URL='https://upload.wikimedia.org/wikipedia/commons/7/78/Panama_Canal_-_at_Miraflores_Locks.webm'
SHIP_URL='https://upload.wikimedia.org/wikipedia/commons/7/73/Container_ship.webm'
PORT_URL='https://upload.wikimedia.org/wikipedia/commons/1/1a/Cargo_ship_disembark_at_the_port.webm'

curl -L --retry 3 "$LOCK_URL" -o assets/real/lock.webm
curl -L --retry 3 "$SHIP_URL" -o assets/real/ship.webm
curl -L --retry 3 "$PORT_URL" -o assets/real/port.webm

FONT='/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc'
[ -f "$FONT" ] || FONT='/usr/share/fonts/truetype/noto/NotoSansCJK-Bold.ttc'

# 3 cinematic 10-second vertical segments. Generic real footage is explicitly marked as illustrative.
make_seg() {
  local in="$1" start="$2" text1="$3" text2="$4" out="$5"
  ffmpeg -y -ss "$start" -t 10 -i "$in" \
    -filter_complex "[0:v]split=2[bg][fg];
      [bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=30,eq=brightness=-0.12:saturation=0.8[bg2];
      [fg]scale=1080:1920:force_original_aspect_ratio=decrease[fg2];
      [bg2][fg2]overlay=(W-w)/2:(H-h)/2,
      drawbox=x=0:y=0:w=iw:h=300:color=black@0.32:t=fill,
      drawbox=x=0:y=1600:w=iw:h=320:color=black@0.35:t=fill,
      drawtext=fontfile='${FONT}':text='${text1}':fontcolor=white:fontsize=88:x=(w-text_w)/2:y=110,
      drawtext=fontfile='${FONT}':text='${text2}':fontcolor=#F9D65C:fontsize=50:x=(w-text_w)/2:y=235,
      drawtext=fontfile='${FONT}':text='示意实景素材｜最终版替换为平陆运河授权画面':fontcolor=white@0.85:fontsize=27:x=(w-text_w)/2:y=1810,
      fps=30,format=yuv420p[v]" \
    -map '[v]' -an -c:v libx264 -preset medium -crf 19 "$out"
}

make_seg assets/real/lock.webm 10 '一河通江海' '134.2公里 · 三大航运枢纽' output/seg1.mp4
make_seg assets/real/ship.webm 8 '5000吨级船舶' '从内河驶向更广阔的海' output/seg2.mp4
make_seg assets/real/port.webm 2 '平陆运河 正式通航' '2026.09.16 · 向海图强' output/seg3.mp4

cat > output/concat.txt <<'EOF'
file 'seg1.mp4'
file 'seg2.mp4'
file 'seg3.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i output/concat.txt -c copy output/base.mp4

# Energetic original synth bed; fixed gains maximize compatibility across FFmpeg builds.
ffmpeg -y \
  -i output/base.mp4 \
  -f lavfi -i 'sine=frequency=55:sample_rate=48000:duration=30' \
  -f lavfi -i 'sine=frequency=110:sample_rate=48000:duration=30' \
  -f lavfi -i 'sine=frequency=220:sample_rate=48000:duration=30' \
  -filter_complex "[1:a]volume=0.07[a1];[2:a]volume=0.045[a2];[3:a]volume=0.025[a3];[a1][a2][a3]amix=inputs=3:normalize=0,afade=t=in:st=0:d=0.3,afade=t=out:st=29.3:d=0.7[a]" \
  -map 0:v -map '[a]' -c:v copy -c:a aac -b:a 192k -movflags +faststart -t 30 output/pinglu_canal_30s_real_safe.mp4

ffprobe -v error -show_entries format=duration,size -of default=nw=1 output/pinglu_canal_30s_real_safe.mp4
