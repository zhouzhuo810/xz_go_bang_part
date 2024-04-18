import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  //全局context
  static BuildContext globalContext =
      navigatorKey.currentState!.overlay!.context;

  // 全局 SharedPreferences
  static SharedPreferences? prefs;

  // 初始化SharedPreferences，需要在main.dart中初始化
  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

}