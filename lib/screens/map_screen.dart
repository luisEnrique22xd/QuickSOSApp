import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quicksosapp/components/alert_filters.dart';
import 'package:quicksosapp/components/mapa.dart';
import 'package:quicksosapp/components/stats_card.dart';
import 'package:quicksosapp/components/alert_bar_chart.dart'; // 🌟 NUEVO IMPORT 🌟
import 'package:quicksosapp/screens/home_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String activeFilter = "All";
  Map<String, dynamic>? selectedAlert; // Alerta seleccionada en el mapa
  bool showDetails = false; // Controla si se muestra el panel

  void _onAlertSelected(Map<String, dynamic> alert) {
    // Si la alerta es vacía (tap en mapa), cerramos los detalles
    if (alert.isEmpty) {
      _closeAlertDetails();
    } else {
      setState(() {
        selectedAlert = alert;
        showDetails = true;
      });
    }
  }

  void _closeAlertDetails() {
    setState(() {
      selectedAlert = null;
      showDetails = false;
    });
  }

  Future<Map<String, dynamic>> getAlertsStats() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('alerts').get();

    int activeCount = 0;
    int resolvedCount = 0;

    Map<String, int> typesCount = {
        'Incendio': 0, // Inicializar para asegurar el orden
        'Robo': 0,
        'Accidente': 0,
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Contar activas y resueltas
      final status = data["status"] ?? "active";
      if (status == "active") activeCount++;
      if (status == "resolved") resolvedCount++;

      // Contar por tipo
      final type = data["alertType"] ?? "Desconocido";
      if (typesCount.containsKey(type)) {
        typesCount[type] = typesCount[type]! + 1;
      } else if (type != "Desconocido") {
        // Manejar tipos inesperados si es necesario, pero nos enfocamos en los 3 principales
        typesCount[type] = (typesCount[type] ?? 0) + 1;
      }
    }

    return {
      "active": activeCount,
      "resolved": resolvedCount,
      "types": typesCount,
    };
  }

  // 🌟 FUNCIÓN PARA OBTENER EL COLOR POR TIPO (para la gráfica)
  Color _getColorByType(String type) {
    switch (type) {
      case 'Incendio':
        return Colors.red;
      case 'Robo':
        return Colors.blue;
      case 'Accidente':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Alertas"),
      ),
      body: Stack(
        children: [
          // Contenido principal scrollable
          FutureBuilder(
            future: getAlertsStats(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!asyncSnapshot.hasData) {
                return const Text("No hay estadísticas disponibles");
              }

              final stats = asyncSnapshot.data!;
              final typeStats = stats["types"] as Map<String, int>;
              final int maxCount = typeStats.values.isNotEmpty 
                                   ? typeStats.values.reduce(math.max) // Obtener el valor máximo
                                   : 1;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alineación para los títulos
                  children: [
                    AlertFilterBar(
                      activeFilter: activeFilter,
                      onFilterSelected: (filter) {
                        setState(() {
                          activeFilter = filter;
                          showDetails = false;
                          selectedAlert = null; // Limpiar al cambiar filtro
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    AlertMapCard(
                      initialCenter: LatLng(19.312968, -97.922873),
                      filterType: activeFilter,
                      onAlertSelected: _onAlertSelected,
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),

                    // 📌 Tarjeta Activas vs Resueltas (Circular Progress Card)
                    const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text("Estado de las Alertas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                    ),
                    
                    StatsCard(
                      data1Value: (stats["active"] as int).toDouble(),
                      data2Value: (stats["resolved"] as int).toDouble(),
                      data1Label: "Activas",
                      data2Label: "Resueltas",
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12),

                    // 📊 GRÁFICA DE BARRAS POR TIPO
                    const Text(
                      "Alertas por Tipo de Incidente",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 📌 Contenedor de la Gráfica de Barras
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: typeStats.entries.map(
                              (entry) => AlertBarChart(
                                type: entry.key,
                                count: entry.value,
                                maxCount: maxCount, // Usamos el valor máximo para escalar
                                color: _getColorByType(entry.key),
                              ),
                            ).toList(),
                        )
                    ),
                    const SizedBox(height: 80), // Espacio inferior para el AnimatedPositioned
                  ],
                ),
              );
            },
          ),


          // Panel de detalles animado
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: showDetails ? 0 : -350,
            left: 0,
            right: 0,
            // Reutiliza la lógica de la card de información de alerta
            child: selectedAlert != null
                ? Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedAlert!['title'] ?? 'Sin título',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: _closeAlertDetails,
                            ),
                          ],
                        ),
                        // ... Resto de los detalles de la alerta ...
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}