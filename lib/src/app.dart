import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_project/src/core/providers.dart';

import 'core/app_routes.dart';
import 'views/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //add app provider
    return AppProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        routes: routes,
        theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
        ),
        themeMode: ThemeMode.system,
        initialRoute: SplashScreen.routeName,
      ),
    );
  }
}
