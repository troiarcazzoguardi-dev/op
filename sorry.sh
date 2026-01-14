#!/bin/bash
# ONESHOT: Host TRUSTEDF57.html GRATIS subito con torsocks

cd "$(dirname "$0")"

# Usa 0x0.st - gratis, no login, immediato
torsocks curl -F "file=@TRUSTEDF57.html" https://0x0.st | tee link.txt | xargs -I {} echo "✅ LINK PUBBLICO:\n{}\n\n📋 COPIA PER KIOSKS: {}"
