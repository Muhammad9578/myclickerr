import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

import '../../../controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import '../../../helpers/session_helper.dart';
import '../p_home_startup.dart';
import 'p_active_booking_screen.dart';
import 'p_new_booking_request_screen.dart';

class PhotographerBookingBarScreen extends StatelessWidget {
  const PhotographerBookingBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (SessionHelper.userType == '2') {
          print("photographer");
          Navigator.pushNamedAndRemoveUntil(
              context, PhotographerHomeStartup.route, (route) => false);
        } else {
          print("user");
        }
        return false;
      },
      child: Scaffold(
        // extendBody: true,
        // extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: "Bookings",
        ),
        // appBar: AppBar(
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(icon: Icon(Icons.directions_car)),
        //       Tab(icon: Icon(Icons.directions_transit)),
        //       Tab(icon: Icon(Icons.directions_bike)),
        //     ],
        //   ),
        //   title: const Text('Tabs Demo'),
        // ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: "Active Bookings"),
                  Consumer<PhotographerBookingListController>(
                      builder: (context, bookingListPrvdr, child) {
                    return Tab(
                        text:
                            "New Requests(${bookingListPrvdr.pendingBooking?.length ?? 0})");
                  }),
                ],
                unselectedLabelStyle:
                    MyTextStyle.medium07Black.copyWith(fontSize: 16),
                unselectedLabelColor: AppColors.black.withOpacity(0.7),
                labelStyle: MyTextStyle.semiBold05Black.copyWith(fontSize: 16),
                labelColor: AppColors.black,
                indicatorWeight: 5,
                indicatorColor: AppColors.orange,
                padding: EdgeInsets.only(left: 20, right: 20),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PhotographerActiveBookingsScreen(),
                    PhotographerNewBookingRequestScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
