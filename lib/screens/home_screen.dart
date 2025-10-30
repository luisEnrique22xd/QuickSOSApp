import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import 'package:quicksosapp/components/mapa.dart';
import 'package:quicksosapp/components/navbar.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      // 🌟 CAMBIO NECESARIO 1: Envuelve el cuerpo en SingleChildScrollView 🌟
      // Esto permite el scroll y evita el desbordamiento de la pantalla principal.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... (Tarjeta de perfil) ...
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
            
            const SizedBox(height: 20),

            // ... (Fila de tarjetas de alerta) ...
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 8,), 
                // 1. CARD: INCENDIOS 
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
                            width: 24, 
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8,),
                // 2. CARD: ROBOS
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

                // 3. CARD: ACCIDENTES
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

                const SizedBox(width: 8,), 
              ],
            ),
            
            const SizedBox(height: 20),
            
            // ... (Tarjeta del mapa) ...
           AlertMapCard(initialCenter: LatLng(19.312968, -97.922873), onMapTap: (point) {
    print("Coordenadas seleccionadas: ${point.latitude}, ${point.longitude}");
  },),
            const SizedBox(height: 8), // Margen inferior para el scroll
           
          ],
        ),
      ), 
    );
  }
}