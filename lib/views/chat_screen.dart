/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterchat/helpers/authenticate.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/helpers/responsive_widget.dart';
import 'package:flutterchat/helpers/theme.dart';
import 'package:flutterchat/services/auth.dart';
import 'package:flutterchat/services/database.dart';
import 'package:flutterchat/views/conversation_screen.dart';
import 'package:flutterchat/views/search.dart';
import 'package:flutterchat/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  int tabSelected = 3;

  bool iAmNo1;
  bool menuCollapsed = true;

  double screenWidth, screenHeight;


  final Duration duration = const Duration(milliseconds: 300);





  getChats() async {
    /// Filling up some data ///
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Constants.colorPrimary,
      statusBarBrightness: Brightness.dark,
    ));
    return ResponsiveWidget(
      smallScreen: Scaffold(
        key: _scaffoldKey,
        backgroundColor: MyThemeData.backgroundColor,
        drawer: Drawer(child: menu(context:context)),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.openDrawer();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.menu)),
          ),
          title: appBar(context),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Search()));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset(
                    "assets/images/search_grey.png",
                    height: 20,
                    width: 20,
                  )),
            )
          ],
          backgroundColor: Color(0xff1F1F1F),
          elevation: 0.0,
        ),
        body: _myAvatar == null
            ? Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Stack(
          children: <Widget>[home(contex: context)],
        ),
      ),
    );
  }

}



*/
