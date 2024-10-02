import 'package:flutter/cupertino.dart';

extension SpaceXY on int {
  SizedBox get SpaceX => SizedBox(
        width: this.toDouble(),
      );

  SizedBox get SpaceY => SizedBox(
        height: this.toDouble(),
      );
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$')
        .hasMatch(this);
  }
}
