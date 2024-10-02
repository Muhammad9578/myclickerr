import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_lab/src/modules/chat/constants/color_constants.dart';
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/auth_controller.dart';
import 'package:photo_lab/src/modules/chat/controllers/home_controller.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';
import 'pages.dart';

class SplashPage extends StatefulWidget {
  static const String route = "splashPage";
  final String? targetUserId;
  final bool issupportperson;

  const SplashPage({Key? key, this.targetUserId, required this.issupportperson})
      : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  Widget? nextScreen;
  NotificationController notificationServices = NotificationController();
  @override
  void initState() {
    super.initState();
    /*Future.delayed(const Duration(seconds: 1), () {
      // just delay for showing this slash page clearer because it too fast
    });*/
    checkSignedIn();

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

  void checkSignedIn() async {
    AuthController authProvider = context.read<AuthController>();
    HomeController homeProvider = context.read<HomeController>();

    bool isLoggedIn = await authProvider.isLoggedIn();
    if (!mounted) {
      // print("not mounted");
      return;
    }
    if (isLoggedIn) {
      // print('already logged in to chat');

      if (widget.targetUserId != null) {
        log("widget.targetUserId = ${widget.targetUserId}");
        QuerySnapshot snapshot = await homeProvider.firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .get();
        log('going to find user with this id: ${widget.targetUserId}');
        for (var doc in snapshot.docs) {
          if (widget.targetUserId == (doc['userId'] ?? '')) {
            log("userId: ${doc['userId']}");
            String targetFirebaseId = doc['id'];

            String photoUrl = '';

            if (doc['photoUrl'].toString().contains('shanzycollection')) {
              photoUrl = doc['photoUrl'].toString().replaceFirst(
                  'http://shanzycollection.com/photolab/public/',
                  'https://myclickerr.info/public/api');
            } else if (doc['photoUrl'].toString().contains('tap4trip')) {
              photoUrl = doc['photoUrl'].toString().replaceFirst(
                  'https://tap4trip.com/photolab/public/',
                  'https://myclickerr.info/public/api');
            } else if (doc['photoUrl']
                .toString()
                .contains('app.myclickerr.com')) {
              photoUrl = doc['photoUrl']
                  .toString()
                  .replaceFirst('https://app.myclickerr.com/',
                      'http://myclickerr.info/public/api')
                  .replaceFirst('http://app.myclickerr.com/',
                      'http://myclickerr.info/public/api');
            } else {
              photoUrl = doc['photoUrl'].toString();
            }
            // String photoUrl = doc['photoUrl'];
            String nickname = doc['nickname'];
            Future.microtask(() {
              // nextScreen = ChatPage(
              //   arguments: ChatPageArguments(
              //       peerId: targetFirebaseId,
              //       peerAvatar: photoUrl,
              //       peerNickname: nickname),
              // );
              // setState(() {
              //
              // });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    arguments: ChatPageArguments(
                        peerId: targetFirebaseId,
                        peerAvatar: photoUrl,
                        peerNickname: nickname,
                        issupportperson: widget.issupportperson),
                  ),
                ),
              );
            });
            //break;
            return;
          }
        }
        Future.microtask(() => Navigator.pop(context));
        Toasty.error('User not found');
      } else {
        nextScreen = HomePage(
          targetUserId: null,
        );
        setState(() {});
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //     const HomePage(
        //       targetUserId: null,
        //     ),
        //   ),
        // );
      }
      return;
    }
    // print('not logged in to chat');
    //try to login user with email
    User? loggedInUser = await SessionHelper.getUser();
    if (loggedInUser != null) {
      authProvider
          .handleSignInWithEmail(
              loggedInUser.id.toString(),
              loggedInUser.email,
              loggedInUser.email,
              loggedInUser.name,
              loggedInUser.profileImage,
              loggedInUser.perHourPrice == "null" ||
                      loggedInUser.perHourPrice.isEmpty
                  ? "1"
                  : "2")
          .then((isSuccess) {
        if (isSuccess) {
          nextScreen = HomePage(
            targetUserId: widget.targetUserId,
          );
          setState(() {});
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => HomePage(
          //             targetUserId: widget.targetUserId,
          //           )),
          // );
        }
      });
    } else {
      if (mounted) Navigator.pop(context);
    }
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    AuthController authProvider = Provider.of<AuthController>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        //Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
      body: nextScreen == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  /*Image.asset(
              "images/photo_lab_logo.png",
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),*/
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        color: ColorConstants.themeColor),
                  ),
                ],
              ),
            )
          : nextScreen,
    );
  }
}
