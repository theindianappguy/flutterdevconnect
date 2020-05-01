import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: appBar(context),
    backgroundColor: Color(0xff145C9E),
    elevation: 0.0,
    centerTitle: false,
    brightness: Brightness.dark,
  );
}

Widget appBar(BuildContext context) {
  return Image.asset(
    "assets/images/logo.png",
    height: 40,
  ) /* Text("Makemyquiz",
      style: TextStyle(
          fontFamily: 'OverpassRegular',
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: Colors.white))*/
      ;
}

Widget whiteButton(
    {@required String label,
    @required Function onTap,
    @required IconData buttonIconData,
    bool haveIcon}) {
  return Column(
    children: <Widget>[
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 220,
          padding: EdgeInsets.only(right: 30, top: 12, bottom: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(23),
                  bottomLeft: Radius.circular(23)),
              gradient: LinearGradient(
                  colors: [const Color(0x36FFFFFF), const Color(0x0FFFFFFF)],
                  begin: FractionalOffset.topLeft,
                  end: FractionalOffset.bottomRight)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                width: 8,
              ),
              (haveIcon ?? true)
                  ? Icon(
                      buttonIconData,
                      color: Colors.white,
                      size: 20,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 16,
      )
    ],
  );
}
