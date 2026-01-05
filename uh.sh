#!/bin/bash

HOST="204.216.141.162"
UID="awtrix_0c0878"
TOR_PORTS=(9050 9150 9250)

# Loop infinito - Ctrl+C solo per fermare SCRIPT
while true; do
    
    # Rotazione Tor automatica
    TOR_PORT=${TOR_PORTS[$((RANDOM % 3))]}
    TORSOCKS_CONF="/tmp/torsocks_${TOR_PORT}_$(date +%s).conf"
    echo "server = 127.0.0.1:${TOR_PORT}" > "$TORSOCKS_CONF"
    export TORSOCKS_CONF_FILE="$TORSOCKS_CONF"
    
    echo "[∞ TOR:${TOR_PORT}] F57 MATRIX LOOP $(date +%H:%M:%S)"
    
    # FRAME 1: Strisce F57 verdi SINISTRA → DESTRA
    torsocks mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
      "name":"F57_LOOP_L2R",
      "text":[{"t":"F57F57F57","c":"#00FF00"},{"t":"57F57F57F","c":"#00A000"}],
      "duration":1.5,
      "scrollSpeed":12,
      "force":true,
      "brightness":220,
      "matrix":true
    }'
    
    sleep 1.8
    
    # FRAME 2: Strisce F57 DESTRA → SINISTRA  
    torsocks mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
      "name":"F57_LOOP_R2L", 
      "text":[{"t":"F57F57F57","c":"#00A000"},{"t":"57F57F57F","c":"#00FF00"}],
      "duration":1.5,
      "scrollSpeed":-12,
      "force":true,
      "brightness":220,
      "matrix":true
    }'
    
    sleep 1.8
    
    # FRAME 3: F57 CENTRATO lampeggiante
    torsocks mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
      "name":"F57_FLASH",
      "text":[{"t":" F 5 7 ","c":"#00FF00"}],
      "duration":0.8,
      "scrollSpeed":0,
      "force":true,
      "brightness":255,
      "matrix":true
    }'
    
    sleep 1
    
    # OVERLAY FINALE: TRUSTEDF57 al centro (ogni 10 loop)
    if [ $((RANDOM % 10)) -eq 0 ]; then
        echo "[★ SPECIAL] TRUSTEDF57 overlay!"
        torsocks mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
          "name":"TRUSTEDF57_OWNED",
          "icon":67893,
          "text":[
            {"t":"TRUSTED","c":"#FFFFFF"},
            {"t":"F57","c":"#FFFF00"}, 
            {"t":"HERE","c":"#FFFFFF"}
          ],
          "duration":8,
          "scrollSpeed":25,
          "force":true,
          "brightness":255,
          "indicator1":true,
          "indicator2":true,
          "indicator3":true
        }'
        sleep 8
    fi
    
    # Cleanup temp config
    rm -f "$TORSOCKS_CONF"
    
done
