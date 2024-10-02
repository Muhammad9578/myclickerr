import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';
import 'package:photo_lab/src/network/api_client.dart';

import 'helpers.dart';

class AppFunctions {
  static String imagepath = '';
  static Future<List<File>> pickImagesFromGallery(context) async {
    final picker = ImagePicker(); // Instance of Image picker
    List<File> selectedImages = [];
    final pickedFile = await picker.pickMultiImage(
        // imageQuality: 100, // To set quality of images
        // maxHeight: 300, // To set maxheight of images that you want in your app
        // maxWidth: 300
        ); // To set maxheight of images that you want in your app
    List<XFile> xfilePick = pickedFile;

    if (xfilePick.isNotEmpty) {
      for (var i = 0; i < xfilePick.length; i++) {
        selectedImages.add(File(xfilePick[i].path));
      }
      return selectedImages;
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1), content: Text('Nothing selected')));

      return selectedImages;
    }
  }

  ///remove one signal
  static void removeOneSignalId(int userId) async {
    try {
      Response response = await Dio().post(ApiClient.updateOneSignalIdUrl,
          data: {'user_id': userId, 'onesignal_id': ''});
      if (response.statusCode == 200) {
        debugLog(response.data);
      }
    } on DioError catch (e) {
      debugLog(e);
    }
  }

  static void toggleUserOnlineStatus(bool isOnline) {
    final data = {
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch
    };
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser != null) {
      // print('inside custom appbar firebase user is not null');
      FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .doc(currentFirebaseUser.uid)
          .update(data);
    } else {
      // print('firebase user is null');
    }
  }

  static Future choosePhoto(context) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: AppColors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Gallery',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "gallery");
              },
            ),
            const SizedBox(width: 6),
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: AppColors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Camera',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "camera");
              },
            )
          ],
        );
      },
    );

    if (result != null) {
      final ImagePicker picker = ImagePicker();
      // Pick an image
      final XFile? image = await picker.pickImage(
          source:
              result == "gallery" ? ImageSource.gallery : ImageSource.camera,
          maxHeight: 500,
          maxWidth: 500);
      if (image != null) {
        imagepath = image.path;

        return Image.file(
          File(imagepath),
          fit: BoxFit.cover,
        );
      }
    }

    return null;
  }

  static Future<File> getFileImage() async {
    var bytes = await rootBundle.load(ImageAsset.PlaceholderImg);
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/profile.png');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    return file;
  }

  static List<Map<String, String>> creatingTimeSLotJson(slots) {
    List<Map<String, String>> timeSlots = [];
    slots.forEach((element) {
      Map<String, String> slot = {'time': element};
      timeSlots.add(slot);
    });

    // print(" jsonEncode in last: ${jsonEncode(timeSlots)}");
    return timeSlots;
  }

  static createSessionOtp() {
    var rng = new Random();
    int sessionOtp = rng.nextInt(900000) + 100000;

    return sessionOtp;
  }



 static createNewSession(photographerBookingListProvider, bkDetail, sessionOtp) {
    photographerBookingListProvider.firebaseFirestore
        .collection(FirestoreConstants.pathSessionCollection)
        .doc(bkDetail.id.toString())
        .set({
      'bookingId': bkDetail.id,
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'endTime': -1,
      'onGoing': true,
      'userId': bkDetail.userId,
      'photographerId': bkDetail.photographerId,
      'otp': sessionOtp,
      'totalHours': -1.0,
    }).then((value) {
      
    }).catchError((error) {
      print("Failed to add user: $error");
      Toasty.error("Unable to create session. Try again");
      
    });
  }
}
