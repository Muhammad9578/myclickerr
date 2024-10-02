import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../../models/booking.dart';
import '../../../widgets/buttons.dart';

class UserRatingPhotographerScreen extends StatefulWidget {
  static const String route = "userRatingPhotographerScreen";
  final Booking bookingDetail;

  const UserRatingPhotographerScreen({Key? key, required this.bookingDetail})
      : super(key: key);

  @override
  State<UserRatingPhotographerScreen> createState() =>
      _UserRatingPhotographerScreenState();
}

class _UserRatingPhotographerScreenState
    extends State<UserRatingPhotographerScreen> {
  double rating = 4;
  String description = '';

  final _formKey = GlobalKey<FormState>();

  void submitRating() async {
    var data = {
      'user_id': widget.bookingDetail.userId,
      'photographer_id': widget.bookingDetail.photographerId,
      'rating': rating,
      'description': description,
      'booking_id': widget.bookingDetail.id,
    };
    userbookingController.submitPhotographerRating(
        context, data, widget.bookingDetail.userId);
  }

  late UserBookingController userbookingController;

  @override
  void initState() {
    userbookingController =
        Provider.of<UserBookingController>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Rate Photographer', action: []),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provide Rating',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 16, color: AppColors.black),
                ),
                10.SpaceY,
                Align(
                  alignment: Alignment.center,
                  child: RatingBar.builder(
                    // itemSize: 30,
                    initialRating: rating,
                    minRating: 1,
                    glowColor: AppColors.pink,
                    unratedColor: AppColors.browne.withOpacity(0.3),
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    // ignoreGestures: true,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: AppColors.orange,
                    ),
                    onRatingUpdate: (rat) {
                      rating = rat;
                      setState(() {});
                    },
                  ),
                ),
                20.SpaceY,
                PrimaryTextField(
                  labelText: "Rating Description",
                  "Enter rating description",
                  lines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter rating description';
                    }
                    return null;
                  },
                  onChange: (value) {
                    description = value;
                  },
                ),
                50.SpaceY,
                Consumer<UserController>(builder: (context, usercontroller, _) {
                  return usercontroller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : GradientButton(
                          text: 'Submit',
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              submitRating();
                            }
                          },
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
