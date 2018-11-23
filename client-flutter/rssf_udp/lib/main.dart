import 'package:flutter/material.dart';
import 'package:rssf_udp/core/udp_rssf.dart';
import 'dart:io';

void main() => runApp(RssfApp());

class RssfApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projeto RSSF - CEIOT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RssfHomePage(title: 'CEIOT - Projeto RSSF '),
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
  bool _ledIsOn;
  int _lightIntesity;
  int _ipVersion;
  String _serverAddr;
  int _serverPort;
  String _debugMsg;

  final int _defaultIntensityValue = 10;

  @override
  void initState() {
    setState(() {
      _ledIsOn = false;
      _lightIntesity = 0;
    });
    super.initState();
  }

  @override
  void dispose() {
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
                hint: Text("Select a IP version"),
                value: _ipVersion,
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
                    _debugMsg = "IP Version Selected [$_ipVersion]";
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Server IP'),
                onChanged: (value) {
                  setState(() {
                    _serverAddr = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Server Port'),
                onChanged: (value) {
                  setState(() {
                    _serverPort = int.parse(value);
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
                margin: EdgeInsets.only(top: 16.0),
                child: Text(
                  "Debug: $_debugMsg - Server: $_serverAddr - Port: $_serverPort",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
