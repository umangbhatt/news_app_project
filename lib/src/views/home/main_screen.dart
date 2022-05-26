import 'package:flutter/material.dart';
import 'package:news_app_project/src/views/home/search_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import 'explore_screen.dart';
import 'headlines_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Map<String, dynamic>> navItems = [
    {'index': 0, 'title': 'Headlines', 'icon': const Icon(Icons.newspaper)},
    {'index': 1, 'title': 'Explore', 'icon': const Icon(Icons.public)},
    {'index': 2, 'title': 'Settings', 'icon': const Icon(Icons.settings)},
  ];

  @override
  Widget build(BuildContext context) {
    return VxResponsive(
      small: _smallLayout(),
      xsmall: _smallLayout(),
      medium: _mediumLayout(),
      large: _largeLayout(),
      xlarge: _largeLayout(),
    );
  }

  Widget searchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        Navigator.of(context).push(PageRouteBuilder(transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          final Tween<Offset> offsetTween = Tween(begin: const Offset(0, 1), end: const Offset(0,0));
          return SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          );
        }, pageBuilder: (context, animation, secondaryAnimation) {
          return const SearchScreen();
        }));
      },
    );
  }

  Widget _smallLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(navItems[_currentIndex]['title']),
        centerTitle: true,
        elevation: 0,
        actions: [searchButton()],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) => setState(() {
                _currentIndex = value;
              }),
          currentIndex: _currentIndex,
          items: navItems
              .map((e) =>
                  BottomNavigationBarItem(icon: e['icon'], label: e['title']))
              .toList()),
      body: IndexedStack(
        index: _currentIndex,
        children: const <Widget>[
          HeadlinesScreen(),
          ExploreScreen(),
          
          SettingsScreen(),
        ],
      ),
    );
  }

  Widget _mediumLayout() {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: navItems
              .map((e) => ListTile(
                    onTap: () {
                      setState(() {
                        _currentIndex = e['index'];
                      });
                    },
                    leading: e['icon'],
                    title: Text(e['title']),
                    selected: e['index'] == _currentIndex,
                  ))
              .toList(),
        ),
      ),
      appBar: AppBar(
        title: Text(navItems[_currentIndex]['title']),
        centerTitle: true,
        elevation: 0,
        actions: [searchButton()],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const <Widget>[
          HeadlinesScreen(),
          ExploreScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }

  bool showDrawer = true;

  Widget _largeLayout() {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: showDrawer ? 300 : 0,
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 300,
                child: Column(
                  children: navItems
                      .map((e) => ListTile(
                            onTap: () {
                              setState(() {
                                _currentIndex = e['index'];
                              });
                            },
                            leading: e['icon'],
                            title: Text(e['title']),
                            selected: e['index'] == _currentIndex,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                actions: [searchButton()],
                leading: IconButton(
                    onPressed: () {
                      setState(() {
                        showDrawer = !showDrawer;
                      });
                    },
                    icon: const Icon(Icons.menu)),
                title: Text(navItems[_currentIndex]['title']),
                centerTitle: true,
                elevation: 0,
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: const <Widget>[
                  HeadlinesScreen(),
                  ExploreScreen(),
                  
                  SettingsScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
