import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../../controllers/user_side_controllers/u_add_booking_order_controller.dart';
import '../../../widgets/primary_text_field.dart';

class ApplyCouponClass extends StatefulWidget {
  const ApplyCouponClass({Key? key}) : super(key: key);

  @override
  State<ApplyCouponClass> createState() => _ApplyCouponClassState();
}

class _ApplyCouponClassState extends State<ApplyCouponClass> {
  bool paidEquipments = false;
  String couponCode = '';

  final couponController = TextEditingController();
  late UserAddBookingOrderController orderProvider;
  final _couponFromKey = GlobalKey<FormState>(debugLabel: 'Password');

  @override
  void initState() {
    super.initState();
    orderProvider =
        Provider.of<UserAddBookingOrderController>(context, listen: false);
    couponController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Coupons",
          style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
        ),
        15.SpaceY,
        Container(
          padding: EdgeInsets.all(0),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: CheckboxListTile(
                side: BorderSide(color: AppColors.orange,width: 2),
                              activeColor: AppColors.orange,
                  title: Text(
                    'Apply Coupons',
                    style: MyTextStyle.semiBold085Black.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  value: paidEquipments,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      paidEquipments = value ?? false;
                      orderProvider.setCouponCodeDiscount(0.0);
                    });
                  },
                ),
              ),
              !paidEquipments
                  ? SizedBox.shrink()
                  : Form(
                      key: _couponFromKey,
                      child: Consumer<UserAddBookingOrderController>(
                          builder: (context, orderPrvdr, child) {
                        return Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 15),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: PrimaryTextField(
                                  controller: couponController,
                                  // initialValue: 'MYC...',
                                  textCapitalization: TextCapitalization.none,
                                  'MYC...',
                                  labelText: "Enter coupon code",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter coupon code';
                                    }
                                    if (orderPrvdr.couponCodeDiscount == 0) {
                                      return 'Invalid coupon code';
                                    }

                                    return null;
                                  },
                                  onChange: (value) {
                                    if (couponController.text != '') {
                                      orderPrvdr.verifyCoupon(
                                          value.trim().toUpperCase());
                                      couponCode = value.trim();
                                    }
                                    if (_couponFromKey.currentState!
                                        .validate()) {}
                                  },
                                ),
                              ),
                              10.SpaceX,
                              orderPrvdr.couponCodeDiscount == 0
                                  ? SizedBox.shrink()
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: couponController.text == ''
                                            ? AppColors.orange
                                            : orderPrvdr.couponCodeDiscount ==
                                                    0.0
                                                ? AppColors.red
                                                : AppColors.orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child:

                                          // TextButton(
                                          //     onPressed: () {}, child: Text(
                                          //     couponController.text==''?
                                          //     "Validate":
                                          //
                                          // )),

                                          Icon(
                                        orderPrvdr.couponCodeDiscount == 0
                                            ? Icons.close
                                            : Icons.check,
                                        color:
                                            orderPrvdr.couponCodeDiscount == 0
                                                ? AppColors.white
                                                : AppColors.white,
                                      ),
                                    ),
                            ],
                          ),
                        );
                      }),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
