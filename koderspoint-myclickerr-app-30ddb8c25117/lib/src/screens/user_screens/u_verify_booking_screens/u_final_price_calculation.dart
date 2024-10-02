import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';

import 'package:provider/provider.dart';

import '../../../helpers/constants.dart';
import '../../../controllers/user_side_controllers/u_add_booking_order_controller.dart';
import '../../../helpers/helpers.dart';

class FinalPriceCalculation extends StatefulWidget {
  final CustomOrder? customOrder;

  FinalPriceCalculation({
    super.key,
    this.customOrder,
  });

  @override
  State<FinalPriceCalculation> createState() => _FinalPriceCalculationState();
}

class _FinalPriceCalculationState extends State<FinalPriceCalculation> {
  late UserAddBookingOrderController userAddBookingOrderProvider;

  @override
  void initState() {
    userAddBookingOrderProvider =
        Provider.of<UserAddBookingOrderController>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userAddBookingOrderProvider.calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kInputBorderRadius),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset.zero)
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Consumer<UserAddBookingOrderController>(
          builder: (context, orderPrvdr, child) {
        return Column(
          children: [
            // widget.customOrder != null
            //     ? SizedBox.shrink()
            //     :
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Price',
                  style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                ),
                Spacer(),
                Text(
                  '\u{20B9} ${orderPrvdr.newOrder!.bidAmount!.toStringAsFixed(1)}',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 18, color: AppColors.black),
                ),
                8.SpaceX,
                Text(
                  'Per Hour',
                  style: MyTextStyle.mediumItalic.copyWith(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            15.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'No. of Hours',
                  style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                ),
                Text(
                  '${orderPrvdr.newOrder!.duration} hours',
                  style: MyTextStyle.mediumItalic.copyWith(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            widget.customOrder != null ? SizedBox.shrink() : 15.SpaceY,
            widget.customOrder != null
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Selected Equipment Price (${orderPrvdr.selectedEquipmentCount})',
                        style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                      ),
                      Text(
                        '\u{20B9} ${orderPrvdr.selectedEquipmentPrice.toStringAsFixed(1)}',
                        style: MyTextStyle.semiBold05Black
                            .copyWith(fontSize: 18, color: AppColors.black),
                      ),
                    ],
                  ),
            15.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sub Total',
                  style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                ),
                Text(
                  '\u{20B9} ${orderPrvdr.subTotal.toStringAsFixed(1)}',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 20, color: AppColors.black),
                ),
              ],
            ),
            15.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tax Amount (18%)',
                  style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                ),
                Text(
                  // \u{20B9} ${orderPrvdr.totalAmount.toStringAsFixed(1)}
                  '\u{20B9} ${orderPrvdr.taxAmount.toStringAsFixed(1)}',
                  style: MyTextStyle.semiBoldBlack.copyWith(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            15.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Coupon Code Discount',
                  style: MyTextStyle.regularBlack.copyWith(fontSize: 14),
                ),
                Text(
                  '\u{20B9} ${orderPrvdr.couponCodeAmount.toStringAsFixed(1)}',
                  // '${orderPrvdr.couponCodeDiscount.toStringAsFixed(1)} %',
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 18),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total Amount',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 14, color: AppColors.black),
                ),
                Text(
                  '\u{20B9} ${orderPrvdr.totalAmount.toStringAsFixed(1)}',
                  style: MyTextStyle.semiBold05Black
                      .copyWith(fontSize: 20, color: AppColors.black),
                ),
              ],
            ),
            0.SpaceY,
          ],
        );
      }),
    );
  }
}
