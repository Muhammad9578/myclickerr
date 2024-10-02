import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../modules/chat/controllers/custom_order_controller.dart';
import '../../../helpers/constants.dart';
import '../../../models/user.dart';
import '../../../helpers/session_helper.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/primary_text_field.dart';

class PhotographerCreateCustomOrderScreen extends StatefulWidget {
  static const route = "photographerCreateCustomOrderScreen";
  final String groupChatId;
  final String peerUserId;
  final String roomid;
  final Function onSendMessage;

  const PhotographerCreateCustomOrderScreen(
      {Key? key,
      required this.onSendMessage,
      required this.groupChatId,
      required this.peerUserId,
      required this.roomid})
      : super(key: key);

  @override
  State<PhotographerCreateCustomOrderScreen> createState() =>
      _PhotographerCreateCustomOrderScreenState();
}

class _PhotographerCreateCustomOrderScreenState
    extends State<PhotographerCreateCustomOrderScreen> {
  late String idFromOrder; // photographer id
  // String idToOrder;
  String orderTotalPrice = '';
  int orderTotalHours = 0;
  String orderDescription = '';
  String orderStatus = '';
  String orderCreatedTimestamp = '';

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late CustomOrderController customOrderProvider;

  late User loggedInUser;

  createCustomOrder() {
    // print(
    // "data: ${widget
    //     .groupChatId} ,, $orderTotalPrice ,, $orderTotalHours ,, $orderDescription ,, ${loggedInUser
    //     .id}"
    // );
    try {
      customOrderProvider.createCustomOrder(
          context: context,
          roomid: widget.roomid,
          groupChatId: widget.groupChatId,
          orderTotalPrice: double.parse(orderTotalPrice.toString()),
          orderTotalHours: orderTotalHours,
          orderStatus: 'Pending',
          orderDescription: orderDescription,
          orderCreatedTimestamp:
              DateTime.now().millisecondsSinceEpoch.toString(),
          photographerId: loggedInUser.id.toString(),
          userId: widget.peerUserId,
          onSendMessage: widget.onSendMessage,
          photographerDetails: {
            FirestoreConstants.orderPname: loggedInUser.name.toString(),
            FirestoreConstants.orderPprofileImage:
                loggedInUser.profileImage.toString(),
            FirestoreConstants.orderPperHourPrice:
                loggedInUser.perHourPrice.toString(),
            FirestoreConstants.orderPskills: loggedInUser.skills.toString(),
            FirestoreConstants.orderPshortBio: loggedInUser.shortBio.toString(),
          });
    } catch (e) {
      customOrderProvider.setStatusLoader(false);
      Toasty.error('Error in creating custom order');
    }
  }

  @override
  void initState() {
    super.initState();
    customOrderProvider =
        Provider.of<CustomOrderController>(context, listen: false);
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          this.idFromOrder = loggedInUser.id.toString();
        });
      }
    });
    // print("create custom order groupChatId: ${widget.groupChatId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Create Custom Order",
        action: [],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      25.SpaceY,
                      PrimaryTextField(
                        textCapitalization: TextCapitalization.sentences,
                        labelText: 'Event Description',
                        'Provide details about event',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter event details'
                            : null,
                        onChange: (value) {
                          orderDescription = value;
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      PrimaryTextField(
                        'Enter Total amount',
                        labelText: "Amount",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter amount';
                          }
                          if (!value.trim().isValidNumbers()) {
                            return 'Only numbers are allowed';
                          }
                          return null;
                        },
                        onChange: (value) {
                          orderTotalPrice = value.trim().toString();
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      PrimaryTextField(
                        labelText: 'Total Time (In Hours)',
                        '30 hour',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter total event duration in hours'
                            : null,
                        // prefixIcon: Icons.calendar_month,
                        onChange: (value) {
                          try {
                            orderTotalHours = int.parse(value);
                          } catch (e) {}
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Consumer<CustomOrderController>(
                  builder: (context, cusOrderPrvdr, child) {
                return cusOrderPrvdr.changeStatusLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      )
                    : GradientButton(
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            cusOrderPrvdr.setStatusLoader(true);
                            createCustomOrder();
                          }
                        },
                        text: 'Create',
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
