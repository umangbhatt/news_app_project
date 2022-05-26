
import 'package:flutter/material.dart';
import 'package:news_app_project/src/models/enums/news_category.dart';
import 'package:news_app_project/src/view_models/theme_view_model.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Consumer<ThemeViewModel>(builder: (context, viewModel, child) {
            return ListView(
              children: [
                ListTile(
                  title: Text(viewModel.themeMode.name.capitalizeFirstLetter()),
                  subtitle: const Text('App Theme'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Select App Theme'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('System Theme'),
                                  selected:
                                      viewModel.themeMode == ThemeMode.system,
                                  onTap: () {
                                    viewModel.setThemeMode(ThemeMode.system);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: const Text('Light Theme'),
                                  selected:
                                      viewModel.themeMode == ThemeMode.light,
                                  onTap: () {
                                    viewModel.setThemeMode(ThemeMode.light);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: const Text('Dark Theme'),
                                  selected:
                                      viewModel.themeMode == ThemeMode.dark,
                                  onTap: () {
                                    viewModel.setThemeMode(ThemeMode.dark);
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          );
                        });
                  },
                ),
                // ListTile(
                //   title: Text('Summary Voice'),
                //   onTap: () async{
                //     FlutterTts _flutterTts = FlutterTts();
                //     var voices = await _flutterTts.getVoices;
                //     log('voices $voices');
                //   },
                // )
              ],
            );
          }),
        ),
      ),
    );
  }
}
