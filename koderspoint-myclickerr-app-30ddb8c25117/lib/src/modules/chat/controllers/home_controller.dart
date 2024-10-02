import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';

class HomeController {
  final FirebaseFirestore firebaseFirestore;

  HomeController({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String userType, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch)
          .where(FirestoreConstants.userType, isEqualTo: userType)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where(FirestoreConstants.userType, isEqualTo: userType)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getChatRoomsFireStore(
      String pathCollection, int limit) {
    return firebaseFirestore.collection(pathCollection).snapshots();
  }

}
