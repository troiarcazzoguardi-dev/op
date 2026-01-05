#!/bin/bash

HOST="204.216.141.162"
UID="awtrix_0c0878"
TOR_PORTS=(9050 9150 9250)

infinite_matrix() {
    while true; do
        # TOR CORRETTO - torsocks nativo senza file conf
        TOR_PORT=${TOR_PORTS[$((RANDOM % 3))]}
        echo "[∞ TOR:$TOR_PORT] F57 MATRIX $(date +%H:%M:%S)"
        
        # FRAME 1: F57 SINISTRA→DESTRA
        torsocks -p $TOR_PORT mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
          "text":[{"t":"F57F57F57","c":"#00FF00"},{"t":"57F57F","c":"#00A000"}],
          "duration":1.8,"scrollSpeed":12,"force":true,"brightness":255,"matrix":true
        }'
        
        sleep 2
        
        # FRAME 2: F57 DESTRA→SINISTRA  
        torsocks -p $TOR_PORT mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
          "text":[{"t":"F57F57F","c":"#00A000"},{"t":"57F57F57","c":"#00FF00"}],
          "duration":1.8,"scrollSpeed":-12,"force":true,"brightness":255,"matrix":true
        }'
        
        sleep 2
        
        # FRAME 3: TRUSTEDF57 CENTRATO
        torsocks -p $TOR_PORT mosquitto_pub -h $HOST -p 1883 -t $UID -m '{
          "text":[{"t":"TRUSTED F57 HERE","c":"#FFFFFF"},{"t":"F57","c":"#FFFF00"}],
          "duration":4,"scrollSpeed":0,"force":true,"brightness":255,
          "indicator1":true,"indicator2":true,"indicator3":true
        }'
        
        sleep 4
    done
}

# AVVIO LOOP
echo "🚀 INFINITE F57 MATRIX LOOP STARTED"
echo "Ctrl+C per fermare"
infinite_matrix
