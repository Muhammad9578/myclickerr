import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';

import 'package:photo_lab/src/widgets/booking_details_card.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/booking.dart';
import '../../../models/user.dart';
import '../../../helpers/session_helper.dart';
import '../../../widgets/primary_text_field.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
import '../../../helpers/helpers.dart';

class PhotographerPreviousBookingScreen extends StatefulWidget {
  static const String route = "photographerPreviousBookingScreen";

  const PhotographerPreviousBookingScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerPreviousBookingScreen> createState() =>
      _PhotographerPreviousBookingScreenState();
}

class _PhotographerPreviousBookingScreenState
    extends State<PhotographerPreviousBookingScreen> {
  late PhotographerBookingListController photographerBookingListProvider;
  User? loggedInUser;
  List<Booking> productList = [];
  String searchBy = 'event title';
  var searchController = TextEditingController();

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
    photographerBookingListProvider =
        Provider.of<PhotographerBookingListController>(context, listen: false);

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
                      controller: searchController,
                      labelText: searchBy == 'maximum bid amount'
                          ? "Enter maximum price"
                          : searchBy == 'minimum bid amount'
                              ? "Enter minimum price"
                              : searchBy == 'event title'
                                  ? "Enter booking title"
                                  : searchBy == 'name'
                                      ? "Enter username"
                                      : "Enter booking status",
                      "Search by $searchBy",
                      suffixIcon: Icons.search,
                      keyboardType: searchBy == 'maximum bid amount' ||
                              searchBy == 'minimum bid amount'
                          ? TextInputType.number
                          : TextInputType.text,
                      onChange: (value) {
                        setState(() {
                          // searchController.text = value;
                        });
                        //filterSearchResults(value);
                      },
                    ),
                  ),
                  9.SpaceX,
                  InkWell(
                    onTap: () {
                      searchController.text = '';
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
                controller: photographerBookingListProvider
                    .pCompletedBookingRefreshController,
                onRefresh: () {
                  // print("loggedInUser!.id: ${loggedInUser!.id}");
                  photographerBookingListProvider.fetchPhotographerBookings(
                      loggedInUser!.id, context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Consumer<PhotographerBookingListController>(
                      builder: (context, bookingListPrvdr, child) {
                    if (bookingListPrvdr.completedBooking == null) {
                      return Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      );
                    }
                    if (bookingListPrvdr.allBookings!.isEmpty) {
                      return Center(child: Text("No Previous booking"));
                    }
                    productList.clear();
                    productList.addAll(
                      bookingListPrvdr.completedBooking!.where((element) {
                        try {
                          return searchBy == 'event status'
                              ? searchController.text.isEmpty ||
                                  element.status.toLowerCase().contains(
                                        searchController.text.toLowerCase(),
                                      )
                              : searchBy == 'event title'
                                  ? searchController.text.isEmpty ||
                                      element.eventTitle.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          )
                                  : searchBy == 'name'
                                      ? searchController.text.isEmpty ||
                                          element.username
                                              .toLowerCase()
                                              .contains(
                                                searchController.text
                                                    .toLowerCase(),
                                              )
                                      : searchBy == 'maximum bid amount'
                                          ? searchController.text.isEmpty ||
                                              double.parse(
                                                      element.totalAmount == ''
                                                          ? "0"
                                                          : element
                                                              .totalAmount) <=
                                                  double.parse(
                                                      searchController.text)
                                          : searchController.text.isEmpty ||
                                              double.parse(
                                                      element.totalAmount == ''
                                                          ? "0"
                                                          : element
                                                              .totalAmount) >=
                                                  double.parse(
                                                      searchController.text);
                        } catch (e) {
                          debugLog("Error: $e");
                          Toasty.error('Invalid search value');
                          return false;
                        }
                      }),
                    );
                    if (productList.isEmpty) {
                      return Center(
                        child: Text('No Previous booking'),
                      );
                    }

                    if (searchBy == 'maximum bid amount') {
                      productList.sort(
                          (a, b) => b.totalAmount.compareTo(a.totalAmount));
                    } else if (searchBy == 'minimum bid amount') {
                      productList.sort(
                          (a, b) => a.totalAmount.compareTo(b.totalAmount));
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
                      searchController.text = '';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'event title';
                      });
                    },
                    child: Text("Event Title")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'event status';
                      });
                    },
                    child: Text("Event Status")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'name';
                      });
                    },
                    child: Text("Username")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '10000';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'maximum bid amount';
                      });
                    },
                    child: Text('Maximum total amount')),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '0';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'minimum bid amount';
                      });
                    },
                    child: Text('Minimum total amount')),
              ],
            ),
          );
        });
  }
}
