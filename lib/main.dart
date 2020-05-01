import 'package:flutter/material.dart';
import 'package:flutterchat/helpers/authenticate.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/views/home_container.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await Constants.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterDevConnect',
      debugShowCheckedModeBanner: false,
      home: userIsLoggedIn != null ? userIsLoggedIn ? WebHome() : Authenticate() : Container(),
    );
  }
}
