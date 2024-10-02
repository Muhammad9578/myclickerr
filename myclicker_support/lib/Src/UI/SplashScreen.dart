import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myclicker_support/Src/UI/ChatHomepage.dart';
import 'package:myclicker_support/Src/UI/ChatScreen.dart';
import 'package:myclicker_support/Src/UI/LoginScreen.dart';
import '../Utils/Constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  FirebaseAuth firebaseauth = FirebaseAuth.instance;
  navigate() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        // FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => firebaseauth.currentUser != null
                    ? ChatHomePage()
                    : LoginScreen()));
      },
    );
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 50, end: 600).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    controller.reverse(from: 500);
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: animation.value,
          width: animation.value,
          child: Image.asset(ImageAsset.AppIcon),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
