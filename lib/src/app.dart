import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_project/src/core/providers.dart';
import 'package:news_app_project/src/view_models/theme_view_model.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'views/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //add app provider
    return AppProvider(
      child: Consumer<ThemeViewModel>(
        builder: ((context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'News App',
            routes: routes,
            theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
            darkTheme: ThemeData.dark().copyWith(
              textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: value.themeMode,
            initialRoute: SplashScreen.routeName,
          );
        }),
      ),
    );
  }
}
