import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

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
            borderSide: BorderSide(
              //strokeAlign: StrokeAlign.center,
              width: 1,
              // color: kInputBackgroundColor.withOpacity(0.9),
            ),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kInputBorderRadius),
              borderSide: BorderSide(width: 1, color: AppColors.lightGrey)),
        ),
        onChanged: onChange,
      ),
    );
  }
}
