import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/user_side_controllers/user_controller.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_appbar.dart';
import 'bank_detail_fragment.dart';

class PaymentInfoScreen extends StatefulWidget {
  static const route = "paymentInfoScreen";

  const PaymentInfoScreen({Key? key}) : super(key: key);

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  late UserController userProvider;
  late PhotorapherController photorapherController;
  late final User loggedInUser;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserController>(context, listen: false);
    photorapherController =
        Provider.of<PhotorapherController>(context, listen: false);
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          photorapherController.fetchBankDetails(loggedInUser.id);
        });
      }
    });
    // loggedInUser = userProvider.getUser()!;
    // setState(() {
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment Info", action: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, BankDetailFragment.route,
                arguments: {'bankDetail': photorapherController.bankAccount});
          },
          child: Text(
            "Edit",
            style: MyTextStyle.boldBlack.copyWith(
              color: AppColors.orange,
              fontSize: 16,
            ),
          ),
        )
      ]),
      body: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: SmartRefresher(
            controller: photographerPaymentInfoRefreshController,
            onRefresh: () {
              // print("loggedInUser!.id: ${loggedInUser.id}");
              photorapherController.fetchBankDetails(loggedInUser.id);
            },
            child: Consumer<PhotorapherController>(
                builder: (context, photoraphercontroller, _) {
              return photoraphercontroller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    )
                  : photoraphercontroller.bankAccount == null
                      ? Center(
                          child: Text(
                          "Bank details not found!",
                          style: MyTextStyle.boldBlack,
                        ))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            30.SpaceY,
                            Text(
                              "Bank",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 14),
                            ),
                            5.SpaceY,
                            Text(
                              "${photoraphercontroller.bankAccount?.bankName}",
                              style: MyTextStyle.semiBold085Black
                                  .copyWith(fontSize: 18),
                            ),
                            20.SpaceY,
                            Text(
                              "Account Number",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 14),
                            ),
                            5.SpaceY,
                            Text(
                              "${photoraphercontroller.bankAccount?.accountNumber}",
                              style: MyTextStyle.semiBold085Black
                                  .copyWith(fontSize: 18),
                            ),
                            20.SpaceY,
                            Text(
                              "Account Holder Name",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 14),
                            ),
                            5.SpaceY,
                            Text(
                              "${photoraphercontroller.bankAccount?.accountHolderName}",
                              style: MyTextStyle.semiBold085Black
                                  .copyWith(fontSize: 18),
                            ),
                            20.SpaceY,
                            Text(
                              "IFSC Code",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 14),
                            ),
                            5.SpaceY,
                            Text(
                              "${photoraphercontroller.bankAccount?.panNumber}",
                              style: MyTextStyle.semiBold085Black
                                  .copyWith(fontSize: 18),
                            ),
                            20.SpaceY,
                            Text(
                              "Country",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 14),
                            ),
                            5.SpaceY,
                            Text(
                              "${photoraphercontroller.bankAccount?.country}",
                              style: MyTextStyle.semiBold085Black
                                  .copyWith(fontSize: 18),
                            ),
                          ],
                        );
            }),
          )),
    );
  }
}
