import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/modules/chat/models/models.dart';
import 'package:photo_lab/src/widgets/loading_view.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../screens/photographer_screens/p_custom_order_screens/p_create_custom_order_screen.dart';
import '../../../screens/user_screens/u_add_booking_screens/u_add_new_booking_screen.dart';
import '../../../widgets/buttons.dart';
import 'pages.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.arguments}) : super(key: key);

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late String currentUserId;
  String? roomId;
  bool isOnline = false;
  int lastSeen = 0;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";
  late CustomOrderController customOrderProvider;
  CustomOrder customorder = CustomOrder(
      photographerId: "",
      orderPhotographerDetails: {},
      orderTotalPrice: 0.0,
      userId: "",
      roomid: "",
      orderCreatedTimestamp: DateTime.now().toString(),
      orderDescription: "",
      orderTotalHours: 0,
      orderStatus: "",
      groupChatId: "",
      documentReference: "");
  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatController chatProvider;
  late AuthController authProvider;

  late StreamSubscription onlineStatusListener;
  late String peerUserId;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    customOrderProvider =
        Provider.of<CustomOrderController>(context, listen: false);
    chatProvider = context.read<ChatController>();
    authProvider = context.read<AuthController>();
    roomId = widget.arguments.roomId;

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
    SessionHelper.getUser().then((value) {
      if (value != null) {
        setState(() {
          loggedInUser = value;
          // isLoading = true;
        });
        // fetchEquipments(loggedInUser!.id);
        // fetchData(loggedInUser!.id, 31.3952319, 74.2570513);
      }
    });
    resetUnreadCounter();

    //authProvider.toggleUserOnlineStatus(true);

    authProvider.firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(widget.arguments.peerId)
        .get()
        .then(
          (doc) => peerUserId = doc[FirestoreConstants.userId],
        );

    onlineStatusListener = authProvider.firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(widget.arguments.peerId)
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
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    String peerId = widget.arguments.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image, customorder, "");
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  //create room if it does not exist
  Future<void> createRoomIfNeeded() async {
    QuerySnapshot snapshot = await chatProvider.firebaseFirestore
        .collection(FirestoreConstants.pathRoomsCollection)
        .where('users', arrayContains: currentUserId)
        //.where('users', arrayContains: widget.arguments.peerId)
        .get();

    List<QueryDocumentSnapshot> docs = snapshot.docs
        .where((element) => element['users'].contains(widget.arguments.peerId))
        .toList();
    if (docs.isEmpty) {
      //create new room
      // print('going to create a new chat room');
      final value = await chatProvider.firebaseFirestore
          .collection(FirestoreConstants.pathRoomsCollection)
          .add({
        FirestoreConstants.dateTime: DateTime.now().millisecondsSinceEpoch,
        FirestoreConstants.lastMessage: '',
        '$currentUserId-photoUrl':
            authProvider.getCurrentFirebaseUser()!.photoURL,
        '${widget.arguments.peerId}-photoUrl': widget.arguments.peerAvatar,
        '$currentUserId-name':
            authProvider.getCurrentFirebaseUser()!.displayName,
        '${widget.arguments.peerId}-name': widget.arguments.peerNickname,
        FirestoreConstants.users: [currentUserId, widget.arguments.peerId]
      });
      roomId = value.id;
    } else {
      // print('chat room already exists');
      roomId = docs.first.id;
    }
  }

  void onSendMessage(String content, int type, CustomOrder customorder,
      String customorderdocumentid) async {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      if (roomId == null) {
        await createRoomIfNeeded();
      }

      chatProvider.sendMessage(
          content,
          type,
          groupChatId,
          currentUserId,
          widget.arguments.peerId,
          roomId!,
          peerUserId,
          customorder,
          customorderdocumentid);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      updateUnreadCounter();
    } else {}
  }

  customOrderBuild(CustomOrder customOrder, String id) {
    // // print("customOrder lst: ${customOrder.orderPhotographerDetails}");
    return Container(
      margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        // color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.SpaceY,
          Text(
            'Created at',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${DateFormat('dd MMM yy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(customOrder.orderCreatedTimestamp)))}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Text(
            'Description',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${customOrder.orderDescription}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Text(
            'Hours',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${customOrder.orderTotalHours} hours',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Price:',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Spacer(),
              Text(
                '\u{20B9} ${customOrder.orderTotalPrice} ',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 20, color: AppColors.black),
              ),
              Text(
                'Per Hour',
                style: MyTextStyle.mediumItalic.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          15.SpaceY,
          customOrder.orderStatus == 'Pending' &&
                  SessionHelper.userType == "2" // means photographer
              ? Divider(
                  color: AppColors.black.withOpacity(0.1),
                  height: 5,
                  thickness: 1,
                )
              : SizedBox.shrink(),
          15.SpaceY,
          Consumer<CustomOrderController>(
              builder: (context, cusOrderPrvdr, child) {
            return cusOrderPrvdr.changeStatusLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  )
                : customOrder.orderStatus == 'Pending' &&
                        SessionHelper.userType == "1"
                    ? Row(
                        children: [
                          Expanded(
                              child: PrimaryButton(
                                  text: "Accept",
                                  color: AppColors.darkBlue,
                                  onPress: () {
                                    customOrder.documentReference = id;
                                    customOrder.groupChatId = groupChatId;

                                    Navigator.pushNamed(
                                        context, UserAddNewBookingScreen.route,
                                        arguments: {
                                          'customOrder': customOrder
                                        });
                                  })),
                          10.SpaceX,
                          Expanded(
                              child: PrimaryButton(
                                  text: "Reject",
                                  color: AppColors.kInputBackgroundColor,
                                  onPress: () {
                                    customOrderProvider.setStatusLoader(true);
                                    customOrderProvider.updateCustomOrderStatus(
                                        orderStatus: 'Rejected',
                                        groupChatId: groupChatId,
                                        documentReference: id);
                                    customOrderProvider
                                        .sendCustomOrderNotificationToPhotographer(
                                            loggedInUser!.id,
                                            customOrder.photographerId,
                                            'rejected');
                                  })),
                        ],
                      )
                    : customOrder.orderStatus == 'Withdrawn'
                        ? rejectedWithdrawnBuild('Order has been Withdrawn')
                        : customOrder.orderStatus == 'Rejected'
                            ? rejectedWithdrawnBuild(
                                SessionHelper.userType == "1"
                                    ? 'Order has been Declined'
                                    : 'Order has been Rejected')
                            : customOrder.orderStatus == 'Accepted'
                                ? rejectedWithdrawnBuild(
                                    SessionHelper.userType == "1"
                                        ? 'Order has been Placed'
                                        : 'Order has been Accepted')
                                : GradientButton(
                                    onPress: () {
                                      customOrderProvider.setStatusLoader(true);
                                      customOrderProvider
                                          .updateCustomOrderStatus(
                                              orderStatus: 'Withdrawn',
                                              groupChatId: groupChatId,
                                              documentReference: id);

                                      customOrderProvider
                                          .sendCustomOrderNotificationToPhotographer(
                                              loggedInUser!.id,
                                              customOrder.photographerId,
                                              'withdrawn');
                                    },
                                    text: customOrder.orderStatus == 'Withdrawn'
                                        ? "Withdrawn by you"
                                        : 'Withdraw Order',
                                  );
          }),
        ],
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      // CustomOrder customorderdetail =
      //     CustomOrder.fromMap(messageChat.customorderdetails);
      if (messageChat.idFrom == currentUserId) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Flexible(
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
                                  child: Text(
                                      prettyDateTimeChat(messageChat.timestamp
                                          .toDate()
                                          .millisecondsSinceEpoch),
                                      style: MyTextStyle.regularBlack.copyWith(
                                          fontSize: 13,
                                          color: AppColors.black
                                              .withOpacity(0.6))),
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
                : messageChat.type == TypeMessage.customOrder
                    // Text
                    ? Flexible(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Me',
                                        style: MyTextStyle.semiBoldBlack
                                            .copyWith(fontSize: 14)),
                                    30.SpaceX,
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          prettyDateTimeChat(messageChat
                                              .timestamp
                                              .toDate()
                                              .millisecondsSinceEpoch),
                                          style: MyTextStyle.regularBlack
                                              .copyWith(
                                                  fontSize: 13,
                                                  color: AppColors.black
                                                      .withOpacity(0.6))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    "Custom Order",
                                    style: MyTextStyle.semiBoldBlack.copyWith(
                                        fontSize: 14,
                                        color: AppColors.darkBlue)),

                                StreamBuilder<DocumentSnapshot>(
                                  stream: getCustomOrderdetail(
                                      groupChatId: groupChatId,
                                      orderid:
                                          messageChat.customorderdocumentid),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      CustomOrder customOrder =
                                          CustomOrder.fromDocument(
                                              snapshot.data!);
                                      return customOrderBuild(customOrder,
                                          customOrder.orderCreatedTimestamp);
                                    }
                                    return Container();
                                  },
                                )

                                // Container(
                                //   // width: MediaQuery.of(context).size.width*0.65,
                                //   child: Text(
                                //       messageChat.customorderdetails[
                                //           "orderDescription"],
                                //       style: MyTextStyle.semiBoldBlack.copyWith(
                                //           fontSize: 15,
                                //           fontStyle: FontStyle.italic,
                                //           height: 1.3)),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : messageChat.type == TypeMessage.image
                        // Image
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20 : 10,
                                right: 10,
                                left: 50),
                            child: IntrinsicWidth(
                              child: Column(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullPhotoPage(
                                            url: messageChat.content,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                                EdgeInsets>(
                                            const EdgeInsets.all(0))),
                                    child: Material(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.network(
                                        messageChat.content,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: ColorConstants.greyColor2,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            width: 200,
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color:
                                                    ColorConstants.themeColor,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, object, stackTrace) {
                                          return Material(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.asset(
                                              'images/img_not_available.jpeg',
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      prettyDateTimeChat(messageChat.timestamp
                                          .toDate()
                                          .millisecondsSinceEpoch),
                                      style: const TextStyle(
                                          color: Color(
                                            0xFF7A7A7A,
                                          ),
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        // Sticker
                        : Container(
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20 : 10,
                                right: 10,
                                left: 50),
                            child: Image.asset(
                              'images/${messageChat.content}.gif',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: <Widget>[
              // isLastMessageLeft(index)
              //     ? Material(
              //         borderRadius: const BorderRadius.all(
              //           Radius.circular(18),
              //         ),
              //         clipBehavior: Clip.hardEdge,
              //         child: Image.network(
              //           widget.arguments.peerAvatar,
              //           loadingBuilder: (BuildContext context, Widget child,
              //               ImageChunkEvent? loadingProgress) {
              //             if (loadingProgress == null) return child;
              //             return Center(
              //               child: CircularProgressIndicator(
              //                 color: ColorConstants.themeColor,
              //                 value: loadingProgress.expectedTotalBytes != null
              //                     ? loadingProgress.cumulativeBytesLoaded /
              //                         loadingProgress.expectedTotalBytes!
              //                     : null,
              //               ),
              //             );
              //           },
              //           errorBuilder: (context, object, stackTrace) {
              //             return const Icon(
              //               Icons.account_circle,
              //               size: 35,
              //               color: ColorConstants.greyColor,
              //             );
              //           },
              //           width: 35,
              //           height: 35,
              //           fit: BoxFit.cover,
              //         ),
              //       )
              //     : Container(width: 35),
              messageChat.type == TypeMessage.text
                  ? Flexible(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        "${widget.arguments.peerNickname}",
                                        style: MyTextStyle.semiBoldBlack
                                            .copyWith(
                                                fontSize: 14,
                                                color: AppColors.darkBlue)),
                                  ),
                                  30.SpaceX,
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        prettyDateTimeChat(messageChat.timestamp
                                            .toDate()
                                            .millisecondsSinceEpoch),
                                        style: MyTextStyle.regularBlack
                                            .copyWith(
                                                fontSize: 13,
                                                color: AppColors.black
                                                    .withOpacity(0.6))),
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
                  : messageChat.type == TypeMessage.customOrder
                      ? Flexible(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            "${widget.arguments.peerNickname}",
                                            style: MyTextStyle.semiBoldBlack
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: AppColors.darkBlue)),
                                      ),
                                      30.SpaceX,
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            prettyDateTimeChat(messageChat
                                                .timestamp
                                                .toDate()
                                                .millisecondsSinceEpoch),
                                            style: MyTextStyle.regularBlack
                                                .copyWith(
                                                    fontSize: 13,
                                                    color: AppColors.black
                                                        .withOpacity(0.6))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      "Custom Order",
                                      style: MyTextStyle.semiBoldBlack.copyWith(
                                          fontSize: 14,
                                          color: AppColors.darkBlue)),

                                  StreamBuilder<DocumentSnapshot>(
                                    stream: getCustomOrderdetail(
                                        groupChatId: groupChatId,
                                        orderid:
                                            messageChat.customorderdocumentid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        CustomOrder customOrder =
                                            CustomOrder.fromDocument(
                                                snapshot.data!);
                                        return customOrderBuild(customOrder,
                                            customOrder.orderCreatedTimestamp);
                                      }
                                      return Container();
                                    },
                                  )
                                  // Container(
                                  //   // width: MediaQuery.of(context).size.width*0.65,
                                  //   child: Text(messageChat.content,
                                  //       style: MyTextStyle.semiBoldBlack
                                  //           .copyWith(
                                  //               fontSize: 15,
                                  //               fontStyle: FontStyle.italic,
                                  //               height: 1.3)),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                          url: messageChat.content),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: ColorConstants.greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  left: 10,
                                  right: 50),
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

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
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.arguments.peerAvatar),
                  maxRadius: 20,
                ),
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
                // widget.arguments.issupportperson == true ||
                //         SessionHelper.userType == "1"
                //     ? SizedBox.shrink()
                //     : Padding(
                //         padding: const EdgeInsets.only(left: 5, right: 5),
                //         child: SizedBox(
                //           // height: 30,
                //           child: TextButton(
                //             onPressed: () {
                //               Navigator.pushNamed(
                //                   context, PhtographerDisplayCustomOrder.route,
                //                   arguments: {
                //                     'groupChatId': groupChatId,
                //                     'peerUserId': peerUserId,
                //                     'onSendMessage': onSendMessage,
                //                     'roomid': roomId
                //                   });
                //             },
                //             child: Text(
                //               "Custom\n Orders",
                //               style: MyTextStyle.boldBlack.copyWith(
                //                   fontSize: 14, color: AppColors.orange),
                //             ),
                //           ),
                //         ),
                //       ),
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
                  SessionHelper.userType == "1"
                      ? buildInput()
                      : widget.arguments.issupportperson
                          ? buildInput()
                          : buildInputphotographer(),
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
          // Button send image
          // Material(
          //   color: Colors.white,
          //   child: Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 1),
          //     child: IconButton(
          //       icon: const Icon(Icons.image),
          //       onPressed: getImage,
          //       color: ColorConstants.darkGrey,
          //     ),
          //   ),
          // ),
          /*Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.face),
                onPressed: getSticker,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),*/

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                focusNode: focusNode,
                autofocus: false,
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text,
                      customorder, "");
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
                onPressed: () => onSendMessage(textEditingController.text,
                    TypeMessage.text, customorder, ""),
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

  Widget buildInputphotographer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.cardBackgroundColor,
      ),
      margin: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    focusNode: focusNode,
                    autofocus: false,
                    onSubmitted: (value) {
                      onSendMessage(textEditingController.text,
                          TypeMessage.text, customorder, "");
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
                      hintStyle:
                          MyTextStyle.semiBold05Black.copyWith(fontSize: 15),
                    ),
                    // focusNode: focusNode,
                    // autofocus: true,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  splashColor: Colors.black,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PhotographerCreateCustomOrderScreen.route,
                      arguments: {
                        'groupChatId': groupChatId,
                        'peerUserId': peerUserId,
                        "onSendMessage": onSendMessage,
                        "roomid": roomId ?? ""
                      },
                    );
                  },
                  child: Text(
                    "Create Custom order",
                    style: MyTextStyle.boldBlack
                        .copyWith(fontSize: 14, color: AppColors.orange),
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: 50,
                  child: ElevatedButton(
                      onPressed: () => onSendMessage(textEditingController.text,
                          TypeMessage.text, customorder, ""),
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSticker() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
            color: Colors.white),
        padding: const EdgeInsets.all(5),
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi1', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi1.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi2', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi2.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi3', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi3.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi4', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi4.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi5', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi5.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi6', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi6.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi7', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi7.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi8', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi8.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage(
                      'mimi9', TypeMessage.sticker, customorder, ""),
                  child: Image.asset(
                    'images/mimi9.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget rejectedWithdrawnBuild(txt) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(15),
      child: Text(
        "$txt",
        style: MyTextStyle.semiBold05Black
            .copyWith(fontSize: 15, color: AppColors.black),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
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

  void updateUnreadCounter() {
    try {
      authProvider.firebaseFirestore
          .collection(FirestoreConstants.pathRoomsCollection)
          .doc(roomId)
          .update({
        '${FirestoreConstants.unreadCounter}-${widget.arguments.peerId}':
            FieldValue.increment(1)
      });
    } catch (e) {
      debugLog("inside updateUnreadCounter exception: $e");
    }
  }

  Future<void> resetUnreadCounter() async {
    print("inside resetUnreadCounter roomId: $roomId");

    try {
      if (roomId == null) {
        await createRoomIfNeeded();
      } else {
        authProvider.firebaseFirestore
            .collection(FirestoreConstants.pathRoomsCollection)
            .doc(roomId)
            .update({'${FirestoreConstants.unreadCounter}-$currentUserId': 0});
      }
    } catch (e) {
      debugLog("inside resetUnreadCounter exception: $e");
    }
  }
}

Stream<DocumentSnapshot> getCustomOrderdetail(
    {required String groupChatId, required String orderid}) {
  return FirebaseFirestore.instance
      .collection(FirestoreConstants.pathCustomOrderCollection)
      .doc(groupChatId)
      .collection(groupChatId)
      .doc(orderid)
      .snapshots();
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String? roomId;
  final bool issupportperson;

  ChatPageArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.issupportperson,
      this.roomId});
}
