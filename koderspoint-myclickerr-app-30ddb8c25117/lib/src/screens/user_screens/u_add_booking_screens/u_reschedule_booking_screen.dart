import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/card.dart';
import 'package:photo_lab/src/models/event_category.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../../helpers/toast.dart';
import '../../../models/booking.dart';

class UserRecheduleBookingScreen extends StatefulWidget {
  static const String route = "userRecheduleBookingScreen";
  final Booking bkDetail;

  const UserRecheduleBookingScreen({
    Key? key,
    required this.bkDetail,
  }) : super(key: key);

  @override
  State<UserRecheduleBookingScreen> createState() =>
      _UserRecheduleBookingScreenState();
}

class _UserRecheduleBookingScreenState
    extends State<UserRecheduleBookingScreen> {
  String details = '';
  String title = '';
  String date = '';
  String time = '';
  String endDate = '';
  String endTime = '';
  String location = '';
  String duration = '';
  DateTime? pickedDate;
  DateTime? pickedEndDate;
  TimeOfDay? pickedTime;
  TimeOfDay? pickedEndTime;
  bool paidEquipments = false;
  double totalAmount = 0;
  EventCategory selectedEventCategory = categoriesData[0];
  String? startTimeFieldError;
  String? endTimeFieldError;
  String? startDateFieldError;
  String? endDateFieldError;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController startDateController = TextEditingController();
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

  User? loggedInUser;
  late UserBookingController userBookingController;

  void rescheduleBooking() async {
    var data = {
      'booking_id': widget.bkDetail.id,
      'event_date': startDateController.text,
      'event_time': startTimeController.text,
      'event_end_date': endDateController.text,
      'event_end_time': endTimeController.text,
    };
    userBookingController.rescheduleBooking(
        context, data, widget.bkDetail.userId);
  }

  @override
  void initState() {
    super.initState();
    userBookingController =
        Provider.of<UserBookingController>(context, listen: false);
    SessionHelper.getUser().then((value) => loggedInUser = value);

    startDateController.text = widget.bkDetail.eventDate;
    startTimeController.text = widget.bkDetail.eventTime;
    endDateController.text = widget.bkDetail.endDate;
    endTimeController.text = widget.bkDetail.endTime;

    pickedEndDate = DateFormat("dd MMM, yyyy").parse(widget.bkDetail.endDate);
    pickedEndTime = convertToTimeOfDay(widget.bkDetail.endTime);

    pickedDate = DateFormat("dd MMM, yyyy").parse(widget.bkDetail.eventDate);
    pickedTime = convertToTimeOfDay(widget.bkDetail.eventTime);

    debugLog("pickedDate: ${pickedDate}");
    debugLog("pickedTime: ${pickedTime}");
    debugLog("pickedEndTime: ${pickedEndTime}");
    debugLog("pickedEndDate: ${pickedEndDate}");
  }

  TimeOfDay convertToTimeOfDay(String timeString) {
    int hours = int.parse(timeString.split(':')[0]);
    int minutes = int.parse(timeString.split(':')[1].toString().split(" ")[0]);

    if (hours >= 12) {
      if (hours > 12) {
        hours -= 12;
      }
      return TimeOfDay(hour: hours, minute: minutes)
          .replacing(hour: hours, minute: minutes);
    } else {
      if (hours == 0) {
        hours = 12;
      }
      return TimeOfDay(hour: hours, minute: minutes).replacing(
        hour: hours,
        minute: minutes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Reschedule Booking",
        action: [],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrimaryTextField(
                        labelText: 'Booking Start Date',
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
                          }
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      PrimaryTextField(
                        labelText: 'Booking Start Time',
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

                            // var df = DateFormat("h:mm a");
                            // var dt = df.parse(pickedTime.format(context));
                            // String formattedTime = DateFormat('HH:mm').format(dt);
                            // if (mounted) {
                            //   startTimeController.text = formattedTime.toString();
                            //   time = formattedTime.toString();
                            // }

                            startTimeController.text =
                                pickedTime!.format(context).toString();
                            time = pickedTime!.format(context).toString();
                          }
                        },
                        suffixIcon: Icons.watch_later_outlined,
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      PrimaryTextField(
                        labelText: 'Booking End Date',
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
                          }
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      PrimaryTextField(
                        labelText: 'Booking End Time',
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
                          }
                        },
                        suffixIcon: Icons.watch_later_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer<UserController>(
                  builder: (context, usercontroller, _) {
                return usercontroller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ))
                    : GradientButton(
                        text: 'Reschedule Booking',
                        onPress: () async {
                          setState(() {
                            startTimeFieldError = null;
                            endTimeFieldError = null;
                            startDateFieldError = null;
                            endDateFieldError = null;
                          });
                          bool res = validateStartDateTime(
                            startDatee: pickedDate,
                            startTimee: pickedTime,
                            endDatee: pickedEndDate,
                            endTimee: pickedEndTime,
                          );
                          if (res == false) {
                            Toasty.error("Booking dates not valid.");
                          } else if (_formKey.currentState!.validate()) {
                            print("good");
                            rescheduleBooking();
                          }
                        },
                      );
              }),
            )
          ],
        ),
      ),
    );
  }

  validateStartDateTime(
      {required TimeOfDay? startTimee,
      required DateTime? startDatee,
      required TimeOfDay? endTimee,
      required DateTime? endDatee}) {
    if (startTimee == null) {
      setState(() {
        startTimeFieldError = 'Kindly re-select start time';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (startDatee == null) {
      setState(() {
        startDateFieldError = 'Kindly re-select start date';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (endDatee == null) {
      setState(() {
        endDateFieldError = 'Kindly re-select end date';
      });
      _formKey.currentState!.validate();
      return false;
    } else if (endTimee == null) {
      setState(() {
        endTimeFieldError = 'Kindly re-select end time';
      });
      _formKey.currentState!.validate();
      return false;
    }

    if (pickedDate!.isAfter(pickedEndDate!)) {
      setState(() {
        startDateFieldError = 'Start date is greater than end date';
      });
      _formKey.currentState!.validate();
      return false;
    }

    if (_formKey.currentState!.validate()) {
      if (startDatee.day == endDatee.day) {
        //   compare time
        print(
            "endTimee.hour: ${endTimee.hour} , startTimee.hour:${startTimee.hour}");
        if (endTimee.hour < startTimee.hour) {
          setState(() {
            endTimeFieldError = 'End time is smaller than start time';
          });
          _formKey.currentState!.validate();
          return false;
        } else {
          return true;
        }
      } else
        return true;
    } else {
      debugLog("FOrm not valid 3");
      return false;
    }
  }
}
