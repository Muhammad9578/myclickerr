import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String email;
  String userType;
  String userId;

  UserChat(
      {required this.id,
      required this.photoUrl,
      required this.nickname,
      required this.aboutMe,
      required this.email,
      required this.userType,
      required this.userId});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.email: email,
      FirestoreConstants.userType: userType,
      FirestoreConstants.userId: userId,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    String email = "";
    String userType = "";
    String userId = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      // photoUrl = doc.get(FirestoreConstants.photoUrl);

      if (doc['photoUrl'].toString().contains('shanzycollection')) {
        photoUrl = doc['photoUrl']
            .toString()
            .replaceFirst('http://shanzycollection.com/photolab/public/',
                'https://myclickerr.info/public/api')
            .replaceFirst(
                'https://app.myclickerr.com/', 'http://myclickerr.info/public/')
            .replaceFirst(
                'http://app.myclickerr.com/', 'http://myclickerr.info/public/');
      } else if (doc['photoUrl'].toString().contains('tap4trip')) {
        photoUrl = doc['photoUrl']
            .toString()
            .replaceFirst('https://tap4trip.com/photolab/public/',
                'https://myclickerr.info/public/api')
            .replaceFirst(
                'https://app.myclickerr.com/', 'http://myclickerr.info/public/')
            .replaceFirst(
                'http://app.myclickerr.com/', 'http://myclickerr.info/public/');
      } else if (doc['photoUrl'].toString().contains('app.myclickerr.com')) {
        photoUrl = doc['photoUrl']
            .toString()
            .replaceFirst(
                'https://app.myclickerr.com/', 'http://myclickerr.info/public/')
            .replaceFirst(
                'http://app.myclickerr.com/', 'http://myclickerr.info/public/');
      } else {
        photoUrl = doc['photoUrl'].toString();
      }
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    try {
      email = doc.get(FirestoreConstants.email);
    } catch (e) {}
    try {
      userType = doc.get(FirestoreConstants.userType);
    } catch (e) {}
    try {
      userId = doc.get(FirestoreConstants.userId);
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
      email: email,
      userType: userType,
      userId: userId,
    );
  }
}
