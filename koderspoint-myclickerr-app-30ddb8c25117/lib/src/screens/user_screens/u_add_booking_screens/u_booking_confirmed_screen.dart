import 'package:flutter/material.dart';

import 'package:photo_lab/src/screens/user_screens/u_home_startup.dart';
import 'package:photo_lab/src/widgets/buttons.dart';

import '../../../widgets/custom_appbar.dart';
import '../../../helpers/helpers.dart';

class UserBookingConfirmedScreen extends StatelessWidget {
  static const route = "userBookingConfirmedScreen";

  const UserBookingConfirmedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Booking Confirmed", action: []),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              20.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "Your Booking was successful",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 24),
                ),
              ),
              20.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Text(
                  textAlign: TextAlign.center,
                  "We’ll notify you once the photographer accepts your Booking invitation",
                  style: MyTextStyle.semiBold07Black.copyWith(fontSize: 14),
                ),
              ),
              30.SpaceY,
              GradientButton(
                onPress: () {
                  // UserAllBookingsScreen;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => UserHomeStartup(
                              selectedIndex: 2,
                            )),
                    (Route<dynamic> route) => false,
                  );
                },
                text: "My Bookings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
