import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

/// SecondaryButton

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;

  const SecondaryButton({required this.text, this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: kButtonPadding,
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(kButtonBorderRadius),
        ),
        side: BorderSide(
          color: AppColors.orange,
          width: kButtonBorderWidth,
        ),
      ),
      onPressed: onPress ?? () {},
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.kSecondaryButtonTextColor,
            fontSize: kPrimaryButtonFontSize,
          ),
        ),
      ),
    );
  }
}

/// Reject Button

class RejectButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final Color color;
  final TextStyle? textStyle;
  final IconData icon;
  final Color iconColor;

  RejectButton({required this.text,
    this.textStyle,
    this.icon = Icons.cancel_outlined,
    this.color = AppColors.kInputBackgroundColor,
    this.iconColor = AppColors.red,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            10.SpaceX,
            Text(
              text,
              style: textStyle ??
                  MyTextStyle.semiBoldDarkBlack.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// GradientButton

class GradientButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double width;
  final VoidCallback? onPress;

  GradientButton({this.text = "",
    this.width = double.infinity,
    this.icon = null,
    this.onPress,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
        ),
      ),
      child: MaterialButton(
          padding: EdgeInsets.only(left: 30, right: 25),
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // shape: StadiumBorder(),
          shape: RoundedRectangleBorder(
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
                  ? SizedBox.shrink()
                  : Text(
                '$text',
                style: MyTextStyle.white16,
              ),
              icon == null
                  ? SizedBox.shrink()
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

/// PrimaryButton

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final Color color;
  final TextStyle? textStyle;

  const PrimaryButton({required this.text,
    this.textStyle,
    this.color = AppColors.kInputBackgroundColor,
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
