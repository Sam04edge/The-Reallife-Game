// lib/src/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:the_reallife_game/src/screens/quests_screen.dart'; // hier
import 'package:the_reallife_game/src/screens/profile_screen.dart';
import 'package:the_reallife_game/src/screens/settings_screen.dart';
import 'package:the_reallife_game/src/screens/inventar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const QuestsScreen(),
    const ProfileScreen(),
    const InventarScreen(), // neu
    const SettingsScreen(),
  ];
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Quests'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventar'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
  ];
  void _onNavTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
