import 'package:flutter/material.dart';
import 'package:quicksosapp/components/auth_guard.dart';
import 'package:quicksosapp/screens/alert_screen.dart';
import 'package:quicksosapp/screens/home_screen.dart';
import 'package:quicksosapp/screens/login_screen.dart';
import 'package:quicksosapp/screens/main_screen.dart';
import 'package:quicksosapp/screens/map_screen.dart';
import 'package:quicksosapp/screens/profile_screen.dart';
import 'package:quicksosapp/screens/sign_up.dart';
import 'package:quicksosapp/themes/theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Quick SOS App',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const LoginScreen(),
      routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const SignUpScreen(),
            '/home': (context) => const AuthGuard(child: HomeScreen()),
            '/alerts': (context) => const AuthGuard(child: AlertScreen()),
            '/map': (context) => const AuthGuard(child: MapScreen()),
            '/account': (context) => const AuthGuard(child: ProfileScreen()),
            '/main': (context) =>  MainScreen(),
            
          },
    );
  }}