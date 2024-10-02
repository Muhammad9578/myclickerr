import 'package:flutter/material.dart';

import 'package:photo_lab/src/widgets/buttons.dart';

import '../../../models/booking.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../helpers/helpers.dart';
import '../p_home_startup.dart';

class PhotographerBookingAcceptScreen extends StatelessWidget {
  static const String route = 'photographerBookingAcceptScreen';

  const PhotographerBookingAcceptScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Booking bkDetail =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Booking;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Booking details",
        action: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              'Booking (${bkDetail.username}) was accepted successfully',
              style: MyTextStyle.semiBold05Black
                  .copyWith(fontSize: 24, color: AppColors.black),
            ),
            30.SpaceY,
            GradientButton(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.5,
              text: "Go to home",
              onPress: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    PhotographerHomeStartup.route,
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
