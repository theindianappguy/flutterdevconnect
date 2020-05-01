import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterchat/helpers/authenticate.dart';
import 'package:flutterchat/helpers/constants.dart';
import 'package:flutterchat/models/conversation_model.dart';
import 'package:flutterchat/models/gif_model.dart';
import 'package:flutterchat/services/auth.dart';
import 'package:flutterchat/services/database.dart';
import 'package:flutterchat/views/home_container.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class ConversationScreen extends StatefulWidget {
  final String name,
      profilePicUrl /*, email*/,
      chatRoomid,
      myNameFinal,
      myEmail,
      myAvatarFinal;
      double width;
  Stream messagesStream;
  GlobalKey<ScaffoldState> scaffoldKey;

  ConversationScreen(
      {this.name,
      this.profilePicUrl,
      this.chatRoomid
      /*, this.email*/,
      this.messagesStream,
      @required this.myAvatarFinal,
      @required this.myNameFinal,
      @required this.myEmail,
      @required this.scaffoldKey,
      @required this.width});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

/// Selected Image
File _selectedImage;

bool selectGif = false;

bool isImageUploading = false;

DatabaseMethods databaseMethods = new DatabaseMethods();

bool isGifLoading = true;

String _myName /*, _myEmail, _myAvatarUrl*/;

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  int tabSelected = 3;
  bool moreOptions = false;

  //List<ConversationModel> conversations = new List<ConversationModel>();

  AnimationController _anglecontroller;
  var angle = 0.0;

  var textController = new TextEditingController();

  showColorAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Pick a colour for this conversation"),
      content: Column(
        children: <Widget>[
          Text("Everyone in this conversation will see this"),
        ],
      ),
      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String myAwesomeMessage = "";

  Image pickedImage;

  /// emojis
  List<String> emojis = new List();

  /// added to make the screen scrool till the last message
  ScrollController _scrollController = new ScrollController();

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.linear);
  }

/*
  Future getImageFromWeb() async{
    Image fromPicker = await ImagePickerWeb.getImage(outputType: ImageType.widget);

    if (fromPicker != null) {
      pickedImage = fromPicker;
      _selectedWebImage =
      await ImagePickerWeb.getImage(outputType: ImageType.file);
      setState(() {

      });
    }
  }
*/

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selectedImage = image;
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = image;
    });
  }

  @override
  void initState() {
    ///

    _anglecontroller = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );

    _anglecontroller.addListener(() {
      setState(() {
        angle = _anglecontroller.value;
      });
    });

    /// adding first message
    //addMessage("Hi");
    getMyInfo();
    databaseMethods.getChats(widget.chatRoomid).then((result) {
      widget.messagesStream = result;
      setState(() {});
    });
    //print(conversations.toString() + "data");
    super.initState();
  }

  getMyInfo() async {
    //_myEmail = await Constants.getUserEmailSharedPreference();
    _myName = await Constants.getUserNameSharedPreference();
    setState(() {});
  }

  @override
  void dispose() {
    _anglecontroller.dispose();
    _selectedImage = null;
    selectGif = false;
    isImageUploading = false;
    super.dispose();
  }

  Widget chatList() {
    return SingleChildScrollView(
      child: Container(
        child: widget.messagesStream != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: widget.messagesStream,
                    builder: (context, snapshot) {
                      return snapshot.data != null
                          ? ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              controller: _scrollController,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ConversationTile(
                                  sendByMe: snapshot.data.documents[index]
                                          .data["sendBy"] ==
                                      _myName,
                                  message: snapshot
                                      .data.documents[index].data["message"],
                                  profilePic: widget.profilePicUrl,
                                  messageImgUrl: snapshot
                                      .data.documents[index].data["imgUrl"],
                                  bottomMargin: index ==
                                      snapshot.data.documents.length - 1,
                                  messageId: snapshot
                                      .data.documents[index].data["messageId"],
                                  chatRoomId: widget.chatRoomid,
                                );
                              })
                          : Container();
                    },
                  )
                ],
              )
            : Container(
                height: MediaQuery.of(context).size.height / 2,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  addMessage(String mesage) async {
    String messageId = randomAlphaNumeric(9);

    setState(() {
      isImageUploading = true;
    });

    var downloadUrl;

    if ((_selectedImage) != null) {
// uploading image  to firebase storage
      StorageReference blogImagesStorageReference = FirebaseStorage.instance
          .ref()
          .child("chatImages")
          .child("${randomAlphaNumeric(10)}.jpg");

      final StorageUploadTask task =
          blogImagesStorageReference.putFile(_selectedImage);

      downloadUrl = await (await task.onComplete).ref.getDownloadURL();

      print(" $downloadUrl");
    }

    Map<String, dynamic> messageData = {
      "sendBy": await Constants.getUserNameSharedPreference(),
      "message": mesage,
      "time": DateTime.now().millisecondsSinceEpoch,
      "messageId": messageId,
      "imgUrl": _selectedImage != null ? downloadUrl : ""
    };

    /// update last message send
    Map<String, dynamic> chatRoomUpdate = {
      "lastmessage": mesage,
      "lastMessageSendBy": _myName,
      'timestamp': Timestamp.now()
    };

    /// ...............

    DatabaseMethods()
        .addMessage(widget.chatRoomid, messageData, messageId, chatRoomUpdate);

    ConversationModel conversatModel3 = new ConversationModel();
    conversatModel3.setMessage(mesage);
    conversatModel3.setSendByMe(true);
    //conversations.add(conversatModel3);
    FocusScope.of(context).unfocus();
    databaseMethods.getChats(widget.chatRoomid).then((result) {
      setState(() {
        widget.messagesStream = result;
      });
    });

    setState(() {
      textController.text = "";
      _selectedImage = null;
      isImageUploading = false;
    });

   // _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark,
    ));

    return Stack(
      children: [
        Column(
          children: <Widget>[
            Container(
              height: 60,
              color: Color(0xff145C9E),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              width: widget.width ?? MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  GestureDetector(
                          onTap: () {
                            homeContainerModel.isChatSelected = false;
                            /* Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Search()));*/
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child:Icon(
                                kIsWeb
                                    ?  Icons.arrow_back
                                : Platform.isAndroid
                                    ? Icons.arrow_back
                                    : Icons.arrow_back_ios,
                                color: Colors.white,
                              )),
                        ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      widget.scaffoldKey.currentState.openEndDrawer();
                      /* Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Search()));*/
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              color: Constants.colorSecondary,
              width: widget.width ?? MediaQuery.of(context).size.width,
              height: kIsWeb
                  ? MediaQuery.of(context).size.height - 60
                  : MediaQuery.of(context).size.height - 84,
              child: Stack(
                children: <Widget>[
                  chatList(),
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 0,
                    right: 0,
                    child: Container(
                      child: selectGif ?? false
                          ? Stack(
                              children: <Widget>[
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                      color: Constants.colorSecondary,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          topLeft: Radius.circular(16))),
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                      color: Color(0x54FFFFFF),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          topLeft: Radius.circular(16))),
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  height: 250,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0x54FFFFFF),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            topLeft: Radius.circular(16))),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 14, right: 16, left: 16),
                                          child: Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectGif = false;
                                                  });
                                                },
                                                child: Transform.rotate(
                                                  angle: pi / 4,
                                                  child: Container(
                                                    child: Image.asset(
                                                      "assets/images/add_solid.png",
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        gradient: LinearGradient(
                                                            colors: [
                                                              const Color(
                                                                  0x36FFFFFF),
                                                              const Color(
                                                                  0x0FFFFFFF)
                                                            ],
                                                            begin:
                                                                FractionalOffset
                                                                    .topLeft,
                                                            end: FractionalOffset
                                                                .bottomRight)),
                                                    padding: EdgeInsets.all(10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 16),
                                                  child: TextField(
                                                    onChanged: (val) {
                                                      getSearch(val);
                                                    },
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Search Gif",
                                                      hintStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'OverpassRegular',
                                                          fontSize: 15),
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 0.4,
                                        ),
                                        SizedBox(
                                          height: 24,
                                        ),
                                        isGifLoading
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : Container(
                                                height: 150,
                                                child: ListView.builder(
                                                    itemCount:
                                                        gifmodel.data.length,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                          onTap: () {
                                                            sendGif(gifmodel
                                                                .data[index]
                                                                .images
                                                                .original
                                                                .url);
                                                            setState(() {
                                                              selectGif = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 8),
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                child: Image.network(
                                                                    gifmodel
                                                                        .data[
                                                                            index]
                                                                        .images
                                                                        .original
                                                                        .url)),
                                                          ));
                                                    }),
                                              )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                moreOptions ?? false
                                    ? Stack(
                                        children: <Widget>[
                                          Stack(
                                            children: <Widget>[
                                              Container(
                                                height: 116,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                      color: Constants
                                                          .colorSecondary,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(16),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      16))),
                                                ),
                                              ),
                                              Container(
                                                height: 116,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0x54FFFFFF),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(16),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      16))),
                                                  padding: EdgeInsets.only(
                                                      top: 14,
                                                      bottom: 12,
                                                      right: 16,
                                                      left: 16),
                                                  child: Row(
                                                    children: <Widget>[
                                                      kIsWeb
                                                          ? Container()
                                                          : GestureDetector(
                                                        onTap: () {
                                                          getImageFromGallery();
                                                        },
                                                        child: Container(
                                                          child: Image.asset(
                                                            "assets/images/gallery.png",
                                                            width: 25,
                                                            height: 25,
                                                          ),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    const Color(
                                                                        0x36FFFFFF),
                                                                    const Color(
                                                                        0x0FFFFFFF)
                                                                  ],
                                                                  begin: FractionalOffset
                                                                      .topLeft,
                                                                  end: FractionalOffset
                                                                      .bottomRight)),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                        ),
                                                      ),
                                                      kIsWeb
                                                          ? Container()
                                                          : SizedBox(
                                                        width: 16,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectGif = true;
                                                            getTrending();
                                                          });
                                                        },
                                                        child: Container(
                                                          child: Image.asset(
                                                            "assets/images/gif.png",
                                                            width: 25,
                                                            height: 25,
                                                          ),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                              gradient: LinearGradient(
                                                                  colors: [
                                                                    const Color(
                                                                        0x36FFFFFF),
                                                                    const Color(
                                                                        0x0FFFFFFF)
                                                                  ],
                                                                  begin: FractionalOffset
                                                                      .topLeft,
                                                                  end: FractionalOffset
                                                                      .bottomRight)),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 16,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          getImageFromCamera();
                                                        },
                                                        child: kIsWeb
                                                            ? Container()
                                                            : Container(
                                                                child:
                                                                    Image.asset(
                                                                  "assets/images/camera.png",
                                                                  width: 25,
                                                                  height: 25,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    gradient: LinearGradient(
                                                                        colors: [
                                                                          const Color(
                                                                              0x36FFFFFF),
                                                                          const Color(
                                                                              0x0FFFFFFF)
                                                                        ],
                                                                        begin: FractionalOffset
                                                                            .topLeft,
                                                                        end: FractionalOffset
                                                                            .bottomRight)),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          (_selectedImage) != null
                                              ? Row(
                                                  children: <Widget>[
                                                    Spacer(),
                                                    Stack(
                                                      children: <Widget>[
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          child: Image.file(
                                                            (_selectedImage),
                                                            height: 100,
                                                            width: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _selectedImage =
                                                                    null;
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 23,
                                                              height: 23,
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom: 0,
                                                                      right: 0),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  color: Constants
                                                                      .colorPrimary),
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        isImageUploading ??
                                                                false
                                                            ? Container(
                                                                width: 100,
                                                                height: 100,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _selectedImage =
                                                                          null;
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                      width: 23,
                                                                      height: 23,
                                                                      margin: EdgeInsets.all(8),
                                                                      padding: EdgeInsets.only(bottom: 0, right: 0),
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Constants.colorPrimary),
                                                                      child: Stack(
                                                                        children: <
                                                                            Widget>[
                                                                          CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            /*  backgroundColor: Color(0xff007EF4),*/
                                                                          ),
                                                                          Container(
                                                                              width: 23,
                                                                              height: 23,
                                                                              alignment: Alignment.center,
                                                                              child: Icon(
                                                                                Icons.file_upload,
                                                                                color: Colors.white,
                                                                                size: 14,
                                                                              ))
                                                                        ],
                                                                      )),
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Container(),
                                Container(
                                  color: Constants.colorSecondary,
                                  width: MediaQuery.of(context).size.width,
                                  height: 0.4,
                                ),
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      color: Constants.colorSecondary,
                                      height: kIsWeb
                                          ? 100
                                          : Platform.isIOS ?? false ? 90 : 80,
                                    ),
                                    Container(
                                      height: kIsWeb
                                          ? 100
                                          : Platform.isIOS ?? false ? 90 : 80,
                                      color: Color(0x54FFFFFF),
                                      padding: EdgeInsets.only(
                                          top: 14,
                                          bottom: kIsWeb
                                              ? 14
                                              : Platform.isIOS ?? false
                                                  ? 24
                                                  : 14,
                                          right: 16,
                                          left: 16),
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                moreOptions = !moreOptions;
                                              });

                                              if (!moreOptions) {
                                                _anglecontroller.reverse();
                                              } else {
                                                _anglecontroller.forward();
                                              }

                                              /*   ///
                                            if(_anglecontroller.status == AnimationStatus.completed){

                                            }else if(_anglecontroller.status == AnimationStatus.dismissed){

                                            }*/
                                            },
                                            child: Container(
                                              child: Transform.rotate(
                                                angle: angle,
                                                child: Image.asset(
                                                  "assets/images/add_solid.png",
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0x36FFFFFF),
                                                        const Color(0x0FFFFFFF)
                                                      ],
                                                      begin: FractionalOffset
                                                          .topLeft,
                                                      end: FractionalOffset
                                                          .bottomRight)),
                                              padding: EdgeInsets.all(10),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 16),
                                              child: TextField(
                                                controller: textController,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Message ...",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          /*GestureDetector(
                                            onTap: () {
                                              addMessage("👍");
                                            },
                                            child: Container(
                                              child: Text(
                                                "👍",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(25),
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0x36FFFFFF),
                                                        const Color(0x0FFFFFFF)
                                                      ],
                                                      begin: FractionalOffset.topLeft,
                                                      end: FractionalOffset
                                                          .bottomRight)),
                                              padding: EdgeInsets.all(10),
                                            ),
                                          ),*/
                                          SizedBox(
                                            width: 16,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (!isImageUploading) {
                                                myAwesomeMessage =
                                                    textController.text;
                                                print("pajji aee lo" +
                                                    myAwesomeMessage);
                                                addMessage(myAwesomeMessage);
                                              }
                                            },
                                            child: Container(
                                              child: Opacity(
                                                opacity:
                                                    isImageUploading ? 0.3 : 1,
                                                child: Image.asset(
                                                  "assets/images/send.png",
                                                  width: 23,
                                                  height: 23,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xff007EF4),
                                                        const Color(0xff2A75BC)
                                                      ],
                                                      begin: FractionalOffset
                                                          .topRight,
                                                      end: FractionalOffset
                                                          .bottomLeft)),
                                              padding: EdgeInsets.all(12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
    /*Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: ChatInfo(
          userName: widget.name,
          userImageUrl: widget.profilePicUrl,
          chatRoomId: widget.chatRoomid,
          myName: myName,
          //userEmail: widget.email,
        ),
      ),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.arrow_back_ios)),
        ),
        centerTitle: true,
        title: Column(
          children: <Widget>[
            Text(
              Constants.makeFirstLetterUpperCase(widget.name),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OverpassRegular'),
            ),
            SizedBox(
              height: 1,
            ),
            Text(
              "Online now",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'OverpassRegular',
                color: Colors.white.withOpacity(0.7),
              ),
            )
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
            child: Container(
                padding: EdgeInsets.only(right: 12, left: 14),
                child: Image.asset(
                  "assets/images/blue_phone.png",
                  height: 20,
                  width: 20,
                )),
          ),
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
            child: Container(
                padding: EdgeInsets.only(right: 16, left: 14),
                child: Image.asset(
                  "assets/images/info_blue.png",
                  height: 20,
                  width: 20,
                )),
          )
        ],
        backgroundColor: Constants.colorPrimary,
        elevation: 0.0,
      ),
      backgroundColor: Constants.colorSecondary,
      body:,
    )*/

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
            height: 150,
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
                              ? Image.network(widget.myAvatarFinal)
                              : CachedNetworkImage(
                                  imageUrl: widget.myAvatarFinal))),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.myNameFinal,
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
                    widget.myEmail,
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
            onTap: () {},
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
          Opacity(
            opacity: 0.8,
            child: Container(
              padding: EdgeInsets.only(left: 30),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    "assets/images/share.png",
                    height: 18,
                    width: 18,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    "Share App",
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
          Opacity(
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
                    "About",
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

  sendGif(String gifUrl) async {
    if (gifUrl != null && gifUrl != "") {
      String messageId = randomAlphaNumeric(9);
      Map<String, dynamic> messageData = {
        "sendBy": await Constants.getUserNameSharedPreference(),
        "message": "",
        "time": DateTime.now().millisecondsSinceEpoch,
        "messageId": messageId,
        "imgUrl": gifUrl
      };

      /// update last message send
      Map<String, dynamic> chatRoomUpdate = {
        "lastmessage": "GIF",
        "lastMessageSendBy": _myName,
        'timestamp': Timestamp.now()
      };

      /// ...............
      ///
      DatabaseMethods().addMessage(
          widget.chatRoomid, messageData, messageId, chatRoomUpdate);
      databaseMethods.getChats(widget.chatRoomid).then((result) {
        setState(() {
          widget.messagesStream = result;
        });
      });
    }
  }

  getTrending() async {
    setState(() {
      isGifLoading = true;
    });
    final data = await http.get(
        "https://api.giphy.com/v1/gifs/trending?api_key=[API_KEY]&limit=25&rating=G");
    var res = data.body;
    var json = jsonDecode(res);
    gifmodel = GifModel.fromJson(json);
    setState(() {
      isGifLoading = false;
    });
  }

  getSearch(String search) async {
    setState(() {
      isGifLoading = true;
    });
    final data = await http.get(
        "https://api.giphy.com/v1/gifs/search?api_key=[API_KEY]&q=$search&limit=10&offset=0&rating=G&lang=en");
    var res = data.body;
    var json = jsonDecode(res);
    gifmodel = GifModel.fromJson(json);
    setState(() {
      isGifLoading = false;
    });
  }

  GifModel gifmodel;
}

class ConversationTile extends StatelessWidget {
  final bool sendByMe;
  final String message;
  final String profilePic;
  final String messageImgUrl;
  final bool bottomMargin;
  final String messageId;
  final String chatRoomId;

  ConversationTile(
      {@required this.sendByMe,
      @required this.message,
      @required this.profilePic,
      @required this.messageImgUrl,
      @required this.bottomMargin,
      @required this.messageId,
      @required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: bottomMargin ? 200 : 0),
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            Container(
                margin: sendByMe
                    ? EdgeInsets.only(left: 30)
                    : EdgeInsets.only(right: 30),
                child: (messageImgUrl == null || messageImgUrl == "")
                    ? GestureDetector(
                        onTap: () {
                          _moreMessageOptions(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 17, bottom: 17, left: 20, right: 20),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: sendByMe
                                      ? [
                                          const Color(0xff007EF4),
                                          const Color(0xff2A75BC)
                                        ]
                                      : [
                                          const Color(0x1AFFFFFF),
                                          const Color(0x1AFFFFFF)
                                        ],
                                  begin: FractionalOffset.centerLeft,
                                  end: FractionalOffset.centerRight),
                              borderRadius: sendByMe
                                  ? BorderRadius.only(
                                      topRight: Radius.circular(23),
                                      topLeft: Radius.circular(23),
                                      bottomLeft: Radius.circular(23))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomRight: Radius.circular(23))),
                          child: Text(
                            message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: sendByMe
                                  ? message != ""
                                      ? BorderRadius.only(
                                          topRight: Radius.circular(23),
                                          topLeft: Radius.circular(23),
                                        )
                                      : BorderRadius.circular(23)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13),
                                      bottomRight: Radius.circular(23)),
                              child: Image.network(
                                messageImgUrl,
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                            message != ""
                                ? Container(
                                    width: 250,
                                    padding: EdgeInsets.only(
                                        top: 8,
                                        bottom: 17,
                                        left: 20,
                                        right: 20),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: sendByMe
                                                ? [
                                                    const Color(0xff007EF4),
                                                    const Color(0xff2A75BC)
                                                  ]
                                                : [
                                                    const Color(0x1AFFFFFF),
                                                    const Color(0x1AFFFFFF)
                                                  ],
                                            begin: FractionalOffset.centerLeft,
                                            end: FractionalOffset.centerRight),
                                        borderRadius: sendByMe
                                            ? BorderRadius.only(
                                                bottomLeft: Radius.circular(23),
                                              )
                                            : BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(23))),
                                    child: Text(message,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300)))
                                : Container(
                                    child: Text(""),
                                  )
                          ],
                        ),
                      )),
          ],
        ));
  }

  Future<void> _moreMessageOptions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('More Options'),
          content: Text(
              'Click Delete message to permanently delete the message and Copy to copy it'),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete Message'),
              onPressed: () {
                DatabaseMethods()
                    .removeChat(chatRoomId: chatRoomId, chatId: messageId);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Copy'),
              onPressed: () {
                Clipboard.setData(new ClipboardData(text: message));
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
