import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/dialogs.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:provider/provider.dart';

import '../controllers/user_side_controllers/user_controller.dart';
import '../screens/shared_screens/notifications_screen.dart';
import 'action_item_badge.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar(
      {Key? key,
      this.themeColor = AppColors.orange,
      required this.title,
      this.elevation = 2,
      this.action})
      : super(key: key);

  final Color? themeColor;
  final String title;
  final double? elevation;
  final List<Widget>? action;

  @override
  Size get preferredSize => new Size.fromHeight(60);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    UserController userProvider = Provider.of<UserController>(context);

    return AppBar(
      iconTheme: Theme.of(context).iconTheme,
      elevation: widget.elevation,
      toolbarHeight: 60,
      title: Text(
        widget.title,
        style: MyTextStyle.semiBoldBlack.copyWith(
          fontSize: 20,
        ),
      ),
      actions: widget.action ??
          [
            ActionItemBadge(
              count: userProvider.unreadNotificationCount,
              icon: Icons.notifications_outlined,
              iconColor: AppColors.black,
              badgeColor: Colors.red.shade800,
              badgeTextColor: Colors.white,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => NotificationsScreen(),
                ));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 9.0),
              child: ActionItemBadge(
                count: 0,
                icon: Icons.login_outlined,
                iconColor: AppColors.black,
                badgeColor: Colors.red.shade800,
                badgeTextColor: Colors.white,
                onTap: () {
                  AppDialogs.exitDialog(context);
                },
              ),
            ),
          ],
    );
  }
}
