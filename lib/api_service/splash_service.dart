
import 'package:flutter/material.dart';

import 'package:tms_app/api_service/prefs/PreferencesKey.dart';
import 'package:tms_app/api_service/prefs/app_preference.dart';
import 'package:tms_app/auth/login_screen.dart';
import 'package:tms_app/dashbard_Screen.dart';




class SplashServices {
  void checkAuthentication(BuildContext context) async {
    Future.delayed(const Duration(seconds: 1), () {
       

      if (AppPreference().getString(PreferencesKey.token).isEmpty ||
          AppPreference().getString(PreferencesKey.token) == "") {
        //Get.to(LangvangeSelection());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AimaLoginScreen()),
        );
      } else {
       Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainDashboard()),
          );

      }
      // Navigator.popAndPushNamed(context, RoutesName.loginscreen);
    });
  }
}
