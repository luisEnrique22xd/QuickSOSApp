import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quicksosapp/components/alert_filters.dart';
import 'package:quicksosapp/components/mapa.dart';
import 'package:quicksosapp/components/stats_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String activeFilter = "All";
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:Text("Mapa de Alertas"),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              AlertFilterBar(
            activeFilter: activeFilter,
            onFilterSelected: (filter) {
              setState(() {
                activeFilter = filter;
              });
            },
          ),
  SizedBox(height: 20),
              AlertMapCard(initialCenter: LatLng(19.312968, -97.922873), onMapTap: (point) {
    print("Coordenadas seleccionadas: ${point.latitude}, ${point.longitude}");
  },),
  SizedBox(height: 20),
  Divider(),
  Text("Estadisticas de Alertas", style: TextStyle(fontFamily: "samsungshapsans",fontSize: 18, fontWeight: FontWeight.bold),),
  StatsCard(data1Value:  75, data2Value: 25, data1Label: "Alertas Activas", data2Label: "Alertas Resueltas",),
            ],
            ),
        )
    );
  }
}