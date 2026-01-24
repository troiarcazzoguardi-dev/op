#!/usr/bin/env python3
from bacpypes.debugging import bacpypes_debugging, ModuleLogger
from bacpypes.core import run
from bacpypes.app import BIPSimpleApplication
from bacpypes.local.device import LocalDeviceObject
from bacpypes.pdu import Address
from bacpypes.apdu import (
    WhoIsRequest, ReadPropertyRequest, ConfirmedEventNotification,
    SimpleAckPDU, ErrorPDU
)
from bacpypes.primitivedata import ObjectIdentifier, Unsigned, CharacterString
from bacpypes.constructeddata import Sequence
import sys
import time

bacpypes_debugging("bacpypes.app:BIPSimpleApplication:10")
bacpypes_debugging("bacpypes.comm:BIPDriver:10")

class EnumApp(BIPSimpleApplication):
    def __init__(self, *args):
        super(EnumApp, self).__init__(*args)
        self.target_addr = Address("67.224.88.86:47808")
        print("🔍 Inviando Who-Is al BBMD...")
        self.do_whois()
    
    def do_whois(self):
        whois = WhoIsRequest()
        whois.pduDestination = self.target_addr
        self.request(whois)
    
    def indication(self, apdu):
        """Gestisce tutte le risposte"""
        if apdu.pduDestination:
            print(f"📥 Risposta da {apdu.pduSource}: {apdu.__class__.__name__}")
        
        if isinstance(apdu, ConfirmedEventNotification):
            print(f"🔔 Evento: {apdu.eventObjectIdentifier}")
        
        # Salva dispositivi I-Am
        if hasattr(apdu, 'iAmDeviceIdentifier'):
            device_id = apdu.iAmDeviceIdentifier
            print(f"🎯 DEVICE: {device_id} @ {apdu.pduSource}")
            self.enum_critical_objects(device_id)
    
    def enum_critical_objects(self, device_id):
        """Enumerazione oggetti TV broadcast"""
        critical_objects = [
            ("analogValue", 1, "AV_STREAM_MUX"),
            ("analogOutput", 10, "AO_VIDEO_SOURCE"), 
            ("binaryOutput", 1, "BO_CHANNEL_SWITCH"),
            ("multiStateOutput", 1, "MSO_STREAM_SELECT"),
            ("file", 1, "CONFIG_DUMP")
        ]
        
        for obj_type, instance, name in critical_objects:
            oid = ObjectIdentifier(obj_type, instance)
            print(f"🔍 Reading {name} ({oid}) su device {device_id}")
            
            req = ReadPropertyRequest(
                objectIdentifier=oid,
                propertyIdentifier="objectName"
            )
            req.pduDestination = self.target_addr
            self.request(req)
            
            # PresentValue immediato
            req2 = ReadPropertyRequest(
                objectIdentifier=oid,
                propertyIdentifier="presentValue"
            )
            req2.pduDestination = self.target_addr
            self.request(req2)
        
        print("✅ Enumerazione completata. Cerca 'CHANNEL 31' o 'STREAM' negli oggetti.")

# Device locale
this_device = LocalDeviceObject(
    objectName=CharacterString("Pentest-Scanner"),
    objectIdentifier=999999,
    maxApduLengthAccepted=1476,
    segmentationSupported="noSegmentation",
    localTime=0,
    localDate=0,
    utcOffset=0,
    daylightSavingsStatus=False,
    vendorIdentifier=15,
)

# App
this_application = EnumApp(this_device, '0.0.0.0')

print("🚀 BACnet Enum su 67.224.88.86:47808 (JCI Metasys)")
print("Aspetta 30-60s per BBMD relay response...")
run()
