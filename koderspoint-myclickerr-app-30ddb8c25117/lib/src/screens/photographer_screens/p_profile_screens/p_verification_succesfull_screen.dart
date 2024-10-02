import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:photo_lab/src/widgets/buttons.dart';

import '../../../models/booking.dart';
import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../shared_screens/on_boarding_screen.dart';
import '../p_home_startup.dart';

class PhotographerVerificationSuccessfulScreen extends StatelessWidget {
  static const route = "photographerVerificationSuccessfulScreen";

  const PhotographerVerificationSuccessfulScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(title: "Booking Confirmed", action: []),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/jsons/accept_animation.json', height: 170),
              30.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "Verification Successful",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 24),
                ),
              ),
              10.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "You can be able to access the application now",
                  style: MyTextStyle.mediumBlack.copyWith(fontSize: 14),
                ),
              ),
              30.SpaceY,
              GradientButton(
                width: MediaQuery.of(context).size.width * 0.5,
                onPress: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      OnBoardingScreen.route,
                      arguments: {'userType': UserType.photographer},
                      (Route<dynamic> route) => false);
                },
                text: "Continue",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
