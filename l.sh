#!/bin/bash
# NDI_HIJACK_SETUP.sh - Installazione REAL Kali Linux

set -e

echo "[+] NDI SDK v5 REAL install (Kali-tested)..."

cd /tmp

# Download NDI SDK v5 Linux (link ATUALIZZATO 2026)
wget -O NDI_SDK_v5_Linux.tar.gz "https://downloads.ndi.tv/SDK/NDI%205%20SDK/NDI%20SDK%20v5%20Linux/Install_NDI_SDK_v5_Linux.tar.gz" || {
    echo "[-] Main link fail, backup mirror..."
    wget -O NDI_SDK_v5_Linux.tar.gz "https://ndownload.ndi.tv/NDI%20SDK%20v5%20Linux/Install_NDI_SDK_v5_Linux.tar.gz"
}

# Estrai ed installa
tar xzf NDI_SDK_v5_Linux.tar.gz
sudo ./Install_NDI_SDK_v5_Linux.sh << EOF
y
/opt/ndi
EOF

# Python deps REAL (numpy-ndi dal git + wheels)
sudo apt update
sudo apt install -y python3-pip python3-dev python3-numpy libavcodec-dev libavformat-dev libswscale-dev

pip3 install --upgrade pip
pip3 install pillow requests numpy

# numpy-ndi REAL (build da source con NDI SDK)
pip3 install git+https://github.com/buresu/numpy-ndi.git || {
    echo "[+] Building numpy-ndi from source..."
    git clone https://github.com/buresu/numpy-ndi.git /tmp/numpy-ndi
    cd /tmp/numpy-ndi
    pip3 install .
}

# Fix LD_LIBRARY_PATH per runtime
echo 'export LD_LIBRARY_PATH=/opt/ndi/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc
export LD_LIBRARY_PATH=/opt/ndi/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Test NDI
python3 -c "
import numpy_ndi as ndi
ndi.initialize()
print('✅ NDI SDK v5 + numpy-ndi REAL - READY!')
ndi.destroy()
"

echo "[+] ✅ SETUP COMPLETO - Esegui: sudo python3 NDI_HIJACK_REAL.py"
