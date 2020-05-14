import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_ip/get_ip.dart';
import 'package:http/http.dart' as http;
import 'package:sharifonline/classes/madadkar.dart';
import 'package:sharifonline/globals.dart';
import 'package:sharifonline/pages/mainScreen.dart';
import 'package:sharifonline/style/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //SharedPreferences prefs = await SharedPreferences.getInstance();
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginUsernameController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool checkValue = false;
  SharedPreferences sharedPreferences;

  bool _obscureTextLogin = true;

  _onChanged(bool value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkValue = value;
      sharedPreferences.setBool("check", checkValue);
      sharedPreferences.setString("username", loginUsernameController.text);
      sharedPreferences.setString("password", loginPasswordController.text);
      //  sharedPreferences.commit();
      getCredential();
    });
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkValue = sharedPreferences.getBool("check");
      if (checkValue != null) {
        if (checkValue) {
          loginUsernameController.text =
              sharedPreferences.getString("username");
          loginPasswordController.text =
              sharedPreferences.getString("password");
        } else {
          loginUsernameController.text = "";
          loginPasswordController.text = "";
          sharedPreferences.remove("username");
          sharedPreferences.remove("password");
          //sharedPreferences.remove("username");

        }
      } else {
        checkValue = false;
      }
    });
  }



  Future<void> loginToSystem() async {
    var result = await http.post(ServerUrl + 'token',
        body: {
          'grant_type': 'password',
          'username': loginUsernameController.text,
          'password': loginPasswordController.text
        }
    );
    if (result.statusCode == 200) {
      //debugPrint('${result.body}');
      var jResult = json.decode(result.body);
      sharedPreferences = await SharedPreferences.getInstance();
      //debugPrint(jResult['access_token']);
      sharedPreferences.setString('token', jResult['access_token']);
      //debugPrint(prefs.get('token'));
      //http.post(ServerUrl+'')
      madadkarInfo info = await getMadadkarInfo();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => mainPage(madadkar: info,),));
    } else {
      showInSnackBar('نام کاربری یا رمز عبور اشتباه است');
    }
  }

  Future<madadkarInfo> getMadadkarInfo() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var ip = await GetIp.ipAddress;
    sharedPreferences.setString('IpAddress', ip);
    var result = await http.post(ServerUrl + 'api/Madadkar/GetMadadkarInfo',
        headers: {
          'Authorization': 'Bearer ' + sharedPreferences.getString('token')
        }
    );
    if (result.statusCode == 200) {
      var jResult = json.decode(result.body);
      return madadkarInfo.fromJson(jResult);
    }
  }


  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: new Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 775.0
                  ? MediaQuery.of(context).size.height
                  : 775.0,
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: new Image(
                        width: 250.0,
                        height: 191.0,
                        fit: BoxFit.fitHeight,
                        image: new AssetImage('assets/images/Mini-Logo.png')),
                  ),
                  new Text('بنیاد خیریه نیکوکاران شریف', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                    textScaleFactor: 1.8,),
                  Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white,
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    width: 100.0,
                    height: 1.0,
                    margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  ),
                  new Text('مددکار آنلاین-نسخه 1.01', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                      textScaleFactor: 0.9),
                  Expanded(
                    flex: 2,
                    child: new ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: _buildSignIn(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //super.initState();
    getCredential();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //loginPasswordController.text = '48067';
    //loginUsernameController.text = '09378170204';


    //_pageController = PageController();
  }

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

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginUsernameController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "Yekan",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.userCircle,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "نام کاربری",
                            hintStyle:
                            TextStyle(fontFamily: "Yekan", fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(
                              fontFamily: "Yekan",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "رمز عبور",
                            hintStyle:
                            TextStyle(fontFamily: "Yekan", fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 170.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: Theme.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: new LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientEnd,
                          Theme.Colors.loginGradientStart
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Theme.Colors.loginGradientEnd,
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 42.0),
                        child: Text(
                          "ورود",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontFamily: "Yekan"),
                        ),
                      ),
                      onPressed: () {
                        if (loginUsernameController.text.isEmpty) {
                          showInSnackBar('نام کاربری را وارد کنید');
                          return;
                        }
                        if (loginPasswordController.text.isEmpty) {
                          showInSnackBar('رمز عبور را وارد کنید');
                        }
                        loginToSystem();
                      }
                    // showInSnackBar("کلید ورود فشرده شد")),
                  )),

            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: checkValue,
                onChanged: _onChanged,

              ),
              Text('ذخیره اطلاعات ورود')
            ],
          )
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }


}
