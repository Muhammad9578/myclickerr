import 'package:flutter/material.dart';

import 'gradient_button.dart';

class SelectPlaceAction extends StatelessWidget {
  final String locationName;
  final String tapToSelectActionText;
  final VoidCallback onTap;

  SelectPlaceAction(this.locationName, this.onTap, this.tapToSelectActionText);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        // onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        'Selected Location',
                        style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold
                        )),
                    SizedBox(height: 10,),
                    Text(
                        locationName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                    ),
                   SizedBox(height: 10,),
                    // Text(this.tapToSelectActionText, style: TextStyle(color: Colors.grey, fontSize: 15)),
                    GradientButton(
                      onPress: onTap,
                      text: 'Confirm Location',
                    ),
                  ],
                ),
              ),
              // Icon(Icons.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
