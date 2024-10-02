import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as au;
import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/booking_session_model.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/pages/splash_page.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import '../../controllers/user_side_controllers/user_controller.dart';
import '../../helpers/helpers.dart';
import '../../helpers/toast.dart';
import '../../models/booking.dart';
import '../../models/user.dart';
import '../../modules/chat/pages/support_chat_page.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/rate_photographer_widget.dart';
import '../photographer_screens/p_all_bookings/dropbpx_upload_screen.dart';
import '../user_screens/u_add_booking_screens/u_reschedule_booking_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  static const String route = 'bookingDetailScreen1';
  final Booking bkDetail;

  const BookingDetailScreen({Key? key, required this.bkDetail})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  String? loggedInUserType;
  User? loggedInUser;
  late Booking bkDetail;
  bool sessionOnGoing = false;
  int? sessionOtp;
  bool? sessionCompleted;
  BookingSession? currentSessionDetail;

  late PhotographerBookingListController photographerBookingListProvider;

  getData() {
    SessionHelper.getUserType();
    // loggedInUserType = userProvider.getUserType();

    // print(
    // "loggedInUser inside bookingdetails screen 1 : ${SessionHelper.userType}"
    // );
  }

  bool isLoading = false;
  bool otpLoader = true;
  late UserController userProvider;

  void sendOtpToUser() async {
    int otp = createSessionOtp();

    if (mounted)
      setState(() {
        otpLoader = true;
      });
    var data = {
      'booking_id': bkDetail.id,
      'photographer_id': bkDetail.photographerId,
      'user_id': bkDetail.userId,
      'otp': otp,
    };

    Response response;
    try {
      response =
          await Dio().post(ApiClient.otpArrivalNotificationUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);
      Toasty.error('Network Error:${e.message}');

      if (mounted)
        setState(() {
          otpLoader = false;
        });

      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        debugLog("OTP sent successfully");
        if (mounted)
          setState(() {
            otpLoader = false;
          });
        otpValidationDialog();
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        if (mounted)
          setState(() {
            otpLoader = false;
          });
      }
    } else {
      Toasty.error('Something went wrong. Try again later');
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    }
  }

  createSessionOtp() {
    var rng = new Random();
    sessionOtp = rng.nextInt(900000) + 100000;
    if (mounted) setState(() {});
    return sessionOtp;
  }

  stopSession() {
    photographerBookingListProvider.firebaseFirestore
        .collection(FirestoreConstants.pathSessionCollection)
        .doc(bkDetail.id.toString())
        .set({
      'bookingId': bkDetail.id,
      // 'startTime': DateTime.now().millisecondsSinceEpoch,
      'endTime': DateTime.now().millisecondsSinceEpoch,
      'onGoing': false,
      'userId': bkDetail.userId,
      'photographerId': bkDetail.photographerId,
      'otp': sessionOtp,
      'totalHours': -1.0,
    }, SetOptions(merge: true)).then((value) {
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    }).catchError((error) {
      print("Failed to stop session: $error");
      Toasty.error("Failed to stop session. Try again");
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    });
  }

  Future<void> otpValidationDialog() async {
    final _formKey = GlobalKey<FormState>();
    final enteredOtp = TextEditingController();

    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    bottom: 10, top: 10, left: 15, right: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      15.SpaceY,
                      const Text(
                        'OTP validation',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      15.SpaceY,
                      PrimaryTextField(
                        labelText: "Session OTP",
                        'Enter session otp',
                        controller: enteredOtp,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter otp'
                            : value != sessionOtp.toString()
                                ? "Invalid Session OTP"
                                : null,
                        keyboardType: TextInputType.number,
                      ),
                      20.SpaceY,
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              print("valid");
                              setState(() {
                                otpLoader = true;
                              });
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 200), () {
                                createNewSession();
                              });
                            }
                          },
                          child: Text("Start Session"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> sessionDialog(sessionData) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'OnGoing Session',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    15.SpaceY,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Started at:',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          sessionData == null
                              ? "Not decided"
                              : '${prettyDateTimePortfolio(sessionData!.startTime)}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    20.SpaceY,
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red),
                        onPressed: () {
                          print("valid");
                          if (mounted)
                            setState(() {
                              otpLoader = true;
                            });
                          stopSession();
                          Navigator.pop(context);
                        },
                        child: Text("Stop Session"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  createNewSession() {
    photographerBookingListProvider.firebaseFirestore
        .collection(FirestoreConstants.pathSessionCollection)
        .doc(bkDetail.id.toString())
        .set({
      'bookingId': bkDetail.id,
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'endTime': -1,
      'onGoing': true,
      'userId': bkDetail.userId,
      'photographerId': bkDetail.photographerId,
      'otp': sessionOtp,
      'totalHours': -1.0,
    }).then((value) {
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    }).catchError((error) {
      print("Failed to add user: $error");
      Toasty.error("Unable to create session. Try again");
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    });
  }

  checkSessionExist() {
    print("inside checkSessionExist");
    photographerBookingListProvider.firebaseFirestore
        .collection(FirestoreConstants.pathSessionCollection)
        .doc(bkDetail.id.toString())
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      print("inside listen: $event");
      if (event.exists) {
        BookingSession sessionDetail = BookingSession.fromJson(event);
        if (sessionDetail.onGoing) {
          if (!sessionOnGoing) {
            currentSessionDetail = sessionDetail;
            sessionOnGoing = true;
            sessionCompleted = false;
            // WidgetsBinding.instance.addPostFrameCallback((_) async {
            //
            // });
            if (mounted) {
              sessionDialog(currentSessionDetail);
              setState(() {
                otpLoader = false;
              });
            }
          }
        } else {
          // stopping session
          sessionOnGoing = false;
          sessionCompleted = true;
          if (mounted)
            setState(() {
              otpLoader = false;
            });
          print("session stopped");
        }
      } else {
        // sessionOnGoing = false;
        if (mounted)
          setState(() {
            otpLoader = false;
          });
      }
    }).onError((err) {
      print("sessionError: $err");
      if (mounted)
        setState(() {
          otpLoader = false;
        });
    });
  }

  @override
  initState() {
    super.initState();
    bkDetail = widget.bkDetail;

    userProvider = Provider.of<UserController>(context, listen: false);
    photographerBookingListProvider =
        Provider.of<PhotographerBookingListController>(context, listen: false);

    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        if (mounted)
          setState(() {
            if (bkDetail.status == 'accepted' && SessionHelper.userType == "2")
              checkSessionExist();
            else
              otpLoader = false;
            this.loggedInUser = loggedInUser;
          });
      }
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: "Booking ",
          action: [],
        ),
        body: otpLoader
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    15.SpaceY,
                    bookingDetailWidget(bkDetail),
                    20.SpaceY,
                    SessionHelper.userType == "2" && bkDetail.rating == null
                        ? SizedBox.shrink()
                        : bkDetail.status == 'completed'
                            ? RatePhotographerWidget(bkDetail: bkDetail)
                            : SizedBox.shrink(),
                    clientDetailWidget(bkDetail),
                    20.SpaceY,
                    downloadFileWidget(bkDetail),
                    paymentBreakdownWidget(bkDetail),
                    50.SpaceY,
                    buttonChoiceWidget(bkDetail),
                    10.SpaceY,
                  ],
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Stack(
                children: [
                  MaterialButton(
                      padding: EdgeInsets.all(12),
                      color: AppColors.red,
                      shape: const CircleBorder(),
                      onPressed: () async {
                        // if (mounted) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => SplashPage(
                        //         targetUserId: "DOhRetbQstgbapKhTyWHAldblYR2",
                        //         issupportperson: true,
                        //         // SessionHelper.userType == '1'
                        //         //     ? photographer.id.toString()
                        //         //     : bkDetail.userId.toString(),
                        //       ),
                        //     ),
                        //   );
                        // }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupportChatScreen(
                              arguments: SupportChatScreenArguments(
                                  peerId:
                                      au.FirebaseAuth.instance.currentUser!.uid,
                                  peerAvatar: "",
                                  peerNickname: "Support Team",
                                  mineimg: loggedInUser!.profileImage ?? "",
                                  minename: loggedInUser!.name ?? ""),
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.support_agent,
                        size: 32,
                        color: Colors.white,
                      )),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(FirestoreConstants.supportpersons)
                        .doc(FirestoreConstants.supportpersons.toLowerCase())
                        .collection("chats")
                        .doc(au.FirebaseAuth.instance.currentUser!.uid ?? "")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink(); // Placeholder for loading
                      }

                      if (snapshot.hasError) {
                        return SizedBox.shrink();
                      }

                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;

                      int unredcounter = data?['unreadCounter'] ?? 0;

                      return Positioned(
                        top: 0,
                        right: 10,
                        // Adjust this value to move the circle more to the right
                        child: unredcounter == 0
                            ? SizedBox.shrink()
                            : Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unredcounter > 99 ? '99+' : '$unredcounter',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
            bkDetail.status != 'accepted'
                ? SizedBox.shrink()
                : sessionCompleted != null && sessionCompleted == true
                    ? SizedBox.shrink()
                    : SessionHelper.userType == "1"
                        ? SizedBox.shrink()
                        : Container(
                            height: 80,
                            child: InkWell(
                                onTap: () {
                                  if (sessionCompleted == null) {
                                    if (sessionOtp == null) {
                                      sendOtpToUser();
                                    } else
                                      otpValidationDialog();
                                  } else {
                                    if (sessionOnGoing) {
                                      sessionDialog(currentSessionDetail);
                                    }
                                  }
                                },
                                child: Image.asset('assets/images/sos.png'))),
            SizedBox(
              height: 20,
            ),
          ],
        ));
  }

  bookingDetailWidget(bkDetail) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      //         crossAxisAlignment: CrossAxisAlignment.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${bkDetail.eventTitle}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MyTextStyle.boldBlack.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              10.SpaceX,
              MaterialButton(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: bkDetail.status == 'accepted'
                          ? AppColors.blue
                          : bkDetail.status == 'rejected'
                              ? AppColors.red
                              : bkDetail.status == 'completed'
                                  ? AppColors.lightGreen
                                  : bkDetail.status == 'pending'
                                      ? AppColors.lightGreen
                                      : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  bkDetail.status == 'accepted'
                      ? "ACCEPTED"
                      : bkDetail.status == 'completed'
                          ? "COMPLETED"
                          : bkDetail.status == 'pending'
                              ? "PENDING"
                              : bkDetail.status == 'rejected' &&
                                      bkDetail.rejectedBy == "1"
                                  ? "Cancelled"
                                  : bkDetail.status == 'rejected'
                                      ? "Rejected"
                                      : "",
                  style: MyTextStyle.semiBold05Black.copyWith(
                    fontSize: 14,
                    color: bkDetail.status == 'accepted'
                        ? AppColors.blue
                        : bkDetail.status == 'rejected'
                            ? AppColors.red
                            : bkDetail.status == 'completed'
                                ? AppColors.lightGreen
                                : bkDetail.status == 'pending'
                                    ? AppColors.lightGreen
                                    : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          14.SpaceY,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple.withOpacity(0.2)),
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.purple),
                ),
              ),
              10.SpaceX,
              Text(
                'Start Date - Time',
                style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
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
                '${bkDetail.eventDate} - ',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '${bkDetail.eventTime}',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
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
                    color: AppColors.orange.withOpacity(0.2)),
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.orange),
                ),
              ),
              10.SpaceX,
              Text(
                'End Date - Time',
                style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
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
                '${bkDetail.endDate} - ',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '${bkDetail.endTime}',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
            ],
          ),
          15.SpaceY,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.black.withOpacity(0.7),
              ),
              12.SpaceX,
              Expanded(
                child: Text(
                  bkDetail.location,
                  // maxLines: 2,
                  style: MyTextStyle.semiBold07Black.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          25.SpaceY,
          Text(
            'Event Title',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${bkDetail.eventTitle}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          20.SpaceY,
          Text(
            'Event Type',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${bkDetail.eventCategory.isEmpty ? "Not defined" : bkDetail.eventCategory}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          20.SpaceY,
          Text(
            'Total Time',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${bkDetail.totalTime} hours',
            style: MyTextStyle.semiBold05Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          20.SpaceY,
          Text(
            'Event Description',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${bkDetail.eventDetails}',
            style: MyTextStyle.medium07Black.copyWith(
                fontSize: 16, color: AppColors.black.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  clientDetailWidget(bkDetail) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            SessionHelper.userType == "1"
                ? 'Photographer Details'
                : "Client Details",
            style: MyTextStyle.semiBold05Black
                .copyWith(fontSize: 16, color: AppColors.black),
          ),
          8.SpaceY,
          Divider(
            color: AppColors.black.withOpacity(0.1),
            height: 5,
            thickness: 1,
          ),
          15.SpaceY,
          Row(
            children: [
              ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: ImageAsset.PlaceholderImg,
                  image: bkDetail.profileImage,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  imageErrorBuilder: (context, error, stackTrace) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bkDetail.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MyTextStyle.semiBold05Black
                          .copyWith(fontSize: 16, color: AppColors.black),
                    ),
                    8.SpaceY,
                    Text(
                      'Booked on ${bkDetail.eventDate} - ${bkDetail.eventTime}',
                      style: MyTextStyle.semiBold05Black.copyWith(
                          fontSize: 12,
                          color: AppColors.black.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              10.SpaceX,
              bkDetail.status == "rejected"
                  ? SizedBox.shrink()
                  : InkWell(
                      onTap: () {
                        // print(
                        // " SessionHelper.userType: ${SessionHelper.userType}"
                        // );
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashPage(
                                targetUserId: SessionHelper.userType == '1'
                                    ? bkDetail.photographerId.toString()
                                    : bkDetail.userId.toString(),
                                issupportperson: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: Icon(Icons.chat_outlined)),
                    )
            ],
          ),
        ],
      ),
    );
  }

  downloadFileWidget(bkDetail) {
    return SessionHelper.userType == "1" && bkDetail.status == 'completed'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.SpaceY,
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Dropbox link',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 16, color: AppColors.black),
                ),
              ),
              8.SpaceY,
              Divider(
                color: AppColors.black.withOpacity(0.1),
                height: 5,
                endIndent: 20,
                indent: 20,
                thickness: 1,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset.zero,
                          blurRadius: 10),
                    ]),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  // highlightColor: Colors.black,
                  splashColor: Colors.black,
                  enableFeedback: false,
                  onTap: () async {
                    String url = bkDetail.fileLink;
                    print("url: $url");
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      Toasty.error(
                          'Unable to start downloading, Invalid album link.');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bkDetail.eventTitle}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 16, color: AppColors.black),
                              ),
                              8.SpaceY,
                              Text(
                                'Uploaded on ${prettyDateTimeForTimeline(bkDetail.completedTime ?? 1691500839)}',
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 12,
                                    color: AppColors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                        10.SpaceX,
                        Icon(
                          Icons.file_download_outlined,
                          size: 25,
                          color: AppColors.blue,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  paymentBreakdownWidget(bkDetail) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: MyTextStyle.semiBold05Black
                .copyWith(fontSize: 16, color: AppColors.black),
          ),
          8.SpaceY,
          Divider(
            color: AppColors.black.withOpacity(0.1),
            height: 5,
            thickness: 1,
          ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Price',
                style: MyTextStyle.regularBlack
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Spacer(),
              Text(
                '\u{20B9} ${bkDetail.bidAmount} ',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 16, color: AppColors.black),
              ),
              Text(
                'Per Hour',
                style: MyTextStyle.regularBlack.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hours required',
                style: MyTextStyle.regularBlack
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '${bkDetail.totalTime} Hours',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 16, color: AppColors.black),
              ),
            ],
          ),
          bkDetail.selectedEquipments.length == 0
              ? SizedBox.shrink()
              : 15.SpaceY,
          bkDetail.selectedEquipments.length == 0
              ? SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Equipment Price (${bkDetail.selectedEquipments.length})',
                      style: MyTextStyle.regularBlack
                          .copyWith(fontSize: 14, color: AppColors.black),
                    ),
                    Text(
                      '\u{20B9} ${bkDetail.totalEquipmentAmount}',
                      style: MyTextStyle.semiBold05Black
                          .copyWith(fontSize: 16, color: AppColors.black),
                    )
                  ],
                ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax Amount',
                style: MyTextStyle.regularBlack
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '\u{20B9} ${bkDetail.taxAmount}',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 16, color: AppColors.black),
              ),
            ],
          ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coupon Code Discount',
                style: MyTextStyle.regularBlack
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '\u{20B9} ${bkDetail.couponCodeDiscount}',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 16, color: AppColors.black),
              ),
            ],
          ),
          15.SpaceY,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Estimated Amount',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Text(
                '\u{20B9} ${bkDetail.totalAmount}',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 18, color: AppColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buttonChoiceWidget(bkDetail) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Consumer<PhotographerBookingListController>(
        builder: (context, photographerPrvdr, child) {
          return bkDetail.status == 'completed' || bkDetail.status == 'rejected'
              ? SizedBox.shrink()
              : isLoading || photographerPrvdr.changeStatusLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      ),
                    )
                  : SessionHelper.userType == '1'
                      ? bkDetail.status != 'completed' ||
                              bkDetail.status != 'pending'
                          ? Column(
                              children: [
                                RejectButton(
                                    text: "Reschedule Booking",
                                    textStyle:
                                        MyTextStyle.semiBoldBlack.copyWith(
                                      fontSize: 16,
                                    ),
                                    icon: Icons.calendar_today_outlined,
                                    iconColor: AppColors.black,
                                    onPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserRecheduleBookingScreen(
                                            bkDetail: bkDetail,
                                          ),
                                        ),
                                      );
                                    }),
                                10.SpaceY,
                                RejectButton(
                                    text: "Cancel Booking",
                                    textStyle:
                                        MyTextStyle.semiBold05Black.copyWith(
                                      fontSize: 16,
                                      color: AppColors.red,
                                    ),
                                    color: AppColors.kInputBackgroundColor,
                                    onPress: () {
                                      showdialog(context, () {
                                        photographerPrvdr.p_changeBookingStatus(
                                            bkDetail.id,
                                            'rejected',
                                            loggedInUser!.id,
                                            context);

                                        Navigator.of(context).pop();
                                      });

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => UserVerifyBookingScreen(
                                      //       photographer: widget.selectedPhotographer,
                                      //       customOrder: widget.customOrder,
                                      //       order: order!,
                                      //       cardDetails: cardDetails!,
                                      //     ),
                                      //   ),
                                      // )
                                    }),
                              ],
                            )
                          : SizedBox.shrink()
                      :

                      // it means photographer

                      bkDetail.status == 'pending'
                          ? Row(
                              children: [
                                Expanded(
                                    child: PrimaryButton(
                                        text: "Accept",
                                        color: AppColors.darkBlue,
                                        onPress: () {
                                          Provider.of<PhotorapherController>(
                                                  context,
                                                  listen: false)
                                              .acceptBooking(
                                                  bkDetail.id,
                                                  'accepted',
                                                  loggedInUser!.id,
                                                  bkDetail,
                                                  photographerBookingListProvider,
                                                  context);
                                          //
                                        })),
                                10.SpaceX,
                                Expanded(
                                    child: PrimaryButton(
                                        text: "Reject",
                                        color: AppColors.kInputBackgroundColor,
                                        onPress: () {
                                          photographerPrvdr
                                              .p_changeBookingStatus(
                                                  bkDetail.id,
                                                  'rejected',
                                                  loggedInUser!.id,
                                                  context);
                                        })),
                              ],
                            )
                          : Column(
                              children: [
                                GradientButton(
                                  text: "Complete Service",
                                  onPress: () {
                                    if (sessionCompleted == null) {
                                      Toasty.error("Session is not completed");
                                      return;
                                    } else if (sessionCompleted == false) {
                                      Toasty.error("Session is not completed");
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => DropboxUploadScreen(
                                          photographerId:
                                              bkDetail.photographerId,
                                          bookingId: bkDetail.id,
                                        ),
                                      ),
                                    );
                                    // photographerPrvdr
                                    //     .p_changeBookingStatus(
                                    //         bkDetail.id,
                                    //         'completed',
                                    //         loggedInUser!.id,
                                    //         context);
                                  },
                                ),
                                15.SpaceY,
                                RejectButton(
                                    text: "Cancel Booking", // for photographer
                                    textStyle:
                                        MyTextStyle.semiBold05Black.copyWith(
                                      fontSize: 16,
                                      color: AppColors.red,
                                    ),
                                    color: AppColors.kInputBackgroundColor,
                                    onPress: () {
                                      showdialog(context, () {
                                        photographerPrvdr.p_changeBookingStatus(
                                            bkDetail.id,
                                            'rejected',
                                            loggedInUser!.id,
                                            context);

                                        Navigator.of(context).pop();
                                      });
                                    }),
                              ],
                            );
        },
      ),
    );
  }

  showdialog(BuildContext context, VoidCallback oncancel) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: oncancel,
              child: Text(
                'Cancel Booking',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform other action, e.g., go back to the previous screen
                Navigator.of(context).pop();
              },
              child: Text('Keep Booking'),
            ),
          ],
        );
      },
    );
  }
}
