import 'package:flutter/material.dart';

import '../../helpers/helpers.dart';
import 'my_home_page.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "splashScreen";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  navigate() {
    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacementNamed(
          context,
          MyHomePage.route,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    // #docregion addListener
    animation = Tween<double>(begin: 50, end: 600).animate(controller)
      ..addListener(() {
        // #enddocregion addListener
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
    // #enddocregion addListener
    controller.reverse(from: 500);
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    //double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          // alignment: Alignment.center,
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
