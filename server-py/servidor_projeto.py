import socket
import struct
import random

HOST = '' #all interfaces
UDP_PORT = 8802

sock = socket.socket(socket.AF_INET6 , socket.SOCK_DGRAM) #UDP IPv6
sock.bind((HOST , UDP_PORT))

IDENTIFICACAO = (0x79)
ALTERA_MAIS = (0x7A)
ALTERA_MENOS = (0x7B)
LED_STATE = (0x7C)
list ipps = []

while True:
        data, addr = sock.recvfrom(1024) #buffer size is 1024 bytes
        offset = 0
        op = struct.unpack_from(">BB", data, offset)
        offset += struct.calcsize(">BB")

        if op[0] == ALTERA_MAIS:
            #ENVIA PARA A PLAQUINHA A ALTERAÇÃO
            valor_led = op[1]
            op = struct.pack(">BB" , ALTERA_MAIS , valor_led)
            sock.sendto(op , ips[0])
        elif op[0] == ALTERA_MENOS:
            #ENVIA PARA A PLAQUINHA A ALTERAÇÃO
            valor_led = op[1]
            op = struct.pack(">BB" , ALTERA_MENOS , valor_led)
            sock.sendto(op , ips[0])
        elif op[0] == LED_STATE:
            op = struct.pack(">BB" , LED_STATE , 0)
            sock.sendto(op , (IP_CLIENTE , PORTA_CLIENTE))
        elif op[0] == IDENTIFICACAO:
            ips.append([addr[0].splip(), addr[1])
        elif op[0] == LISTA_PLACAS:
            op = struct.pack(">BB" , PLACAS , LISTA_DE_PLACAS)
            sock.sendto(op , (IP_CLIENTE , PORTA_CLIENTE))        
            
            