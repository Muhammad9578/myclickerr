import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/widgets/booking_details_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/booking.dart';
import '../../../models/user.dart';
import '../../../widgets/primary_text_field.dart';

class PhotographerNewBookingRequestScreen extends StatefulWidget {
  const PhotographerNewBookingRequestScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerNewBookingRequestScreen> createState() =>
      _PhotographerNewBookingRequestScreenState();
}

class _PhotographerNewBookingRequestScreenState
    extends State<PhotographerNewBookingRequestScreen> {
  late PhotographerBookingListController photographerBookingListProvider;
  User? loggedInUser;
  List<Booking> productList = [];
  String searchBy = 'event title';
  var searchController = TextEditingController();

  @override
  initState() {
    super.initState();
    photographerBookingListProvider =
        Provider.of<PhotographerBookingListController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      if (value != null) {
        loggedInUser = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 0.0, right: 0, top: 20, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PrimaryTextField(
                    labelText: searchBy == 'maximum bid amount'
                        ? "Enter maximum price"
                        : searchBy == 'minimum bid amount'
                            ? "Enter minimum price"
                            : searchBy == 'event status'
                                ? 'Enter event status'
                                : searchBy == 'event title'
                                    ? "Enter event title"
                                    : 'username',
                    controller: searchController,
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
                  .pNewRequestBookingRefreshController,
              onRefresh: () {
                // print("loggedInUser!.id: ${loggedInUser!.id}");
                photographerBookingListProvider.fetchPhotographerBookings(
                    loggedInUser!.id, context);
                setState(() {});
              },
              child: Consumer<PhotographerBookingListController>(
                  builder: (context, bookingListPrvdr, child) {
                if (bookingListPrvdr.pendingBooking == null) {
                  return Text("Loading");
                }

                productList.clear();
                productList.addAll(
                  bookingListPrvdr.pendingBooking.where((element) {
                    try {
                      return searchBy == 'event status'
                          ? searchController.text.isEmpty ||
                              element.eventTitle.toLowerCase().contains(
                                    searchController.text.toLowerCase(),
                                  )
                          : searchBy == 'event title'
                              ? searchController.text.isEmpty ||
                                  element.eventTitle.toLowerCase().contains(
                                        searchController.text.toLowerCase(),
                                      )
                              : searchBy == 'name'
                                  ? searchController.text.isEmpty ||
                                      element.username.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          )
                                  : searchBy == 'maximum bid amount'
                                      ? searchController.text.isEmpty ||
                                          double.parse(element.totalAmount == ''
                                                  ? "0"
                                                  : element.totalAmount) <=
                                              double.parse(
                                                  searchController.text)
                                      : searchController.text.isEmpty ||
                                          double.parse(element.totalAmount == ''
                                                  ? "0"
                                                  : element.totalAmount) >=
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
                    child: Text('No New Request (Refresh)'),
                  );
                }
                if (searchBy == 'maximum bid amount') {
                  productList
                      .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
                } else if (searchBy == 'minimum bid amount') {
                  productList
                      .sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
                }

                return Container(
                  color: AppColors.white,
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: productList.length,
                    // photographerBookings.length,
                    itemBuilder: (context, index) {
                      var bkDetail = productList[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 20.0, right: 20),
                        child: BookingDetailCard(
                          bkDetail: bkDetail,
                        ),
                      );

                      // PhotographerBookingListItem(
                      //   photographerBookings[index],
                      //   onPress: () {
                      //     Navigator.pushNamed(
                      //         context, BookingDetailScreen.route,
                      //         arguments:
                      //             photographerBookings[index]);
                      //   },
                      // );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
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
