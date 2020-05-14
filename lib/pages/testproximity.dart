import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class proximity extends StatefulWidget {
  @override
  _proximityState createState() => _proximityState();
}

class _proximityState extends State<proximity> {
  void channelUse() async {
    String result = '';
    if (Platform.isAndroid) {
      var method = MethodChannel('my.method.channel.fortest');
      try {
        result = await method.invokeMethod('turnon');
      } on PlatformException catch (e) {
        result = e.message;
      }
      setState(() {
        success = result;
      });
    }
  }

  String success = 'Not OK';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'WakeLock Status: $success',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: channelUse,
        tooltip: 'Increment',
        child: Icon(Icons.lock_outline),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
