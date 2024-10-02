import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import 'package:photo_lab/src/widgets/booking_details_card.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/booking.dart';
import '../../../models/user.dart';
import '../../../controllers/user_side_controllers/u_booking_controller.dart';
import '../../../helpers/session_helper.dart';
import '../../../widgets/primary_text_field.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';

class UserPreviousBookingScreen extends StatefulWidget {
  static const String route = "userPreviousBookingScreen";

  const UserPreviousBookingScreen({Key? key}) : super(key: key);

  @override
  State<UserPreviousBookingScreen> createState() =>
      _UserPreviousBookingScreenState();
}

class _UserPreviousBookingScreenState extends State<UserPreviousBookingScreen> {
  late UserBookingController userBookingProvider;
  User? loggedInUser;
  List<Booking> productList = [];
  String searchQuery = '';
  String searchBy = 'event title';

  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  getData() {
    SessionHelper.getUser().then((value) {
      if (value != null) {
        loggedInUser = value;
        // userBookingProvider.fetchUserAllBookings(loggedInUser!.id);
        setState(() {});
      }
    });
  }

  @override
  initState() {
    super.initState();
    userBookingProvider =
        Provider.of<UserBookingController>(context, listen: false);

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Previous Bookings", action: []),
      body: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      labelText: searchBy == 'event title'
                          ? "Enter event title"
                          : searchBy == 'username'
                              ? "Enter photographer name"
                              : 'booking status',
                      searchBy == 'username'
                          ? "Search by photographer name"
                          : "Search by $searchBy",
                      suffixIcon: Icons.search,
                      onChange: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        //filterSearchResults(value);
                      },
                    ),
                  ),
                  9.SpaceX,
                  InkWell(
                    onTap: () {
                      closeKeyboard(context);
                      showModelBottomSheet();
                    },
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.darkBlack.withOpacity(0.3))),
                      child: SvgPicture.asset(
                        ImageAsset.FilterIcon,
                        height: 20,
                        width: 20,
                        color: AppColors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              // fit: FlexFit.loose,
              child: SmartRefresher(
                controller: userBookingProvider
                    .userPreviousBookingScreenRefreshController,
                onRefresh: () {
                  // print("loggedInUser!.id: ${loggedInUser!.id}");
                  userBookingProvider.fetchUserAllBookings(
                    loggedInUser!.id,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Consumer<UserBookingController>(
                      builder: (context, bookingListPrvdr, child) {
                    if (bookingListPrvdr.previousBooking == null) {
                      return Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      );
                    }
                    if (bookingListPrvdr.previousBooking!.isEmpty) {
                      return Center(child: Text("No Booking available"));
                    }
                    productList.clear();
                    productList.addAll(
                        bookingListPrvdr.previousBooking!.where((element) {
                      try {
                        return searchBy == 'event title'
                            ? searchQuery.isEmpty ||
                                element.eventTitle.toLowerCase().contains(
                                      searchQuery.toLowerCase(),
                                    )
                            : searchBy == 'booking status'
                                ? searchQuery.isEmpty ||
                                    element.status.toLowerCase().contains(
                                          searchQuery.toLowerCase(),
                                        )
                                : searchQuery.isEmpty ||
                                    element.username.toLowerCase().contains(
                                          searchQuery.toLowerCase(),
                                        );
                      } catch (e) {
                        debugLog("Error: $e");
                        Toasty.error('Invalid search value');
                        return false;
                      }
                    }));
                    if (productList.isEmpty) {
                      return Center(
                        child: Text('No Booking available'),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productList.length,
                      // photographerBookings.length,
                      itemBuilder: (context, index) {
                        var bkDetail = productList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: BookingDetailCard(
                            bkDetail: bkDetail,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showModelBottomSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: AppColors.orange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBottomSheetBorderRadius)),
        context: context,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: kScreenPadding,
                left: kScreenPadding,
                right: kScreenPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    kScreenPadding * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Search By",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 18),
                ),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'booking status';
                      });
                    },
                    child: Text("Event Status")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'event title';
                      });
                    },
                    child: Text("Event Title")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'username';
                      });
                    },
                    child: Text("Photographer Name")),
              ],
            ),
          );
        });
  }
}
