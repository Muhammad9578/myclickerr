import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:photo_lab/src/widgets/buttons.dart';

import '../../../models/booking.dart';
import '../../../helpers/helpers.dart';

class PhotographerAcceptBookingScreen extends StatelessWidget {
  static const route = "photographerAcceptBookingScreen";

  const PhotographerAcceptBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Booking bkDetail =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Booking;

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
                  "Booking (${bkDetail.eventTitle}) was successfully accepted",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 24),
                ),
              ),
              30.SpaceY,
              GradientButton(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.5,
                onPress: () {
                  // UserAllBookingsScreen;
                  Navigator.pop(context);

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
