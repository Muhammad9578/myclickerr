import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_lab/src/models/event_category.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/helpers/prefs.dart';
import 'package:photo_lab/src/screens/shared_screens/webview_screen.dart';
import 'package:place_picker/place_picker.dart';

import 'constants.dart';

List<EventCategory> categoriesData = [];

void debugLog(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

bool rememberMe = false;

List<String> photographerAvailabilityList = [
  "1:00 AM",
  "2:00 AM",
  "3:00 AM",
  "4:00 AM",
  "5:00 AM",
  "6:00 AM",
  "7:00 AM",
  "8:00 AM",
  "9:00 AM",
  "10:00 AM",
  "11:00 AM",
  "12:00 PM",
  "01:00 PM",
  "02:00 PM",
  "03:00 PM",
  "04:00 PM",
  "05:00 PM",
  "06:00 PM",
  "07:00 PM",
  "08:00 PM",
  "09:00 PM",
  "10:00 PM",
  "11:00 PM",
  "12:00 AM",
];

String getCardType(String cardNumber) {
  cardNumber = cardNumber.replaceAll(" ", "");
  if (cardNumber.startsWith("4")) {
    return "Visa";
  } else if (cardNumber.startsWith("5")) {
    return "Mastercard";
  } else {
    return "";
  }
}

void launchURL(BuildContext context, String url) async {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => WebViewScreen(url: url),
  ));
  /*try {
    await tabs.launch(
      url,
      customTabsOption: tabs.CustomTabsOption(
        toolbarColor: Theme.of(context).primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: tabs.CustomTabsSystemAnimation.slideIn(),
        // or user defined animation.
        */ /*animation: const CustomTabsAnimation(
          startEnter: 'slide_up',
          startExit: 'android:anim/fade_out',
          endEnter: 'android:anim/fade_in',
          endExit: 'slide_down',
        ),*/ /*
        extraCustomTabs: const <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
      safariVCOption: tabs.SafariViewControllerOption(
        preferredBarTintColor: Theme.of(context).primaryColor,
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle: tabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debug// print(e.toString());
  }*/
}

Future<void> initOneSignal(User loggedInUser) async {
  final status = await OneSignal.shared.getDeviceState();
  final String? osUserID = status?.userId;
  try {
    if (osUserID != null) {
      Prefs.setOnesignalUserId(osUserID);
      try {
        Response response = await Dio().post(ApiClient.updateOneSignalIdUrl,
            data: {'user_id': loggedInUser.id, 'onesignal_id': osUserID});
        if (response.statusCode == 200) {
          debugLog(response.data);
        }
      } on DioError catch (e) {
        debugLog(e);
      }
    } else {
      debugLog('onesignal id is null');
    }
  } catch (e) {
    debugLog("Exception with initOneSignal error is: $e");
  }
  // We will update this once he logged in and goes to dashboard.
  //updateUserProfile(osUserID);
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

String prettyDateTimePortfolio(int timestamp) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd MMM, yyyy - hh:mm a').format(date);
}

String prettyDateTimeForTimeline(int timestamp) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('dd MMM, yyyy - hh:mm a').format(date);
}

String prettyDateTimeForNotification(int timestamp) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;

  DateTime currentDate = DateTime.fromMillisecondsSinceEpoch(currentTime);
  DateTime notificationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

  const int aDay = 1000 * 60 * 60 * 24;
  int diff = currentTime - timestamp;
  if (diff < aDay) {
    //less than 24 hours
    return DateFormat('hh:mm a').format(notificationDate);
  } else if (currentDate.year != notificationDate.year) {
    return DateFormat('dd MMM yy, hh:mm a').format(notificationDate);
  } else {
    return DateFormat('dd MMM, hh:mm a').format(notificationDate);
  }
}



/*bool isKeyboardShowing() {
  return WidgetsBinding.instance.window.viewInsets.bottom > 0;
}*/

closeKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$')
        .hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool isValidNumbers() {
    return RegExp(r'^(-?)(0|([1-9][0-9]*))([0-9]+)?$').hasMatch(this);
  }
}

Future<LocationResult> pushScreenWithDelay<LocationResult>(
    BuildContext context, Widget page) {
  return Navigator.push<LocationResult>(
          context, MaterialPageRoute(builder: (context) => page))
      .then((result) async {
    await Future.delayed(
        Duration(milliseconds: 500)); // Add a delay of 500 milliseconds
    return result!;
  });
}

Future<LocationResult> showPlacePicker(BuildContext context,
    {LatLng? displayLocation, LatLng? defaultLocation}) async {
  LocationResult? result;
  try {
    result = await pushScreenWithDelay<LocationResult>(
      context,
      PlacePicker(
        defaultLocation: defaultLocation,
        displayLocation: displayLocation,
        kGoogleMapsKey,
      ),
    );
    // result = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => PlacePicker(
    //       kGoogleMapsKey,
    //     ),
    //   ),
    // );

    //// print(result);
    return result;
  } catch (e) {
    debugLog("Exception in picking location: $e");
    throw "Exception in picking location: $e";
  }
}

double checkDouble(dynamic value) {
  if (value == null) {
    return 0.toDouble();
  } else if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
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

Future<void> deleteDialog(title, description, context, onDelete) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              // color: AppColors.orange,
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Icon(
                      Icons.delete_forever_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$title',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$description',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Cancel',
                    style: TextStyle(
                        color: AppColors.black.withOpacity(0.8),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: onDelete,
              //     () {
              //   Navigator.pop(context, 1);
              // },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.red,
                    ),
                  ),
                  Text(
                    'Yes',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        );
      });
}

Future<bool> ExitDialog(context) async {
  switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              // color: AppColors.orange,
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                ),
              ),
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
                    'Exit App',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Are you sure to Exit?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                // Navigator.of(context).pop(false);
                Navigator.pop(context, 0);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Cancel',
                    style: TextStyle(
                        color: AppColors.black.withOpacity(0.8),
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
                      color: AppColors.red,
                    ),
                  ),
                  Text(
                    'Yes',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        );
      })) {
    case 0:
      return false;
    case 1:
      return true;
    default:
      return false;
  }
}
