import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import 'package:photo_lab/src/models/booking.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../controllers/user_side_controllers/u_booking_controller.dart';
import '../helpers/constants.dart';
import '../helpers/helpers.dart';

class RatePhotographerWidget extends StatefulWidget {
  const RatePhotographerWidget({super.key, required this.bkDetail});

  final Booking bkDetail;

  @override
  State<RatePhotographerWidget> createState() => _RatePhotographerWidgetState();
}

class _RatePhotographerWidgetState extends State<RatePhotographerWidget> {
  double rating = 4;
  String description = '';
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  late Booking bkDetail;
  late PhotographerPortfolioController photographerPortfolioProvider;
  late UserBookingController userBookingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userBookingProvider =
          Provider.of<UserBookingController>(context, listen: false);
      this.bkDetail = widget.bkDetail;

      photographerPortfolioProvider =
          Provider.of<PhotographerPortfolioController>(context, listen: false);
      photographerPortfolioProvider.getskills();

      if (bkDetail.rating != null) {
        photographerPortfolioProvider.alreadyRated = true;
        rating = bkDetail.rating!;
        description = bkDetail.ratingDescription ?? "Not Provided";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotographerPortfolioController>(
        builder: (context, portfolioPrvdr, child) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset.zero,
                  blurRadius: 10),
            ]),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    portfolioPrvdr.alreadyRated
                        ? 'Rating'
                        : "Rate your experience",
                    style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    rating <= 1
                        ? 'Poor'
                        : rating <= 2
                            ? 'Average'
                            : rating <= 3
                                ? "Good"
                                : rating <= 4
                                    ? "Very Good"
                                    : "Excellent",
                    style: MyTextStyle.semiBoldBlack
                        .copyWith(fontSize: 14, color: AppColors.blue),
                  ),
                ],
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
                    color: AppColors.yellow,
                  ),
                  ignoreGestures: portfolioPrvdr.alreadyRated,
                  onRatingUpdate: (rat) {
                    print("rat: $rat");
                    if (!portfolioPrvdr.alreadyRated) {
                      rating = rat;
                      setState(() {});
                    }
                  },
                ),
              ),
              20.SpaceY,
              PrimaryTextField(
                labelText: "Comments",
                initialValue: description,
                "Enter comments",
                lines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter rating description';
                  }
                  return null;
                },
                readOnly: portfolioPrvdr.alreadyRated ? true : false,
                onChange: (value) {
                  description = value;
                },
              ),
              12.SpaceY,

              portfolioPrvdr.alreadyRated
                  ? SizedBox.shrink()
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: AppColors.orange, width: 1),
                            ),
                            child: MaterialButton(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              // shape: StadiumBorder(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(kButtonBorderRadius),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                portfolioPrvdr.submitRating(
                                  context: context,
                                  userBookingProvider: userBookingProvider,
                                  bkDetail: widget.bkDetail,
                                  rating: rating,
                                  description: description,
                                );
                              },
                              child: Text(
                                'Submit',
                                style: MyTextStyle.white16
                                    .copyWith(color: AppColors.orange),
                              ),
                            ),
                          ),
                        ),
              // GradientButton(
              //   text: 'Submit',
              //   onPress: () {
              //     if (_formKey.currentState!.validate()) {
              //       // setState(() {
              //       //   isLoading = true;
              //       // });
              //       // submitRating();
              //     }
              //   },
              // ),
            ],
          ),
        ),
      );
    });
  }
}
