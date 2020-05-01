import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/views/conversation_screen.dart';
import 'package:flutterchat/widgets/widgets.dart';

class ChatInfo extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String chatRoomId;
  final String myName;
  final double height;
  //final String userEmail;
  ChatInfo(
      {@required this.userName,
      @required this.userImageUrl,
      @required this.chatRoomId,
      @required this.myName,
      @required this.height
      /* this.userEmail*/
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color(0xff1C1B1B)),
            height: height ?? MediaQuery.of(context).size.height,
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: 60,
                ),
                Container(
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 34,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Constants.colorAccent, width: 2),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(120)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: kIsWeb
                                    ? Image.network(userImageUrl)
                                    : CachedNetworkImage(
                                        imageUrl: userImageUrl))),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          userName,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Random@gmail.com",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 40,
                ),
                whiteButton(
                    label: "Block Messages",
                    onTap: () {
                      Map<String, String> blockData = {
                        "id": getChatRoomId(
                            userName.toLowerCase(), myName.toLowerCase())
                      };
                      databaseMethods.blockUser(
                          userName: userName, blockInfo: blockData);
                      databaseMethods.removeChatRoom(chatRoomId);
                      Navigator.pop(context);
                    },
                    buttonIconData: Icons.block),
                whiteButton(
                    label: "Delete Messages",
                    onTap: () {
                      databaseMethods.removeChatRoom(chatRoomId);
                      Navigator.pop(context);
                    },
                    buttonIconData: Icons.delete),
                Spacer(),
                SizedBox(
                  height: 80,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
