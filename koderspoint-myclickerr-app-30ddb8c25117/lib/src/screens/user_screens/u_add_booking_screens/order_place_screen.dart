// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/order.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/modules/chat/controllers/custom_order_controller.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user_side_controllers/u_booking_controller.dart';
import '../../../helpers/helpers.dart';
import '../../../widgets/buttons.dart';
import '../u_home_startup.dart';

class OrderPlaceScreen extends StatefulWidget {
  final Order order;
  final CardDetails cardDetails;
  CustomOrder? customOrder;

  OrderPlaceScreen(
      {Key? key,
      required this.order,
      this.customOrder,
      required this.cardDetails})
      : super(key: key);

  @override
  State<OrderPlaceScreen> createState() => _OrderPlaceScreenState();
}

class _OrderPlaceScreenState extends State<OrderPlaceScreen> {
  late UserBookingController userBookingProvider;
  late CustomOrderController customOrderProvider;

  bool isLoading = false;
  bool isSuccessful = false;
  bool inError = false;
  String message = '';

  Future<Map<String, dynamic>?> hirePhotographer(int userId) async {
    Order order = widget.order;
    var request =
        http.MultipartRequest('POST', Uri.parse(ApiClient.hirePhotographerUrl));
    debugLog(
        "order.eventCategoryId.toString(): ${order.eventCategoryId.toString()}");
    request.fields.addAll({
      'user_id': order.userId.toString(),
      'photographer_id': order.photographerId.toString(),
      'event_details': order.details,
      'event_date': order.date,
      'event_time': order.time,
      'location': order.location!,
      'total_time': order.duration,
      'paid_equipments': order.paidEquipment ? '1' : '0',
      'total_amount': order.totalAmount.toInt().toString(),
      'event_title': order.title.toString(),
      "event_end_date": order.endDate.toString(),
      "event_end_time": order.endTime.toString(),
      'latitude': order.latitude.toString(),
      'longitude': order.longitude.toString(),
      'address_line1': order.addressLane1.toString(),
      'address_line2': order.addressLane2.toString(),
      'city': order.city.toString(),
      'state': order.state.toString(),
      'country': order.country.toString(),
      'pin_code': order.pinCode.toString(),
      // if the length is greater than one, it means user have selected event category from dropdown
      // then we will also add that in booking
      if (categoriesData.length > 1 && order.eventCategoryId != 0)
        'event_category_id': order.eventCategoryId.toString(),

      //  ------------
      'bid_amount': order.bidAmount!.toStringAsFixed(1),
      'coupon_code_discount': order.couponCodeDiscount!.toStringAsFixed(1),
      'tax_amount': order.taxAmount!.toStringAsFixed(1),
      'total_equipment_amount': order.totalEquipmentAmount!.toStringAsFixed(1),
      'selected_equipments': jsonEncode(order.selectedEquipment),
    });

    debugLog(
        "Final request params while adding new booking: ${request.fields}");

    try {
      http.StreamedResponse response = await request.send();
      //debugLog('stream:' + await response.stream.bytesToString());
      if (response.statusCode == 200) {
        String strRes = await response.stream.bytesToString();
        debugLog(strRes);
        Map<String, dynamic> jsonResponse = jsonDecode(strRes);
        bool status = jsonResponse['status'];
        if (status) {
          if (!mounted) {
            return null;
          }
          return jsonResponse;
        } else {
          Toasty.error('Error: ${jsonResponse['message']}');
          debugLog('Error  : ${jsonResponse['message']}');
        }
      } else {
        Toasty.error('Error creating booking');
        debugLog('Error status code: ${response.statusCode}');
        debugLog('Error:' + await response.stream.bytesToString());
        setStatusMessage('Unable to create Booking, try again later');
        setState(() {
          isLoading = false;
          isSuccessful = false;
        });
      }
    } catch (e) {
      debugLog('Network Error: ${e.toString()}');
      Toasty.error('Network Error: ${e.toString()}');
      setStatusMessage('Unable to create Booking, try again later');
      setState(() {
        isLoading = true;
        isSuccessful = false;
      });
    }

    return null;
  }

  void setStatusMessage(String message) {
    setState(() => this.message = message);
  }

  void deleteBooking(id) async {
    debugLog("booking id to delete: $id");

    try {} on dio.DioError catch (e) {
      debugLog(e.message);

      photographerEquipmentRefreshController.refreshCompleted();
      Toasty.success('Network Error: ${e.message}');
      return null;
    }
  }

  void placeOrder(CardDetails cardDetails) async {
    User? loggedInUser = await SessionHelper.getUser();
    if (loggedInUser == null) {
      return;
    }
    setState(() {
      isLoading = true;
      isSuccessful = false;
    });
    setStatusMessage('Creating Booking...');
    var data = await hirePhotographer(loggedInUser.id);

    if (data == null) {
      setState(() {
        isLoading = false;
      });
    } else {
      try {
        String clientSecret = data['data']['client_secret'];
        int bookingId = data['data']['booking_id'];
        setStatusMessage('Booking Created...');
        Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

        var billingDetails = BillingDetails(
          email: loggedInUser.email,
          phone: loggedInUser.phone,
          address: Address(
            city: widget.order.city.toString(),
            country: widget.order.country,
            line1: widget.order.addressLane1,
            line2: widget.order.addressLane2,
            state: widget.order.state,
            postalCode: widget.order.pinCode, // postal code
          ),
        );
        setStatusMessage('Initializing Payment...');
        final paymentIntent = await Stripe.instance
            .confirmPayment(
          clientSecret,
          PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
        )
            .onError((StripeException stripeError, stackTrace) {
          LocalizedErrorMessage errorMsg = stripeError.error;

          debugLog(stripeError);
          debugLog("Stripe error msg: ${errorMsg.message}");

          deleteBooking(bookingId);

          setState(() {
            isLoading = false;
          });

          Toasty.error('Error: ${errorMsg.localizedMessage}');
          setStatusMessage('${errorMsg.localizedMessage}');
          throw errorMsg.localizedMessage.toString();
        });

        if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
          //Toasty.success('Payment Successful');
          setStatusMessage('Payment Successful');
          try {
            dio.Response confirmPaymentResponse =
                await dio.Dio().post(ApiClient.confirmPaymentUrl, data: {
              'booking_id': bookingId,
              'status': paymentIntent.status.name,
              'transaction_id': paymentIntent.id
            });
            setState(() {
              isLoading = false;
            });
            if (confirmPaymentResponse.statusCode == 200) {
              //Toasty.success('Booking Confirmed');
              debugLog(confirmPaymentResponse.data);
              final jsonResponse = confirmPaymentResponse.data;
              bool status = jsonResponse['status'];
              if (status) {
                setStatusMessage('Booking Done\nsuccessfully');
                setState(() {
                  userBookingProvider.fetchUserAllBookings(loggedInUser.id);

                  isSuccessful = true;
                  if (widget.customOrder != null) {
                    // updating custom order status to accepted
                    customOrderProvider.updateCustomOrderStatus(
                        orderStatus: 'Accepted',
                        groupChatId: widget.customOrder!.groupChatId,
                        documentReference:
                            widget.customOrder!.documentReference);

                    customOrderProvider
                        .sendCustomOrderNotificationToPhotographer(
                            loggedInUser.id,
                            widget.order.photographerId,
                            'accepted');
                  }
                });
              } else {
                setState(() => isSuccessful = false);
                String message = jsonResponse['message'];
                setStatusMessage(message);
                //Toasty.error('Error: ${message}');
              }
            } else {
              setStatusMessage('Payment done but failed to confirm booking');
            }
          } catch (e) {
            // e.printError();
            debugLog(e);
            setState(() {
              isLoading = false;
            });
            setStatusMessage(
                'Payment done but failed to confirm booking with exception');
          }
        } else if (paymentIntent.status ==
            PaymentIntentsStatus.RequiresConfirmation) {
          Toasty.error('Requires Confirmation');
          setStatusMessage('Payment intent requires confirmation');
        } else {
          debugLog("error msg: ${paymentIntent.status}");
          Toasty.error('Error: ${paymentIntent.status}');
        }
      } catch (e) {}
    }
  }

  @override
  void initState() {
    super.initState();

    customOrderProvider =
        Provider.of<CustomOrderController>(context, listen: false);
    userBookingProvider =
        Provider.of<UserBookingController>(context, listen: false);

    placeOrder(widget.cardDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Order Placement",
        action: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isLoading,
                child: const CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              ),
              Visibility(
                visible: isSuccessful,
                child: Icon(
                  size: 75,
                  Icons.check_circle_outline_sharp,
                  color: isSuccessful ? Colors.green : Colors.red,
                ),
              ),
              !isLoading && isSuccessful == false
                  ? Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 5, color: Colors.red)),
                          child: Icon(
                            size: 55,
                            Icons.close,
                            color: isSuccessful ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 15),
                        isSuccessful
                            ? SizedBox.shrink()
                            : Text(
                                "Booking failed because",
                                style: MyTextStyle.semiBoldBlack
                                    .copyWith(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 28),
              Text(
                message == "Your card number is incorrect."
                    ? "Your payment card number is not valid."
                    : message,
                style: MyTextStyle.semiBoldBlack
                    .copyWith(fontSize: isSuccessful ? 24 : 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              Visibility(
                visible: isSuccessful,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    20.SpaceY,
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Text(
                        textAlign: TextAlign.center,
                        "We’ll notify you once the photographer accepts your Booking invitation",
                        style:
                            MyTextStyle.semiBold07Black.copyWith(fontSize: 14),
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
            ],
          ),
        ),
      ),
    );
  }
}
