import 'package:flutter/material.dart';
import 'package:news_app_project/src/view_models/headlines_view_model.dart';
import 'package:provider/provider.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>HeadlinesViewModel()),
      ],
      child: child,
    );
  }
}