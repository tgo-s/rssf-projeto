# -*- coding: utf-8 -*-

import struct
import socket
from common import Common
import sys
sys.path.insert(0, '../libs/')


class ClientUtils:
    CLIENT_PROTOCOL_ID = 2
    com = Common()
    sock = None

    def startClient(self, addr, port):
        initialPackage = []
        initialPackage.append(self.com.IDENTIFY)
        initialPackage.append(self.CLIENT_PROTOCOL_ID)

        self.sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
        #self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.com.sendPackage(addr, port, self.sock, initialPackage[0], initialPackage[1])

        print("Waiting for server response...")

        package = self.waitPackage(self.sock, initialPackage[0], initialPackage[1])

        if(package[0] == self.com.SUCCESS and package[1] == 1):
            print("Indetification success!")
            return True
        else:
            print("Indetification problem")
            return False

        pass

    def sendPackage(self, addr, port, operation, value):

        self.com.sendPackage(addr, port, self.sock, operation, value)

        print("Waiting for server response...")

        package = self.waitPackage(self.sock, operation, value)

        return package

    def waitPackage(self, sock, operation, value):

        while True:
            data, addr = sock.recvfrom(1024)
            offset = 0
            response = struct.unpack_from(">BB", data, offset)
            offset += struct.calcsize(">BB")
            if(response is not None):
                print("Response received from server [%s]:[%s]" %(addr[0], addr[1]))
                #pack = self.handlePackage(sock, addr, response,  operation, value)
                #if(pack is not None):
                return response
            pass
        pass

    pass

    def close(self):
        self.sock.close()
        pass

pass

def enum(**enums):
    return type('Enum', (), enums)

UserInputs = enum(EXIT = 0, LED_GET_STATE = 1, LIGHT_UP = 2, LIGHT_DOWN = 3)    

# end of ClientUtils

