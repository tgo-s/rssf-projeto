# -*- coding: utf-8 -*-

import sys
sys.path.insert(0, '../libs/')
from common import Common

from client_utils import *


class Client:
    server_addr = "2804:14c:87c4:2003:de8c:412f:6f:1e52"
    server_port = 8802
    cliUtil = ClientUtils()

    def handleLedState(self, package):
        com = Common()
        if len(package) > 0 and package[0] == com.LED_STATE:
            ledVal = package[1]
            print("The LED STATE is currently at: [%d]" %ledVal)
            pass
        elif len(package) > 0 and package[0] == com.SUCCESS and package[1] == 0:
            print("An error occurred attempting to get LED STATE")
            pass

    def handlePackageReturn(self, package):
        com = Common()
        if(len(package) > 0 and package[0] == com.SUCCESS and package[1] == 1):
            print("Command executed")
            pass
        else:
            print("An error occured trying to execute command")
            pass
        pass

    def handleClientInput(self, input):
        com = Common()
        operation = []
        try:
            usrInput = int(input)
            if usrInput == UserInputs.LED_GET_STATE:
                operation.append(com.LED_GET_STATE)
                operation.append(1)
                package = self.cliUtil.sendPackage(self.server_addr, self.server_port, operation[0], operation[1])
                print("Package received from server")
                self.handleLedState(package)
                pass
            elif usrInput == UserInputs.LIGHT_UP:
                operation.append(com.LIGHT_UP)
                operation.append(com.LIGHT_DEFAULT_VALUE)
                package = self.cliUtil.sendPackage(self.server_addr, self.server_port, operation[0], operation[1])
                print("Package received from server")
                self.handlePackageReturn(package)
            elif usrInput == UserInputs.LIGHT_DOWN:
                operation.append(com.LIGHT_DOWN)
                operation.append(com.LIGHT_DEFAULT_VALUE)
                package = self.cliUtil.sendPackage(self.server_addr, self.server_port, operation[0], operation[1])
                print("Package received from server")
                self.handlePackageReturn(package)
            elif usrInput == UserInputs.EXIT:
                print("Exiting program")
                self.cliUtil.close()
                pass
            pass
        except ValueError:
            print("Unable to proccess the input")
            pass
        pass

    def startClient(self):
        success = self.cliUtil.startClient(self.server_addr, self.server_port)
        condition = -1
        if(success):
            while condition != 0:
                self.printClientOptions()
                inputVal = input(">")
                condition = inputVal
                if(inputVal != 0):
                    print("User Input = %s" % inputVal)
                    self.handleClientInput(inputVal)
                    pass
                pass
            pass

        pass

    def printClientOptions(self):
        print("Set one of those options")
        print("1 - Get Led State from server")
        print("2 - Led - Light Up")
        print("3 - Led - Light Down")
        print("0 - Exit")
        pass

    pass

cli = Client()
cli.startClient()