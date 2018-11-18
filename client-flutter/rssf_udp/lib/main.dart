import 'package:flutter/material.dart';
import 'package:rssf_udp/core/udp_rssf.dart';

void main() => runApp(RssfApp());

class RssfApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String _debugMsg = "";
  Color _red = Color(0x9D0000);
  Color _green = Color(0x007A0F);
  bool _isRedActive = false;
  bool _isGreenActive = false;  

  Color _changeButtonColor(int button, bool isActive){
    Color newColor;
    if(button == 1){
      if(isActive){
        newColor = Color(0xFF0000);
        _debugMsg = "Led Red is On";
      }
      else{
        newColor = Color(0x9D0000);
        _debugMsg = "Led Red is Off";
      }
    }
    else if (button == 2){
      if(isActive){
        newColor = Color(0x00C718);
        _debugMsg = "Led Green is On";
      }
      else{
        newColor = Color(0x007A0F);
        _debugMsg = "Led Green is Off";
      }
    }
    return newColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                RaisedButton(
                  color: _red,
                  onPressed: () {
                    _isRedActive = !_isRedActive;
                    _red = _changeButtonColor(1, _isRedActive);
                  },
                ),
                RaisedButton(
                  color: _green,
                  onPressed: () {
                    _isGreenActive = !_isGreenActive;
                    _green = _changeButtonColor(2, _isGreenActive);
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Text(
              '$_debugMsg',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
    );
  }

  
}
