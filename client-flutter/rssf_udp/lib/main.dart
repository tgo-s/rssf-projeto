import 'package:flutter/material.dart';
import 'package:rssf_udp/core/udp_rssf.dart';
import 'dart:io';

void main() async {
  runApp(RssfApp());
}

class RssfApp extends StatelessWidget {
  RssfApp();
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
      ),
    );
  }
}

class RssfHomePage extends StatefulWidget {
  RssfHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RssfHomePageState createState() => _RssfHomePageState();
}

class _RssfHomePageState extends State<RssfHomePage> {
  FlutterUdpClient _flutterUdpClient;
  bool _ledIsOn;
  int _lightIntesity;
  String _debugMsg;
  int _ipVersion = 0;
  String _serverAddr;
  int _serverPort;

  final int _defaultIntensityValue = 10;

  Future<List<int>> sendPackage(int op, int value) async {
    List<int> package = [];

    package =
        await _flutterUdpClient.sendPackage(_serverAddr, _serverPort, op, 1);

    return package;
  }

  @override
  void initState() {
    // _debugMsg = "Getting led status";
    // sendPackage(Operation.LED_GET_STATE, 1).then((result) {
    //   List<int> package = result;
    //   if (package.length > 0 && package[0] == Operation.LED_STATE) {
    //     _lightIntesity = package[1];
    //     if (_lightIntesity > 0) {
    //       _ledIsOn = true;
    //     }
    //   }
    // });
    setState(() {
      _ledIsOn = false;
      _lightIntesity = 0;
    });

    super.initState();
  }

  @override
  void dispose() {
    _flutterUdpClient.closeClient();
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
              DropdownButton(
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text("IPv4"),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text("IPv6"),
                    value: 2,
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _ipVersion = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Server IP'),
                onChanged: (value) {
                  _serverAddr = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Server Port'),
                onChanged: (value) {
                  _serverPort = int.parse(value);
                },
              ),
              RaisedButton(
                child: Text("Connect"),
                onPressed: () {
                  setState(() {
                    // bool connected = await _flutterUdpClient.startClient(
                    //     _serverAddr, _serverPort, _ipVersion);

                    // if (connected) {
                    //   _debugMsg = "Connected";
                    // } else {
                    //   _debugMsg = "Error";
                    // }
                  });
                },
              ),
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
                          _lightIntesity -= _defaultIntensityValue;
                          if (_lightIntesity <= 0) {
                            _ledIsOn = false;
                            _lightIntesity = 0;
                          } else {
                            _debugMsg = "Error";
                          }
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text("Light Up"),
                      onPressed: () {
                        setState(() {
                          _lightIntesity += _defaultIntensityValue;
                          _ledIsOn = true;
                          if (_lightIntesity >= 100) {
                            _lightIntesity = 100;
                          } else {
                            _debugMsg = "Error";
                          }
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
