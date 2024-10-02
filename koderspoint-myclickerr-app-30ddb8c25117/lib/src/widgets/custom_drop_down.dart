import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  CustomDropdown(
      {Key? key,
      this.height = 60,
      required this.items,
      this.selectedValue,
      required this.onSubmit,
      this.icon = Icons.keyboard_arrow_down_sharp,
      this.hint = 'Select Mode'})
      : super(key: key);

  final List<String> items;
  final hint;
  final double height;
  final icon;
  final onSubmit;
  final String? selectedValue;

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        
        border: Border.all(
          color: Colors.black.withOpacity(0.4), // Border color
          width: 1, // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Border radius
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          hint: Text(
            widget.hint,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          items: widget.items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 18,color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: selectedValue ?? null,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
              widget.onSubmit(selectedValue);
            });
          },
          icon: Icon(widget.icon),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
