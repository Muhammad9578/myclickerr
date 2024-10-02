import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/screens/shared_screens/market_place_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_side_photographer_profile_screen/u_hire_photographer_screen.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';

class PhotographerHomeScreen1 extends StatelessWidget {
  static const String route = "PhotographerLandingPage";

  const PhotographerHomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    //var photographerBookingListProvider = Provider.of<PhotographerBookingListProvider>(context, listen: false);

    return Scaffold(
      // extendBody: true,
      // extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: "Bookings",
      ),

      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Hire a Photographer"),
                Tab(text: "Market"),
              ],
              unselectedLabelStyle:
                  MyTextStyle.medium07Black.copyWith(fontSize: 16),
              unselectedLabelColor: AppColors.black.withOpacity(0.7),
              labelStyle: MyTextStyle.semiBoldBlack.copyWith(fontSize: 15),
              labelColor: AppColors.black,
              indicatorWeight: 5,
              indicatorColor: AppColors.orange,
              padding: EdgeInsets.only(left: 20, right: 20),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  UserHirePhotographer(),
                  MarketplaceScreen1(),
                  // PhotographerNewBookingRequestScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
