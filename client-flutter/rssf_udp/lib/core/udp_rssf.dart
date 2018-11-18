import 'dart:io';

class FlutterUdpClient {
  final String client_addr = "127.0.0.1";
  final int client_protocol_id = 2;

  Future<List<int>> sendPackage(
      String address, int port, operation, value) async {
    List<int> initPackage = [];
    //initial package to the server
    initPackage.add(Operation.IDENTIFY);
    initPackage.add(client_protocol_id);

    RawDatagramSocket socket = await RawDatagramSocket.bind(client_addr, 0);
    InternetAddress addr = new InternetAddress(address);
    Common com = new Common();

    print("Sending an operation ${com.getOperationName(Operation.IDENTIFY)} to Server");

    socket.send(initPackage, addr, port);
    initPackage.clear();

    print("Waiting for server response...");

    await for (RawSocketEvent ev in socket.asBroadcastStream()) {
      if (ev == RawSocketEvent.read) {
        Datagram dg = socket.receive();
        
        if (dg != null) {
          
          List<int> receivedPack = dg.data;
          if (receivedPack.length >= 1) {
            print('Response received from server [${dg.address}]:[${dg.port}]');
            print("Value received was - OP: ${com.getOperationName(receivedPack[0])} - Value:${receivedPack[1]}");

            if (receivedPack[0] == Operation.HANDSHAKE) {
              List<int> newPackage = [];
              newPackage.add(operation);
              newPackage.add(value);
              print("Sending the following operation to server - ${com.getOperationName(operation)} with value: ${value}");
              socket.send(newPackage, dg.address, dg.port);
              print("Waiting for server response...");
            } else {
              print("Closing client connection");
              socket.close();
              return receivedPack;
            }
          }
        }
      }
    }
    socket.close();
    return null;
  }
}

class Common {
  String getOperationName(int operation) {
    String operationName = "";
    switch (operation) {
      case Operation.IDENTIFY:
        operationName = "IDENTIFY";
        break;
      case Operation.HANDSHAKE:
        operationName = "HANDSHAKE";
        break;
      case Operation.LED_STATE:
        operationName = "Led State";
        break;
      case Operation.LED_GET_STATE:
        operationName = "Led get state";
        break;
      default:
    }
    return operationName;
  }
}

class Operation {
  static const IDENTIFY = (0x79);
  static const LIGHT_UP = (0x7A);
  static const LIGHT_DOWN = (0x7B);
  static const LED_STATE = (0x7C);
  static const DEVICES_LIST = (0x7D);
  static const HANDSHAKE = (0x7E);
  static const LED_GET_STATE = (0x7F);
}

enum UserInputs {
  LED_GET_STATE,
  DEVICES_LIST,
  LIGHT_UP,
  LIGHT_DOWN,
}

enum LedState { LEDS_OFF,LEDS_RED, LEDS_GREEN, LEDS_ALL }
