import socket
import struct
import random
from threading import Thread

import sys
sys.path.insert(0, '../libs/')

from common import Common


def startServer():
    HOST = '' #all interfaces
    UDP_PORT = 8802
    #sock = socket.socket(socket.AF_INET6 , socket.SOCK_DGRAM) #UDP IPv6
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) #UDP IPv4
    sock.bind((HOST , UDP_PORT))

    com = Common()

    #devices = {}

    print("Starting Python Host")
    sock.settimeout(10)
    counter = 0
    while True:
            print("Waiting for clients...")

            try:
                data, addr = sock.recvfrom(1024) #buffer size is in bytes
                if(data is not None):
                    offset = 0
                    op = struct.unpack_from(">BB", data, offset)
                    offset += struct.calcsize(">BB")
                    client_addr = addr[0]
                    client_port = addr[1]
                    if op[0] == com.IDENTIFY:
                        print("[%s] request was received from client [%s]:[%s]" %(com.getOperationName(op[0]), client_addr, client_port))
                        print("Sending handshake...")
                        com.sendPackage(client_addr, client_port, sock, com.HANDSHAKE, 1)
                    else:
                        print("Operation not found\n")
                    pass
                
                pass
            except socket.timeout: # as ex:
                counter += 1
                print("Timeout counter: %d " %counter)
                #print("Exception: %s" %ex)
                pass
            # finally:
            #     sock.close()
            #     pass

            # if op[0] == com.LIGHT_UP:
                #ENVIA PARA A PLAQUINHA A ALTERAÇÃO
            #     valor_led = op[1]
            #     op = struct.pack(">BB" , com.LIGHT_UP, valor_led)
            #     sock.sendto(op , devices[0])
            # elif op[0] == com.LIGHT_DOWN:
            #     #ENVIA PARA A PLAQUINHA A ALTERAÇÃO
            #     valor_led = op[1]
            #     op = struct.pack(">BB" , com.LIGHT_DOWN , valor_led)
            #     sock.sendto(op , devices[0])
            # elif op[0] == com.LED_STATE:
            #     op = struct.pack(">BB" , com.LED_STATE , 0)
            #     sock.sendto(op , (addr[0].splip(), addr[1]))
            # # elif op[0] == com.IDENTIFY:
            # #     devices[] =  
            # elif op[0] == com.DEVICES_LIST:
            #     op = struct.pack(">BB" , PLACAS , com.DEVICES_LIST)
            #     sock.sendto(op , (addr[0].splip(), addr[1]))        

startServer()


