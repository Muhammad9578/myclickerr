import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';

class CategoryListItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPress;

  const CategoryListItem(this.text,
      {this.isSelected = false, required this.onPress, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: kDefaultSpace),
      child: MaterialButton(
        padding: const EdgeInsets.only(right: 10, left: 10),
        color: isSelected ? AppColors.orange : null,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.orange,
            width: !isSelected ? kButtonBorderWidth : 0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(kButtonBorderRadius),
          ),
        ),
        onPressed: onPress,
        child: FittedBox(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? AppColors.white
                  : AppColors.kSecondaryButtonTextColor,
              fontSize: kPrimaryButtonFontSize,
            ),
          ),
        ),
      ),
    );
  }
}
