import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Src/Controllers/ChatController.dart';
import 'Src/UI/SplashScreen.dart';
import 'Src/Utils/Constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  OneSignal.shared.setLogLevel(
      kDebugMode ? OSLogLevel.verbose : OSLogLevel.none, OSLogLevel.none);
  OneSignal.shared.setAppId(kOneSignalAppID);
  OneSignal.shared.consentGranted(true);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  SharedPreferences prefs;
  MyApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const int blackPrimaryValue = 0xFF000000;

    const MaterialColor primaryBlack = MaterialColor(
      blackPrimaryValue,
      <int, Color>{
        50: Color(blackPrimaryValue),
        100: Color(blackPrimaryValue),
        200: Color(blackPrimaryValue),
        300: Color(blackPrimaryValue),
        400: Color(blackPrimaryValue),
        500: Color(blackPrimaryValue),
        600: Color(blackPrimaryValue),
        700: Color(blackPrimaryValue),
        800: Color(blackPrimaryValue),
        900: Color(blackPrimaryValue),
      },
    );
    return MultiProvider(
      providers: [
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            prefs: prefs,
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
          ),
        ),
      ],
      child: FGBGNotifier(
        onEvent: (FGBGType event) {
          // print("online offline event: $event");
          if (event == FGBGType.foreground) {
            toggleUserOnlineStatus(true);
          } else if (event == FGBGType.background) {
            toggleUserOnlineStatus(false);
          }
        },
        child: MaterialApp(
          title: "My Clickerr Support",
          theme: ThemeData(
            primarySwatch: primaryBlack,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: kPrimaryColor,
              foregroundColor: kOnPrimaryColor,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Colors.transparent),
              child: const SafeArea(child: SplashScreen())),
        ),
      ),
    );
  }
}

void toggleUserOnlineStatus(bool isOnline) {
  final data = {
    'isOnline': isOnline,
    'lastSeen': DateTime.now().millisecondsSinceEpoch
  };
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? currentFirebaseUser = firebaseAuth.currentUser;
  if (currentFirebaseUser != null) {
    firebaseFirestore
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .update(data);
  } else {}
}
