import 'package:flutter/material.dart';
import 'package:news_app_project/src/view_models/explore_view_model.dart';
import 'package:news_app_project/src/view_models/headlines_view_model.dart';
import 'package:news_app_project/src/view_models/news_summary_view_model.dart';
import 'package:news_app_project/src/view_models/search_view_model.dart';
import 'package:news_app_project/src/view_models/theme_view_model.dart';
import 'package:provider/provider.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>HeadlinesViewModel()),
        ChangeNotifierProvider(create: (_)=>ExploreViewModel()),
        ChangeNotifierProvider(create: (_)=>SearchViewModel()),
        ChangeNotifierProvider(create: (_)=>ThemeViewModel()),
        ChangeNotifierProvider(create: (_)=>NewsSummaryViewModel()),
      ],
      child: child,
    );
  }
}