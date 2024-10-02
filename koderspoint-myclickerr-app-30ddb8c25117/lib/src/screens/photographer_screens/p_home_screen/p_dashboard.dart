import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_all_bookings/p_all_booking_screen.dart';
import 'package:photo_lab/src/widgets/booking_details_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../widgets/my_bar_graph.dart';

class PhotographerDashboardScreen extends StatefulWidget {
  static const String route = "photographerDashboardScreen";

  const PhotographerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerDashboardScreen> createState() =>
      _PhotographerDashboardScreenState();
}

class _PhotographerDashboardScreenState
    extends State<PhotographerDashboardScreen> {
  bool isLoading = false;

  //Future<List<Booking>?>? _value;
  User? loggedInUser;

  late PhotographerBookingListController photographerBookingListProvider;

  getData() {
    SessionHelper.getUser().then((value) {
      if (value != null) {
        loggedInUser = value;
      }
    });
  }

  @override
  initState() {
    super.initState();
    photographerBookingListProvider =
        Provider.of<PhotographerBookingListController>(context, listen: false);

    SessionHelper.getUser().then((value) {
      if (value != null) {
        loggedInUser = value;
        // _value = fetchData(loggedInUser!.id);

        // photographerBookingListProvider.fetchUserBooking(loggedInUser!.id);
        // photographerBookingListProvider.setBookingDetails(_value);
        // setState(() {});
        // _value = fetchData(5);
      }
    });
    // getData();
  }

  Widget infoCardsBuild({quantity, icon, title, color, iconColor}) {
    return Container(
      padding: EdgeInsets.all(15),
      // width: w * 0.4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$quantity',
                style: MyTextStyle.boldBlack.copyWith(fontSize: 24),
              ),
              Icon(icon, color: iconColor),
            ],
          ),
          15.SpaceY,
          Text(
            title,
            style: MyTextStyle.medium07Black
                .copyWith(fontSize: 14, color: Colors.black.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: SmartRefresher(
        controller: photographerBookingListProvider.pHomeRefreshController,
        onRefresh: () {
          photographerBookingListProvider.fetchPhotographerBookings(
              loggedInUser!.id, context);
        },
        child: Consumer<PhotographerBookingListController>(
          builder: (context, bookingListPrvdr, child) {
            if (bookingListPrvdr.allBookings == null) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              );
            }

            // if (bookingListPrvdr.allBookings!.isNotEmpty) {
            var photographerBookings = bookingListPrvdr.allBookings;
            return Container(
              child:
                  // photographerBookings == null ||
                  //     photographerBookings.isEmpty
                  //     ? const Center(
                  //   child: Text('There is no booking request'),
                  // )
                  //     :

                  SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: infoCardsBuild(
                            title: "Total Bookings",
                            icon: Icons.calendar_month,
                            quantity: bookingListPrvdr.totalBookings,
                            color: AppColors.lightGrey,
                            iconColor: AppColors.browne,
                          ),
                        ),
                        20.SpaceX,
                        Expanded(
                          child: infoCardsBuild(
                            title: "Total Clients",
                            icon: Icons.person,
                            quantity: bookingListPrvdr.totalClients,
                            color: AppColors.lightPurple,
                            iconColor: AppColors.purple,
                          ),
                        ),
                      ],
                    ),
                    20.SpaceY,
                    infoCardsBuild(
                      title: "Total Amount Earned",
                      icon: Icons.credit_card,
                      quantity:
                          '\u{20B9} ${bookingListPrvdr.totalAmountEarned.toStringAsFixed(1)}',
                      color: AppColors.lightPink,
                      iconColor: AppColors.pink,
                    ),
                    10.SpaceY,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Bookings',
                          style: MyTextStyle.medium07Black
                              .copyWith(fontSize: 14, color: AppColors.black),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, PhotographerAllBookingScreen.route);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 15, bottom: 15),
                            child: Text(
                              'See All',
                              style: MyTextStyle.semiBold05Black.copyWith(
                                  fontSize: 16, color: AppColors.orange),
                            ),
                          ),
                        ),
                      ],
                    ),
                    5.SpaceY,
                    photographerBookings == null || photographerBookings.isEmpty
                        ? SizedBox.shrink()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              var bkDetail = photographerBookings[index];
                              return BookingDetailCard(
                                bkDetail: bkDetail,
                              );
                            },
                          ),
                    20.SpaceY,
                    Text(
                      'This Year\'s Performance Analysis (${DateTime.now().year})',
                      style: MyTextStyle.medium07Black
                          .copyWith(fontSize: 14, color: AppColors.black),
                    ),
                    20.SpaceY,
                    MyBarGraph(
                        chartData:
                            bookingListPrvdr.photographerPerformanceChart!),
                    20.SpaceY,
                    Row(
                      children: [
                        Expanded(
                          child: infoCardsBuild(
                            title: "Accepted Bookings",
                            icon: Icons.domain_verification_rounded,
                            quantity:
                                '${bookingListPrvdr.totalAcceptedBookings}',
                            color: AppColors.shaderGreen,
                            iconColor: AppColors.purple,
                          ),
                        ),
                        20.SpaceX,
                        Expanded(
                          child: infoCardsBuild(
                            title: "Rejected Bookings",
                            icon: Icons.close,
                            quantity:
                                '${bookingListPrvdr.totalRejectedBookings}',
                            color: AppColors.shaderBrown,
                            iconColor: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                    20.SpaceY,
                  ],
                ),
              ),
            );
            // } else {
            //   return Center(
            //     child: Text('There is 1no booking request'),
            //   );
            // }
          },
        ),
      ),
    );
  }
}
