import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/shared_controllers/sharedcontroller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/notification_model.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<List<NotificationModel>>? _value;

  User? loggedInUser;
  bool isLoading = false;
  late UserController userProvider;

  late SharedController sharedController;
  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserController>();
    SessionHelper.getUser().then((loggedInUser) {
      print("loggedInUser: ${{loggedInUser!.id}}");
      sharedController = Provider.of<SharedController>(context, listen: false);
      setState(() {
        this.loggedInUser = loggedInUser;
        _value =
            sharedController.fetchNotifications(loggedInUser.id, userProvider);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifications",
        action: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: loggedInUser == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              )
            : FutureBuilder(
                future: _value,
                builder: (BuildContext context,
                    AsyncSnapshot<List<NotificationModel>> snapshot) {
                  print("snapshot.data not null: ${snapshot.data}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<NotificationModel> notificationsList =
                          snapshot.data!;
                      if (notificationsList.isEmpty) {
                        return Center(
                          child: Text('No notifications available'),
                        );
                      }
                      return ListView.builder(
                        itemCount: notificationsList.length,
                        itemBuilder: (context, index) {
                          final notification = notificationsList[index];
                          return Container(
                            // margin: EdgeInsets.only(bottom: kDefaultSpace),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: AppColors.lightPink,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          // chat, booking_completed, booking_rejected, new_booking_request, custom_order,
                                          notification.type == 'chat'
                                              ? Icons.chat_outlined
                                              : notification.type ==
                                                      'booking_completed'
                                                  ? Icons.check
                                                  :
                                                  //     todo verify notification  type
                                                  notification.type ==
                                                          'booking_rejected'
                                                      ? Icons.close
                                                      : notification.type ==
                                                              'new_booking_request'
                                                          ? Icons
                                                              .calendar_month_outlined
                                                          : notification.type ==
                                                                  'custom_order'
                                                              ? Icons
                                                                  .payment_outlined
                                                              : Icons
                                                                  .account_balance_wallet_outlined,
                                          color:
                                              AppColors.notificationIconBlack,
                                        ),
                                      ),
                                      15.SpaceX,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notificationsList[index].text,
                                              style: MyTextStyle.semiBoldBlack
                                                  .copyWith(fontSize: 16),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              prettyDateTimeForNotification(
                                                  notificationsList[index]
                                                          .time *
                                                      1000),
                                              style: MyTextStyle.semiBold05Black
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  15.SpaceY,
                                  notificationsList.length - 1 != index
                                      ? Divider(
                                          color:
                                              AppColors.black.withOpacity(0.1),
                                          height: 5,
                                          thickness: 1,
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('No data available'),
                      );
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
      ),
    );
  }
}
