import 'package:flutter/material.dart';
import 'package:news_app_project/src/views/home/main_screen.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
      
      ),
      body: SafeArea(child: Text(routeName)),
    );
  }
}
