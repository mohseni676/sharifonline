import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:sharifonline/classes/hami.dart';
import 'package:sharifonline/classes/madadkar.dart';
import 'package:sharifonline/globals.dart';
import 'package:sharifonline/pages/callScreen.dart';
import 'package:sharifonline/style/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class DialerPage extends StatefulWidget {
  final madadkarInfo madadkar;

  const DialerPage({Key key, this.madadkar}) : super(key: key);

  @override
  _DialerPageState createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage>
    implements SipUaHelperListener {
  String _password = 'alimohseni@62';
  String _wsUri = 'ws://vs.sharifngo.com:8088/ws';
  String _sipUri = '4009@vs.sharifngo.com';
  String _displayName = '4009';
  String _authorizationUser = '4009';
  TextEditingController _controller = new TextEditingController();
  var _searchController = new TextEditingController();
  List<HamisInfo> _hamis = new List<HamisInfo>();
  List<HamisInfo> _hamisOut;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String _filter = '';

//  double _localVideoHeight;
//  double _localVideoWidth;
//  EdgeInsetsGeometry _localVideoMargin;
  MediaStream _localStream;
  MediaStream _remoteStream;

  String _RegistrationState = '';
  String _PhoneState = '';

  RegistrationState _registrationState;
  CallStateEnum _callstate = CallStateEnum.NONE;
  SIPUAHelper helper = SIPUAHelper();
  bool isRegistered = false;

  final _debouncer = Debouncer(milliseconds: 500);

  //Future<List<HamisInfo>> _future;
  Future<List<HamisInfo>> GetHamis() async {
    List<HamisInfo> res = new List<HamisInfo>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await http.post(ServerUrl + 'api/Madadkar/GetHamis',
        headers: {'Authorization': 'Bearer ' + token});
    debugPrint(result.statusCode.toString());
    if (result.statusCode == 200) {
      Iterable jResults = json.decode(result.body);

      res = jResults.map((model) => HamisInfo.fromJson(model)).toList();
      return res;
    }
    return null;
  }

  void _handelStreams(CallState event) async {
    MediaStream stream = event.stream;

    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer.srcObject = stream;
      }
      _localStream = stream;
      _localStream.getAudioTracks()[0].enableSpeakerphone(false);
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer.srcObject = stream;
      }
      _remoteStream = stream;
      _remoteStream.getAudioTracks()[0].enableSpeakerphone(false);
    }
  }

  void _handleHangup() {
    helper.hangup();
  }

  void _handleAccept() {
    helper.answer();
  }

  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer.initialize();
    }
  }

  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer.dispose();
      _remoteRenderer = null;
    }
  }

  Widget _handleCall(BuildContext context) {
    var dest = _controller.text;
    if (dest == null || dest.isEmpty) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('شماره خالی.'),
            content: Text('لطفا یک شماره یا داخلی را وارد کنید'),
            actions: <Widget>[
              FlatButton(
                child: Text('قبول'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    helper.call(dest, true);
    // _preferences.setString('dest', dest);
    return null;
  }

  handleSave(BuildContext context) {
    UaSettings settings = UaSettings();

    settings.webSocketUrl = _wsUri;
    settings.uri = _sipUri;
    settings.authorizationUser = _authorizationUser;
    settings.password = _password;
    settings.displayName = _displayName;
    //settings.webSocketExtraHeaders = _wsExtraHeaders;

    helper.start(settings);
  }

  @override
  void initState() {
    setState(() {
      _password = widget.madadkar.sipPassword;
      _wsUri = widget.madadkar.sipWsUrl;
      _sipUri = widget.madadkar.sipUrl;
      _displayName = widget.madadkar.sipDisplayname;
      _authorizationUser = widget.madadkar.sipExtention;
    });
    // TODO: implement initState


    _registrationState = helper.registerState;
    helper.addSipUaHelperListener(this);
    handleSave(context);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    helper.removeSipUaHelperListener(this);
  }

  void GoToCallScreen(BuildContext context, String PhoneNumber) {
    // ignore: unrelated_type_equality_checks
    if (isRegistered)
      // debugPrint('OK OK OK OK ===================');
      Navigator.push(context,
          MaterialPageRoute(
            builder: (context) =>
                callScreen(
                  PhoneNumber: PhoneNumber,

                  SipHelper: helper,),));
    else
      showInSnackBar('خط تلفن قطع می باشد، با پشتیبان تماس بگیرید');
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style:
        TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: "Yekan"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: new Scaffold(

          floatingActionButton: FloatingActionButton(
            child: new Column(
              children: <Widget>[
                Icon(Icons.call),
                Text('برنامه نویس', textScaleFactor: 0.7,)
              ],
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  callScreen(PhoneNumber: '09158259007',

                    SipHelper: helper,),));
            },
          ),


          key: _scaffoldKey,
          appBar: AppBar(
              title: new Row(
                children: <Widget>[
                  new Text('وضعیت خط تلفن'),
                  new Icon(
                    isRegistered ? Icons.phone_android : Icons.phonelink_erase,
                    color: isRegistered ? Colors.greenAccent : Colors.black26,
                  ),
                  Text('شماره دخلی:$_authorizationUser', textScaleFactor: 0.7,)
                ],
              )),
          body: new Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery.of(context).size.width,
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

            padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: new Column(
              children: <Widget>[
                new Container(
                  //height: 50,
                    color: Colors.black26,
                    child: new TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.white,),
                        hintText: 'جستجوی حامی',


                      ),

                      //controller: _searchController,
                      onChanged: (String value) {
                        setState(() {
                          _filter = value;
                        });
                      },
                    )),
                Expanded(
                  child: FutureBuilder<List<HamisInfo>>(
                    future: GetHamis(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var s = snapshot.data;

                        return ListView.builder(
                          itemCount: s.length,
                          itemBuilder: (context, index) {
                            if (_filter != null) {
                              return '${s[index].hamiLName}'
                                  .contains(_filter) ||
                                  '${s[index].hamiFName}'
                                      .contains(_filter) ||
                                  '${s[index].hamiMobile1}'
                                      .contains(_filter) ||
                                  '${s[index].hamiMobile2}'
                                      .contains(_filter)
                                  ?
                              new Container(
                                  decoration: new BoxDecoration(
                                    color: Colors.grey.shade200.withOpacity(
                                        0.3),
                                    borderRadius: new BorderRadius.circular(
                                        5.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  margin: EdgeInsets.all(4),
                                  child:
                                  new
                                  Column(
                                    children: <Widget>[
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                      children: <Widget>[
                                        new Container(

                                          child: new Text(
                                              '${s[index].hamiFName} ${s[index]
                                                  .hamiLName}'),

                                        ),

                                      ],
                                      ),
                                      Row(
                                        mainAxisAlignment: '${s[index]
                                            .hamiMobile2}' != ''
                                            ? MainAxisAlignment
                                            .spaceAround
                                            : MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              GoToCallScreen(
                                                  context, '${s[index]
                                                  .hamiMobile1}');
                                            },
                                            color: Colors.green,
                                            child: new Row(children: <Widget>[
                                              new Text('${s[index].hamiMobile1}',
                                                textScaleFactor: 0.9,),
                                              new Icon(Icons.phone)
                                            ],),
                                          ),
                                          '${s[index].hamiMobile2}' != ''
                                              ? FlatButton(
                                            onPressed: () {
                                              GoToCallScreen(
                                                  context, '${s[index]
                                                  .hamiMobile2}');
                                            },
                                            color: Colors.green,
                                            child: new Row(children: <Widget>[
                                              new Text('${s[index].hamiMobile2}',
                                                textScaleFactor: 0.9,),
                                              new Icon(Icons.phone)
                                            ],),
                                          )
                                              : Container(width: 0, height: 0,),

                                        ],
                                      )

                                    ],
                                  )
                              )

                                  : Container(
                                width: 0,
                                height: 0,
                              );
                            }
                            return
                              new Container(
                                  decoration: new BoxDecoration(
                                    color: Colors.grey.shade200.withOpacity(
                                        0.3),
                                    borderRadius: new BorderRadius.circular(
                                        5.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  margin: EdgeInsets.all(4),
                                  child:
                                  new
                                  Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          new Container(

                                            child: new Text(
                                                '${s[index]
                                                    .hamiFName} ${s[index]
                                                    .hamiLName}'),

                                          ),

                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: '${s[index]
                                            .hamiMobile2}' != ''
                                            ? MainAxisAlignment
                                            .spaceAround
                                            : MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              GoToCallScreen(
                                                  context, '${s[index]
                                                  .hamiMobile1}');
                                            },
                                            color: Colors.green,
                                            child: new Row(children: <Widget>[
                                              new Text(
                                                '${s[index].hamiMobile1}',
                                                textScaleFactor: 0.9,),
                                              new Icon(Icons.phone)
                                            ],),
                                          ),
                                          '${s[index].hamiMobile2}' != ''
                                              ? FlatButton(
                                            onPressed: () {
                                              GoToCallScreen(
                                                  context, '${s[index]
                                                  .hamiMobile2}');
                                            },
                                            color: Colors.green,
                                            child: new Row(children: <Widget>[
                                              new Text(
                                                '${s[index].hamiMobile2}',
                                                textScaleFactor: 0.9,),
                                              new Icon(Icons.phone)
                                            ],),
                                          )
                                              : Container(width: 0, height: 0,),

                                        ],
                                      )

                                    ],
                                  )
                              );
                          },
                        );
                      }
                      return new Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          child: new Column(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              new Text('در حال دریافت اطلاعات')
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )),
    );
  }

  @override
  void callStateChanged(CallState state) {
    setState(() {
      _callstate = state.state;
    });
    // TODO: implement callStateChanged
    if (state.state == CallStateEnum.STREAM) {
      _handelStreams(state);
    }
    switch (state.state) {
      case CallStateEnum.STREAM:
        {
          setState(() {
            _PhoneState = 'تماس برقرار است';
          });
          break;
        }
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.PROGRESS:
        {
          setState(() {
            _PhoneState = 'در حال برقراری تماس';
          });
          break;
        }
      case CallStateEnum.ENDED:
        {
          setState(() {
            _PhoneState = 'تماس پایان یافت';
          });
          break;
        }
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.ACCEPTED:
        {
          _PhoneState = 'تماس پاسخ داده شده است';
          break;
        }

      default:
        {
          setState(() {
            _PhoneState = '';
          });
        }
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registrationState = state;
      if (_registrationState.state == RegistrationStateEnum.REGISTERED)
        setState(() {
          isRegistered = true;
        });
      else if (_registrationState.state == RegistrationStateEnum.UNREGISTERED)
        setState(() {
          isRegistered = false;
        });
    });
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}
