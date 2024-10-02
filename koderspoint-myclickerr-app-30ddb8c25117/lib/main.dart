import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:photo_lab/src/app.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

var prefss;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // set the publishable key for Stripe - this is mandatory
  Stripe.publishableKey = kStripeKey;
  prefss = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    name: 'MyClickerr',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.shared.setLogLevel(
      kDebugMode ? OSLogLevel.verbose : OSLogLevel.none, OSLogLevel.none);
  OneSignal.shared.setAppId(kOneSignalAppID);
  OneSignal.shared.consentGranted(true);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}
