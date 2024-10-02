import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../helpers/constants.dart';
import '../../../helpers/utils.dart';
import '../../../widgets/loading_view.dart';
import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../controllers/chat_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/supportchatmodel.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key, required this.arguments})
      : super(key: key);

  final SupportChatScreenArguments arguments;

  @override
  SupportChatScreenState createState() => SupportChatScreenState();
}

class SupportChatScreenState extends State<SupportChatScreen> {
  bool isOnline = false;
  int lastSeen = 0;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  String userid = "";
  final int _limitIncrement = 20;

  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  User? loggedInUser;
  late ChatController chatProvider;

  // late AuthProvider authProvider;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late StreamSubscription onlineStatusListener;
  FirebaseAuth firebaseauth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    userid = widget.arguments.peerId;
    imageUrl = widget.arguments.peerAvatar;
    chatProvider = context.read<ChatController>();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    resetUnreadCounter();
    checkAndAddFieldsToDocument(userid);
    onlineStatusListener = firebaseFirestore
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          if (event.data()!.containsKey('isOnline')) {
            isOnline = event['isOnline'];
          }
          if (event.data()!.containsKey('lastSeen')) {
            lastSeen = event['lastSeen'];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    onlineStatusListener.cancel();
    //authProvider.toggleUserOnlineStatus(false);
    resetUnreadCounter();
    super.dispose();
  }

  Future<void> checkAndAddFieldsToDocument(String userid) async {
    final DocumentReference chatDocRef = FirebaseFirestore.instance
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons
            .toLowerCase()) // Assuming 'userid' is the user's document ID
        .collection(FirestoreConstants.chats)
        .doc(userid); // Use the same 'userid' as the chat document ID

    DocumentSnapshot chatDocSnapshot = await chatDocRef.get();

    if (!chatDocSnapshot.exists) {
      // The chat document doesn't exist, so add it with fields
      await chatDocRef.set({
        'id': userid,
        'lastMessage': '',
        'lastMessageType': 1,
        'name': widget.arguments.minename,
        'unreadCounter': 0,
        'supportunreadCounter': 0,
        'photoUrl': widget.arguments.mineimg,
        'dateTime': FieldValue.serverTimestamp()

        // Add more fields as needed
      });
    }
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {});
    }
  }

  Future<void> sendpushnotifcation(
    String title,
    String body,
  ) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.supportpersons)
          .doc(FirestoreConstants.supportpersons.toLowerCase())
          .get();

      if (!snapshot.exists) {
        print('Document does not exist');
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;

      if (data.containsKey('fcmTokens')) {
        final arrayValue = data['fcmTokens'] as List<dynamic>;
        for (var data in arrayValue) {
          debugLog(data);
          NotificationController.sendnotification(data, title, body);
        }
      } else {
        print('Field does not exist');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> sendMessage(String content, String userid) async {
    final chatRoomMessagesCollection = FirebaseFirestore.instance
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .collection(FirestoreConstants.chats)
        .doc(userid)
        .collection(FirestoreConstants.messages);
    try {
      if (content.trim().isNotEmpty) {
        await chatRoomMessagesCollection.add({
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          "sentby": userid
        });
        if (listScrollController.hasClients) {
          listScrollController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
        textEditingController.text = "";
        updatelastmessage(content);
        sendpushnotifcation(
            "${widget.arguments.minename} Sent you a message", content);
      } else {
        Fluttertoast.showToast(
            msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      SupportMessageChat messageChat =
          SupportMessageChat.fromDocument(document);
      if (messageChat.sentby == userid) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                decoration: BoxDecoration(
                    color: AppColors.senderCardLightGreen,
                    borderRadius: BorderRadius.circular(8)),
                margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20 : 10,
                    right: 10,
                    left: 50),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Me',
                              style: MyTextStyle.semiBoldBlack
                                  .copyWith(fontSize: 14)),
                          30.SpaceX,
                          Align(
                            alignment: Alignment.centerRight,
                            child: messageChat.timestamp == null
                                ? SizedBox.shrink()
                                : Text(
                                    prettyDateTimeChat(messageChat.timestamp
                                        .toDate()
                                        .millisecondsSinceEpoch),
                                    style: MyTextStyle.regularBlack.copyWith(
                                        fontSize: 13,
                                        color:
                                            AppColors.black.withOpacity(0.6))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        // width: MediaQuery.of(context).size.width*0.65,
                        child: Text(messageChat.content,
                            style: MyTextStyle.mediumBlack
                                .copyWith(fontSize: 15, height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  decoration: BoxDecoration(
                      color: AppColors.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.only(left: 10, right: 50),
                  child: IntrinsicWidth(
                    // stepWidth: MediaQuery.of(context).size.width*0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  "${widget.arguments.peerNickname}",
                                  style: MyTextStyle.semiBoldBlack.copyWith(
                                      fontSize: 14, color: AppColors.darkBlue)),
                            ),
                            30.SpaceX,
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  prettyDateTimeChat(messageChat.timestamp
                                      .toDate()
                                      .millisecondsSinceEpoch),
                                  style: MyTextStyle.regularBlack.copyWith(
                                      fontSize: 13,
                                      color: AppColors.black.withOpacity(0.6))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          // width: MediaQuery.of(context).size.width*0.65,
                          child: Text(messageChat.content,
                              style: MyTextStyle.mediumBlack
                                  .copyWith(fontSize: 15, height: 1.3)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.sentby) !=
                "supportperson") ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    // print("widget.arguments.peerAvatar: ${widget.arguments.peerAvatar}");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  color: AppColors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.kOnPrimaryColor,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Container(
                    height: 45.0,
                    width: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: AppColors.orange),
                    child: Icon(
                      Icons.support_agent,
                      size: 32,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widget.arguments.peerNickname,
                        style: MyTextStyle.boldBlack.copyWith(fontSize: 17),
                      ),
                      Visibility(
                        visible: isOnline || lastSeen > 0,
                        child: Container(
                          margin: const EdgeInsets.only(top: 3),
                          child: Text(
                              isOnline
                                  ? "online"
                                  : 'Last seen ${DateFormat('dd MMM yy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastSeen))}',
                              style: MyTextStyle.semiBold05Black
                                  .copyWith(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),

                  // Sticker
                  //isShowSticker ? buildSticker() : const SizedBox.shrink(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                focusNode: focusNode,
                autofocus: false,
                onSubmitted: (value) {
                  sendMessage(textEditingController.text, userid);
                },
                textAlign: TextAlign.start,
                cursorColor: AppColors.black,
                style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        width: 3, color: AppColors.cardBackgroundColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        width: 3, color: AppColors.cardBackgroundColor),
                  ),
                  fillColor: AppColors.cardBackgroundColor,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 20),
                  hintText: 'Write your message...',
                  filled: true,
                  hintStyle: MyTextStyle.semiBold05Black.copyWith(fontSize: 15),
                ),
                // focusNode: focusNode,
                // autofocus: true,
              ),
            ),
          ),
          10.SpaceX,

          SizedBox(
            height: 45,
            width: 50,
            child: ElevatedButton(
                onPressed: () =>
                    sendMessage(textEditingController.text, userid),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(50, 45),
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      // width: 40,
                      height: 45,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        ImageAsset.SendIcon,
                        height: 20,
                        width: 20,
                        color: AppColors.white,
                      ),
                    ))),
          )
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: userid.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getSupportChatStream(userid, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }

  void updatelastmessage(String message) {
    try {
      FirebaseFirestore.instance
          .collection(FirestoreConstants.supportpersons)
          .doc(FirestoreConstants.supportpersons.toLowerCase())
          .collection(FirestoreConstants.chats)
          .doc(userid)
          .update({
        FirestoreConstants.lastMessage: message,
        FirestoreConstants.dateTime: FieldValue.serverTimestamp(),
        FirestoreConstants.supportunreadCounter: FieldValue.increment(1)
      });
    } catch (e) {
      debugLog("inside updatelastmessage exception: $e");
    }
  }

  Future<void> resetUnreadCounter() async {
    try {
      firebaseFirestore
          .collection(FirestoreConstants.supportpersons)
          .doc(FirestoreConstants.supportpersons.toLowerCase())
          .collection(FirestoreConstants.chats)
          .doc(userid)
          .update({'unreadCounter': 0});
    } catch (e) {
      debugLog("inside resetUnreadCounter exception: $e");
    }
  }
}

class SupportChatScreenArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String mineimg;
  final String minename;

  SupportChatScreenArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.mineimg,
      required this.minename});
}
