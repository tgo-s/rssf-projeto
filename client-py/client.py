import sys
sys.path.insert(0, '../libs/')

from common import Common

import socket
import struct
import time

UDP_PORT = 8802
UDP_IP = "::1"

sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)

com = Common()

op = struct.pack(">BB", com.LED_STATE, 0)

print("UDP Target IP/PORT [%s]:[%s]" %(UDP_IP, UDP_PORT))

sock.sendto(op, (UDP_IP, UDP_PORT))

while True:
    data, addr = sock.recvfrom(1024)
    print("Listening response from server ...\n")

    offset = 0

    op = struct.unpack_from(">BB", data, offset)

    offset += struct.calcsize(">BB")

    if op[0] == com.LED_STATE:
        print("Getting led state... \n")
        print("Led state is [%s]\n" %com.getLedStateString(op))
        com.sendPackage(addr[0].strip(), addr[1],sock, com.LED_TOGGLE_REQUEST, op[1])
    elif op[0] == com.LED_SET_STATE:
        print("Setting led state to: [%s]\n" %com.getLedStateString(op))
        com.sendPackage(addr[0].strip(), addr[1], sock, com.LED_STATE, op[1])
    pass

    # time.sleep(1000)
