import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:photo_lab/src/widgets/buttons.dart';

import '../../../models/booking.dart';
import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../shared_screens/profile_selections.dart';

class PhotographerPendingVerificationScreen extends StatelessWidget {
  static const route = "photographerPendingVerificationScreen";

  const PhotographerPendingVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Booking bkDetail =
    // ModalRoute.of(context)!.settings.arguments as Booking;

    return Scaffold(
      // appBar: CustomAppBar(title: "Booking Confirmed", action: []),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              80.SpaceY,
              kLogoImage,
              Spacer(),
              Lottie.asset('assets/jsons/see_saw_loader.json', height: 170),
              15.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "Verification Pending",
                  style: MyTextStyle.boldBlack.copyWith(fontSize: 28),
                ),
              ),
              15.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "Let us see your profile and verify. Once the verification is done you can be able to access MyClicker.",
                  style: MyTextStyle.medium07Black
                      .copyWith(fontSize: 15, height: 1.5),
                ),
              ),
              Spacer(),
              GradientButton(
                // width: MediaQuery.of(context).size.width * 0.5,
                onPress: () {
                  // UserAllBookingsScreen;
                  Navigator.pushNamedAndRemoveUntil(
                      context, ProfileSelectionScreen.route, (route) => false);

                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //       builder: (context) => PhotographerHomeStartup(
                  //             selectedIndex: 0,
                  //           )),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                text: "Go to Home",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
