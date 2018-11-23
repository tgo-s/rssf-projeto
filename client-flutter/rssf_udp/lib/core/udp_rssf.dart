import 'dart:io';

class FlutterUdpClient {
  final String clientAddr = "127.0.0.1";
  final int clientProtocolId = 2;
  RawDatagramSocket socket;

  Future<bool> startClient(String address, int port) async {
    List<int> initPackage = [];
    //initial package to the server
    initPackage.add(Operation.IDENTIFY);
    initPackage.add(clientProtocolId);

    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    // Future.wait([
    //   RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((rawSocket) {
    //     if (rawSocket != null) {
    //       socket = rawSocket;
    //     }
    //   })
    // ]);

    Common com = new Common();

    print(
        "Sending an operation ${com.getOperationName(Operation.IDENTIFY)} to Server");

    InternetAddress addr = new InternetAddress(address);
    socket.send(initPackage, addr, port);

    print("Waiting for server response...");

    List<int> receivedPackage = await waitPackage(socket);

    if (receivedPackage[0] == Operation.SUCCESS && receivedPackage[1] == 1) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<int>> sendPackage(
      String address, int port, operation, value) async {
    // socket = await RawDatagramSocket.bind(client_addr, 0);
    List<int> package = [];
    package.add(operation);
    package.add(value);
    InternetAddress addr = new InternetAddress(address);
    socket.send(package, addr, port);
    package.clear();
    package = await waitPackage(socket);
    return package;
  }

  Future<List<int>> waitPackage(RawDatagramSocket socket) async {
    List<int> receivedPack = [];
    // socket.listen((RawSocketEvent ev) {
    //   print("Event: $ev");
    //   if (ev == RawSocketEvent.read) {
    //     Datagram dg = socket.receive();
    //     if (dg != null) {
    //       receivedPack = dg.data;
    //     }
    //   }
    // });

    await for (RawSocketEvent ev in socket.asBroadcastStream()) {
      if (ev == RawSocketEvent.read) {
        Datagram dg = socket.receive();

        if (dg != null) {
          if (dg.data.length >= 1) {
            // print('Response received from server [${dg.address}]:[${dg.port}]');
            // print("Value received was - OP: ${com.getOperationName(receivedPack[0])} - Value:${receivedPack[1]}");
            receivedPack = dg.data;
            break;
          }
        }
      }
    }
    return receivedPack;
  }

  void closeClient() {
    socket.close();
  }
}

class Common {
  String getOperationName(int operation) {
    String operationName = "";
    switch (operation) {
      case Operation.IDENTIFY:
        operationName = "IDENTIFY";
        break;
      case Operation.SUCCESS:
        operationName = "SUCCESS";
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
  static const SUCCESS = (0x7E);
  static const LED_GET_STATE = (0x7F);
}

enum UserInputs {
  LED_GET_STATE,
  LIGHT_UP,
  LIGHT_DOWN,
}

enum LedState { LEDS_OFF, LEDS_RED, LEDS_GREEN, LEDS_ALL }
