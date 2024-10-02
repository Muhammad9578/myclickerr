import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myclicker_support/Src/UI/LoginScreen.dart';

import '../../main.dart';
import 'Constants.dart';

class PrimaryTextField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final bool hideText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final int lines;
  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String value)? onChange;
  final String? Function(String? value)? validator;
  final void Function()? onTap;
  final void Function()? suffixIconOnTap;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const PrimaryTextField(this.hintText,
      {this.hideText = false,
      this.labelText,
      this.prefixIcon,
      this.suffixIcon,
      this.lines = 1,
      this.onChange,
      this.validator,
      this.initialValue,
      this.textCapitalization = TextCapitalization.sentences,
      this.controller,
      this.readOnly = false,
      this.onTap,
      this.suffixIconOnTap,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.focusNode,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: kDefaultSpace * 0.8,
        bottom: kDefaultSpace * 0.8,
      ),
      child: TextFormField(
        initialValue: initialValue,
        textCapitalization: keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : textCapitalization,
        style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
        controller: controller,
        obscureText: hideText,
        keyboardType: keyboardType,
        minLines: lines,
        maxLines: lines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          // fillColor: kInputBackgroundColor,
          hintText: hintText,
          labelStyle: MyTextStyle.medium07Black.copyWith(fontSize: 16),
          hintStyle: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          labelText: labelText,
          // filled: true,

          suffixIcon: suffixIcon == null
              ? null
              : InkWell(
                  onTap: suffixIconOnTap,
                  child: Icon(suffixIcon,
                      color: AppColors.black.withOpacity(0.5))),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: AppColors.black.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: const BorderSide(
              //strokeAlign: StrokeAlign.center,
              width: 1,
              // color: kInputBackgroundColor.withOpacity(0.9),
            ),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kInputBorderRadius),
              borderSide:
                  const BorderSide(width: 1, color: AppColors.lightGrey)),
        ),
        onChanged: onChange,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double width;
  final VoidCallback? onPress;

  GradientButton(
      {this.text = "",
      this.width = double.infinity,
      this.icon = null,
      this.onPress,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
        ),
      ),
      child: MaterialButton(
          padding: const EdgeInsets.only(left: 30, right: 25),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // shape: StadiumBorder(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(kButtonBorderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: text == "" || icon == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              // .SpaceX,
              text == ""
                  ? const SizedBox.shrink()
                  : Text(
                      '$text',
                      style: MyTextStyle.white16,
                    ),
              icon == null
                  ? const SizedBox.shrink()
                  : Icon(
                      icon,
                      color: AppColors.white,
                      size: 15,
                    ),
              // 24.SpaceX
            ],
          ),
          onPressed: onPress),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final Color color;
  final TextStyle? textStyle;

  const PrimaryButton(
      {required this.text,
      this.textStyle,
      this.color = kInputBackgroundColor,
      this.onPress,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        elevation: 0,
        padding: kButtonPadding,
        color: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(kButtonBorderRadius),
          ),
        ),
        onPressed: onPress ?? () {},
        child: Text(
          text,
          style: textStyle ??
              (text == 'Accept'
                  ? MyTextStyle.semiBoldDarkBlack
                      .copyWith(fontSize: 16, color: Colors.white)
                  : MyTextStyle.semiBoldDarkBlack.copyWith(fontSize: 16)),
        ),
      ),
    );
  }
}

class CircleProfile extends StatelessWidget {
  final Image image;
  final double radius;

  const CircleProfile({required this.radius, required this.image, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      child: ClipOval(
        child: AspectRatio(aspectRatio: 1, child: image),
      ),
    );*/

    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: const AssetImage('images/placeholder.png'),
            image: image.image,
            imageErrorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Error'));
            },
          ),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: const Center(
        child: CircularProgressIndicator(
          color: ColorConstants.themeColor,
        ),
      ),
    );
  }
}

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
    return AppBar(
      // titleSpacing: 0,
      // leadingWidth: 50,
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
            Padding(
              padding: const EdgeInsets.only(right: 9.0),
              child: ActionItemBadge(
                count: 0,
                icon: Icons.login_outlined,
                iconColor: AppColors.black,
                badgeColor: Colors.red.shade800,
                badgeTextColor: Colors.white,
                onTap: () {
                  openDialog(context);
                },
              ),
            ),
          ],
    );
  }
}

class CustomNavTile extends StatelessWidget {
  final String title;
  final bool selected;
  final IconData icon;
  final void Function() onTap;

  const CustomNavTile(
      {required this.title,
      required this.icon,
      required this.selected,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                //colors: [Color(0x00D9D9D9), Color(0xFFD9D9D9)],
                colors: [kPrimaryButtonColor.withAlpha(0), kPrimaryButtonColor],
              )
            : null,
      ),
      child: ListTile(
        selected: selected,
        leading: Icon(icon,
            color: selected
                ? kPrimaryButtonColor
                : kPrimaryButtonColor.withAlpha(130)),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}

class ActionItemBadge extends StatelessWidget {
  final int count;
  final Color badgeColor;
  final Color iconColor;
  final Color badgeTextColor;
  final IconData icon;
  final void Function() onTap;

  const ActionItemBadge({
    required this.count,
    required this.iconColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 9.0, left: 9, top: 18),
            child: Icon(
              icon,
              size: 25,
              color: iconColor,
            ),
          ),
          Visibility(
            visible: count > 0,
            child: Positioned(
              top: 8,
              right: 11,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.red.shade800,
                child: FittedBox(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(color: badgeTextColor, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openDialog(BuildContext context) async {
  switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              // color: AppColors.orange,
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Icon(
                      Icons.exit_to_app,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Are you sure to logout?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Cancel',
                    style: TextStyle(
                        color: AppColors.black.withOpacity(0.8),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.red,
                    ),
                  ),
                  const Text(
                    'Yes',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        );
      })) {
    case 0:
      break;
    case 1:
      // exit(0);
      var loggedInUserr;
      toggleUserOnlineStatus(false);
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final Widget child;

  CustomBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0.0, -2.0), // Negative y-offset for top shadow
            blurRadius: 4.0,
          ),
        ],
      ),
      // border: Border.all(color: Colors.black)),
      child: child,
    );
  }
}
