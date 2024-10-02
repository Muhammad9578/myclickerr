import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'Constants.dart';

closeKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

void debugLog(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

String prettyDateTimeChat(int timestamp) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;

  DateTime currentDate = DateTime.fromMillisecondsSinceEpoch(currentTime);
  DateTime chatDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

  const int aDay = 1000 * 60 * 60 * 24;
  int diff = currentTime - timestamp;
  if (diff < aDay) {
    //less than 24 hours
    return "Today ${DateFormat('hh:mm a').format(chatDate)}";
  } else if (currentDate.year != chatDate.year) {
    return DateFormat('dd MMM yy, hh:mm a').format(chatDate);
  } else {
    return DateFormat('dd MMM, hh:mm a').format(chatDate);
  }
}

String prettyDateTime(int timestamp) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  const int aDay = 1000 * 60 * 60 * 24;
  int diff = currentTime - timestamp;
  if (diff < aDay) {
    //less than 24 hours
    return DateFormat('hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  } else if (diff >= 1000 * 60 * 60 * 24 && diff < aDay * 2) {
    return 'Yesterday';
  } else {
    return DateFormat('dd MMM')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }
}
