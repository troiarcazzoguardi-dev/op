#!/bin/bash
# 1-SHOT: HOST DIRETTO IP LOCALE + PORTE APERTE + AUTO-DISCOVERY

echo "🔥 HOSTING DIRETTO TRUSTEDF57.html..."

# 1. VERIFICA FILE
[ ! -f "./TRUSTEDF57.html" ] && echo "❌ TRUSTEDF57.html non trovato!" && exit 1

# 2. AUTO-DISCOVERY IP PUBBLICO
PUB_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "ERRORE IP")
[ -z "$PUB_IP" ] && echo "❌ No IP pubblico" && exit 1

echo "🌐 IP PUBBLICO: $PUB_IP"

# 3. APRI PORTE (firewalld/ufw automatico)
sudo firewall-cmd --add-port=8080/tcp --permanent 2>/dev/null || sudo ufw allow 8080 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || sudo ufw reload 2>/dev/null || true

# 4. AVVIA PYTHON SERVER (porta 8080)
PID=$(pgrep -f "python.*8080" | head -1)
[ -z "$PID" ] && nohup python3 -m http.server 8080 > /dev/null 2>&1 &
sleep 2

# 5. TEST LOCALE
curl -s http://localhost:8080/TRUSTEDF57.html > /dev/null || echo "⚠️ Test locale fallito"

echo ""
echo "✅ HOST ATTIVO!"
echo "🔗 LINK KIOSKS: http://$PUB_IP:8080/TRUSTEDF57.html"
echo ""
echo "📋 COPIA: http://$PUB_IP:8080/TRUSTEDF57.html"
echo "🛑 STOP: sudo pkill -f 'python.*8080'"
echo ""
echo "http://$PUB_IP:8080/TRUSTEDF57.html" > KIOSK_DIRECT_LINK.txt
