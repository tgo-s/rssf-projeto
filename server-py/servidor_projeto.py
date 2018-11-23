#-*- coding: utf-8 -*-

import socket
import struct
import random
from threading import Thread

import sys
sys.path.insert(0, '../libs')
from common import Common

device_addr = []
ui_addr = []


def handleOperations(op, sock, client_addr, client_port):
    com = Common()
    print("[%s] request was received from client [%s]:[%s]" %(com.getOperationName(op[0]), client_addr, client_port))
    if op[0] == com.IDENTIFY:
        if(op[1] == com.CLIENT_MICROCONTROLLER):
            device_addr.append(client_addr)
            device_addr.append(client_port)
            print("Device identified - IP registered")
            pass
        elif (op[1] == com.CLIENT_UI):
            ui_addr.append(client_addr)
            ui_addr.append(client_port)
            print("Client identified - IP registered")
            pass
        print("Sending [%s]..." %com.getOperationName(com.SUCCESS))
        com.sendPackage(client_addr, client_port, sock, com.SUCCESS, 1)
        pass
    # elif op[0] == com.DEVICES_LIST:
    #     print("Sending %s..." %com.getOperationName(com.DEVICES_LIST))
    #     com.sendPackage(client_addr, client_port, sock, com.DEVICES_LIST, 1)
    #     pass
    elif op[0] == com.LED_STATE:
        if(len(ui_addr) > 0):
            print("Sending [%s] to client" %com.getOperationName(com.LED_STATE))
            com.sendPackage(ui_addr[0], ui_addr[1], sock, com.LED_STATE, op[1])
            pass
        else:
            print("There are no clients registered")
            pass
        pass
    elif op[0] == com.LED_GET_STATE:
        if(len(device_addr) > 0):
            print("Sending [%s] to device..." %com.getOperationName(com.LED_GET_STATE))
            com.sendPackage(device_addr[0], device_addr[1], sock, com.LED_GET_STATE, 0)    
            pass
        else:
            print("There are no devices registered")
            print("Returning [%s] to client..." %com.getOperationName(com.SUCCESS))
            com.sendPackage(ui_addr[0], ui_addr[1], sock, com.SUCCESS, 0)    
            pass
        pass
    elif (op[0] == com.LIGHT_UP):
        if(len(device_addr) > 0):
            print("Sending [%s] to device..." %com.getOperationName(com.LIGHT_UP))
            com.sendPackage(device_addr[0], device_addr[1], sock, com.LIGHT_UP, com.LIGHT_DEFAULT_VALUE)    
            pass
        else:
            print("There are no devices registered")
            print("Returning [%s] to client..." %com.getOperationName(com.SUCCESS))
            com.sendPackage(ui_addr[0], ui_addr[1], sock, com.SUCCESS, 0)    
            pass
        pass
    elif (op[0] == com.LIGHT_DOWN):
        if(len(device_addr) > 0):
            print("Sending [%s] to device..." %com.getOperationName(com.LIGHT_DOWN))
            com.sendPackage(device_addr[0], device_addr[1], sock, com.LIGHT_DOWN, com.LIGHT_DEFAULT_VALUE)    
            pass
        else:
            print("There are no devices registered")
            print("Returning [%s] to client..." %com.getOperationName(com.SUCCESS))
            com.sendPackage(ui_addr[0], ui_addr[1], sock, com.SUCCESS, 0)    
            pass
        pass
    elif (op[0] == com.SUCCESS):
        if(op[1] == 1):
            print("Server received a [%s] return from client" %com.getOperationName(com.SUCCESS))
            pass
        else:
            print("The operation sent returned without success" %com.getOperationName(com.SUCCESS))
            pass
        pass
    else:
        print("Operation [%d] not found\n" %op[0])
    pass

def startServer():
    HOST = '' #all interfaces
    UDP_PORT = 8802
    # sock = socket.socket(socket.AF_INET6 , socket.SOCK_DGRAM) #UDP IPv6
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) #UDP IPv4
    sock.bind((HOST , UDP_PORT))

    #devices = {}

    print("Starting Python Host")
    addrInfo = sock.getsockname()
    print("AddrInfo: [%s]:[%s]" %(addrInfo[0], addrInfo[1]))
    #sock.settimeout(10)
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
                    handleOperations(op,sock,client_addr,client_port)
                pass
            except socket.timeout: # as ex:
                counter += 1
                print("Timeout counter: %d " %counter)
                #print("Exception: %s" %ex)
                pass
            except KeyboardInterrupt:
                print('Keyboard Interrupt, closing socket...')
                sock.close()
                break
                   

startServer()