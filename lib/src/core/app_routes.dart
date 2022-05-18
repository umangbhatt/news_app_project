import 'package:flutter/material.dart';
import 'package:news_app_project/src/views/home/main_screen.dart';
import 'package:news_app_project/src/views/splash_screen.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  MainScreen.routeName : (context) => MainScreen(),
};
