import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthController extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthController({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  User? getCurrentFirebaseUser() {
    return firebaseAuth.currentUser;
  }

  Future<bool> isLoggedIn() async {
    //bool isLoggedIn = await googleSignIn.isSignedIn();
    bool isLoggedIn = firebaseAuth.currentUser != null;
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onlyCreateUserForEmailVerification(
      String email, String password) async {
    late final UserCredential credential;

    User? firebaseUser;
    try {
      try {
        firebaseUser = (await firebaseAuth.signInWithEmailAndPassword(
                email: email.trim(), password: password.trim()))
            .user;
      } on FirebaseAuthException catch (e) {
        debugLog("Firebase exception 1: $e");

        // print('code: ${e.code}');
        if (e.code == 'wrong-password') {
        } else if (e.code == 'user-not-found') {
          firebaseUser = (await firebaseAuth.createUserWithEmailAndPassword(
                  email: email, password: password))
              .user;
        }
      }
      if (firebaseUser != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print("exception e: $e");
      if (e.code == 'weak-password') {
        throw 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'email-already-in-use';
      } else if (e.code == 'network-request-failed')
        throw 'No Internet Connection';
      else if (e.code == 'invalid-email')
        throw 'Email not valid';
      else {
        throw 'Network error. Try again later';
      }
    } catch (e) {
      throw 'Network error. Try again later';
    }

    return false;
  }

  Future<bool> handleSignInWithEmail(String userId, String email,
      String password, String name, String photoURL, String userType) async {
    _status = Status.authenticating;
    notifyListeners();
    debugLog("inside firebase signin");
    //User? firebaseUser = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;
    User? firebaseUser;
    try {
      firebaseUser = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
    } on FirebaseAuthException catch (e) {
      debugLog("Firebase exception: $e");

      // print('code: ${e.code}');
      if (e.code == 'wrong-password') {
      } else if (e.code == 'user-not-found') {
        firebaseUser = (await firebaseAuth.createUserWithEmailAndPassword(
                email: email, password: password))
            .user;
      }
    }
    if (firebaseUser != null) {
      debugLog(
          "inside auth_provider Firebase user is not null: ${firebaseUser.uid}");
      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        await firebaseUser.updateProfile(displayName: name, photoURL: photoURL);
        firebaseUser = firebaseAuth.currentUser!;
        firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebaseUser.uid)
            .set({
          FirestoreConstants.nickname: name,
          FirestoreConstants.photoUrl: photoURL,
          FirestoreConstants.id: firebaseUser.uid,
          FirestoreConstants.email: firebaseUser.email,
          FirestoreConstants.userType: userType,
          FirestoreConstants.userId: userId,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.chattingWith: null,
          FirestoreConstants.isverifiedscreenshown: false
        });

        // Write data to local storage
        User? currentUser = firebaseUser;
        await prefs.setString(FirestoreConstants.id, currentUser.uid);
        await prefs.setString(
            FirestoreConstants.nickname, currentUser.displayName ?? "");
        await prefs.setString(
            FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        await prefs.setString(
            FirestoreConstants.email, currentUser.email ?? "");
        await prefs.setString(FirestoreConstants.userType, userType);
        await prefs.setString(FirestoreConstants.userId, userId);
      } else {
        // print(" Already sign up, just get data from firestore");
        DocumentSnapshot documentSnapshot = documents[0];
        UserChat userChat = UserChat.fromDocument(documentSnapshot);
        // print("firebaseUser.uid: ${firebaseUser.uid} \n  userChat.id: ${ userChat.id}" );

        // Write data to local
        await prefs.setString(FirestoreConstants.id, userChat.id);
        await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
        await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
        await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        await prefs.setString(FirestoreConstants.email, userChat.email);
        await prefs.setString(FirestoreConstants.userType, userChat.userType);
        await prefs.setString(FirestoreConstants.userId, userChat.userId);
      }
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          // Writing data to server because here is a new user
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          // Write data to local
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

/*void toggleUserOnlineStatus(bool isOnline) {
    final data = {
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch
    };
    firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(getUserFirebaseId())
        .update(data);
  }*/
}
