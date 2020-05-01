import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/helpers/authenticate.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/helpers/helper_functions.dart';
import 'package:flutterchat/helpers/responsive_widget.dart';
import 'package:flutterchat/helpers/theme.dart';
import 'package:flutterchat/models/home_container_model.dart';
import 'package:flutterchat/services/auth.dart';
import 'package:flutterchat/services/database.dart';
import 'package:flutterchat/services/search_service.dart';
import 'package:flutterchat/views/chatinfo.dart';

import 'conversation_screen.dart';

class WebHome extends StatefulWidget {
  final String userName;
  final String userAvatarUrl;
  final String chatRoomId;
  WebHome({this.userName, this.chatRoomId, this.userAvatarUrl});

  @override
  _WebHomeState createState() => _WebHomeState();
}

/// Defining some variable globally

HomeContainerModel homeContainerModel = new HomeContainerModel();
String _myName = "", _myAvatar = "";
String _myEmail = "";

///
Stream infoStream;

/// creating a chat stream to listen
Stream messagesStreamHome;

class _WebHomeState extends State<WebHome> {
  ///using key for scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ///

  ///
  Stream chats;

  @override
  void initState() {
    // messagesStreamHome = widget.messageStream;
    homeContainerModel.chatRoomIdGlobal = widget.chatRoomId;
    databaseMethods
        .getChats(homeContainerModel.chatRoomIdGlobal)
        .then((result) {
      messagesStreamHome = result;
      homeContainerModel.messagesStream = result;
      //print("${result.data.toString()} this shit is real");
      //homeContainerModel.userPicUrlGlobal =
    });

    getMyInfoAndChat();

    /// Stream
    if (infoStream == null) {
      infoStream =
          Stream<HomeContainerModel>.periodic(Duration(milliseconds: 100), (x) {
        //print("${homeContainerModel.chatRoomIdGlobal.toString()}");
        return homeContainerModel;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    infoStream = null;
    homeContainerModel.messagesStream = null;
    super.dispose();
  }

  getMyInfoAndChat() async {
    _myAvatar = await Constants.getUserAvatarSharedPreference();
    _myName = await Constants.getUserNameSharedPreference();
    _myEmail = await Constants.getUserEmailSharedPreference();
    //print("this is uservavatar $_myName");
    //print("Filling up some dat $_myName");
    DatabaseMethods().getUserChats(_myName).then((value) {
      chats = value;
      //if (!mounted) return;
      setState(() {});
    });
  }


  /// Scaffold..........................

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: infoStream,
      builder: (context, snapshot) {
        //print("${snapshot.data.userNameGlobal}");
        return snapshot.hasData ? SafeArea(
          child: Container(
            child: HomeContainerWidgets(),
          ),
        ) : Container();
      },
    );
  }

  Widget HomeContainerWidgets(){
    return ResponsiveWidget(
      /// Large Screen DONE
      largeScreen: Scaffold(
          key: _scaffoldKey,
          backgroundColor: MyThemeData.backgroundColor,
          drawer: Drawer(child: menu(context: context)),
          endDrawer: Drawer(
            child: ChatInfo(
              userName: homeContainerModel.userNameGlobal,
              userImageUrl: homeContainerModel.userPicUrlGlobal,
              chatRoomId: homeContainerModel.chatRoomIdGlobal,
              height: MediaQuery.of(context).size.height,
              myName: _myName,
              //userEmail: widget.email,
            ),
          ),
          body: _myAvatar == null
              ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : ItsLargeHome(
            chats: chats,
            userName: homeContainerModel.userNameGlobal,
            userPicUrl: homeContainerModel.userPicUrlGlobal,
            chatRoomId: homeContainerModel.chatRoomIdGlobal,
            scaffoldKey: _scaffoldKey,
          )),
      smallScreen: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: MyThemeData.backgroundColor,
        drawer: Drawer(child: menu(context: context)),
        endDrawer: Drawer(
          child: ChatInfo(
            userName: homeContainerModel.userNameGlobal,
            userImageUrl: homeContainerModel.userPicUrlGlobal,
            chatRoomId: homeContainerModel.chatRoomIdGlobal,
            myName: _myName,
            height: MediaQuery.of(context).size.height - 24,
            //userEmail: widget.email,
          ),
        ),
        body: _myAvatar == null
            ? Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Stack(
          children: <Widget>[
            homeContainerModel.isChatSelected
                ? Container()
                : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Home(
                    context: context,
                    width: MediaQuery.of(context).size.width,
                    chats: chats,
                    homeScaffoldKey: _scaffoldKey)),
            homeContainerModel.isChatSelected
                ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ConversationScreen(
                  width: MediaQuery.of(context).size.width,
                  name: homeContainerModel.userNameGlobal,
                  profilePicUrl:
                  homeContainerModel.userPicUrlGlobal,
                  chatRoomid:
                  homeContainerModel.chatRoomIdGlobal,
                  messagesStream:
                  homeContainerModel.messagesStream,
                  myNameFinal: _myName,
                  myEmail: _myEmail,
                  myAvatarFinal: _myAvatar,
                  scaffoldKey: _scaffoldKey,
                ))
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget menu({context, double menuWidth}) {
    return Container(
      decoration: BoxDecoration(color: Color(0xff1C1B1B)),
      width: menuWidth ?? MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 60,
          ),
          Container(
              padding: EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              ? Image.network(_myAvatar)
                              : CachedNetworkImage(imageUrl: _myAvatar))),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    _myName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    _myEmail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'OverpassRegular',
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {

            },
            child: Container(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    "assets/images/home.png",
                    height: 18,
                    width: 18,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: (){
              HelperFunctions.launchURL("https://sanskartiwari26.web.app/");
            },
            child: Opacity(
              opacity: 0.8,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/github.png",
                      height: 18,
                      width: 18,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Github",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: (){
              HelperFunctions.launchURL("https://sanskartiwari26.web.app/");
            },
            child: Opacity(
              opacity: 0.8,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/info.png",
                      height: 18,
                      width: 18,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "About Dev",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Opacity(
            opacity: 0.8,
            child: Container(
              padding: EdgeInsets.only(left: 14),
              child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 34, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          const Color(0xff007EF4),
                          const Color(0xff2A75BC)
                        ],
                        begin: FractionalOffset.topRight,
                        end: FractionalOffset.bottomLeft),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/coin.png",
                      height: 18,
                      width: 18,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Donate",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Constants.saveUserLoggedInSharedPreference(false);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Opacity(
              opacity: 0.8,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/logout.png",
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}

String getAvatarUrlOfOther(List<dynamic> avatarUrl) {
  if (avatarUrl[0] == _myAvatar) {
    return avatarUrl[1];
  } else {
    return avatarUrl[0];
  }
}

class Home extends StatefulWidget {
  final BuildContext context;
  final double width;
  Stream chats;
  final GlobalKey<ScaffoldState> homeScaffoldKey;

  Home(
      {@required this.context,
      @required this.width,
      @required this.chats,
      @required this.homeScaffoldKey});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchString = "";
  QuerySnapshot querySnapshot;
  bool isLoading = false;

  QuerySnapshot usersSnapshot;


  getRecentMembers() {
    DatabaseMethods().getRecentUsers().then((snapshot) {
      print(snapshot.documents[0].data['userName'].toString()+"this is awesome");
      setState(() {
        usersSnapshot = snapshot;
      });
    });
  }

  initiateSearch() {
    getUserAvatar();

    setState(() {
      isLoading = true;
    });
    print("initiated the search with : $searchString");
    setState(() {
      isLoading = true;
    });

    SearchService().searchByName(searchString).then((result) {
      setState(() {
        querySnapshot = result;
        print("${querySnapshot.documents.length}");
        print(("this is ${querySnapshot.documents[0].toString()}"));
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  getUserAvatar() async {
    //_myAvatarUrl = await Constants.getUserAvatarSharedPreference();
    _myEmail = await Constants.getUserEmailSharedPreference();
    _myName = await Constants.getUserNameSharedPreference();
    setState(() {});
  }

  Widget recentUserList(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 30,),
        Container(
          padding: EdgeInsets.symmetric(horizontal:  16),
          child: Text(
            "Recent Members of FlutterDevConnect",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'OverpassRegular',
            ),
          ),
        ),
        Container(
          child: usersSnapshot != null
              ? ListView.builder(
              itemCount: usersSnapshot.documents.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return userTile(
                  userEmail: usersSnapshot.documents[index].data['email'],
                  userName:
                  usersSnapshot.documents[index].data['userName'],
                  userAvatarUrl:
                  usersSnapshot.documents[index].data['avatarUrl'],
                );
              })
              : Container(),
        ),
      ],
    );
  }

  Widget userList() {
    return isLoading
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            child: querySnapshot != null
                ? ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return userTile(
                        userEmail: querySnapshot.documents[index].data['email'],
                        userName:
                            querySnapshot.documents[index].data['userName'],
                        userAvatarUrl:
                            querySnapshot.documents[index].data['avatarUrl'],
                      );
                    })
                : Container(),
          );
  }

  @override
  void initState() {
    getRecentMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff1F1F1F),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                color: Color(0xff145C9E),
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                width: widget.width ?? 300,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.homeScaffoldKey.currentState.openDrawer();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          )),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        homeContainerModel.isSearching =
                            !homeContainerModel.isSearching;
                        /* Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Search()));*/
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            homeContainerModel.isSearching
                                ? "Cancel"
                                : "Find Dev",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "OverpassRegular",
                                fontSize: 15),
                          )),
                    ),
                  ],
                ),
              ),
              homeContainerModel.isSearching
                  ? Container(
                  width: MediaQuery.of(context).size.width > 800 ? 300 : MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        decoration: BoxDecoration(
                          color: Color(0x54FFFFFF),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 16),
                                child: TextField(
                                  // controller: textController,
                                  onChanged: (val) {
                                    searchString = val;
                                  },
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "search username ...",
                                    hintStyle: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                              onTap: () {
                                initiateSearch();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                child: Image.asset(
                                  "assets/images/search_white.png",
                                  width: 25,
                                  height: 25,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color(0x36FFFFFF),
                                          const Color(0x0FFFFFFF)
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight)),
                                padding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ),

                      /// List.....
                      userList(),
                      recentUserList()
                    ],
                  ),
                    )
                  : Container(
                      // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      height: MediaQuery.of(context).size.height - 56,
                      child: widget.chats != null
                          ? StreamBuilder(
                              stream: widget.chats,
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.documents.length,
                                        itemBuilder: (context, index) {
                                          return ChatTile(
                                            userName: Constants
                                                .makeFirstLetterUpperCase(snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["chatRoomId"]
                                                    .toString()
                                                    .replaceAll("_", "")
                                                    .replaceAll(_myName, "")),
                                            userPicUrl: getAvatarUrlOfOther(
                                                snapshot.data.documents[index]
                                                    .data["avatarUrl"]),
                                            lastMessage: snapshot
                                                .data
                                                .documents[index]
                                                .data["lastmessage"],
                                            timestamp: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["timestamp"] ??
                                                "NA",
                                            //TODO
                                            unreadMessages: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["unreadMessages"] ??
                                                0,
                                            lastMessageSendBy: snapshot
                                                .data
                                                .documents[index]
                                                .data["lastMessageSendBy"],
                                            chatRoomId: snapshot
                                                .data
                                                .documents[index]
                                                .data["chatRoomId"],
                                            width: widget.width,
                                          );
                                        })
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                              },
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget userTile({String userName, userEmail, String userAvatarUrl}) {
  return Container(
    width: 300,
    margin: EdgeInsets.symmetric(vertical: 12),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Image.network(userAvatarUrl)),
        SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              userName,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            Text(
              userEmail,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () async {
            if (userName != _myName) {
              List<String> users = [_myName, userName];

              List<String> avatarUrls = [_myAvatar, userAvatarUrl];

              List<int> unreadMessages = [0, 1];

              String chatRoomid =
                  getChatRoomId(userName, _myName); // "$userName\_${myName}";

              /// Create Chat Room
              Map<String, dynamic> chatRoom = {
                "users": users,
                "avatarUrl": avatarUrls,
                "lastmessage": "Hey",
                "lastMessageSendBy": _myName,
                'timestamp': Timestamp.now(),
                "unreadMessage": unreadMessages,
                "chatRoomId": chatRoomid
              };

              bool canMessage;
              DatabaseMethods().addChatRoom(chatRoom, chatRoomid).then((val) {
                canMessage = val;
                if (canMessage) {
                  homeContainerModel.chatRoomIdGlobal = chatRoomid;
                  databaseMethods.getChats(chatRoomid).then((result) {
                    messagesStreamHome = result;
                    homeContainerModel.messagesStream = result;
                    homeContainerModel.isSearching = false;

                    /// setting up the profile pic name and email
                    homeContainerModel.userPicUrlGlobal = userAvatarUrl;
                    homeContainerModel.userNameGlobal = userName;
                    homeContainerModel.userEmailGlobal = userEmail;

                    print(
                        "${homeContainerModel.messagesStream}   $messagesStreamHome");
                    homeContainerModel.isChatSelected = true;
                  });
                  /* Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        */ /*
                                userName: userName, userAvatarUrl: userAvatarUrl, chatRoomid,messagesStream,*/ /*
                          builder: (context) => WebHome(
                            userName: userName,
                            userAvatarUrl: userAvatarUrl,
                            chatRoomId: chatRoomid,
                          )));*/
                }
              });

              /// sending to chat

            } else {
              // TODO show snackbar you cannot send message to yourself
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Constants.colorAccent,
                  borderRadius: BorderRadius.circular(40)),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white),
              )),
        )
      ],
    ),
  );
}

void _moreOptionBottomSheet(
    {@required BuildContext context, @required String chatRoomId}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.only(bottom: 36),
          child: new Wrap(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Text(
                    "More Options..",
                    style: TextStyle(fontSize: 16),
                  )),
              ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(
                    'Delete Chat',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    databaseMethods.removeChatRoom(chatRoomId);
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

class ChatTile extends StatelessWidget {
  final String userName, userPicUrl, lastMessage, chatRoomId;
  final Timestamp timestamp;
  final int unreadMessages;

  // provide 0
  final String lastMessageSendBy;
  final double width;

  // provide false

  ChatTile(
      {this.userName,
      this.userPicUrl,
      this.lastMessage,
      this.timestamp,
      this.unreadMessages,
      this.lastMessageSendBy,
      this.chatRoomId,
      @required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _moreOptionBottomSheet(context: context, chatRoomId: chatRoomId);
      },
      onTap: () {
        homeContainerModel.isChatSelected = true;
        homeContainerModel.userNameGlobal = userName;
        homeContainerModel.userPicUrlGlobal = userPicUrl;
        homeContainerModel.chatRoomIdGlobal = chatRoomId;
        databaseMethods.getChats(chatRoomId).then((result) {
          messagesStreamHome = result;
          homeContainerModel.messagesStream = result;

          /// setting up the profile pic name and email
          homeContainerModel.userPicUrlGlobal = userPicUrl;
          homeContainerModel.userNameGlobal = userName;
          // homeContainerModel.userEmailGlobal = userEmail;
        });

        /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(userName, userPicUrl, chatRoomId)));*/
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        color: homeContainerModel.chatRoomIdGlobal == chatRoomId
            ? Colors.black26
            : Colors.transparent,
        width: width ?? MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(2),

                decoration: BoxDecoration(
                    border:
                        /*selectedAvatarUrl == avatarUrl
                        ?*/
                        Border.all(color: Colors.white, width: 0.7)
                    /* : Border.all(color: Colors.transparent, width: 10)*/,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: kIsWeb
                        ? Image.network(userPicUrl,height: 40,
                      width: 40,)
                        : CachedNetworkImage(imageUrl: userPicUrl,height: 40,
                      width: 40,))),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  width: (width ?? MediaQuery.of(context).size.width) - 80,
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        userName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      unreadMessages > 0
                          ? Row(
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Constants.colorAccent,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  "$unreadMessages",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'OverpassRegular',
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Spacer(),
                      Text(
                        Constants.timeAgoSinceDate(
                            DateTime.fromMillisecondsSinceEpoch(
                                    timestamp.millisecondsSinceEpoch)
                                .toIso8601String())
                        /*timeago.format(DateTime.
                        fromMillisecondsSinceEpoch(timestamp.nanoseconds),allowFromNow: true)*/
                        ,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'OverpassRegular',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    lastMessageSendBy == _myName
                        ? Row(
                            children: <Widget>[
                              Image.asset(
                                "assets/images/back_arrow.png",
                                width: 14,
                                height: 14,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          )
                        : Container(),
                    Container(
                      width: (width ?? MediaQuery.of(context).size.width) - 158,
                      child: Text(
                        lastMessage,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              unreadMessages > 0 ? Colors.white : Colors.white,
                          fontFamily: 'OverpassRegular',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 14,
                ),
                Container(
                  width: (width ?? MediaQuery.of(context).size.width) - 80,
                  height: 0.4,
                  color: Colors.white70,
                ),
                SizedBox(
                  height: 8,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ItsLargeHome extends StatefulWidget {
  final Stream chats;
  final String userName;
  final String userPicUrl;
  final String chatRoomId;
  final scaffoldKey;

  ItsLargeHome(
      {@required this.chats,
      @required this.chatRoomId,
      @required this.userPicUrl,
      @required this.userName,
      @required this.scaffoldKey});

  @override
  _ItsLargeHomeState createState() => _ItsLargeHomeState();
}

class _ItsLargeHomeState extends State<ItsLargeHome> {
  @override
  Widget build(BuildContext context) {
    /*  databaseMethods.getChats(widget.chatRoomId).then((result) {
          messagesStreamHome = result;
          /// setting up the profile pic name and email
          homeContainerModel.userPicUrlGlobal = widget.userPicUrl;
          homeContainerModel.userNameGlobal = widget.userName;
          // homeContainerModel.userEmailGlobal = userEmail;
          setState(() {});
        });*/
    return Row(
      children: <Widget>[
        Expanded(
            child: Home(
                context: context,
                width: 300,
                chats: widget.chats,
                homeScaffoldKey: widget.scaffoldKey)),
        homeContainerModel.isChatSelected
            ? ConversationScreen(
                width: MediaQuery.of(context).size.width - 300,
                name: homeContainerModel.userNameGlobal,
                profilePicUrl: homeContainerModel.userPicUrlGlobal,
                chatRoomid: homeContainerModel.chatRoomIdGlobal,
                messagesStream: homeContainerModel.messagesStream,
                myNameFinal: homeContainerModel.userNameGlobal,
                //TODO
                myEmail: "somethingrandomdoupdate@gmail.com",
                myAvatarFinal: homeContainerModel.userPicUrlGlobal,
                scaffoldKey: widget.scaffoldKey,
              )
            : Container(
                width: kIsWeb ? MediaQuery.of(context).size.width - 300 : 0,
              ),
      ],
    );
  }
}
