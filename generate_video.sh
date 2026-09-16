#!/usr/bin/env bash
set -euo pipefail

OUT="pinglu_canal_30s.mp4"
W=1080
H=1920
FPS=30
D=30
FONT="/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"

ffmpeg -y \
  -f lavfi -i "color=c=#071A2E:s=${W}x${H}:r=${FPS}:d=${D}" \
  -f lavfi -i "sine=frequency=62:sample_rate=48000:duration=${D}" \
  -f lavfi -i "sine=frequency=124:sample_rate=48000:duration=${D}" \
  -f lavfi -i "sine=frequency=248:sample_rate=48000:duration=${D}" \
  -filter_complex "
  [0:v]
    format=yuv420p,
    drawbox=x=0:y=1210:w=1080:h=710:color=#0B5D78@0.95:t=fill,
    drawbox=x=0:y=1478:w=1080:h=442:color=#0B8FA6@0.35:t=fill,
    drawbox=x=562:y=1094:w=302:h=86:color=#EAF7FF@0.95:t=fill,
    drawbox=x=680:y=1046:w=130:h=48:color=#FFB000@0.95:t=fill,
    drawtext=fontfile='${FONT}':text='平陆运河':fontsize=118:fontcolor=white:x='(w-text_w)/2':y='180':alpha='if(lt(t,0.4),0, if(lt(t,1.2),(t-0.4)/0.8, if(lt(t,4.2),1, max(0,1-(t-4.2)/0.6))))',
    drawtext=fontfile='${FONT}':text='通江达海  向海图强':fontsize=52:fontcolor=#BFEFFF:x='(w-text_w)/2':y='330':alpha='if(lt(t,0.9),0, if(lt(t,1.8),(t-0.9)/0.9, if(lt(t,4.5),1, max(0,1-(t-4.5)/0.5))))',
    drawtext=fontfile='${FONT}':text='134.2 公里':fontsize=102:fontcolor=#FFFFFF:x='90':y='380':enable='between(t,5,9)',
    drawtext=fontfile='${FONT}':text='一条运河  打开西部陆海新通道':fontsize=48:fontcolor=#AEEBFF:x='90':y='520':enable='between(t,5,9)',
    drawbox=x=110:y=920:w=860:h=10:color=#6DE8FF@0.9:t=fill:enable='between(t,9,14)',
    drawbox=x=110:y=1120:w=860:h=10:color=#6DE8FF@0.9:t=fill:enable='between(t,9,14)',
    drawtext=fontfile='${FONT}':text='5000 吨级船舶':fontsize=92:fontcolor=white:x='(w-text_w)/2':y='690':enable='between(t,9,14)',
    drawtext=fontfile='${FONT}':text='船闸开启  江海直达':fontsize=56:fontcolor=#BFEFFF:x='(w-text_w)/2':y='1230':enable='between(t,9,14)',
    drawtext=fontfile='${FONT}':text='马道 · 企石 · 青年':fontsize=70:fontcolor=#FFFFFF:x='(w-text_w)/2':y='500':enable='between(t,14,19)',
    drawtext=fontfile='${FONT}':text='三大航运枢纽':fontsize=108:fontcolor=#FFE47A:x='(w-text_w)/2':y='650':enable='between(t,14,19)',
    drawtext=fontfile='${FONT}':text='连接江海  激活沿线':fontsize=54:fontcolor=#C9F5FF:x='(w-text_w)/2':y='850':enable='between(t,14,19)',
    drawtext=fontfile='${FONT}':text='出海航程':fontsize=54:fontcolor=#BFEFFF:x='(w-text_w)/2':y='480':enable='between(t,19,24)',
    drawtext=fontfile='${FONT}':text='缩短 560+ 公里':fontsize=104:fontcolor=#FFFFFF:x='(w-text_w)/2':y='610':enable='between(t,19,24)',
    drawtext=fontfile='${FONT}':text='更近的海  更大的世界':fontsize=54:fontcolor=#FFE47A:x='(w-text_w)/2':y='810':enable='between(t,19,24)',
    drawtext=fontfile='${FONT}':text='2026.09.16':fontsize=64:fontcolor=#BFEFFF:x='(w-text_w)/2':y='500':enable='between(t,24,30)',
    drawtext=fontfile='${FONT}':text='平陆运河  正式通航':fontsize=90:fontcolor=white:x='(w-text_w)/2':y='650':enable='between(t,24,30)',
    drawtext=fontfile='${FONT}':text='向海而兴  逐梦深蓝':fontsize=66:fontcolor=#FFE47A:x='(w-text_w)/2':y='840':enable='between(t,24,30)',
    drawtext=fontfile='${FONT}':text='广西 · 中国':fontsize=42:fontcolor=#C9F5FF:x='(w-text_w)/2':y='1040':enable='between(t,26,30)',
    fade=t=in:st=0:d=0.3,fade=t=out:st=29.4:d=0.6[v];
  [1:a]volume=0.09[a1];
  [2:a]volume=0.04[a2];
  [3:a]volume=0.02[a3];
  [a1][a2][a3]amix=inputs=3:normalize=0,afade=t=in:st=0:d=0.4,afade=t=out:st=29.2:d=0.8[a]" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -preset veryfast -crf 21 -pix_fmt yuv420p \
  -c:a aac -b:a 192k -movflags +faststart -t ${D} "$OUT"

mkdir -p output
mv "$OUT" output/
ffprobe -v error -show_entries format=duration,size -of default=nw=1 output/pinglu_canal_30s.mp4
