import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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
                    child: 
                    Text("Name \n$username", style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),),
                  )),
              ],
             ),
          ),
          SizedBox(height: 20,),
          Row(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    const SizedBox(width: 8,), // Margen izquierdo

    // 1. CARD: INCENDIOS (FIRE)
    Expanded(
      child: Card(
        color: Colors.grey[800],
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              Row(
                children: <Widget>[
                 
                  Flexible(child: const Text('Incendios', style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              const SizedBox(height: 4),
             
              const Text(
                'Totales: 2',
                style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
               Image.asset(
                    'assets/images/fire.png', 
                    width: 24, // Ajustar el tamaño según sea necesario
                    height: 24,
                  ),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 8,),
    Expanded(
      child: Card(
        color: Colors.grey[800],
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
             
              Row(
                children: <Widget>[
                  Flexible(child: const Text('Robos', style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              const SizedBox(height: 4),
              // TEXTO de la cuenta
              const Text(
                'Totales: 3',
                style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Image.asset(
                    'assets/images/robbery.png',
                    width: 24,
                    height: 24,
                  ),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 8,),

    Expanded(
      child: Card(
        color: Colors.grey[800],
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              Row(
                children: <Widget>[
                  Flexible(child: const Text('Accidentes', style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              const SizedBox(height: 4),
              // TEXTO de la cuenta
              const Text(
                'Totales: 6',
                style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
                  Image.asset(
                    'assets/images/accident.png', 
                    width: 24,
                    height: 24,
                  ),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 8,), // Margen derecho
  ],
),
SizedBox(height: 20,),
Card(
  color: Colors.grey[800],
  elevation: 10,
  child: Padding(padding: const EdgeInsets.all(8.0),
  child: Column(
    children: [
      SizedBox(
        height: 300,
        width: double.infinity,
        child: OSMViewer(controller: SimpleMapController(initPosition: GeoPoint(latitude: 47.4358055, longitude: 48.4737324), markerHome: const MarkerIcon(icon: Icon(Icons.home)),)))
    ],
  ),
  ),
)
        ],
      ), 
    );
  }
}