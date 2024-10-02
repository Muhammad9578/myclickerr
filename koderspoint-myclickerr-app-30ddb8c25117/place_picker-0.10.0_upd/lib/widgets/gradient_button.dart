import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double width;
  final VoidCallback? onPress;

  GradientButton(
      {this.text = "", this.width = double.infinity, this.icon = null, this.onPress});

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
              Radius.circular(30),
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
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: "AlbertSans",
                          fontWeight: FontWeight.w600)
                    ),
              icon == null
                  ? SizedBox.shrink()
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 15,
                    ),
              // 24.SpaceX
            ],
          ),
          onPressed: onPress),
    );
  }
}
