// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myclicker_support/Src/UI/ChatScreen.dart';
import 'package:myclicker_support/Src/UI/LoginScreen.dart';
import 'package:myclicker_support/Src/Utils/Extensions.dart';
import 'package:provider/provider.dart';

import '../Controllers/NotificationService.dart';
import '../Models/ChatModels.dart';
import '../Utils/Constants.dart';
import '../Utils/Functions.dart';
import '../Utils/Widgets.dart';

class ChatHomePage extends StatefulWidget {
  ChatHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => ChatHomePageState();
}

class ChatHomePageState extends State<ChatHomePage> {
  ChatHomePageState({Key? key});
  final ScrollController listScrollController = ScrollController();
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  int limit = 200;
  final int limitIncrement = 200;

  bool isLoading = false;
  bool isOpened = false;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseauth = FirebaseAuth.instance;
  late String currentUserId;
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    currentUserId = firebaseauth.currentUser!.uid;
    listScrollController.addListener(scrollListener);
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
        // NotificationServices.sendnotification(value, "", "");
      }
    });
  }

  @override
  void dispose() {
    btnClearController.close();
    //authProvider.toggleUserOnlineStatus(false);
    super.dispose();
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        limit += limitIncrement;
      });
    }
  }

  bool allSelected = true;
  bool unreadSelected = false;
  bool readSelected = false;
  var searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Inbox",
        ),
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
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.darkBlack.withOpacity(0.3))),
                          child: Image.asset(
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection(FirestoreConstants.supportpersons)
                        .doc(FirestoreConstants.supportpersons.toLowerCase())
                        .collection(FirestoreConstants.chats)
                        .orderBy(FirestoreConstants.dateTime,
                            descending: true) // Subcollection for chat rooms
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

                        if (sdocument!.isNotEmpty) {
                          return ListView.separated(
                            itemCount: sdocument.length,
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
        const unreadCounterKey = FirestoreConstants.supportunreadCounter;
        if (docData.containsKey(unreadCounterKey) &&
            docData[unreadCounterKey] > 0) {
          debugLog("enter");
          documents.add(snapshot.docs[i]);
        }
      } else if (readSelected) {
        const unreadCounterKey = FirestoreConstants.supportunreadCounter;
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
      const userNameKey = "name";

      final docData = doc.data();
      return docData.containsKey(userNameKey) &&
          docData[userNameKey]
              .toString()
              .toLowerCase()
              .startsWith(searchController.text.toLowerCase());
    }).toList();

    return updatedDocuments;
  }

  Widget buildItem(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>>? document) {
    if (document != null) {
      ChatRoom userChat = ChatRoom.fromDocument(document);

      String PersonId = document["id"];
      String photoUrl =
          document.data()!.containsKey('photoUrl') ? document['photoUrl'] : '';
      String name =
          document.data()!.containsKey('name') ? document['name'] : '';

      int supportunreadCounter =
          document.data()!.containsKey(FirestoreConstants.supportunreadCounter)
              ? int.parse(
                  document[FirestoreConstants.supportunreadCounter].toString())
              : 0;

      return Column(
        children: [
          InkWell(
            onTap: () {
              closeKeyboard(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    arguments: ChatScreenArguments(
                      peerId: PersonId,
                      peerAvatar: photoUrl,
                      peerNickname: name,
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
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.lightGrey),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FadeInImage.assetNetwork(
                          placeholder: ImageAsset.LogoImage,
                          image: photoUrl.replaceFirst('https', 'http'),
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
                                    image: AssetImage('images/placeholder.png'),
                                  ),
                                  color: AppColors.lightGrey),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: kDefaultSpace * 2.3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            name,
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
                          visible: supportunreadCounter != 0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: kAccentColor,
                            child: FittedBox(
                              child: Text(
                                supportunreadCounter > 99
                                    ? '99+'
                                    : '$supportunreadCounter',
                                style: const TextStyle(
                                    color: kPrimaryTextColor, fontSize: 13),
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
                  decoration: const BoxDecoration(
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
                            const Text(
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
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          thickness: 2,
                        ),
                        const SizedBox(height: 16.0),
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
                        const SizedBox(height: 16.0),
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
