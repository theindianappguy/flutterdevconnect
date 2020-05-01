import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/helpers/data.dart';
import 'package:flutterchat/services/auth.dart';
import 'package:flutterchat/services/database.dart';
import 'package:flutterchat/widgets/widgets.dart';

import 'home_container.dart';

String selectedAvatarUrl;

class SignUp extends StatefulWidget {
  final Function toogleView;

  SignUp({this.toogleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text feild
  bool _loading = false;
  String email = '', password = '', name = "";
  String error = '';

  List<String> avatarUrls = new List();

  @override
  void initState() {
    super.initState();

    avatarUrls = getAvatarUrls();
    avatarUrls.shuffle();
    selectedAvatarUrl = avatarUrls[0].toString();
  }

  Widget avatarTile(String avatarUrl, _SignUpState context, int index) {
    return GestureDetector(
      onTap: () {
        selectedAvatarUrl = avatarUrl;
        setState(() {});
      },
      child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(
            right: 14,
            left: index == 0 ? 30 : 0,
          ),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              border: selectedAvatarUrl == avatarUrl
                  ? Border.all(color: Color(0xff007EF4), width: 4)
                  : Border.all(color: Colors.transparent, width: 10),
              color: Colors.white,
              borderRadius: BorderRadius.circular(120)),
          child: kIsWeb
              ? Image.network(avatarUrl)
              : CachedNetworkImage(imageUrl: avatarUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Constants.colorPrimary));

    return Scaffold(
      backgroundColor: Constants.colorSecondary,
      appBar: appBarMain(context),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Container(
                    height: MediaQuery.of(context).size.height - 60,
                    padding: EdgeInsets.only(top: 30, bottom: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          margin: EdgeInsets.only(bottom: 40),
                          child: ListView.builder(
                              itemCount: avatarUrls.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return avatarTile(
                                    avatarUrls[index], this, index);
                              }),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width > 800
                              ? 400
                              : MediaQuery.of(context).size.width - 60,
                          child: Column(
                            children: <Widget>[
                              ///
                              TextFormField(
                                style: Constants.inputTextStyle(),
                                validator: (val) =>
                                    val.isEmpty ? "Enter an Name" : null,
                                decoration:
                                    Constants.themedecoration("username"),
                                onChanged: (val) {
                                  setState(() {
                                    name = val.toLowerCase();
                                  });
                                },
                              ),

                              SizedBox(
                                height: 8,
                              ),

                              TextFormField(
                                style: Constants.inputTextStyle(),
                                textCapitalization: TextCapitalization.none,
                                validator: (val) =>
                                    val.isEmpty ? "Enter an Email" : null,
                                decoration: Constants.themedecoration("email"),
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                style: Constants.inputTextStyle(),
                                validator: (val) => val.length > 6
                                    ? null
                                    : "Please Enter "
                                        "Password more than 6 character",
                                decoration:
                                    Constants.themedecoration("password"),
                                obscureText: true,
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      _loading = true;
                                    });

                                    await _authService
                                        .signUpWithEmailAndPassword(
                                            email, password)
                                        .then((value) {
                                      if (value != null) {
                                        /// uploading user info to Firestore
                                        Map<String, String> userInfo = {
                                          "userName": name,
                                          "email": email,
                                          "avatarUrl": selectedAvatarUrl,
                                        };
                                        DatabaseMethods()
                                            .addData(userInfo)
                                            .then((result) {});

                                        Constants
                                            .saveUserLoggedInSharedPreference(
                                                true);
                                        Constants.saveUserNameSharedPreference(
                                            name);
                                        print("$name username saved");
                                        Constants
                                            .saveUserAvatarSharedPreference(
                                                selectedAvatarUrl);
                                        print(
                                            "$selectedAvatarUrl user avatar saved");
                                        Constants.saveUserEmailSharedPreference(
                                            email);
                                        print("$email user email saved");

                                        setState(() {
                                          _loading = false;
                                        });

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WebHome()));
                                      }else{
                                        setState(() {
                                          _loading = false;
                                          error = "please supply a valid/another email";
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width > 800
                                      ? 400
                                      : MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 24),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      gradient: LinearGradient(
                                          colors: [
                                            const Color(0xff007EF4),
                                            const Color(0xff2A75BC)
                                          ],
                                          begin: FractionalOffset.topRight,
                                          end: FractionalOffset.bottomLeft)),
                                  child: Text(
                                    "Sign Up",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'OverpassRegular',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _authService.signInWithGoogle(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width > 800
                                      ? 400
                                      : MediaQuery.of(context).size.width - 60,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Text(
                                    "Sign Up with Google",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xff071930),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'OverpassRegular',
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                              Container(
                                child: error.isEmpty
                                    ? Container()
                                    : Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      error,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Already have and account?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'OverpassRegular',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        widget.toogleView();
                                      },
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'OverpassRegular',
                                          decoration: TextDecoration.underline,
                                        ),
                                      ))
                                ],
                              ),
                            ],
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
}
