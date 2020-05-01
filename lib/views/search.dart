

/*class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

String myName, myEmail, myAvatarUrl;

class _SearchState extends State<Search> {*/
/*  String searchString = "";*/
/* QuerySnapshot querySnapshot;

  bool isLoading = false;
*/
/* getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
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
  }*/

/*  getUserAvatar() async {
    myAvatarUrl = await Constants.getUserAvatarSharedPreference();
    myEmail = await Constants.getUserEmailSharedPreference();
    myName = await Constants.getUserNameSharedPreference();
    setState(() {});
  }

  Widget userList() {
    return isLoading ? Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(child: CircularProgressIndicator(),),
    ) : Container(
      child: querySnapshot != null
          ? ListView.builder(
              itemCount: querySnapshot.documents.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return userTile(
                  userEmail: querySnapshot.documents[index].data['email'],
                  userName: querySnapshot.documents[index].data['userName'],
                  userAvatarUrl:
                      querySnapshot.documents[index].data['avatarUrl'],
                );
              })
          : Container(),
    );
  }*/

/* Widget userTile({String userName, userEmail, String userAvatarUrl}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(8),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: Image.network(userAvatarUrl)),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              SizedBox(
                height: 2,
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
              if (userName != myName) {
                List<String> users = [myName, userName];

                List<String> avatarUrls = [myAvatarUrl, userAvatarUrl];

                List<int> unreadMessages = [0, 1];

                String chatRoomid =
                    getChatRoomId(userName, myName); // "$userName\_${myName}";

                /// Create Chat Room
                Map<String, dynamic> chatRoom = {
                  "users": users,
                  "avatarUrl": avatarUrls,
                  "lastmessage": "Hey",
                  "lastMessageSendBy": myName,
                  // TIME TODO
                  "unreadMessage": unreadMessages,
                  "chatRoomId": chatRoomid
                };

                bool canMessage;
                DatabaseMethods().addChatRoom(chatRoom, chatRoomid).then((val) {
                  canMessage =  val;
                  if (canMessage) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          */ /*
                                userName: userName, userAvatarUrl: userAvatarUrl, chatRoomid,messagesStream,*/ /*
                            builder: (context) => WebHome(
                              userName: userName,
                              userAvatarUrl: userAvatarUrl,
                                chatRoomId: chatRoomid,
                            )));
                  }
                });

                /// sending to chat

              } else {
                // TODO show snackbar you cannot send message to yourself
              }
            },
            child: Container(
                padding: EdgeInsets.all(12),
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
*/
/* @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: appBar(context),
          centerTitle: true,
          backgroundColor: Constants.colorPrimary,
          elevation: 0.0,
        ),
        backgroundColor: Constants.colorSecondary,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "search username ...",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 16),
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
              userList()
            ],
          ),
        ));
  }
}
*/
