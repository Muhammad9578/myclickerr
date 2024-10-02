import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';

class PhoneTextField extends StatelessWidget {
  final Country selectedCountry;
  final String phone;
  final void Function(Country? country, String? phone) onChange;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly;

  const PhoneTextField(
      {this.phone = '',
      required this.selectedCountry,
      required this.onChange,
      this.controller,
      this.validator,
      this.readOnly = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black54),
          color: AppColors.kInputBackgroundColor.withAlpha(0),
          borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(
        top: kDefaultSpace * 0.8,
        bottom: kDefaultSpace * 0.8,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            CountryPicker(
              initialCountry: selectedCountry,
              readOnly: readOnly,
              onCountrySelected: (country) {
                onChange(country, phone);
              },
            ),
            Container(
              width: 2.5,
              margin: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 10, right: 0),
              decoration: BoxDecoration(
                color: const Color(0xFF909090),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Expanded(
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                controller: controller,
                // inputFormatters: [
                //   LengthLimitingTextInputFormatter(10),
                //
                // ],
                validator: validator,
                readOnly: readOnly,
                decoration: InputDecoration(
                  //fillColor: kInputBackgroundColor,
                  hintText: 'Phone Number',
                  //filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  onChange(selectedCountry, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountryPicker extends StatelessWidget {
  final void Function(Country country) onCountrySelected;
  final Country initialCountry;
  final bool readOnly;

  const CountryPicker(
      {required this.initialCountry,
      required this.onCountrySelected,
      this.readOnly = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!readOnly) {
          showCountryPicker(
            context: context,
            showPhoneCode: true,
            // optional. Shows phone code before the country name.
            countryListTheme: CountryListThemeData(
              borderRadius: BorderRadius.circular(kBottomSheetBorderRadius),
            ),
            onSelect: (Country country) {
              onCountrySelected(country);
            },
          );
        }
      },
      child: Row(
        children: [
          const SizedBox(width: 14),
          Text(
            initialCountry.flagEmoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 8),
          Text(
            '+${initialCountry.phoneCode}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
