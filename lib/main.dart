import 'package:flutter/material.dart';
import 'package:quicksosapp/components/notifiers.dart';
import 'package:quicksosapp/main_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';


void main() async {
  selectedTabIndex.value = 0;
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hilwgntzgnhqusinzwsr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbHdnbnR6Z25ocXVzaW56d3NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3OTI1ODksImV4cCI6MjA3ODM2ODU4OX0.-_5EHP45jmOeVTgQmiXLs95ga2NiicqbQJB_kKxv1cs',
    debug: true, // Útil para depuración
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MainApp());
  
}