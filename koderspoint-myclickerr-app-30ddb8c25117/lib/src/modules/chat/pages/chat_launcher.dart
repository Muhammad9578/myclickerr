// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_lab/src/modules/chat/constants/constants.dart';
// import 'package:photo_lab/src/modules/chat/pages/chat_page.dart';
// import 'package:photo_lab/src/modules/chat/providers/home_provider.dart';
// import 'package:provider/provider.dart';

// class ChatLauncherScreen extends StatefulWidget {
//   final String targetUserId;

//   const ChatLauncherScreen({Key? key, required this.targetUserId})
//       : super(key: key);

//   @override
//   State<ChatLauncherScreen> createState() => _ChatLauncherScreenState();
// }

// class _ChatLauncherScreenState extends State<ChatLauncherScreen> {
//   late AuthProvider _authProvider;
//   late HomeProvider homeProvider;
//   String? targetFirebaseId;

//   void findFirebaseUserFromId() async {
//     QuerySnapshot snapshot = await homeProvider.firebaseFirestore
//         .collection(FirestoreConstants.pathUserCollection)
//         .get();

//     for (var doc in snapshot.docs) {
//       if (widget.targetUserId == doc['userId']) {
//         targetFirebaseId = doc['id'];
//         String photoUrl = doc['photoUrl'];
//         String nickname = doc['nickname'];
//         Future.microtask(() => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ChatPage(
//                   arguments: ChatPageArguments(
//                       peerId: targetFirebaseId!,
//                       peerAvatar: photoUrl,
//                       peerNickname: nickname,
//                       issupportperson: false),
//                 ),
//               ),
//             ));
//         break;
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     // print('target user id: ${widget.targetUserId}');
//     _authProvider = context.read<AuthProvider>();
//     homeProvider = context.read<HomeProvider>();

//     findFirebaseUserFromId();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
