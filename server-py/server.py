from common import Common

import time
import socket    
import struct 
import sys 

HOST = ''
UDP_PORT = 8802

sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
sock.bind((HOST, UDP_PORT))
#sock.listen(1)

print("Iniciando Servidor... \n")

com = Common()

while True:
    print("Waiting for client ...\n")
    data, addr = sock.recvfrom(1024)
    offset = 0
    op = struct.unpack_from(">BB", data, offset)
    offset += struct.calcsize(">BB")
    if (op[0] == com.LED_STATE):
        print("%s recieved from : [%s]:[%s]\n" %(com.getOperationName(op[0]), addr[0].strip(), addr[1]))
        com.sendPackage(addr[0].strip(), addr[1], sock,  com.LED_STATE, com.getValue())
    elif op[0] == com.LED_TOGGLE_REQUEST:
        print("Server received a toggle request...\n")
        com.sendPackage(addr[0].strip(), addr[1], sock, com.LED_SET_STATE, com.getValue())
    pass

    time.sleep(1.5)