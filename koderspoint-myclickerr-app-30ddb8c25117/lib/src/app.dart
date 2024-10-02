import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import 'package:photo_lab/src/controllers/shared_controllers/sharedcontroller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_add_booking_order_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_photographer_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/my_routes.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/screens/shared_screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);

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
        ChangeNotifierProvider<UserController>(
          create: (_) => UserController(prefs: prefs),
        ),
        ChangeNotifierProvider<UserAddBookingOrderController>(
          create: (_) => UserAddBookingOrderController(),
        ),
        ChangeNotifierProvider<PhotographerPortfolioController>(
          create: (_) => PhotographerPortfolioController(),
        ),
        ChangeNotifierProvider<PhotographerBookingListController>(
          create: (_) => PhotographerBookingListController(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider<UserSidePhotographerController>(
          create: (_) => UserSidePhotographerController(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider<UserBookingController>(
          create: (_) => UserBookingController(),
        ),
        ChangeNotifierProvider<SharedController>(
          create: (_) => SharedController(),
        ),
        ChangeNotifierProvider<PhotorapherController>(
          create: (_) => PhotorapherController(),
        ),
        Provider<SettingController>(
          create: (_) => SettingController(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
        Provider<HomeController>(
          create: (_) => HomeController(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<ChatController>(
          create: (_) => ChatController(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
        ChangeNotifierProvider<CustomOrderController>(
          create: (_) => CustomOrderController(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
      ],
      child: FGBGNotifier(
        onEvent: (FGBGType event) {
          // print("online offline event: $event");
          if (event == FGBGType.foreground) {
            AppFunctions.toggleUserOnlineStatus(true);
          } else if (event == FGBGType.background) {
            AppFunctions.toggleUserOnlineStatus(false);
          }
        },
        child: MaterialApp(
          title: kAppName,
          theme: ThemeData(
            primarySwatch: primaryBlack,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.kOnPrimaryColor,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Colors.white),
              child: SafeArea(child: const SplashScreen())),
          initialRoute: SplashScreen.route,
          routes: MyRoutes.namedRoutes,
          onGenerateRoute: MyRoutes.onGenerateRoutes,
        ),
      ),
    );
  }
}
