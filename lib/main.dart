import 'dart:async';

import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:countdown/countdown.dart';

import 'otp.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: new MyHomePage(title: 'Time-based One Time Password'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String barcode = "";
  int totp = 0;

  int val = 0;
  CountDown cd;

  void _randomNumber() {
    setState(() {
      countdown();
      //print('$barcode');
      totp = OTP.generateTOTPCode(
          barcode.toString(), new DateTime.now().millisecondsSinceEpoch);
//      if (val == 0) {
//        //totp = new Random().nextInt(999999) + 100000;
//        totp = OTP.generateTOTPCode(
//            barcode.toString(), new DateTime.now().millisecondsSinceEpoch);
//      }
    });
  }

  void countdown() {
    //print("countdown() called");
    cd = new CountDown(new Duration(seconds: 30));
    // StreamSubscription sub=cd.stream.listen(null);
    var sub = cd.stream.listen(null);
    sub.onDone(() {
      //print("Done");
      countdown();
    });

    sub.onData((Duration d) {
      if (val == d.inSeconds) return;
      //print("onData: d.inSeconds=${d.inSeconds}");
      setState(() {
        val = d.inSeconds;
        if (val == 0) {
          totp = OTP.generateTOTPCode(
              barcode.toString(), new DateTime.now().millisecondsSinceEpoch);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Card(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.timelapse),
                    title: new Text(
                      totp.toString(),
                      style: new TextStyle(
                          color: Colors.deepPurple, fontSize: 30.50),
                    ),
                    subtitle: new Text('Time-Based OTP'),
                  ),
                  new ButtonTheme.bar(
                    // make buttons use the appropriate styles for cards
                    child: new ButtonBar(
                      children: <Widget>[
                        new Text(
                          val.toString(),
                          style: new TextStyle(fontSize: 30.50),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Scan QR Code',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _scan() {
    scan();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      setState(() {
        _randomNumber();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode = 'Nothing Scan');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
