import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../models/user.dart';
import '../../../modules/chat/controllers/custom_order_controller.dart';
import '../../../widgets/custom_appbar.dart';
import '../../user_screens/u_add_booking_screens/u_add_new_booking_screen.dart';
import 'p_create_custom_order_screen.dart';

class PhtographerDisplayCustomOrder extends StatefulWidget {
  static const route = "phtographerDisplayCustomOrder";
  final String groupChatId;
  final String peerUserId;
  final String roomid;
  final Function onSendMessage;

  const PhtographerDisplayCustomOrder({Key? key,
    required this.groupChatId,
    required this.onSendMessage,
    required this.peerUserId,
    required this.roomid})
      : super(key: key);

  @override
  State<PhtographerDisplayCustomOrder> createState() =>
      _PhtographerDisplayCustomOrderState();
}

class _PhtographerDisplayCustomOrderState
    extends State<PhtographerDisplayCustomOrder> {
  bool isLoading = false;
  User? loggedInUser;

  // List<PhotographerEquipment>? equipments = [];
  List<QueryDocumentSnapshot> listMessage = [];

  late CustomOrderController customOrderProvider;

  @override
  initState() {
    super.initState();
    customOrderProvider =
        Provider.of<CustomOrderController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      if (value != null) {
        setState(() {
          loggedInUser = value;
          // isLoading = true;
        });
        // fetchEquipments(loggedInUser!.id);
        // fetchData(loggedInUser!.id, 31.3952319, 74.2570513);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("groupChatId: ${widget.groupChatId}");

    return Scaffold(
      appBar: CustomAppBar(title: "Custom Orders", action: [
        SessionHelper.userType == '1'
            ? SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.only(left: 5, right: 10),
          child: SizedBox(
            height: 30,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  PhotographerCreateCustomOrderScreen.route,
                  arguments: {
                    'groupChatId': widget.groupChatId,
                    'peerUserId': widget.peerUserId,
                    "onSendMessage": widget.onSendMessage,
                    "roomid": widget.roomid
                  },
                );
              },
              child: Text(
                "+ Add New",
                style: MyTextStyle.boldBlack
                    .copyWith(fontSize: 14, color: AppColors.orange),
              ),
            ),
          ),
        ),
      ]),
      body: Container(
          child: Center(
              child: StreamBuilder<QuerySnapshot>(
                  stream: customOrderProvider.getCustomOrder(
                      groupChatId: widget.groupChatId, limit: 100),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      listMessage = snapshot.data!.docs;
                      if (listMessage.length > 0) {
                        return ListView.builder(
                          shrinkWrap: true,
                          addRepaintBoundaries: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.docs.length,
                          // reverse: true,
                          itemBuilder: (context, index) {
                            DocumentSnapshot? document =
                            snapshot.data?.docs[index];

                            return Padding(
                              padding:
                              EdgeInsets.only(top: index == 0 ? 20 : 0),
                              child: customOrderBuild(document!),
                            );
                          },
                        );
                      } else {
                        return SessionHelper.userType == "2"
                            ? CustomOrderNotFound(
                          groupChatId: widget.groupChatId,
                          peerUserId: widget.peerUserId,
                          onSendMessage: widget.onSendMessage,
                          roomid: widget.roomid,
                        )
                            : Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20),
                            child: Text(
                              textAlign: TextAlign.center,
                              "Custom Order not available.",
                              style: MyTextStyle.mediumBlack
                                  .copyWith(fontSize: 20),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                    }
                  }))),
    );
  }

  customOrderBuild(DocumentSnapshot document) {
    CustomOrder customOrder = CustomOrder.fromDocument(document);
    // // print("customOrder lst: ${customOrder.orderPhotographerDetails}");
    return Container(
      margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset.zero,
                blurRadius: 10),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.SpaceY,
          Text(
            'Created at',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${DateFormat('dd MMM yy, hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(customOrder.orderCreatedTimestamp)))}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Text(
            'Description',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${customOrder.orderDescription}',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Text(
            'Hours',
            style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          ),
          5.SpaceY,
          Text(
            '${customOrder.orderTotalHours} hours',
            style: MyTextStyle.semiBold085Black.copyWith(
                fontSize: 17, color: AppColors.black.withOpacity(0.85)),
          ),
          15.SpaceY,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Price:',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 14, color: AppColors.black),
              ),
              Spacer(),
              Text(
                '\u{20B9} ${customOrder.orderTotalPrice} ',
                style: MyTextStyle.semiBold05Black
                    .copyWith(fontSize: 20, color: AppColors.black),
              ),
              Text(
                'Per Hour',
                style: MyTextStyle.mediumItalic.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          15.SpaceY,
          customOrder.orderStatus == 'Pending' &&
              SessionHelper.userType == "2" // means photographer
              ? Divider(
            color: AppColors.black.withOpacity(0.1),
            height: 5,
            thickness: 1,
          )
              : SizedBox.shrink(),
          15.SpaceY,
          Consumer<CustomOrderController>(
              builder: (context, cusOrderPrvdr, child) {
                return cusOrderPrvdr.changeStatusLoading
                    ? Center(
                  child: CircularProgressIndicator(
                      color: AppColors.orange),
                )
                    : customOrder.orderStatus == 'Pending' &&
                    SessionHelper.userType == "1"
                    ? Row(
                  children: [
                    Expanded(
                        child: PrimaryButton(
                            text: "Accept",
                            color: AppColors.darkBlue,
                            onPress: () {
                              customOrder.documentReference = document.id;
                              customOrder.groupChatId =
                                  widget.groupChatId;

                              Navigator.pushNamed(
                                  context, UserAddNewBookingScreen.route,
                                  arguments: {
                                    'customOrder': customOrder
                                  });
                            })),
                    10.SpaceX,
                    Expanded(
                        child: PrimaryButton(
                            text: "Reject",
                            color: AppColors.kInputBackgroundColor,
                            onPress: () {
                              customOrderProvider.setStatusLoader(true);
                              customOrderProvider.updateCustomOrderStatus(
                                  orderStatus: 'Rejected',
                                  groupChatId: widget.groupChatId,
                                  documentReference: document.id);
                              customOrderProvider
                                  .sendCustomOrderNotificationToPhotographer(
                                  loggedInUser!.id,
                                  customOrder.photographerId,
                                  'rejected');
                            })),
                  ],
                )
                    : customOrder.orderStatus == 'Withdrawn'
                    ? rejectedWithdrawnBuild('Order has been Withdrawn')
                    : customOrder.orderStatus == 'Rejected'
                    ? rejectedWithdrawnBuild(
                    SessionHelper.userType == "1"
                        ? 'Order has been Declined'
                        : 'Order has been Rejected')
                    : customOrder.orderStatus == 'Accepted'
                    ? rejectedWithdrawnBuild(
                    SessionHelper.userType == "1"
                        ? 'Order has been Placed'
                        : 'Order has been Accepted')
                    : GradientButton(
                  onPress: () {
                    customOrderProvider.setStatusLoader(true);
                    customOrderProvider
                        .updateCustomOrderStatus(
                        orderStatus: 'Withdrawn',
                        groupChatId: widget.groupChatId,
                        documentReference: document.id);

                    customOrderProvider
                        .sendCustomOrderNotificationToPhotographer(
                        loggedInUser!.id,
                        customOrder.photographerId,
                        'withdrawn');
                  },
                  text: customOrder.orderStatus == 'Withdrawn'
                      ? "Withdrawn by you"
                      : 'Withdraw Order',
                );
              }),
        ],
      ),
    );
  }

  Widget rejectedWithdrawnBuild(txt) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(15),
      child: Text(
        "$txt",
        style: MyTextStyle.semiBold05Black
            .copyWith(fontSize: 15, color: AppColors.black),
      ),
    );
  }
}

class CustomOrderNotFound extends StatelessWidget {
  final String groupChatId;
  final String peerUserId;
  final Function onSendMessage;
  final String roomid;

  const CustomOrderNotFound({
    required this.groupChatId,
    required this.peerUserId,
    required this.onSendMessage,
    required this.roomid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 25,
                color: AppColors.black,
              )),
          20.SpaceY,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text(
              textAlign: TextAlign.center,
              "Custom order is not created yet",
              style: MyTextStyle.mediumBlack.copyWith(fontSize: 20),
            ),
          ),
          30.SpaceY,
          GradientButton(
              text: "+ Create Custom Orders",
              onPress: () {
                Navigator.pushNamed(
                  context,
                  PhotographerCreateCustomOrderScreen.route,
                  arguments: {
                    'groupChatId': groupChatId,
                    'peerUserId': peerUserId,
                    "onSendMessage": onSendMessage,
                    "roomid": roomid ?? ""
                  },
                );
              }),
        ],
      ),
    );
  }
}
