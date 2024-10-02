import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
import '../../../models/user.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_appbar.dart';

class PhotographerTimeSlotAvailabilityScreen extends StatefulWidget {
  static const route = "photographerTimeSlotAvailabilityScreen";

  const PhotographerTimeSlotAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerTimeSlotAvailabilityScreen> createState() =>
      _PhotographerTimeSlotAvailabilityScreenState();
}

class _PhotographerTimeSlotAvailabilityScreenState
    extends State<PhotographerTimeSlotAvailabilityScreen> {
  List<String> allTimeSlots = [];
  List<String> selectedTimeSlots = [];
  bool isAvailable = true;
  late User? loggedInUser;

  @override
  void initState() {
    allTimeSlots.clear();
    selectedTimeSlots.clear();
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          print("loggedInUser.timeslots: ${loggedInUser.timeslots}");

          allTimeSlots.addAll(photographerAvailabilityList);
          selectedTimeSlots.addAll(loggedInUser.timeslots);
          isAvailable = loggedInUser.isAvailable == "1" ? true : false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("selectedTimeSlots: $selectedTimeSlots");
    return Scaffold(
      appBar: CustomAppBar(title: "Time slots and availability", action: []),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.SpaceY,
                Container(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Now?",
                        style: MyTextStyle.semiBoldBlack.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      Switch(
                        value: isAvailable,
                        activeColor: Colors.orange,
                        inactiveTrackColor: AppColors.browne.withOpacity(0.3),
                        inactiveThumbColor: AppColors.red,
                        onChanged: (bool value) {
                          setState(() {
                            print("switch value: $value");
                            if (value) {
                              selectedTimeSlots
                                  .addAll(photographerAvailabilityList);
                            } else {
                              selectedTimeSlots.clear();
                            }
                            isAvailable = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kDefaultSpace * 3),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Time Slots",
                    style: MyTextStyle.semiBoldBlack.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                15.SpaceY,
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _buildChoiceList(allTimeSlots),
                ),
                20.SpaceY,
                Consumer<PhotorapherController>(
                    builder: (context, photoraphercontroller, _) {
                  return photoraphercontroller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        )
                      : GradientButton(
                          onPress: () {
                            if (isAvailable && selectedTimeSlots.isEmpty) {
                              debugLog(
                                  "Minimum 1 time slot should be selected.");
                              Toasty.error("Please select some time slots.");
                              return;
                            }

                            photoraphercontroller.updateTimeSlots(context,
                                loggedInUser!, isAvailable, selectedTimeSlots);
                          },
                          text: "Update",
                        );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildChoiceList(reportList) {
    List<Widget> choices = [];

    reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.only(right: 5.0),
        child: ChoiceChip(
          selectedColor: AppColors.orange.withOpacity(0.8),
          // disabledColor: AppColors.orange.withOpacity(0.2),
          label: Container(
            // color: Colors.orange.shade400,
            width: 70,
            child: Text(
              item,
              style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
            ),
          ),
          backgroundColor: AppColors.orange.withOpacity(0.1),
          selected: selectedTimeSlots.contains(item),
          onSelected: (selected) {
            if (isAvailable) {
              setState(
                () {
                  if (selectedTimeSlots.contains(item)) {
                    selectedTimeSlots.remove(item);
                  } else {
                    selectedTimeSlots.add(item);
                  }
                },
              );
            }
          },
        ),
      ));
    });

    return choices;
  }
}
