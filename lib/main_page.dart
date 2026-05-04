import 'package:flutter/material.dart';
import 'tabs/home_page.dart';
import 'tabs/connect/connect_screen.dart';
import 'tabs/play/play_screen.dart';
import 'tabs/memories/memories_screen.dart';
import 'tabs/character/character_screen.dart';
import 'tabs/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ConnectScreen(),
    const PlayScreen(),
    const MemoriesScreen(),
    const CharacterScreen(),
    const SettingsPage(),
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
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Connect'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Play',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Memories'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Character'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
