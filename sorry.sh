#!/bin/bash
# SERVERNEO.NET ONESHOT - TUO TRUSTEDF57.html

[ ! -f "./TRUSTEDF57.html" ] && echo "❌ TRUSTEDF57.html non trovato qui!" && exit 1

echo "🚀 Upload su SERVERNEO.NET..."

# Serverneo.net upload GRATIS (no login)
URL=$(torsocks curl -s --data-binary @TRUSTEDF57.html https://serverneo.net/ 2>/dev/null | grep -o 'https://serverneo\.net/[^[:space:]]\+' | head -1)

[ -z "$URL" ] && URL=$(torsocks curl -s -X POST -H "Content-Type: text/html" --data-binary @TRUSTEDF57.html https://serverneo.net/ | grep -o 'https://serverneo\.net/[^[:space:]]\+' | head -1)

echo ""
echo "✅ SERVERNEO.NET LINK:"
echo "🌐 $URL"
echo ""
echo "📋 COPIA NEI KIOSKS: $URL"
echo "$URL" > serverneo_link.txt
