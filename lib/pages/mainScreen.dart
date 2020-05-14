//import 'dart:html';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_ip/get_ip.dart';
import 'package:sharifonline/classes/madadkar.dart';
import 'package:sharifonline/pages/testproximity.dart';
import 'package:sharifonline/style/theme.dart' as Theme;

import 'dialerScreen.dart';

class mainPage extends StatefulWidget {
  final madadkarInfo madadkar;

  const mainPage({Key key, this.madadkar}) : super(key: key);

  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  String Ip;

  Future<String> GetIPAddress() async {
    return await GetIp.ipAddress;
  }


  @override
  void initState() {
    GetIPAddress().then((value) {
      setState(() {
        Ip = value;
      });
    });
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }


  Future<bool> _onWillPopScope() {
    return showDialog(
        context: context,
        builder: (context) =>
            Directionality(
              textDirection: TextDirection.rtl,
              child: new AlertDialog(
                title: new Text('آیا مطمئنید؟'),
                content: new Text('آیا میخاهید خارج شوید؟'),
                actions: <Widget>[
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: roundedButton("خیر", const Color(0xFF167F67),
                        const Color(0xFFFFFFFF)),
                  ),
                  new GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: roundedButton(" بلی ", const Color(0xFF167F67),
                        const Color(0xFFFFFFFF)),
                  ),
                ],
              ),
            )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: _onWillPopScope,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: new AppBar(
              title: new Text('مددکار آنلاین'),
              centerTitle: true,
            ),
            drawer: Drawer(
              child: new Container(
                padding: EdgeInsets.fromLTRB(10, 25, 10, 5),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(width: 2),
                          color: Colors.white30),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              CircleAvatar(
                                child: Icon(FontAwesomeIcons.user),
                              ),
                              Padding(
                                padding: EdgeInsets.all(2),
                              ),
                              new Column(
                                children: <Widget>[
                                  Text('${widget.madadkar.madadkarName}'),
                                  Text('کد مددکاری: ${widget.madadkar
                                      .madadkarId}'),
                                  Text('آدرس آی پی: $Ip')
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            body: new Center(
                child: new Container(
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientStart,
                          Theme.Colors.loginGradientEnd
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),

                  padding: EdgeInsets.all(15),
                  child: new GridView.count(
                    crossAxisCount: 4,
                    children: <Widget>[
                      new RaisedButton(
                        padding: EdgeInsets.all(5),
                        color: Colors.greenAccent,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new CircleAvatar(
                              child: Icon(Icons.people),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 3)),
                            new Text('پیگیری حامیان', textScaleFactor: 0.9,)
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DialerPage(madadkar: widget.madadkar,),
                              ));
                        },
                      ),
                      new RaisedButton(
                        padding: EdgeInsets.all(5),
                        color: Colors.greenAccent,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new CircleAvatar(
                              child: Icon(Icons.people),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 3)),
                            new Text('تست پروکسیمیتی', textScaleFactor: 0.9,)
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    proximity(),
                              ));
                        },
                      )

                    ],
                  ),
                )),
          ),
        )
        ,
      );

  }
}


