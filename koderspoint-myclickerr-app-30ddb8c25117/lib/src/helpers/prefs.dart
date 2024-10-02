
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {

  static Future<void> setOnesignalUserId(String oneSignalUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('onesignal_user_id', oneSignalUserId);
  }

  static Future<String?> getOnesignalUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('onesignal_user_id');
  }

}