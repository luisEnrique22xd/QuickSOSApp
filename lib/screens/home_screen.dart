import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String username =
        FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        title: Text('Inicio'),
      ),
      body: Column(
        children: [
          Center(
             child: Row(
              children: [
                Card(
                  color: Colors.grey[700],
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(username, style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 24, fontWeight: FontWeight.w600,color: Colors.white),),
                  )),
                
              ],
             ),
          ),
        ],
      ), 
    );
  }
}