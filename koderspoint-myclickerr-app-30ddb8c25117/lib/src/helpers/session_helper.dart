import 'dart:convert';

import 'package:photo_lab/main.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static String? userType;

  static void removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('logged_in_user');
  }

  static void setRememberMeFlag(prefs, bool rememberMe) async {
    prefs.setBool('rememberMe', rememberMe);
  }

  static void updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_user', jsonEncode(user.toJson()));
  }

  static void setuseremail(
      UserType usertype, bool remeberme, String email) async {
    if (usertype.name == 'user') {
      if (remeberme == true) {
        await prefss.setString("useremail", email);
      } else {
        if (prefss.containsKey('useremail')) {
          await prefss.remove('useremail');
        }
      }
    } else {
      if (remeberme == true) {
        await prefss.setString("photographeremail", email);
      } else {
        if (prefss.containsKey('photographeremail')) {
          await prefss.remove('photographeremail');
        }
      }
    }
  }

  static void setUser(
    User user,
    UserType usertype,
  ) async {
    print("inside setUser  usertype.name: ${usertype} ");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_user', jsonEncode(user.toJson()));
    if (prefs.containsKey('userType')) {
      await prefs.remove('userType');
    }
    if (usertype.name == 'user') {
      await prefs.setString('userType', "1");
      await prefs.setString("useremail", user.email);
      // print("inside user");
      SessionHelper.userType = "1";
    } else {
      // print("inside photographer");
      await prefs.setString('userType', "2");
      SessionHelper.userType = "2";
      await prefs.setString("photographeremail", user.email);
    }
    await prefs.reload();
    print(
        "after inside setUser  usertype.name: ${userType} \n  SessionHelper.userType: ${SessionHelper.userType}");
  }

  static Future<void> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    SessionHelper.userType = prefs.getString('userType');
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('logged_in_user');
    if (json == null) {
      return null;
    }
    SessionHelper.userType = prefs.getString('userType');
    // print("inside session helper getUser: ${prefs.getString('userType')}");
    User user = User.fromJson(jsonDecode(prefs.getString('logged_in_user')!),
        fromSessionClass: true);

    return user;
  }

  Future<String> getemail() async {
    String email = "";
    if (prefss.containsKey('rememberMe')) {
      if (prefss.getBool("rememberMe")) {
        if (userType == "1") {
          if (prefss.containsKey('useremail')) {
            email = prefss.getString("useremail") ?? "";
          }
        } else if (userType == "2") {
          if (prefss.containsKey('photographeremail')) {
            email = prefss.getString("photographeremail") ?? "";
          }
        }
      }
    }
    return email;
  }
}
