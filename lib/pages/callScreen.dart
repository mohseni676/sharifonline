import 'dart:async';

import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sip_ua/sip_ua.dart';


class callScreen extends StatefulWidget {
  final SIPUAHelper SipHelper;
  final String PhoneNumber;


  const callScreen({Key key, this.SipHelper, this.PhoneNumber})
      : super(key: key);

  @override
  _callScreenState createState() => _callScreenState();
}

class _callScreenState extends State<callScreen>
    implements SipUaHelperListener {

  //PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK=32;
  bool _proximityValues = false;
  String _timeLabel = '00:00';
  Timer _timer;
  Widget callStatus = Container(
    height: 150,
    width: 180,
  );
  String _PhoneState = '';
  Widget _callButton;




  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream _localStream;
  MediaStream _remoteStream;

  SIPUAHelper get helper => widget.SipHelper;
  CallStateEnum _callstate = CallStateEnum.NONE;

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

  //بخش مربوط به عملیات قطع تماس
  void _handleHangup() {
    setState(() {
      if (_remoteStream != null)
        _remoteStream.getAudioTracks()[0].enableSpeakerphone(true);
      if (_localStream != null)
        _localStream.getAudioTracks()[0].enableSpeakerphone(true);
    });
    try {
      helper.hangup();
      debugPrint('==============Hangup=============');
    } catch (ex) {
      throw ex;
    }

    _timer.cancel();
  }

  Widget dialing = new Container(
    width: 180,
    height: 150,
    alignment: Alignment.center,
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(),
        Text('در حال برقراری تماس')
      ],
    ),
  );

  Widget accepted = new Container(
    width: 180,
    height: 150,
    alignment: Alignment.center,
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(FontAwesomeIcons.headphones),
          radius: 40,
        ),
        Text('تماس پاسخ داده شد')
      ],
    ),
  );

  @override
  deactivate() {
    super.deactivate();
    helper.removeSipUaHelperListener(this);
    _disposeRenderers();
  }

  //تنظیم و راه اندازی رندر صوت
  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer.initialize();
    }
  }

  //از بین بردن رندرهای صوت
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

  //ویجت انجام شماره گیری و برقراری تماس
  Widget _handleCall(BuildContext context) {
    var dest = widget.PhoneNumber;
    _startTimer();


    helper.call(dest, true);
    // _preferences.setString('dest', dest);
    return null;
  }

  //ایجاد کننده تایمر تماس
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      if (mounted) {
        this.setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer.cancel();
      }
    });
  }


  //برگشت به صفحه قبل
  void _backToDialPad() {
    _timer.cancel();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      _callButton = RaisedButton(

        child: new Text('شماره گیری ${widget.PhoneNumber}'),
        color: Colors.green,
        onPressed: () {
          _handleCall(context);
        },
        padding: EdgeInsets.fromLTRB(5, 45, 5, 45),
      );
    });

    proximityEvents.listen((ProximityEvent event) {
      setState(() {
        // event.getValue return true or false
        _proximityValues = event.getValue();
      });
    });


    _initRenderers();
    helper.addSipUaHelperListener(this);
//_startTimer();
  }


  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    return AbsorbPointer(
      absorbing: _proximityValues,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: new Text('تماس با ${widget.PhoneNumber}'),
              centerTitle: true,
            ),
            body:
            new Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //Text('${_proximityValues}'),
                    Container(
                      height: 200,
                      width: 200,
                    ),

/*
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text('وضعیت: ${_callstate}'),
                      ],
                    ),
*/

                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text('وضعیت: ${_PhoneState}'),
                      ],
                    ),

                    // new Text(_timeLabel),
                    _callButton,
/*
                    RaisedButton(
                      child: new Text('قطع تماس ${widget.PhoneNumber}'),
                      color: Colors.red,
                      onPressed: () {
                        _handleHangup();
                      },
                      padding: EdgeInsets.fromLTRB(5,15,5,15),



                    ),
*/

                  ],
                ),
              ),

            )
        ),
      )
      ,
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
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
        {
          setState(() {
            _callButton = RaisedButton(
              child: new Text('قطع تماس ${widget.PhoneNumber}'),
              color: Colors.red,
              onPressed: () {
                _handleHangup();
              },
              padding: EdgeInsets.fromLTRB(5, 45, 5, 45),


            );
          });
          break;
        }
      case CallStateEnum.ENDED:
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.FAILED:
        {
          setState(() {
            _callButton = RaisedButton(

              child: new Text('شماره گیری ${widget.PhoneNumber}'),
              color: Colors.green,
              onPressed: () {
                _handleCall(context);
              },
              padding: EdgeInsets.fromLTRB(5, 45, 5, 45),
            );
          });
          break;
        }

      default:
        {
          setState(() {
            _callButton = RaisedButton(

              child: new Text('شماره گیری ${widget.PhoneNumber}'),
              color: Colors.green,
              onPressed: () {
                _handleCall(context);
              },
              padding: EdgeInsets.fromLTRB(5, 45, 5, 45),
            );
          });
        }
    }
    switch (state.state) {
      case CallStateEnum.STREAM:
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
      case CallStateEnum.FAILED:
        {
          _PhoneState = 'تماس قطع شد';
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
    // TODO: implement registrationStateChanged
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}
