#!/bin/bash
# 🚀 ELEVATOR LOOP CONTROL - Köln Im Zollhafen 20 (TRUSTEDF57)
# CTRL+C per fermare | Monitor: mosquitto_sub -t 'ELX+/elevator/information/#'

BROKER="116.203.65.150"
PORT=1883
ASCENSORI=("ELXO-00000001" "ELXO-00000002" "ELXK-00000001" "ELXS-00000001" "ELXT-00000001")

echo "🔥 INIZIO LOOP ASCENSORI - Köln (116.203.65.150:1883)"
echo "📡 Monitor in terminale separato: torsocks mosquitto_sub -t 'ELX+/elevator/information/#' -v"
echo "⏹️  CTRL+C per fermare"

trap "echo '🛑 Loop fermato'; exit 0" INT

CICLO=0
while true; do
  ((CICLO++))
  echo "🔄 CICLO #$CICLO ============================================="
  
  for ASC in "${ASCENSORI[@]}"; do
    echo "  🏢 $ASC - SALITA (piano alto)..."
    
    # OTIS LCB_II (ELXO)
    if [[ $ASC == ELXO* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/up" -m '{"direction":"up","speed":1.0}' >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/control/motion" -m "UP" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/target-floor" -m "10" >/dev/null 2>&1
    fi
    
    # KONE LCE375 (ELXK)
    if [[ $ASC == ELXK* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/up" -m "true" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/lce/control/target" -m "6" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/cmd/up" -m '{"floor":6}' >/dev/null 2>&1
    fi
    
    # SCHINDLER SMART (ELXS)
    if [[ $ASC == ELXS* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/up" -m '{"target":15}' >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/smart/miconic/goto" -m "15" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/control/up" -m "true" >/dev/null 2>&1
    fi
    
    # TKE TCI-MC (ELXT)
    if [[ $ASC == ELXT* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/up" -m "1" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/tci/control/floor" -m "10" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/cmd/motion" -m "UP" >/dev/null 2>&1
    fi
    
    # COMANDI UNIVERSALI (tutti)
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/up" -m "true" >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/control/up" -m '{"direction":"UP"}' >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/target-floor/absolute" -m "10" >/dev/null 2>&1
    
    sleep 12  # Tempo salita
    
    echo "  🏢 $ASC - DISCESA (ground floor)..."
    
    # OTIS
    if [[ $ASC == ELXO* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/down" -m '{"direction":"down"}' >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/control/motion" -m "DOWN" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/target-floor" -m "3" >/dev/null 2>&1
    fi
    
    # KONE
    if [[ $ASC == ELXK* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/down" -m "true" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/lce/control/target" -m "2" >/dev/null 2>&1
    fi
    
    # SCHINDLER
    if [[ $ASC == ELXS* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/down" -m '{"target":4}' >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/smart/miconic/goto" -m "4" >/dev/null 2>&1
    fi
    
    # TKE
    if [[ $ASC == ELXT* ]]; then
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/down" -m "-1" >/dev/null 2>&1
      torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/tci/control/floor" -m "3" >/dev/null 2>&1
    fi
    
    # UNIVERSALI
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/control/move/down" -m "true" >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/control/down" -m '{"direction":"DOWN"}' >/dev/null 2>&1
    torsocks mosquitto_pub -h $BROKER -p $PORT -t "$ASC/elevator/target-floor/absolute" -m "1" >/dev/null 2>&1
    
    sleep 12  # Tempo discesa
  done
  
  echo "✅ Ciclo #$CICLO completato - pausa 25s prima prossimo giro..."
  sleep 25
done
