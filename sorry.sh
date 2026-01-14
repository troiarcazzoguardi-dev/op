#!/bin/bash
# ONESHOT PERFETTO: Host TUO TRUSTEDF57.html GRATIS - FILEBIN.NET

# Verifica TUO file nella directory corrente
if [ ! -f "./TRUSTEDF57.html" ]; then
    echo "❌ TRUSTEDF57.html NON TROVATO nella directory dove avvii!"
    exit 1
fi

echo "🚀 Uploadando IL TUO TRUSTEDF57.html su filebin.net..."

# Filebin.net = GRATIS, NO REGISTRO, HTML diretto, no UA block
URL=$(torsocks curl -s -F "file=@TRUSTEDF57.html" https://filebin.net | grep -o 'https://filebin\.net/[a-z0-9]*' | head -1)

if [ -z "$URL" ]; then
    echo "❌ Errore upload, riprova"
    exit 1
fi

echo ""
echo "✅ FATTO! LA TUA PAGINA È ONLINE:"
echo "🌐 $URL"
echo ""
echo "📋 COPIA QUESTO NEI KIOSKS:"
echo "$URL"
echo ""
echo "🧪 Test automatico..."
torsocks curl -s -A "Mozilla/5.0" "$URL" | head -20

# Salva link
echo "$URL" > kiosk_link.txt
echo "💾 Link salvato in kiosk_link.txt"
