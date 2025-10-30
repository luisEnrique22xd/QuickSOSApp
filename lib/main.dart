import 'package:flutter/material.dart';
import 'package:quicksosapp/components/notifiers.dart';
import 'package:quicksosapp/main_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  selectedTabIndex.value = 0;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MainApp());
  
}