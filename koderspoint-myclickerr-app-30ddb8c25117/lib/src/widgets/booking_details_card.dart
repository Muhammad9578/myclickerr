import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/booking.dart';
import 'package:photo_lab/src/screens/shared_screens/booking_details_screen1.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

class BookingDetailCard extends StatefulWidget {
  const BookingDetailCard({
    super.key,
    required this.bkDetail,
  });

  final Booking bkDetail;

  @override
  State<BookingDetailCard> createState() => _BookingDetailCardState();
}

class _BookingDetailCardState extends State<BookingDetailCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // if (bkDetail.status != 'completed') {
        // closeKeyboard(context);
        // Navigator.pushNamed(context, BookingDetailScreen1.route,
        //     arguments: bkDetail);

        await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return BookingDetailScreen(
              bkDetail: widget.bkDetail,
            );
          },
        ));

        // }
      },
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset.zero,
                  blurRadius: 10),
            ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    '${widget.bkDetail.eventTitle}',
                    style: MyTextStyle.boldBlack.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                5.SpaceX,
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: widget.bkDetail.status == 'accepted'
                            ? AppColors.blue
                            : widget.bkDetail.status == 'rejected'
                                ? AppColors.red
                                : widget.bkDetail.status == 'completed'
                                    ? AppColors.lightGreen
                                    : widget.bkDetail.status == 'pending'
                                        ? AppColors.lightGreen
                                        : Colors.transparent,
                        width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    widget.bkDetail.status == 'accepted'
                        ? "ACCEPTED"
                        : widget.bkDetail.status == 'completed'
                            ? "COMPLETED"
                            : widget.bkDetail.status == 'pending'
                                ? "PENDING"
                                : widget.bkDetail.status == 'rejected' &&
                                        widget.bkDetail.rejectedBy == "1"
                                    ? "Cancelled"
                                    : widget.bkDetail.status == 'rejected'
                                        ? "Rejected"
                                        : "",
                    style: MyTextStyle.semiBold05Black.copyWith(
                      fontSize: 14,
                      color: widget.bkDetail.status == 'accepted'
                          ? AppColors.blue
                          : widget.bkDetail.status == 'rejected'
                              ? AppColors.red
                              : widget.bkDetail.status == 'completed'
                                  ? AppColors.lightGreen
                                  : AppColors.lightGreen,
                    ),
                  ),
                )
              ],
            ),
            5.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.black,
                  // size: 23,
                ),
                12.SpaceX,
                Text(
                  '${widget.bkDetail.eventDate} - ',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 14, color: AppColors.black),
                ),
                Text(
                  '${widget.bkDetail.eventTime}',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 14, color: AppColors.black),
                ),
              ],
            ),
            15.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.black,
                ),
                12.SpaceX,
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.bkDetail.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MyTextStyle.semiBold05Black
                        .copyWith(fontSize: 14, color: AppColors.black),
                  ),
                ),
              ],
            ),
            15.SpaceY,
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
                  'Estimated Amount:',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 14, color: AppColors.black),
                ),
                Spacer(),
                Text(
                  '\u{20B9} ${widget.bkDetail.totalAmount} ',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 20, color: AppColors.black),
                ),
                // Text(
                //   'Per Hour',
                //   style: MyTextStyle.mediumItalic.copyWith(
                //     fontSize: 14,
                //   ),
                // ),
              ],
            ),
            15.SpaceY,
            Divider(
              color: AppColors.black.withOpacity(0.1),
              height: 5,
              thickness: 1,
            ),
            15.SpaceY,
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: ImageAsset.PlaceholderImg,
                      image: widget.bkDetail.profileImage,
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
                ),
                15.SpaceX,
                Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.bkDetail.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 16, color: AppColors.black),
                              ),
                            ),
                          ],
                        ),
                        8.SpaceY,
                        Text(
                          'Booked on ${widget.bkDetail.eventDate} - ${widget.bkDetail.eventTime}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: MyTextStyle.semiBold05Black.copyWith(
                              fontSize: 12,
                              color: AppColors.black.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            15.SpaceY,
            widget.bkDetail.status == 'pending' && SessionHelper.userType == "2"
                ? Divider(
                    color: AppColors.black.withOpacity(0.1),
                    height: 5,
                    thickness: 1,
                  )
                : SizedBox.shrink(),
            widget.bkDetail.status == 'pending' && SessionHelper.userType == "2"
                ? 15.SpaceY
                : SizedBox.shrink(),
            widget.bkDetail.status == 'pending' && SessionHelper.userType == "2"
                ?
                // ? timelineBuild()
                Consumer<PhotographerBookingListController>(
                    builder: (context, photographerPrvdr, child) {
                    return photographerPrvdr.changeStatusLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                  color: AppColors.orange),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: PrimaryButton(
                                      text: "Accept",
                                      color: AppColors.darkBlue,
                                      onPress: () async {
                                        await photographerPrvdr.acceptBooking(
                                          widget.bkDetail.id,
                                          'accepted',
                                          widget.bkDetail.photographerId,
                                          widget.bkDetail,
                                          context,
                                        );
                                        photographerPrvdr
                                            .pNewRequestBookingRefreshController
                                            .requestRefresh();
                                      })),
                              10.SpaceX,
                              Expanded(
                                  child: PrimaryButton(
                                      text: "Reject",
                                      color: AppColors.kInputBackgroundColor,
                                      onPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RejectBookingDialog(
                                              onReject: () async {
                                                await photographerPrvdr
                                                    .p_changeBookingStatus(
                                                        widget.bkDetail.id,
                                                        'rejected',
                                                        SessionHelper
                                                                    .userType ==
                                                                "1"
                                                            ? widget
                                                                .bkDetail.userId
                                                            : widget.bkDetail
                                                                .photographerId,
                                                        context,
                                                        fromDetail: false);

                                                photographerPrvdr
                                                    .pNewRequestBookingRefreshController
                                                    .requestRefresh();
                                              },
                                            );
                                          },
                                        );
                                      })),
                            ],
                          );
                  })
                // : SizedBox.shrink(),
                : widget.bkDetail.status == 'pending'
                    ? SizedBox.shrink()
                    : timelineBuild(),
          ],
        ),
      ),
    );
  }

  Container timelineBuild() {
    // 1 for 1st item, 2 for 2nd item of row and so on.
    String? n1, n2, n3;
    int? t1, t2, t3;

    if (widget.bkDetail.bookedTime != null) {
      n1 = 'Booked';
      t1 = widget.bkDetail.bookedTime;
    }

    if (widget.bkDetail.completedTime != null) {
      n3 = 'Completed';
      t3 = widget.bkDetail.completedTime;
    } else if (widget.bkDetail.rejectedTime != null) {
      n3 = 'Rejected';
      t3 = widget.bkDetail.rejectedTime;
    } else if (widget.bkDetail.cancelledTime != null) {
      n3 = 'Cancelled';
      t3 = widget.bkDetail.cancelledTime;
    }

    if (widget.bkDetail.rescheduledTime != null) {
      n2 = 'Rescheduled';
      t2 = widget.bkDetail.rescheduledTime;
    } else if (widget.bkDetail.acceptedTime != null) {
      n2 = 'Accepted';
      t2 = widget.bkDetail.acceptedTime;
    }

    if (n3 == null) {
      // means ont finalized
      if (widget.bkDetail.rescheduledTime != null) {
        {
          n2 = 'Accepted';
          t2 = widget.bkDetail.acceptedTime;
        }
        {
          n3 = 'Rescheduled';
          t3 = widget.bkDetail.rescheduledTime;
        }
      }
    }

    if (n2 == null) {
      if (widget.bkDetail.rejectedTime != null) {
        n2 = 'Rejected';
        t2 = widget.bkDetail.rejectedTime;
      } else {
        n2 = 'Cancelled';
        t2 = widget.bkDetail.cancelledTime;
      }
      n3 = null;
      t3 = null;
    }

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Expanded(
                      child: SizedBox(
                        height: 1.4,
                        child: Container(
                          color: AppColors.black.withOpacity(0.1),
                        ),
                      ),
                    )
                  ],
                ),
                8.SpaceY,
                Text(
                  "${n1 ?? 'null'}",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 12),
                ),
                3.SpaceY,
                FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "${prettyDateTimeForTimeline(t1 ?? 1691500839)}",

                      // "${bkDetail.eventDate} - ${bkDetail.eventTime}",
                      style: MyTextStyle.medium07Black.copyWith(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    n3 == null
                        ? SizedBox.shrink()
                        : Expanded(
                            child: SizedBox(
                              height: 1.4,
                              child: Container(
                                color: AppColors.black.withOpacity(0.1),
                              ),
                            ),
                          )
                  ],
                ),
                8.SpaceY,
                Text(
                  '${n2 ?? 'null'}',
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 12),
                ),
                3.SpaceY,
                FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "${prettyDateTimeForTimeline(t2 ?? t1 ?? 1691500839)}",
                      style: MyTextStyle.medium07Black.copyWith(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          n3 == null
              ? SizedBox.shrink()
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  shape: BoxShape.circle,
                                  color: AppColors.purple),
                            ),
                          ),
                          // Expanded(
                          //   child: SizedBox(
                          //     height: 1.4,
                          //     child: Container(
                          //       color: AppColors.black.withOpacity(0.1),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      8.SpaceY,
                      Text(
                        "$n3",
                        style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 12),
                      ),
                      3.SpaceY,
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "${prettyDateTimeForTimeline(t3!)}",
                            style: MyTextStyle.medium07Black
                                .copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}

class RejectBookingDialog extends StatelessWidget {
  final VoidCallback onReject;

  RejectBookingDialog({required this.onReject});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reject Booking'),
      content: Text('Are you sure you want to reject this booking?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onReject(); // Call the provided onReject callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Reject'),
        ),
      ],
    );
  }
}
