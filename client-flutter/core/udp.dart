import 'dart:io';

void main() async {
  FlutterUdpClient flutterClient = new FlutterUdpClient();
  Common com = new Common();
  print("Sending an operation ${com.getOperationName(Operation.IDENTIFY)} to Server");
  List<int> buffer = await flutterClient.sendPackage("127.0.0.1", 8802, Operation.IDENTIFY, 1);
  print("Value received was: OP: ${com.getOperationName(buffer[0])} - Value:${buffer[1]}");
  buffer.clear();
  buffer = await flutterClient.sendPackage("127.0.0.1", 8802, Operation.HANDSHAKE, 1);
}

class FlutterUdpClient {
  final String client_addr = "127.0.0.1";

  Future<List<int>> sendPackage(
      String address, int port, int op, int value) async {
    List<int> package = [];
    package.add(op);
    package.add(value);
    RawDatagramSocket socket = await RawDatagramSocket.bind(client_addr, 0);
    InternetAddress addr = new InternetAddress(address);
    socket.send(package, addr, port);
    package.clear();
    
    await for (RawSocketEvent ev in socket.asBroadcastStream()) {
      
      if (ev == RawSocketEvent.read) {
        Datagram dg = socket.receive();
        if (dg != null) {
          package = dg.data;
          if(package.length > 0){
            print('Response received from server [${dg.address}]:[${dg.port}]');
            socket.close();
            return package;
          }
        }
      }
    }
    return package;
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
      default:
    }
    return operationName;
  }
}

class Operation {
  static const IDENTIFY = (0x79);
  static const HANDSHAKE = (0x7E);
}
