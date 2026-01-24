#!/usr/bin/env python3
from bacpypes.core import run
from bacpypes.app import BIPSimpleApplication  
from bacpypes.local.device import LocalDeviceObject
from bacpypes.pdu import Address
from bacpypes.apdu import WhoIsRequest, ReadPropertyRequest
from bacpypes.primitivedata import ObjectIdentifier, CharacterString
import time

class SimpleEnum(BIPSimpleApplication):
    def __init__(self, *args):
        super().__init__(*args)
        self.target = Address("67.224.88.86:47808")
        print("🎯 Who-Is -> BBMD JCI Metasys")
        whois = WhoIsRequest()
        whois.pduDestination = self.target
        self.request(whois)
    
    def indication(self, apdu):
        print(f"📨 {apdu.__class__.__name__}: {apdu}")
        
        # Dispositivi trovati
        if hasattr(apdu, 'deviceIdentifier'):
            dev_id = apdu.deviceIdentifier
            print(f"\n🎯 DEVICE ID: {dev_id}")
            self.read_stream_objects(dev_id)
    
    def read_stream_objects(self, dev_id):
        print("\n🔍 Enumerando oggetti BROADCAST:")
        objects = [
            (200001, "AV_STREAM"),    # AnalogValue stream mux
            (100001, "BO_CHANNEL"),   # BinaryOutput channel
            (200010, "AO_SOURCE"),    # AnalogOutput source
        ]
        
        for inst, name in objects:
            oid = ObjectIdentifier('analogValue', inst)
            print(f"  📊 {name}: {oid}")
            
            # ObjectName
            req1 = ReadPropertyRequest(objectIdentifier=oid, propertyIdentifier=19)
            req1.pduDestination = self.target
            self.request(req1)

this_device = LocalDeviceObject(
    objectName=CharacterString("Enum-Tool"),
    objectIdentifier=12345
)

app = SimpleEnum(this_device, '0.0.0.0')
print("Avvio... (attendi 20s)")
run()
