#!/bin/bash
# VIDEHUB_FULL_HIJACK - Routing PRIMA + PNG Stream DOPO con TAKE

VIDEOHUB_IP="66.44.213.48"
VIDEOHUB_PORT=9990
NDI_INPUT=11  # FROM Studio
PNG_URL="https://i.postimg.cc/tJq1ZFH3/pat.png"

echo "[+] VIDEOHUB CLEAN SWITCH FULL HIJACK"
echo "[+] FASE 1: FORCE ROUTING su Input 11 + TAKE..."

# FASE 1: HIJACK ROUTING PRIMA (con TAKE per CleanSwitch)
for CH in {0..11}; do
    echo -e "OUT ${CH} ${NDI_INPUT}" | nc -w 2 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
    sleep 0.1
done

# TAKE BUTTON - Applica TUTTI i routing
echo "[+] TAKE button..."
echo -e "TAKE" | nc -w 3 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
sleep 2

# VERIFICA routing
echo "[+] VERIFICA ROUTING:"
ROUTING=$(echo "VIDEO OUTPUT ROUTING" | nc -w 3 ${VIDEOHUB_IP} ${VIDEOHUB_PORT})
echo "$ROUTING" | grep -A 15 "ROUTING:"
if echo "$ROUTING" | grep -q "OUT .* ${NDI_INPUT}"; then
    echo "✅ ROUTING OK - Tutti su Input 11!"
else
    echo "❌ Routing fallito - RIPROVA manuale: OUT X 11 + TAKE"
fi

echo "[+] FASE 2: Avvio PNG live stream 1080p60 → Input 11..."
# Download PNG
wget -O pat.png "$PNG_URL" || curl -L -o pat.png "$PNG_URL"

# FASE 2: PNG STREAM FFmpeg (quello che ti piace con frame/fps)
echo "[+] Starting 1080p60 PNG loop → udp://239.0.0.11:1234..."
ffmpeg -stream_loop -1 -re -i pat.png \
  -vf "scale=1920:1080,fps=60" \
  -pix_fmt yuv420p -preset ultrafast \
  -f mpegts "udp://239.0.0.11:1234?pkt_size=1316" \
  -loglevel info &

FFMPEG_PID=$!
sleep 3

echo "🎥 PNG STREAM ATTIVO - Vedrai frame=... fps=60"
echo "📺 TUTTI i 12 canali (LIVE TO CH3/403, Control Room...) vedono PNG!"

# WATCHDOG con TAKE
watchdog() {
    while kill -0 $FFMPEG_PID 2>/dev/null; do
        ROUTING=$(timeout 2 bash -c "echo 'VIDEO ROUTING' | nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT}")
        CHANGED=0
        for CH in {0..11}; do
            if ! echo "$ROUTING" | grep -q "OUT ${CH} ${NDI_INPUT}"; then
                echo -e "OUT ${CH} ${NDI_INPUT}" | nc -w 1 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
                CHANGED=1
            fi
        done
        if [ $CHANGED = 1 ]; then
            echo -e "TAKE" | nc -w 2 ${VIDEOHUB_IP} ${VIDEOHUB_PORT}
            echo "[!] WATCHDOG: RESTORED + TAKE"
        fi
        sleep 5
    done
}

watchdog &
WATCHDOG_PID=$!

echo "🔥 HIJACK COMPLETO!"
echo "[+] Monitor: torsocks nc ${VIDEOHUB_IP} ${VIDEOHUB_PORT} → VIDEO ROUTING"
echo "[+] Ctrl+C per stop"
echo -n "[Live status] "

trap "kill $FFMPEG_PID $WATCHDOG_PID 2>/dev/null; echo '[+] Stopped'; rm pat.png; exit" INT TERM

# Live status
while kill -0 $FFMPEG_PID 2>/dev/null; do
    echo -n "."
    sleep 10
done
echo ""
wait $FFMPEG_PID
