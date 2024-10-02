import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as au;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/modules/chat/models/chat_room.dart';
import 'package:photo_lab/src/modules/chat/pages/support_chat_page.dart';
import 'package:photo_lab/src/modules/chat/utils/utils.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/loading_view.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../screens/photographer_screens/p_home_startup.dart';
import '../../../screens/user_screens/u_home_startup.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/primary_text_field.dart';
import '../models/models.dart';
import 'pages.dart';

class HomePage extends StatefulWidget {
  final String? targetUserId;

  const HomePage({Key? key, this.targetUserId}) : super(key: key);

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState({Key? key});

  User? loggedInUser;

  getUserData() {
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
  }

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 500;
  final int _limitIncrement = 500;
  String _textSearch = "";
  bool isLoading = false;
  bool isOpened = false;

  late AuthController authProvider;
  late HomeController homeProvider;
  late String currentUserId;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    // debugPrint('target user id: ${widget.targetUserId}');
    authProvider = Provider.of<AuthController>(context, listen: false);
    homeProvider = Provider.of<HomeController>(context, listen: false);
    getUserData();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    //authProvider.toggleUserOnlineStatus(true);
    registerNotification();
    configLocalNotification();
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    btnClearController.close();
    //authProvider.toggleUserOnlineStatus(false);
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // debugPrint('onMessage 12: $message');
      if (message.notification != null) {
        // debugPrint("message.notification!: ${message.notification!}");
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      // debugPrint('push token: $token');
      if (token != null) {
        homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
            currentUserId, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      _limit += _limitIncrement;
    }
  }

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.dfa.flutterchatdemo'
          : 'com.duytq.flutterchatdemo',
      'MyClickerr',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // debugPrint(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: ColorConstants.themeColor,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    const Text(
                      'Cancel',
                      style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    const Text(
                      'Yes',
                      style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  bool allSelected = true;
  bool unreadSelected = false;
  bool readSelected = false;
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (SessionHelper.userType == '2') {
          debugPrint("photographer");
          Navigator.pushNamedAndRemoveUntil(
              context, PhotographerHomeStartup.route, (route) => false);
        } else {
          debugPrint("user");
          Navigator.pushNamedAndRemoveUntil(
              context, UserHomeStartup.route, (route) => false);
        }
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Inbox"),
        body: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                15.SpaceY,
                //buildSearchBar(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: kScreenPadding, right: kScreenPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PrimaryTextField(
                          "Search by name",
                          labelText: "Enter name",
                          suffixIcon: Icons.search,
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          onChange: (value) {
                            setState(() {
                              debugPrint("search${searchController.text}");
                              // searchController.text = value;
                              // filterSearchResults(value);
                            });
                          },
                        ),
                      ),
                      9.SpaceX,
                      InkWell(
                        onTap: () async {
                          searchController.text = "";
                          closeKeyboard(context);
                          bool? res = await showbottomshet();
                          if (res != null && res) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.darkBlack.withOpacity(0.3))),
                          child: SvgPicture.asset(
                            ImageAsset.FilterIcon,
                            height: 20,
                            width: 20,
                            color: AppColors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                15.SpaceY,
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(FirestoreConstants.supportpersons)
                      .doc(FirestoreConstants.supportpersons.toLowerCase())
                      .collection(FirestoreConstants.chats)
                      .doc(au.FirebaseAuth.instance.currentUser!.uid ?? "")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox
                          .shrink(); // Show a loading indicator while data is loading
                    }

                    if (snapshot.hasError) {
                      return SizedBox.shrink();
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              closeKeyboard(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupportChatScreen(
                                    arguments: SupportChatScreenArguments(
                                      peerId: au.FirebaseAuth.instance
                                              .currentUser!.uid
                                              .toString() ??
                                          "",
                                      peerAvatar: "",
                                      peerNickname: "Support Team",
                                      mineimg: loggedInUser!.profileImage ?? "",
                                      minename: loggedInUser!.name ?? "",
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultSpace * 3,
                                  vertical: kDefaultSpace * 1.5),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Container(
                                        height: 50.0,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: AppColors.orange),
                                        child: Icon(
                                          Icons.support_agent,
                                          size: 32,
                                          color: Colors.white,
                                        )),
                                    const SizedBox(
                                      width: kDefaultSpace * 2.3,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 5),
                                          Text(
                                            "Support Team",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: MyTextStyle.semiBoldBlack
                                                .copyWith(fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "No Messages Yet!",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: MyTextStyle.mediumBlack
                                                .copyWith(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        SizedBox.shrink(),
                                        const SizedBox(height: 6),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 3.0,
                          ),
                        ],
                      );

                      // Document doesn't exist or no data
                    }

                    final data = snapshot.data
                        as DocumentSnapshot<Map<String, dynamic>>?;
                    return Container(
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: buildItem1(context, data!)),
                            Divider(
                              thickness: 3.0,
                            ),
                          ],
                        ));
                  },
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: homeProvider.firebaseFirestore
                        .collection(FirestoreConstants.pathRoomsCollection)
                        .where(FirestoreConstants.users,
                            arrayContains: currentUserId)
                        .orderBy(FirestoreConstants.dateTime, descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>?
                          sdocument = [];
                      if (snapshot.hasData) {
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>?
                            document = filterDocuments(snapshot.data!);

                        sdocument = updateSearchResults(document);

                        if (sdocument!.length > 0) {
                          return ListView.separated(
                            itemCount: sdocument.length ?? 0,
                            controller: listScrollController,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              color: Color(0xffb9b9b9),
                              height: 2,
                              endIndent: 15,
                              indent: 15,
                            ),
                            itemBuilder: (context, index) {
                              return buildItem(context, sdocument?[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("Chat Empty"),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // Loading
            Positioned(
              child: isLoading ? const LoadingView() : const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterDocuments(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = [];

    for (int i = 0; i < snapshot.docs.length; i++) {
      Map<String, dynamic> docData = snapshot.docs[i].data();

      if (allSelected) {
        documents = snapshot.docs;
        break;
      } else if (unreadSelected) {
        final unreadCounterKey =
            '${FirestoreConstants.unreadCounter}-$currentUserId';
        if (docData.containsKey(unreadCounterKey) &&
            docData[unreadCounterKey] > 0) {
          documents.add(snapshot.docs[i]);
        }
      } else if (readSelected) {
        final unreadCounterKey =
            '${FirestoreConstants.unreadCounter}-$currentUserId';
        if (!docData.containsKey(unreadCounterKey) ||
            docData[unreadCounterKey] == 0) {
          documents.add(snapshot.docs[i]);
        }
      }
    }

    return documents;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? updateSearchResults(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? documents,
  ) {
    if (searchController.text.isEmpty) {
      return documents;
    }

    final updatedDocuments = documents?.where((doc) {
      final users = doc["users"] as List;
      final userId = users[0] == currentUserId ? users[1] : users[0];
      final userNameKey = "$userId-name";

      final docData = doc.data();
      return docData.containsKey(userNameKey) &&
          docData[userNameKey]
              .toString()
              .toLowerCase()
              .startsWith(searchController.text.toLowerCase());
    }).toList();

    return updatedDocuments;
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: ColorConstants.greyColor, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    btnClearController.add(true);
                    setState(() {
                      _textSearch = value;
                    });
                  } else {
                    btnClearController.add(false);
                    setState(() {
                      _textSearch = "";
                    });
                  }
                });
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search nickname (you have to type exactly string)',
                hintStyle:
                    TextStyle(fontSize: 13, color: ColorConstants.greyColor),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder<bool>(
              stream: btnClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          searchBarTec.clear();
                          btnClearController.add(false);
                          setState(() {
                            _textSearch = "";
                          });
                        },
                        child: const Icon(Icons.clear_rounded,
                            color: ColorConstants.greyColor, size: 20))
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: const TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }

  Widget buildItem(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>>? document) {
    if (document != null) {
      debugPrint("document: ${document.data()}");
      ChatRoom1 userChat = ChatRoom1.fromDocument(document);
      if (userChat.users[0] == currentUserId &&
          userChat.users[1] == currentUserId) {
        return SizedBox.shrink();
      }
      String otherPersonId = userChat.users.where((element) {
        return element != currentUserId;
      }).first;
      String photoUrl = document.data()!.containsKey('$otherPersonId-photoUrl')
          ? document['$otherPersonId-photoUrl']
              .toString()
              .replaceAll("https", "http")
              .replaceFirst('http://app.myclickerr.com/',
                  'http://myclickerr.info/public/')
          : '';
      log("log(photoUrl);$photoUrl");
      String name = document.data()!.containsKey('$otherPersonId-name')
          ? document['$otherPersonId-name']
          : '';

      int unreadCounter = document
              .data()!
              .containsKey('${FirestoreConstants.unreadCounter}-$currentUserId')
          ? document['${FirestoreConstants.unreadCounter}-$currentUserId']
          : 0;
      debugPrint(
          'users:${userChat.users} \nname: ${document['$otherPersonId-name']}');
      debugPrint("photourl: $photoUrl");
      return Column(
        children: [
          InkWell(
            onTap: () {
              /*if (Utilities.isKeyboardShowing()) {

              }*/
              closeKeyboard(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    arguments: ChatPageArguments(
                        peerId: otherPersonId,
                        peerAvatar: photoUrl,
                        peerNickname: name,
                        issupportperson: false,
                        roomId: userChat.id),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultSpace * 3, vertical: kDefaultSpace * 1.5),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.lightGrey),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FadeInImage.assetNetwork(
                          placeholder: ImageAsset.LogoImage,
                          image: photoUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 50.0,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image:
                                        AssetImage(ImageAsset.PlaceholderImg),
                                  ),
                                  color: AppColors.lightGrey),
                            );
                          },
                        ),
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: 25.0,
                    //   backgroundImage: NetworkImage(photoUrl),
                    //   backgroundColor: Colors.grey,
                    // ),
                    const SizedBox(
                      width: kDefaultSpace * 2.3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            '$name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userChat.lastMessageType == TypeMessage.image
                                ? 'picture'
                                : userChat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                MyTextStyle.mediumBlack.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(prettyDateTime(userChat.dateTime),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF7A7A7A))),
                        const SizedBox(height: 6),
                        Visibility(
                          visible: unreadCounter != 0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.orange,
                            child: FittedBox(
                              child: Text(
                                unreadCounter > 99 ? '99+' : '$unreadCounter',
                                style: const TextStyle(
                                    color: AppColors.kPrimaryTextColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          /*const Divider(
              color: Colors.red,
              height: 0,
            )*/
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildItem1(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>>? document) {
    if (document != null) {
      ChatRoom userChat = ChatRoom.fromDocument(document);

      String PersonId = document["id"];
      String photoUrl = document.data()!.containsKey('photoUrl')
          ? document['photoUrl']
              .toString()
              .replaceAll("https", "http")
              .replaceFirst('http://app.myclickerr.com/api',
                  'http://myclickerr.info/public/')
          : "";
      log(photoUrl);
      String name =
          document.data()!.containsKey('name') ? document['name'] : '';

      int unreadCounter =
          document.data()!.containsKey(FirestoreConstants.unreadCounter)
              ? int.parse(document[FirestoreConstants.unreadCounter].toString())
              : 0;

      return Column(
        children: [
          InkWell(
            onTap: () {
              closeKeyboard(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupportChatScreen(
                    arguments: SupportChatScreenArguments(
                      peerId: PersonId,
                      peerAvatar: "",
                      peerNickname: "Support Team",
                      mineimg: loggedInUser!.profileImage ?? "",
                      minename: loggedInUser!.name ?? "",
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultSpace * 3, vertical: kDefaultSpace * 1.5),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                        height: 50.0,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.orange),
                        child: Icon(
                          Icons.support_agent,
                          size: 32,
                          color: Colors.white,
                        )),
                    const SizedBox(
                      width: kDefaultSpace * 2.3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            "Support Team",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userChat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                MyTextStyle.mediumBlack.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        userChat.dateTime == null
                            ? SizedBox.shrink()
                            : Text(
                                prettyDateTime(userChat.dateTime
                                    .toDate()
                                    .millisecondsSinceEpoch),
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: Color(0xFF7A7A7A))),
                        const SizedBox(height: 6),
                        Visibility(
                          visible: unreadCounter != 0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.orange,
                            child: FittedBox(
                              child: Text(
                                unreadCounter > 99 ? '99+' : '$unreadCounter',
                                style: const TextStyle(
                                    color: AppColors.kPrimaryTextColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future showbottomshet() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 5,
        context: context,
        builder: (context) {
          return CustomBottomSheet(
            child: StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Colors
                    .transparent, // Set the background color as transparent
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter by',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Divider(
                          thickness: 2,
                        ),
                        SizedBox(height: 16.0),
                        buildFilterOption('All', allSelected, () {
                          setState(() {
                            allSelected = true;
                            unreadSelected = false;
                            readSelected = false;
                          });
                          setState(() {});
                        }),
                        buildFilterOption('Unread', unreadSelected, () {
                          setState(() {
                            allSelected = false;
                            unreadSelected = true;
                            readSelected = false;
                          });
                          setState(() {});
                        }),
                        buildFilterOption('Read', readSelected, () {
                          setState(() {
                            allSelected = false;
                            unreadSelected = false;
                            readSelected = true;
                          });
                          setState(() {});
                        }),
                        SizedBox(height: 16.0),
                        GradientButton(
                            text: "Apply Filters",
                            icon: null,
                            onPress: () {
                              searchController.text = "";
                              setState(() {});
                              Navigator.pop(context, true);
                            }),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  Widget buildFilterOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final Widget child;

  CustomBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0.0, -2.0), // Negative y-offset for top shadow
            blurRadius: 4.0,
          ),
        ],
      ),
      // border: Border.all(color: Colors.black)),
      child: child,
    );
  }
}
