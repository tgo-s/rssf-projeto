import 'package:flutter/material.dart';
import 'package:rssf_udp/core/udp_rssf.dart';
import 'dart:io';

void main() async {
  FlutterUdpClient fClient = FlutterUdpClient();
  final String _serverAddr = "10.0.2.2";
  final int _serverPort = 8802;
  bool connected = await fClient.startClient(_serverAddr, _serverPort);
  if (connected) {
    runApp(RssfApp(fClient));
  }
}

class RssfApp extends StatelessWidget {
  final FlutterUdpClient flutterUdpClient;

  RssfApp(this.flutterUdpClient);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projeto RSSF - CEIOT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RssfHomePage(
        title: 'CEIOT - Projeto RSSF ',
        channel: flutterUdpClient,
      ),
    );
  }
}

class RssfHomePage extends StatefulWidget {
  RssfHomePage({Key key, this.title, @required this.channel}) : super(key: key);
  final String title;
  final FlutterUdpClient channel;

  @override
  _RssfHomePageState createState() => _RssfHomePageState();
}

class _RssfHomePageState extends State<RssfHomePage> {
  bool _ledIsOn;
  int _lightIntesity;
  String _debugMsg;
  final int _defaultIntensityValue = 10;
  final String _serverAddr = "10.0.2.2";
  final int _serverPort = 8802;

  Future<List<int>> sendPackage(int op, int value) async {
    List<int> package = [];

    package = await widget.channel.sendPackage(_serverAddr, _serverPort, op, 1);

    return package;
  }

  @override
  void initState() {
    _debugMsg = "Client connected";
    _debugMsg = "Getting led status";
    sendPackage(Operation.LED_GET_STATE, 1).then((result) {
      List<int> package = result;
      if (package.length > 0 && package[0] == Operation.LED_STATE) {
        _lightIntesity = package[1];
        if (_lightIntesity > 0) {
          _ledIsOn = true;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    widget.channel.closeClient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16.0),
        child: Center(
          child: Column(
            children: <Widget>[
              _ledIsOn
                  ? Image.asset("assets/img/light_bulb_on.png")
                  : Image.asset("assets/img/light_bulb_off.png"),
              Container(
                margin: EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Light Down"),
                      onPressed: () {
                        setState(() {
                          List<int> localPackage = [];
                          _debugMsg = "Sending Light Down package";
                          sendPackage(
                                  Operation.LIGHT_DOWN, _defaultIntensityValue)
                              .then((result) {
                            _debugMsg = "Package received";
                            localPackage = result;
                            if (localPackage.length > 0 &&
                                localPackage[0] == Operation.SUCCESS &&
                                localPackage[1] == 1) {
                              _debugMsg = "Success";
                              _lightIntesity -= _defaultIntensityValue;
                              if (_lightIntesity <= 0) {
                                _ledIsOn = false;
                                _lightIntesity = 0;
                              }
                            } else {
                              _debugMsg = "Error";
                            }
                          });
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Light Up"),
                      onPressed: () {
                        setState(() {
                          List<int> localPackage = [];
                          _debugMsg = "Sending Light Down package";
                          sendPackage(
                                  Operation.LIGHT_UP, _defaultIntensityValue)
                              .then((result) {
                            localPackage = result;
                            _debugMsg = "Package received";
                            if (localPackage.length > 0 &&
                                localPackage[0] == Operation.SUCCESS &&
                                localPackage[1] == 1) {
                              _debugMsg = "Success";
                              _lightIntesity += _defaultIntensityValue;
                              _ledIsOn = true;
                              if (_lightIntesity >= 100) {
                                _lightIntesity = 100;
                              }
                            } else {
                              _debugMsg = "Error";
                            }
                          });
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Text("Led intensity is at: $_lightIntesity"),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: Text(
                  _debugMsg,
                  style: TextStyle(color: Colors.lightGreen),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
