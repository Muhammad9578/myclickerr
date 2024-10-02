import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/screens/shared_screens/profile_selections.dart';

import 'helpers.dart';

class AppDialogs {
  static Future<void> exitDialog(context) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                // color: AppColors.orange,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to logout?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.cancel,
                        color: AppColors.black.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.red,
                      ),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(
                          color: AppColors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        // exit(0);
        var loggedInUserr;
        SessionHelper.getUser().then((loggedInUser) {
          if (loggedInUser != null) {
            loggedInUserr = loggedInUser;
            // SessionHelper.setRememberMeFlag(
            //     Provider.of<AuthController>(context, listen: false).prefs,
            //     false);
            AppFunctions.removeOneSignalId(loggedInUserr!.id);
            SessionHelper.removeUser();
            FirebaseAuth.instance.signOut();
            AppFunctions.toggleUserOnlineStatus(false);
            Navigator.of(context).pushNamedAndRemoveUntil(
                ProfileSelectionScreen.route, (Route<dynamic> route) => false);
          }
        });
    }
  }
}
