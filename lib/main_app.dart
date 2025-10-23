import 'package:flutter/material.dart';
import 'package:quicksosapp/screens/login_screen.dart';
import 'package:quicksosapp/screens/main_screen.dart';
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
            // '/home': (context) => const AuthGuard(child: HomeScreen()),
            // '/charts': (context) => const AuthGuard(child: ChartsScreen()),
            // '/account': (context) => const AuthGuard(child: AccountScreen()),
            '/main': (context) =>  MainScreen(),
            // '/recommendations': (context) => const RecommendationsScreen(),
          },
    );
  }}