import struct
import socket
import random

class Common:


    IDENTIFY = (0x79)
    LIGHT_UP = (0x7A)
    LIGHT_DOWN = (0x7B)
    LED_STATE = (0x7C)
    DEVICES_LIST = (0x7D)
    HANDSHAKE = (0x7E)

    LEDS_GREEN = 2
    LEDS_RED = 1
    LEDS_ALL = 3


    def sendPackage(self, address, port, sock, operation, value):
        print("Sending [%s] package request to: [%s]:[%s]\n" %(self.getOperationName(operation), address, port))
        package = struct.pack(">BB", operation, value)
        # enviar o IP pra localhost ou pra alguem?
        sock.sendto(package, (address, port))

    # def sendPackageToClient(self, address, port, sock, operation, value):
    #     print("Sending %s package request to: [%s]:[%s]\n" %(self.getOperationName(operation), address, port))
    #     sock.sendto( "%d¬%s" %(operation, value) ,(address, port))

    def getLedStateString(self, operation):
        response = ""
        if operation[1] == self.LEDS_RED:
            response = "LED RED"
        elif operation[1] == self.LEDS_GREEN:
            response = "LED GREEN"
        elif operation[1] == self.LEDS_ALL:
            response = "LEDS RED AND GREEN"
        
        return response

    def getOperationName(self, operation):
        if operation == self.LED_STATE:
            response = "LED STATE"
        elif operation == self.IDENTIFY:
            response = "IDENTIFY"
        elif operation == self.HANDSHAKE:
            response = "HANDSHAKE"
        elif operation == self.LIGHT_UP:
            response = "LIGHT UP LED"
        elif operation == self.LIGHT_DOWN:
            response = "LIGHT DOWN LED"            
        
        # if operation[1] == 0:
        #     response += " OFF"
        # elif operation[1] == 1:
        #     response += " ON"

        return response

    def getValue(self):
        return random.randint(0,3)    
