import 'package:flutter/material.dart';
import 'package:quicksosapp/components/navbar.dart';
import 'package:quicksosapp/components/notifiers.dart';
import 'package:quicksosapp/screens/alert_screen.dart';
import 'package:quicksosapp/screens/home_screen.dart';
import 'package:quicksosapp/screens/map_screen.dart';
import 'package:quicksosapp/screens/profile_screen.dart';

class MainScreen extends StatelessWidget {
    MainScreen({super.key});
  
  final List<Widget> _pages = const [
    HomeScreen(),
    AlertScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
     return ValueListenableBuilder<int>(
      valueListenable: selectedTabIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => selectedTabIndex.value = index,
          ),
        );
      },
     );
  }
}