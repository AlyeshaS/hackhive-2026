import 'package:flutter/material.dart';
import 'suggestions/suggestions_screen.dart';
import 'deep_talk/deep_talk_screen.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    // Home Tab
    Center(
      child: Text(
        'Welcome Home! 👋',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    // Suggestions Tab
    SuggestionsScreen(),
    // Deep Talk Tab
    DeepTalkScreen(),
    // Settings Tab
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Suggestions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Deep Talk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
