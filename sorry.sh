#!/bin/bash
# CODICE BUONO: SENZA TORSOCKS - HOST GRATIS SUBITO

[ ! -f "./TRUSTEDF57.html" ] && echo "❌ TRUSTEDF57.html non trovato!" && exit 1

echo "🚀 FILEBIN.NET UPLOAD..."

# Filebin.net + UA buono = funziona sempre
URL=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  -F "file=@TRUSTEDF57.html" https://filebin.net | \
  grep -o 'https://filebin\.net/[a-z0-9]*' | head -1)

echo ""
echo "✅ LINK PUBBLICO:"
echo "$URL"
echo ""
echo "📋 COPIA NEI KIOSKS:"
echo "$URL" 
echo "$URL" > KIOSK_LINK.txt
echo "💾 Salvato in KIOSK_LINK.txt"

# Test
curl -s "$URL" | head -10
