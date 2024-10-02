// ignore_for_file: must_be_immutable

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/user.dart' as user;
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';
import 'package:provider/provider.dart';
import '../../modules/chat/pages/splash_page.dart';
import '../shared_screens/profile_main_screen.dart';
import 'p_all_bookings/p_booking_tabbar_screen.dart';
import 'p_home_screen/p_homescreen.dart';

class PhotographerHomeStartup extends StatefulWidget {
  static const route = "photographerHomeStartup";
  int selectedIndex;

  PhotographerHomeStartup({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<PhotographerHomeStartup> createState() =>
      _PhotographerHomeStartupState();
}

class _PhotographerHomeStartupState extends State<PhotographerHomeStartup>
    with WidgetsBindingObserver {
  user.User? loggedInUser;
  late FirebaseFirestore firebaseFirestore;
  late FirebaseAuth firebaseAuth;
  late UserController userProvider;
  late PhotographerBookingListController photographerBookingListProvider;

  @override
  void initState() {
    super.initState();
    photographerBookingListProvider =
        Provider.of<PhotographerBookingListController>(context, listen: false);

    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          photographerBookingListProvider.fetchPhotographerBookings(
              loggedInUser.id, context);
          initOneSignal(loggedInUser);
          SessionHelper.getUserType();
        });
      }
    });
    userProvider = Provider.of<UserController>(context, listen: false);

    firebaseFirestore = FirebaseFirestore.instance;
    firebaseAuth = FirebaseAuth.instance;
    toggleUserOnlineStatus(true);

    OneSignal.shared.setNotificationOpenedHandler((notification) {
      var notify = notification.notification.additionalData;
      if (notify!["type"] == "new_booking_request") {
        print("Received notification: new_booking_request");
      }
      if (notify["type"] == "user") {
        //open Profileo(notify["id"])
      }
      if (notify["type"] == "post") {
        //open ViewPost(notify["id"])
      }
      print('Opened');

      debugLog(
          "HELLO HELLO HELLO HELLO  HELLO    =================================================    ${notify.toString()}");
      Provider.of<PhotographerBookingListController>(context, listen: false)
          .fetchPhotographerBookings(loggedInUser!.id, context);
      Provider.of<UserBookingController>(context, listen: false)
          .fetchUserAllBookings(
        loggedInUser!.id,
      );
    });

    // Initialize OneSignal notification received handler

    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      Provider.of<PhotographerBookingListController>(context, listen: false)
          .fetchPhotographerBookings(loggedInUser!.id, context);
      Provider.of<UserBookingController>(context, listen: false)
          .fetchUserAllBookings(
        loggedInUser!.id,
      );

      print("Received notification: ${event.notification.body}");
    });
  }

  void toggleUserOnlineStatus(bool isOnline) {
    final data = {
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch
    };
    User? currentFirebaseUser = firebaseAuth.currentUser;
    if (currentFirebaseUser != null) {
      // print('inside pHome startup firebase user is not null');
      firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(currentFirebaseUser.uid)
          .update(data);
    } else {
      // print('firebase user is null');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    toggleUserOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      //do your stuff
      toggleUserOnlineStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      toggleUserOnlineStatus(true);
    }
  }

  // ***********************************************
  // bottom nav bar
  //static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    PhotographerHomeScreen1(),
    // SplashPage(),
    SplashPage(
      issupportperson: false,
    ),
    // Center(child: Text("No User found"),),

    PhotographerBookingBarScreen(),
    CombinedProfileMainScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(widget.selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 3),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 3),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(FirestoreConstants.supportpersons)
                      .doc(FirestoreConstants.supportpersons.toLowerCase())
                      .collection("chats")
                      .doc(FirebaseAuth.instance.currentUser!.uid ?? "")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Icon(Icons.chat); // PlaceholderFor loading
                    }

                    if (snapshot.hasError) {
                      return Icon(Icons.chat);
                    }
                    final data = snapshot.data?.data() as Map<String, dynamic>?;

                    int unredcounter = data?['unreadCounter'] ?? 0;
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: firebaseFirestore
                            .collection(FirestoreConstants.pathRoomsCollection)
                            .where(FirestoreConstants.users,
                                arrayContains: firebaseAuth.currentUser!.uid)
                            .orderBy(FirestoreConstants.dateTime,
                                descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Icon(Icons.chat); // Show a loading indicator
                          }

                          if (snapshot.hasError) {
                            return Icon(Icons.chat);
                          }

                          // Calculate the total unreadCounter
                          int totalUnreadCounter = 0;
                          if (snapshot.hasData) {
                            final documents = snapshot.data!.docs;
                            for (var document in documents) {
                              debugLog(document
                                  .data()[FirestoreConstants.unreadCounter]
                                  .toString());
                              if (document.data().containsKey(
                                  '${FirestoreConstants.unreadCounter}-${firebaseAuth.currentUser!.uid}')) {
                                debugLog(document
                                    .data()[
                                        '${FirestoreConstants.unreadCounter}-${firebaseAuth.currentUser!.uid}']
                                    .toString());
                                if (document.data()[
                                        '${FirestoreConstants.unreadCounter}-${firebaseAuth.currentUser!.uid}'] >
                                    0) {
                                  totalUnreadCounter += 1;
                                }
                              }
                            }
                          }

                          if (unredcounter > 0) {
                            totalUnreadCounter += 1;
                          }
                          return totalUnreadCounter == 0
                              ? Icon(Icons.chat)
                              : badges.Badge(
                                  badgeContent: Text(
                                    '$totalUnreadCounter',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.red,
                                  ),
                                  position: badges.BadgePosition.topEnd(
                                      top: -8, end: -8),
                                  child: Icon(Icons.chat),
                                );
                        });
                  }),
            ),
            label: 'Inbox',
          ),
          ///////

          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.only(top: 5.0, bottom: 3),
          //     child: Icon(Icons.chat),
          //   ),
          //   label: 'Inbox',
          // ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 3),
              child: Consumer<PhotographerBookingListController>(
                  builder: (context, bookingListPrvdr, child) {
                return bookingListPrvdr.pendingBooking.isEmpty
                    ? Icon(Icons.shopping_bag_rounded)
                    : badges.Badge(
                        badgeContent: Text(
                          '${bookingListPrvdr.pendingBooking.length}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.red), // Customize badge color
                        position: badges.BadgePosition.topEnd(
                            top: -8, end: -8), // Adjust position
                        child: Icon(Icons.shopping_bag_rounded),
                      );
              }),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 3),
              child: Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: widget.selectedIndex,
        iconSize: 25,
        selectedItemColor: AppColors.darkOrange,
        selectedLabelStyle: MyTextStyle.semiBold05Black.copyWith(
          fontSize: 14,
        ),
        enableFeedback: true,
        onTap: _onItemTapped,
        unselectedItemColor: AppColors.orange.withOpacity(0.8),
        unselectedLabelStyle: MyTextStyle.medium07Black
            .copyWith(fontSize: 14, color: AppColors.black.withOpacity(0.7)),
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Future<int> getUnreadCounter() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .collection("chats")
        .doc(FirebaseAuth.instance.currentUser!.uid ?? "")
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['unreadCounter'] ?? 0;
    }

    return 0; // Default value if document doesn't exist
  }
}
