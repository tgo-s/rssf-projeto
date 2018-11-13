import asyncore
import socket
import struct

import sys
sys.path.insert(0, '../libs/')

from common import Common

class ServerHandler(asyncore.dispatcher_with_send):
    def handle_read(self):
        data = self.recv(1024)
        if data:
            self.send(data)
            #self.handle_client(data)

     
    


class Server(asyncore.dispatcher):
    def __init__(self, host, port):
        asyncore.dispatcher.__init__(self)
        self.create_socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.set_reuse_addr()
        self.bind((host, port))
        self.listen(5)

    def handle_accept(self):
        pair = self.accept()
        if pair is not None:
            sock, addr = pair
            print ("Connection from %s" %repr(addr))
            handler = ServerHandler(sock)


server = Server("localhost", 8802)
asyncore.loop()