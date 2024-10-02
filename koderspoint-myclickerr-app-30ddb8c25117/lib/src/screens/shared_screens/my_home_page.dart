import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/user.dart' as user;
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_home_startup.dart';
import 'package:photo_lab/src/screens/shared_screens/profile_selections.dart';
import 'package:photo_lab/src/screens/user_screens/u_home_startup.dart';
import 'package:provider/provider.dart';
import '../../modules/chat/controllers/auth_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  static const String route = 'home_screen';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  user.User? loggedInUser;
  bool checking = true;
  late AuthController authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthController>(context, listen: false);
    SessionHelper.getUser().then((loggedInUser) {
      checking = false;
      if (loggedInUser != null) {
        this.loggedInUser = loggedInUser;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold();
    } else {
      if (authProvider.prefs.containsKey('rememberMe')) {
        if (authProvider.prefs.getBool('rememberMe')!) {
          if (loggedInUser != null) {
            if (loggedInUser!.perHourPrice.isEmpty) {
              return UserHomeStartup();
            } else {
              return PhotographerHomeStartup();
            }
          } else {
            return const ProfileSelectionScreen();
          }
        } else {
          return const ProfileSelectionScreen();
        }
      } else {
        return const ProfileSelectionScreen();
      }
    }
  }
}
