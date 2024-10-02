import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/models/order.dart';
import 'package:photo_lab/src/models/photographer.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_add_booking_order_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_photographer_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/screens/user_screens/u_add_booking_screens/u_add_booking_address_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_add_booking_screens/u_display_p_equipment_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_verify_booking_screens/u_apply_coupon.dart';
import 'package:photo_lab/src/screens/user_screens/u_verify_booking_screens/u_final_price_calculation.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import '../../../modules/chat/models/custom_order.dart';
import '../../../models/photographer_equipment.dart';
import '../../../helpers/utils.dart';
import '../u_add_booking_screens/order_place_screen.dart';

class UserVerifyBookingScreen extends StatefulWidget {
  static const String route = "userVerifyBookingScreen";
  final Order order;
  final CardDetails cardDetails;
  final CustomOrder? customOrder;
  final Photographer? photographer;

  UserVerifyBookingScreen(
      {Key? key,
      required this.order,
      this.customOrder,
      this.photographer,
      required this.cardDetails})
      : super(key: key);

  @override
  State<UserVerifyBookingScreen> createState() =>
      _UserVerifyBookingScreenState();
}

class _UserVerifyBookingScreenState extends State<UserVerifyBookingScreen> {
  late UserSidePhotographerController photographerProvider;

  LatLng? latLng;
  String location = '';
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressLane1 = TextEditingController();
  final TextEditingController addressLane2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController pinCode = TextEditingController();

  late UserAddBookingOrderController orderProvider;

  // late Photographer photographer;
  late Order order;

  pickBookingAddress() async {
    try {
      LocationResult locationResult;

      locationResult = await showPlacePicker(context, displayLocation: latLng);

      if (locationResult.latLng == null) {
        // Toasty.error("Invalid Service Location");
        return;
      }

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return UserAddBookingAddressScreen(
            locationResult: locationResult,
          );
        },
      )).then((value) {
        if (value == null) {
          // Toasty.error("Invalid Service Location");
        } else {
          // todo add this data in order object

          debugLog("has some data: ${value}");
          this.order.longitude = value['longitude'];
          this.order.latitude = value['latitude'];
          this.order.addressLane1 = value['addressLane1'];
          this.order.addressLane2 = value['addressLane2'];
          this.order.city = value['city'];
          this.order.country = value['country'];
          this.order.pinCode = value['pinCode'];
          this.order.state = value['state'];
          this.order.location = value['location'];
          locationController.text = value['location'];
          this.location = value['location'];
          setState(() {});
        }
      }).catchError((error) {
        debugLog("Exception picking address: $error");
        Toasty.error("Invalid Service Location");
      });

      //
      // latLng = locationResult.latLng;
      // String? formattedAddress =
      //     locationResult.formattedAddress;
      //
      // if (formattedAddress != null) {
      //   print("locationResult 2: ${locationResult}");
      //   locationController.text = formattedAddress;
      //
      //   location = formattedAddress + "\u{20B9}";
      //   if (locationResult.city != null) {
      //     city.text = locationResult.city!.name ?? '';
      //     if (!city.text.isEmpty) {
      //       location = location + city.text + ', ';
      //     }
      //   }
      //   if (locationResult.country != null) {
      //     location =
      //         location + (locationResult.country!.name ?? '');
      //     country.text = locationResult.country!.name ?? '';
      //   }
      //   if (locationResult.administrativeAreaLevel1 != null) {
      //     location = location +
      //         (locationResult.administrativeAreaLevel1!.name ??
      //             '');
      //     state.text =
      //         locationResult.administrativeAreaLevel1!.name ??
      //             '';
      //   }
      //   setState(() {});
      // }
    } catch (e) {
      Toasty.error("Unable to fetch event location. PLease try again.");
      debugLog("Exception occur in getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    photographerProvider =
        Provider.of<UserSidePhotographerController>(context, listen: false);
    orderProvider =
        Provider.of<UserAddBookingOrderController>(context, listen: false);
    // // print(
    //     " 2orderProvider.finalSelectedEquipments : ${orderProvider.finalSelectedEquipments.length}}");

    // photographer = photographerProvider.selectedPhotographer;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderProvider.setCouponCodeDiscount(0.0);
    });
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    // // print(
    //     "skills : ${widget.customOrder!.orderPhotographerDetails![FirestoreConstants.orderPskills]}");
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, order);
        return await false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Booking Details", action: []),
        body: Container(
          padding: EdgeInsets.only(top: 5, bottom: 20),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 12, top: 15),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset.zero)
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: FadeInImage.assetNetwork(
                                        placeholder: ImageAsset.PlaceholderImg,
                                        image: widget.customOrder == null
                                            ? widget.photographer!.imageURL
                                                .replaceFirst('https', 'http')
                                            : widget
                                                .customOrder!
                                                .orderPhotographerDetails![
                                                    FirestoreConstants
                                                        .orderPprofileImage]
                                                .replaceFirst('https', 'http'),
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            ImageAsset.PlaceholderImg,
                                            //  fit: BoxFit.fitWidth,
                                            width: 50,
                                            height: 50,
                                          );
                                        },
                                      ),
                                    ),
                                    15.SpaceX,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.customOrder == null
                                                ? '${widget.photographer!.name} '
                                                : '${widget.customOrder!.orderPhotographerDetails![FirestoreConstants.orderPname]}',
                                            style: MyTextStyle.semiBold05Black
                                                .copyWith(
                                                    fontSize: 16,
                                                    color: AppColors.black),
                                          ),
                                          8.SpaceY,
                                          Text(
                                            widget.customOrder == null
                                                ? '${widget.photographer!.skills ?? ''}'
                                                : '${widget.customOrder!.orderPhotographerDetails![FirestoreConstants.orderPskills] == 'null' ? '' : '${widget.customOrder!.orderPhotographerDetails![FirestoreConstants.orderPskills]}'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: MyTextStyle.semiBold05Black
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: AppColors.black
                                                        .withOpacity(0.5)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                15.SpaceY,
                                widget.customOrder != null
                                    ? SizedBox.shrink()
                                    : Divider(
                                        color: AppColors.black.withOpacity(0.1),
                                        height: 5,
                                        thickness: 1,
                                      ),
                                15.SpaceY,
                                widget.customOrder != null
                                    ? SizedBox.shrink()
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Price:',
                                            style: MyTextStyle.mediumBlack
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: AppColors.black),
                                          ),
                                          Spacer(),
                                          Text(
                                            '\u{20B9} ${widget.photographer!.perHourPrice}',
                                            style: MyTextStyle.semiBold05Black
                                                .copyWith(
                                                    fontSize: 18,
                                                    color: AppColors.black),
                                          ),
                                          8.SpaceX,
                                          Text(
                                            'Per Hour',
                                            style: MyTextStyle.mediumItalic
                                                .copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          10.SpaceY,
                          Text(
                            "Event Details",
                            style: MyTextStyle.medium07Black
                                .copyWith(fontSize: 14),
                          ),
                          10.SpaceY,
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset.zero)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: [
                                //     Text(
                                //       '${order.date} - ',
                                //       style: MyTextStyle.semiBoldBlack.copyWith(
                                //           fontSize: 17, color: AppColors.darkBlue),
                                //     ),
                                //     Text(
                                //       '${order.time}',
                                //       style: MyTextStyle.semiBoldBlack.copyWith(
                                //           fontSize: 17, color: AppColors.darkBlue),
                                //     ),
                                //     Spacer(),
                                //     Align(
                                //       alignment: Alignment.topRight,
                                //       child: InkWell(
                                //         onTap: () {
                                //           Navigator.pop(context);
                                //         },
                                //         child: Text(
                                //           "Edit",
                                //           style: MyTextStyle.semiBoldBlack.copyWith(
                                //               fontSize: 16,
                                //               color: AppColors.darkOrange),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.purple
                                              .withOpacity(0.2)),
                                      child: Container(
                                        height: 6,
                                        width: 6,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.purple),
                                      ),
                                    ),
                                    10.SpaceX,
                                    Text(
                                      'Start Date - Time',
                                      style: MyTextStyle.medium07Black
                                          .copyWith(fontSize: 14),
                                    ),
                                    Spacer(),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context, order);
                                        },
                                        child: Text(
                                          "Edit",
                                          style: MyTextStyle.semiBoldBlack
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: AppColors.darkOrange),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                5.SpaceY,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    40.SpaceX,
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.black,
                                      size: 22,
                                    ),
                                    12.SpaceX,
                                    Text(
                                      '${order.date} - ',
                                      style: MyTextStyle.semiBold05Black
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.black),
                                    ),
                                    Text(
                                      '${order.time}',
                                      style: MyTextStyle.semiBold05Black
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.black),
                                    ),
                                  ],
                                ),
                                20.SpaceY,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.orange
                                              .withOpacity(0.2)),
                                      child: Container(
                                        height: 6,
                                        width: 6,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.orange),
                                      ),
                                    ),
                                    10.SpaceX,
                                    Text(
                                      'End Date - Time',
                                      style: MyTextStyle.medium07Black
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                5.SpaceY,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    40.SpaceX,
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.black,
                                      size: 22,
                                    ),
                                    12.SpaceX,
                                    Text(
                                      '${order.endDate} - ',
                                      style: MyTextStyle.semiBold05Black
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.black),
                                    ),
                                    Text(
                                      '${order.endTime}',
                                      style: MyTextStyle.semiBold05Black
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.black),
                                    ),
                                  ],
                                ),
                                25.SpaceY,
                                Text(
                                  'Event Title',
                                  style: MyTextStyle.medium07Black
                                      .copyWith(fontSize: 14),
                                ),
                                5.SpaceY,
                                Text(
                                  '${order.title}',
                                  style: MyTextStyle.semiBold085Black.copyWith(
                                    fontSize: 17,
                                  ),
                                ),
                                20.SpaceY,
                                Text(
                                  'Event Type',
                                  style: MyTextStyle.medium07Black
                                      .copyWith(fontSize: 14),
                                ),
                                5.SpaceY,
                                Text(
                                  '${order.type}',
                                  style: MyTextStyle.semiBold085Black.copyWith(
                                    fontSize: 17,
                                  ),
                                ),
                                20.SpaceY,
                                Text(
                                  'Total Time',
                                  style: MyTextStyle.medium07Black
                                      .copyWith(fontSize: 14),
                                ),
                                5.SpaceY,
                                Text(
                                  '${order.duration} hours',
                                  style: MyTextStyle.semiBold085Black.copyWith(
                                    fontSize: 17,
                                  ),
                                ),
                                20.SpaceY,
                                Text(
                                  'Event Description',
                                  style: MyTextStyle.medium07Black
                                      .copyWith(fontSize: 14),
                                ),
                                5.SpaceY,
                                Text(
                                  '${order.details}',
                                  style: MyTextStyle.medium07Black.copyWith(
                                      fontSize: 16,
                                      color: AppColors.black.withOpacity(1)),
                                ),
                              ],
                            ),
                          ),
                          20.SpaceY,
                          Text(
                            "Service Location",
                            style: MyTextStyle.medium07Black
                                .copyWith(fontSize: 14),
                          ),
                          15.SpaceY,
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset.zero)
                              ],
                            ),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              // highlightColor: Colors.black,
                              splashColor: Colors.black,
                              enableFeedback: false,
                              onTap: pickBookingAddress,
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors
                                          .darkOrange, //.withOpacity(0.7),
                                    ),
                                    12.SpaceX,
                                    Expanded(
                                      // fit: FlexFit.loose,
                                      child: Text(
                                        order.location!.isEmpty
                                            ? "Add Location"
                                            : order.location!,
                                        maxLines: 4,
                                        style: MyTextStyle.semiBold085Black
                                            .copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    order.location!.isNotEmpty
                                        ? SizedBox.shrink()
                                        : Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            size: 20,
                                            color: AppColors.black
                                                .withOpacity(0.7),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.SpaceY,
                    !order.paidEquipment
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Add Ons",
                                  style: MyTextStyle.medium07Black
                                      .copyWith(fontSize: 14),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      UserSideDisplayPhotographerEquipmentsScreen
                                          .route,
                                      arguments: orderProvider
                                          .allPhotographerEquipments,
                                    );
                                  },
                                  child: Text(
                                    "View all",
                                    style: MyTextStyle.semiBoldBlack.copyWith(
                                        fontSize: 16,
                                        color: AppColors.darkOrange),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    !order.paidEquipment
                        ? SizedBox.shrink()
                        : EquipmentSelectionHandler(),
                    !order.paidEquipment ? 0.SpaceY : 10.SpaceY,
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ApplyCouponClass(),
                          20.SpaceY,
                          Text(
                            "Basic Price Breakdown",
                            style: MyTextStyle.medium07Black
                                .copyWith(fontSize: 14),
                          ),
                          15.SpaceY,
                          FinalPriceCalculation(
                            customOrder: widget.customOrder,
                          ),
                        ],
                      ),
                    ),
                    65.SpaceY,
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: GradientButton(
                  text: "Confirm Booking",
                  onPress: () {
                    print("order.location: ${order.location}");
                    if (order.location!.isEmpty) {
                      Toasty.error("Service Location not provided.");
                      return;
                    }
                    //=================================================
//TODO: remove pop after testing
//++++++++++++++++++++++++++++++++++++++++++++++++
                    // Navigator.pop(context);
                    // Navigator.pop(context);

                    order.couponCodeDiscount = orderProvider.couponCodeAmount;
                    order.totalAmount = orderProvider.totalAmount;
                    order.totalEquipmentAmount =
                        orderProvider.selectedEquipmentPrice;
                    order.taxAmount = orderProvider.taxAmount;
                    order.selectedEquipment =
                        orderProvider.finalSelectedEquipments;

                    debugLog(
                        "final order details: ${order.bidAmount}, ${order.totalAmount}, ${order.selectedEquipment}");
                    debugLog(
                        "order details before proceding: ${order.photographerId} , ${order.userId}");

                    //  todo uncomment below after testing
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPlaceScreen(
                          customOrder: widget.customOrder,
                          order: order,
                          cardDetails: widget.cardDetails,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentSelectionHandler extends StatelessWidget {
  const EquipmentSelectionHandler({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;

    return Consumer<UserAddBookingOrderController>(
        builder: (context, orderPrvdr, child) {
      return SizedBox(
        height: sw * 0.15 + 44,
        child: ListView.builder(
          itemCount: orderPrvdr.allPhotographerEquipments.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            PhotographerEquipment equipment =
                orderPrvdr.allPhotographerEquipments[index];
            return Container(
              width: sw * 0.8,
              margin: EdgeInsets.only(right: 8, bottom: 10, top: 10, left: 13),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset.zero)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FadeInImage.assetNetwork(
                      placeholder: ImageAsset.PlaceholderImg,
                      image: equipment.equipmentImagePath,
                      // .replaceFirst('https', 'http'),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.width * 0.15,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          ImageAsset.PlaceholderImg,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.width * 0.15,
                        );
                      },
                    ),
                  ),
                  10.SpaceX,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            "${equipment.name} ${equipment.name}",
                            overflow: TextOverflow.ellipsis,
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 15),
                          ),
                        ),
                        8.SpaceY,
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            "Price: ${equipment.amount} / ${equipment.amountPer}",
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 12, color: AppColors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 35,
                    margin: EdgeInsets.only(right: 15, left: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.zero,
                            backgroundColor: equipment.count != 0
                                ? AppColors.lightOrange
                                : AppColors.darkOrange,
                          ),
                          onPressed: () {
                            if (equipment.count != 0) {
                              //remove
                              orderPrvdr.changeSelectedEuipmentCount(
                                  equipment.id, --equipment.count);
                            } else {
                              //add
                              orderPrvdr.changeSelectedEuipmentCount(
                                  equipment.id, ++equipment.count);
                            }
                          },
                          child: Text(equipment.count != 0 ? "Remove" : "Add")),
                    ),
                  ),
                  // below is version 1 equipment addition and subtraction
                  // Row(
                  //   children: [
                  //     // IconButton(
                  //     //   onPressed: equipment.count == 0
                  //     //       ? null
                  //     //       : () {
                  //     //           orderPrvdr.changeSelectedEuipmentCount(
                  //     //               equipment.id, --equipment.count);
                  //     //         },
                  //     //   icon: Icon(
                  //     //     CupertinoIcons.minus,
                  //     //   ),
                  //     // ),
                  //     Container(
                  //       height: 35,
                  //       margin: EdgeInsets.only(right: 10),
                  //       child:
                  //
                  //       ClipRRect(
                  //         borderRadius: BorderRadius.circular(10),
                  //         child: ElevatedButton(
                  //             style:
                  //             ElevatedButton.styleFrom(
                  //               // padding: EdgeInsets.zero,
                  //               backgroundColor:
                  //               equipment.count!=0? AppColors.lightOrange:
                  //               AppColors.darkOrange,
                  //             ),
                  //             onPressed: (){
                  //               if(equipment.count != 0){
                  //                 //remove
                  //                 orderPrvdr.changeSelectedEuipmentCount(
                  //                     equipment.id, --equipment.count);
                  //               }else{
                  //                 //add
                  //                 orderPrvdr.changeSelectedEuipmentCount(
                  //                     equipment.id, ++equipment.count);
                  //               }
                  //             }, child: Text(
                  //             equipment.count!=0?"Remove":"Add")),
                  //       ),
                  //     ),
                  //     // Text(
                  //     //   "${equipment.count}",
                  //     //   style: MyTextStyle.semiBoldBlack.copyWith(
                  //     //       fontSize: 18,
                  //     //       color: equipment.count == 0
                  //     //           ? AppColors.black.withOpacity(0.5)
                  //     //           : AppColors.black),
                  //     // ),
                  //     // IconButton(
                  //     //   onPressed: () {
                  //     //     orderPrvdr.changeSelectedEuipmentCount(
                  //     //         equipment.id, ++equipment.count);
                  //     //   },
                  //     //   icon: Icon(
                  //     //     CupertinoIcons.add,
                  //     //   ),
                  //     // )
                  //   ],
                  // ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
