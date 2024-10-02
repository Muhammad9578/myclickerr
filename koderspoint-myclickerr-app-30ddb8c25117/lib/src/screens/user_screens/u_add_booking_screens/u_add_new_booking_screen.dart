import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_add_booking_order_controller.dart';
import 'package:photo_lab/src/helpers/cards_manager.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/card.dart';
import 'package:photo_lab/src/models/event_category.dart';
import 'package:photo_lab/src/models/order.dart';
import 'package:photo_lab/src/models/photographer.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/screens/user_screens/u_payment_screens/payment_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_verify_booking_screens/u_verify_booking_screen.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../models/photographer_equipment.dart';
import '../../../modules/chat/models/custom_order.dart';

class UserAddNewBookingScreen extends StatefulWidget {
  static const String route = "userAddNewBookingScreen";
  final Photographer? selectedPhotographer;

  // bool customOrder;
  final CustomOrder? customOrder;

  UserAddNewBookingScreen(
      {Key? key, this.selectedPhotographer, this.customOrder})
      : super(key: key);

  @override
  State<UserAddNewBookingScreen> createState() =>
      _UserAddNewBookingScreenState();
}

class _UserAddNewBookingScreenState extends State<UserAddNewBookingScreen> {
  String details = '';
  String title = '';
  String date = '';
  String time = '';
  String endDate = '';
  String endTime = '';
  String location = '';
  String duration = '';
  String duration1 = '';
  LatLng latLng = LatLng(0.0, 0.0);
  String? startTimeFieldError;
  String? endTimeFieldError;
  String? startDateFieldError;
  Order? order;
  String? endDateFieldError;

  bool paidEquipments = false;
  bool isLoading = false;
  double totalAmount = 0;
  EventCategory selectedEventCategory = categoriesData[0];
  DateTime? pickedDate;
  DateTime? pickedEndDate;
  TimeOfDay? pickedTime;
  TimeOfDay? pickedEndTime;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressLane1 = TextEditingController();
  final TextEditingController addressLane2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController pinCode = TextEditingController();

  CardModel? selectedCard;
  CardDetails? cardDetails;
  bool isAvailable = true;
  User? loggedInUser;
  late UserAddBookingOrderController orderProvider;

  clearingList() {
    if (widget.selectedPhotographer != null) {
      selectedTimeSlots.addAll(widget.selectedPhotographer!.timeslots);

      debugLog(widget.selectedPhotographer!.isAvailable);
      isAvailable =
          widget.selectedPhotographer!.isAvailable == "1" ? true : false;
      debugLog(selectedTimeSlots.toString());
      widget.selectedPhotographer!.photographerEquipment.forEach((element) {
        element.count = 0;
      });
    }
  }

  List<String> selectedTimeSlots = [];

  @override
  void initState() {
    super.initState();
// debugLog("photographerId: ${widget.selectedPhotographer!.id}");
    orderProvider =
        Provider.of<UserAddBookingOrderController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      loggedInUser = value;
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;

          //  isAvailable = loggedInUser!.isAvailable == "1" ? true : false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderProvider.clearPreviousData();
      orderProvider.setNewOrder(null);
      orderProvider.setCustomOrder(null);
      clearingList();

      // // print(
      //     " 0 orderProvider.finalSelectedEquipments: ${orderProvider.finalSelectedEquipments.length}");
    });

    if (widget.customOrder != null) {
      duration = widget.customOrder!.orderTotalHours.toString();
      details = widget.customOrder!.orderDescription.toString();
      durationController.text =
          "${widget.customOrder!.orderTotalHours.toString()} hrs";
    } else {
      // // print("widget.customOrde: ${widget.customOrder}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Booking Details",
        action: [],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: PrimaryTextField(
                        labelText: 'Start Date',
                        '21 July, 2021',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter booking start date'
                            : startDateFieldError,
                        readOnly: true,
                        controller: startDateController,
                        suffixIcon: Icons.calendar_month_outlined,
                        // prefixIcon:
                        onTap: () async {
                          pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.orange,

                                    onPrimary: AppColors.white,
                                    //onSurface: Colors.blueAccent, // <-- SEE HERE
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.orange,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            debugLog(
                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('d MMM, y').format(pickedDate!);
                            debugLog(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            startDateController.text = formattedDate;
                            date = formattedDate;
                            if (widget.customOrder == null) {
                              calculateTotalTime(
                                  startTimee: pickedTime,
                                  startDatee: pickedDate,
                                  endTimee: pickedEndTime,
                                  endDatee: pickedEndDate);
                            }
                          }
                        },
                      ),
                    ),
                    10.SpaceX,
                    Expanded(
                      child: PrimaryTextField(
                        labelText: 'Start Time',
                        '08:00 PM',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter booking start time';
                          } else
                            return startTimeFieldError;
                        },
                        readOnly: true,
                        controller: startTimeController,
                        onTap: () async {
                          if (!mounted) {
                            return;
                          }
                          pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.orange,
                                  onPrimary: AppColors.white,
                                  //onSurface: Colors.blueAccent, // <-- SEE HERE
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.orange
                                      /*foregroundColor: AppColors.orange,*/
                                      ),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (pickedTime != null) {
                            debugLog(
                                "pickedTime : ${pickedTime!.format(context)}");
                            print(pickedDate != null);
                            startTimeController.text =
                                pickedTime!.format(context).toString();
                            time = pickedTime!.format(context).toString();
                            if (widget.customOrder == null) {
                              if (widget.customOrder == null) {
                                calculateTotalTime(
                                    startTimee: pickedTime,
                                    startDatee: pickedDate,
                                    endTimee: pickedEndTime,
                                    endDatee: pickedEndDate);
                              }
                            }
                          }
                        },
                        suffixIcon: Icons.watch_later_outlined,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryTextField(
                        labelText: 'End Date',
                        '21 July, 2021',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter booking end date'
                            : endDateFieldError,
                        readOnly: true,
                        controller: endDateController,
                        suffixIcon: Icons.calendar_month_outlined,
                        // prefixIcon:
                        onTap: () async {
                          pickedEndDate = await showDatePicker(
                            context: context,
                            initialDate: pickedDate ?? DateTime.now(),
                            firstDate: pickedDate ?? DateTime.now(),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.orange,
                                    onPrimary: AppColors.white,
                                    //onSurface: Colors.blueAccent, // <-- SEE HERE
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: AppColors.orange
                                        /*foregroundColor: AppColors.orange,*/
                                        ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedEndDate != null) {
                            debugLog(
                                pickedEndDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('d MMM, y').format(pickedEndDate!);
                            debugLog(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            endDateController.text = formattedDate;
                            endDate = formattedDate;
                            if (widget.customOrder == null) {
                              calculateTotalTime(
                                  startTimee: pickedTime,
                                  startDatee: pickedDate,
                                  endTimee: pickedEndTime,
                                  endDatee: pickedEndDate);
                            }
                          }
                        },
                      ),
                    ),
                    10.SpaceX,
                    Expanded(
                      child: PrimaryTextField(
                        labelText: 'End Time',
                        '08:00 PM',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter booking end time'
                            : endTimeFieldError,
                        readOnly: true,
                        controller: endTimeController,
                        onTap: () async {
                          if (!mounted) {
                            return;
                          }
                          pickedEndTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.orange,
                                  onPrimary: AppColors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.orange),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (pickedEndTime != null) {
                            debugLog(
                                "end pickedTime : ${pickedEndTime!.format(context)}");
                            if (mounted) {
                              endTimeController.text =
                                  pickedEndTime!.format(context).toString();
                              endTime =
                                  pickedEndTime!.format(context).toString();
                            }
                            if (widget.customOrder == null) {
                              calculateTotalTime(
                                  startTimee: pickedTime,
                                  startDatee: pickedDate,
                                  endTimee: pickedEndTime,
                                  endDatee: pickedEndDate);
                            }
                          }
                        },
                        suffixIcon: Icons.watch_later_outlined,
                      ),
                    ),
                  ],
                ),

                PrimaryTextField(
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.name,
                  labelText: 'Event Title',
                  'Provide title booking here',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter booking title'
                      : null,
                  onChange: (value) {
                    title = value;
                  },
                ),

                PrimaryTextField(
                  labelText: 'Total Duration',
                  // initialValue: duration,
                  controller: durationController,
                  readOnly: true,
                  duration,
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter total event duration '
                      : null,
                  // prefixIcon: Icons.calendar_month,
                  onChange: (value) {
                    duration = value;
                    _calculateTotalAmount();
                  },
                ),

                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: kDefaultSpace * 0.8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kInputBorderRadius),
                      border: Border.all(width: 1, color: Colors.black45)),
                  child: DropdownButton<EventCategory>(
                    value: selectedEventCategory,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    isExpanded: true,
                    elevation: 12,
                    style:
                        const TextStyle(color: AppColors.black, fontSize: 16),
                    underline: Container(
                      height: 0,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        selectedEventCategory = value;
                        setState(() {});
                      }
                    },
                    items: categoriesData.map((value) {
                      return DropdownMenuItem<EventCategory>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
                3.SpaceY,
                PrimaryTextField(
                  textCapitalization: TextCapitalization.sentences,
                  initialValue: details,
                  labelText: 'Event Description',
                  readOnly: widget.customOrder == null ? false : true,
                  'Provide details about your event',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter event details'
                      : null,
                  onChange: (value) {
                    details = value;
                  },
                ),
                const SizedBox(
                  height: kDefaultSpace,
                ),
                // Column(
                //   children: [
                //     PrimaryTextField(
                //       textCapitalization: TextCapitalization.sentences,
                //       labelText: "Location",
                //       'USA, New York',
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter event location'
                //           : null,
                //       suffixIcon: Icons.location_on,
                //       /*onChange: (value) {
                //          location = value;
                //        },*/
                //       controller: locationController,
                //       readOnly: true,
                //       onTap: () async {
                //         try {
                //           LocationResult locationResult =
                //           await showPlacePicker(context);
                //           debugLog(
                //               "locationResult 1: ${locationResult.name},  ${locationResult.locality}, "
                //                   " ${locationResult.country?.name},  ${locationResult.city?.name}, "
                //                   " ${locationResult.postalCode}, "
                //                   " ${locationResult.administrativeAreaLevel1?.name}, "
                //                   " ${locationResult.administrativeAreaLevel2?.name}, "
                //                   " ${locationResult.subLocalityLevel1?.name}, "
                //                   " ${locationResult.subLocalityLevel1?.name}, "
                //                   " ${locationResult.subLocalityLevel2?.name}, "
                //                   " ${locationResult.placeId} ");
                //
                //           latLng = locationResult.latLng;
                //           String? formattedAddress =
                //               locationResult.formattedAddress;
                //
                //           if (formattedAddress != null) {
                //             print("locationResult 2: ${locationResult}");
                //             locationController.text = formattedAddress;
                //
                //             location = formattedAddress + "\u{20B9}";
                //             if (locationResult.city != null) {
                //               city.text = locationResult.city!.name ?? '';
                //               if (!city.text.isEmpty) {
                //                 location = location + city.text + ', ';
                //               }
                //             }
                //             if (locationResult.country != null) {
                //               location =
                //                   location + (locationResult.country!.name ?? '');
                //               country.text = locationResult.country!.name ?? '';
                //             }
                //             if (locationResult.administrativeAreaLevel1 != null) {
                //               location = location +
                //                   (locationResult.administrativeAreaLevel1!.name ??
                //                       '');
                //               state.text =
                //                   locationResult.administrativeAreaLevel1!.name ??
                //                       '';
                //             }
                //             setState(() {});
                //           }
                //         } catch (e) {
                //           Toasty.error(
                //               "Unable to fetch event location. PLease try again.");
                //           debugLog("Exception occur in getting location: $e");
                //         }
                //       },
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: addressLane1,
                //       labelText: 'Address Lane 1',
                //       'Provide address 1',
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter address of lane1'
                //           : null,
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: addressLane2,
                //       labelText: 'Address Lane2',
                //       'Provide  address 2',
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter address of lane2'
                //           : null,
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: city,
                //       labelText: 'City',
                //       readOnly: city.text.isEmpty ? false : true,
                //       'Provide city name',
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter city'
                //           : null,
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: state,
                //       labelText: 'State',
                //       readOnly: state.text.isEmpty ? false : true,
                //       'Provide state name',
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter state'
                //           : null,
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: country,
                //       labelText: 'Country',
                //       'Provide country',
                //       readOnly: state.text.isEmpty ? false : true,
                //       validator: (value) => value == null || value.isEmpty
                //           ? 'Please enter country'
                //           : null,
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace * 2,
                //     ),
                //     PrimaryTextField(
                //       controller: pinCode,
                //       labelText: 'Pin Code',
                //       'Provide postal code',
                //       validator: (value) {
                //         if (value == null || value.isEmpty)
                //           return 'Please enter pin code';
                //         else if (!value.trim().isValidNumbers()) {
                //           return 'Only numbers are allowed';
                //         } else if (value.length != 6) {
                //           return 'Only six digits are allowed';
                //         } else
                //           return null;
                //       },
                //     ),
                //     const SizedBox(
                //       height: kDefaultSpace,
                //     ),
                //   ],
                // ),

                widget.customOrder == null
                    ? widget.selectedPhotographer!.photographerEquipment
                                .length >
                            0
                        ? CheckboxListTile(
                            activeColor: AppColors.orange,
                            title: const Text(
                                'Select Paid Equipments (Do you want equipments of photographer in event)'),
                            value: paidEquipments,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                paidEquipments = value ?? false;
                              });
                              _calculateTotalAmount();
                            },
                          )
                        : SizedBox.shrink()
                    : SizedBox.shrink(),
                const SizedBox(
                  height: kDefaultSpace * 2,
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const HeadingText('Total Amount: '),
                //     HeadingText('$totalAmount'),
                //   ],
                // ),
                // const SizedBox(
                //   height: kDefaultSpace * 3,
                // ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GradientButton(
                        text: 'Proceed',
                        onPress: () async {
                          if (!isAvailable) {
                            Toasty.error(
                                "Photographer is not available for bookings right now");

                            if (mounted) {
                              return;
                            }
                          }

                          if (selectedTimeSlots.isNotEmpty) {
                            final DateFormat inputFormat =
                                DateFormat('hh:mm a');
                            final DateTime pickedDateTime =
                                inputFormat.parse(pickedTime!.format(context));
                            final int pickedHour = pickedDateTime.hour > 12
                                ? pickedDateTime.hour - 12
                                : pickedDateTime.hour;
                            final String pickedAmPm =
                                pickedDateTime.hour < 12 ? 'AM' : 'PM';
                            String formattedHour = pickedHour.toString();

                            if (pickedAmPm == 'PM') {
                              formattedHour =
                                  pickedHour.toString().padLeft(2, '0');
                            }

                            log(selectedTimeSlots.toString());

                            debugLog('$formattedHour:00 $pickedAmPm');
                            bool isPickedTimeAvailable = selectedTimeSlots
                                .contains('$formattedHour:00 $pickedAmPm');

                            if (isPickedTimeAvailable == false) {
                              Toasty.error(
                                  "Photographer is not available for bookings for this time");

                              if (mounted) {
                                return;
                              }
                            }
                          }
                          // // print(
                          //     " 1 orderProvider.finalSelectedEquipments: ${orderProvider.finalSelectedEquipments.length} ");
                          orderProvider.clearPreviousData();
                          setState(() {
                            startTimeFieldError = null;
                            endTimeFieldError = null;
                            startDateFieldError = null;
                            endDateFieldError = null;
                          });
                          bool res = validateStartDateTime(
                            startDate: pickedDate,
                            startTime: pickedTime,
                            endDate: pickedEndDate,
                            endTime: pickedEndTime,
                          );
                          if (res == false) {
                            Toasty.error("Booking dates not valid.");
                          } else if (_formKey.currentState!.validate()) {
                            selectedCard = await CardsManager.getDefaultCard(
                                loggedInUser!.id);
                            if (!mounted) {
                              return;
                            }
                            _calculateTotalAmount();
                            selectedCard ??= await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ));
                            if (!mounted || selectedCard == null) {
                              return;
                            }
                            cardDetails = CardDetails(
                                number:
                                    selectedCard!.number.replaceAll(' ', ''),
                                expirationMonth:
                                    int.parse(selectedCard!.expiryMonth),
                                expirationYear:
                                    int.parse(selectedCard!.expiryYear) + 2000);
                            // Navigator.pop(context);

                            // this list is only used in case of custom order
                            List<PhotographerEquipment> emptyEquipmentList = [];

                            order = Order(
                              userId: loggedInUser!.id,
                              photographerId: widget.customOrder == null
                                  ? widget.selectedPhotographer!.id!
                                  : int.parse(
                                      widget.customOrder!.photographerId),
                              eventCategoryId: selectedEventCategory.id,
                              details: widget.customOrder == null
                                  ? details
                                  : widget.customOrder!.orderDescription,
                              type: selectedEventCategory.name,
                              date: date,
                              time: time,
                              title: title,
                              endDate: endDate,
                              endTime: endTime,
                              longitude: latLng.longitude,
                              latitude: latLng.latitude,
                              addressLane1: addressLane1.text,
                              addressLane2: addressLane2.text,
                              city: city.text,
                              country: country.text,
                              pinCode: pinCode.text,
                              state: state.text,
                              location: location,
                              duration: duration,
                              paidEquipment: paidEquipments,
                              totalAmount: totalAmount,
                              bidAmount: widget.customOrder == null
                                  ? double.parse(widget
                                      .selectedPhotographer!.perHourPrice
                                      .toString())
                                  : widget.customOrder!.orderTotalPrice,
                            );

                            orderProvider.setNewOrder(order);
                            debugLog(
                                "order details before proceding: ${order!.photographerId} , ${order!.userId}");
                            print(
                                "totalAmount before proceeding: ${order!.totalAmount}");

                            if (widget.customOrder != null) {
                              orderProvider.setCustomOrder(widget.customOrder);
                            }
                            // // print(
                            //     "widget.selectedPhotographer!.photographerEquipment: ${widget.selectedPhotographer!.photographerEquipment[1].count}");

                            orderProvider.setSelectedEquipments(
                                widget.customOrder == null
                                    ? List.from(widget.selectedPhotographer!
                                        .photographerEquipment)
                                    : List.from(emptyEquipmentList));
                            clearingList();

                            // todo uncomment below for navigating afer testing
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserVerifyBookingScreen(
                                  photographer: widget.selectedPhotographer,
                                  customOrder: widget.customOrder,
                                  order: order!,
                                  cardDetails: cardDetails!,
                                ),
                              ),
                            ).then((value) {
                              if (value != null) {
                                //   longitude: 0.0,
                                // latitude:  0.0,
                                // addressLane1: addressLane1.text,
                                // addressLane2: addressLane2.text,
                                // city: city.text,
                                // country: country.text,
                                // pinCode: pinCode.text,
                                // state: state.text,
                                // location: location
                                latLng =
                                    LatLng(value.latitude, value.longitude);

                                addressLane1.text = value.addressLane1;
                                addressLane2.text = value.addressLane2;
                                city.text = value.city;
                                country.text = value.country;
                                pinCode.text = value.pinCode;
                                state.text = value.state;
                                location = value.location;
                                locationController.text = value.location;
                                this.location = value.location;
                                this.order = value;
                                setState(() {});
                              }
                            });
                          } else {
                            Toasty.error(
                                "Form not valid. Please fill all fields");
                          }
                        },
                      ),
                const SizedBox(
                  height: kDefaultSpace * 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _calculateTotalAmount() {
    setState(() {
      if (widget.customOrder == null) {
        totalAmount = widget.selectedPhotographer!.perHourPrice *
            double.parse(
              duration.replaceAll(":", "."),
              //(source) => 0,
            );
        if (paidEquipments) {
          totalAmount += widget.selectedPhotographer!.equipmentCharges;
        }
      } else {
        totalAmount = widget.customOrder!.orderTotalPrice;
      }
    });
  }

  bool validateStartDateTime({
    required TimeOfDay? startTime,
    required DateTime? startDate,
    required TimeOfDay? endTime,
    required DateTime? endDate,
  }) {
    log(startDate.toString());
    log(startTime.toString());
    log(endTime.toString());
    log(DateTime.now().toString());
    if (startTime == null) {
      setState(() {
        startTimeFieldError = 'Kindly re-select start time';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (startDate == null) {
      setState(() {
        startDateFieldError = 'Kindly re-select start date';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (endTime == null) {
      setState(() {
        endTimeFieldError = 'Kindly re-select end time';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (endDate == null) {
      setState(() {
        endDateFieldError = 'Kindly re-select end date';
      });
      _formKey.currentState!.validate();
      return false;
    }

    if (startDate.isAfter(endDate)) {
      setState(() {
        startDateFieldError = 'Start date is greater than end date';
      });
      _formKey.currentState!.validate();
      return false;
    }

    if (startDate.day == DateTime.now().day &&
        startTime.hour <= DateTime.now().hour) {
      setState(() {
        startTimeFieldError = 'Start Time must be greater then current Time';
      });
      _formKey.currentState!.validate();
      return false;
    }

    if (startDate.day == endDate.day) {
      if (endTime.hour < startTime.hour ||
          (endTime.hour == startTime.hour &&
              endTime.minute < startTime.minute)) {
        setState(() {
          endTimeFieldError = 'End time is smaller than start time';
        });
        _formKey.currentState!.validate();
        return false;
      }
    }

    return _formKey.currentState!.validate();
  }

  // validateStartDateTime(
  //     {required TimeOfDay? startTimee,
  //     required DateTime? startDatee,
  //     required TimeOfDay? endTimee,
  //     required DateTime? endDatee}) {
  //   if (startTimee == null) {
  //     setState(() {
  //       startTimeFieldError = 'Kindly re-select start time';
  //     });
  //     _formKey.currentState!.validate();
  //     return false;
  //   } else if (startDatee == null) {
  //     setState(() {
  //       startDateFieldError = 'Kindly re-select start date';
  //     });
  //     _formKey.currentState!.validate();
  //     return false;
  //   } else if (endDatee == null) {
  //     setState(() {
  //       endDateFieldError = 'Kindly re-select end date';
  //     });
  //     _formKey.currentState!.validate();
  //     return false;
  //   } else if (endTimee == null) {
  //     setState(() {
  //       endTimeFieldError = 'Kindly re-select end time';
  //     });
  //     _formKey.currentState!.validate();
  //     return false;
  //   }

  //   if (pickedDate!.isAfter(pickedEndDate!)) {
  //     setState(() {
  //       startDateFieldError = 'Start date is greater than end date';
  //     });
  //     _formKey.currentState!.validate();
  //     return false;
  //   }

  //   if (_formKey.currentState!.validate()) {
  //     if (startDatee!.day == DateTime.now().day) {
  //       int selectedHour = startTimee!.hour;
  //       if (selectedHour <= DateTime.now().hour + 1) {
  //         setState(() {
  //           startTimeFieldError = 'Kindly re-select start time';
  //         });
  //         _formKey.currentState!.validate();
  //         return false;
  //       } else {
  //         if (startDatee.day == endDatee.day) {
  //           //   compare time
  //           print(
  //               "endTimee.hour: ${endTimee.hour} , startTimee.hour:${startTimee.hour}");
  //           if (endTimee.hour < startTimee.hour) {
  //             setState(() {
  //               endTimeFieldError = 'End time is smaller than start time';
  //             });
  //             _formKey.currentState!.validate();
  //             return false;
  //           } else {
  //             if (endTimee.minute < startTimee.minute) {
  //               setState(() {
  //                 endTimeFieldError = 'End time is smaller than start time';
  //               });
  //               _formKey.currentState!.validate();
  //               return false;
  //             } else {
  //               return true;
  //             }
  //           }
  //         } else
  //           return true;
  //       }
  //     } else {
  //       if (startDatee.day == endDatee.day) {
  //         //   compare time
  //         print(
  //             "endTimee.hour: ${endTimee.hour} , startTimee.hour:${startTimee.hour}");
  //         if (endTimee.hour < startTimee.hour) {
  //           setState(() {
  //             endTimeFieldError = 'End time is smaller than start time';
  //           });
  //           _formKey.currentState!.validate();
  //           return false;
  //         } else {
  //           if (endTimee.minute < startTimee.minute) {
  //             setState(() {
  //               endTimeFieldError = 'End time is smaller than start time';
  //             });
  //             _formKey.currentState!.validate();
  //             return false;
  //           } else {
  //             return true;
  //           }
  //         }
  //       } else
  //         return true;
  //     }
  //   } else {
  //     debugLog("FOrm not valid 3");
  //     return false;
  //   }
  // }

  String calculateTotalTime(
      {required TimeOfDay? startTimee,
      required DateTime? startDatee,
      required TimeOfDay? endTimee,
      required DateTime? endDatee}) {
    if (startTimee != null &&
        startDatee != null &&
        endTimee != null &&
        endDatee != null) {
      final startTime = DateTime(startDatee.year, startDatee.month,
          startDatee.day, startTimee.hour, startTimee.minute);
      final endTime = DateTime(endDatee.year, endDatee.month, endDatee.day,
          endTimee.hour, endTimee.minute);

      final d = endTime.difference(startTime);
      final totalHours = d.inHours;
      final totalMinutes =
          d.inMinutes.remainder(60); // Get the remaining minutes

      final result = '$totalHours.$totalMinutes';
      durationController.text = '${totalHours}hrs ${totalMinutes}min';
      duration = result;
      setState(() {
        _calculateTotalAmount();
      });
      return result;
    }

    return "";
  }
}
