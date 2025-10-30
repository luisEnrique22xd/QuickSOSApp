import 'package:flutter/material.dart';
import 'package:quicksosapp/components/alert_card.dart';
import 'package:quicksosapp/components/alert_filters.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filtro activo
  String activeFilter = "All";

  // Lista de alertas simuladas (aquí luego conectas con tu backend)
  final List<Map<String, dynamic>> allAlerts = [
    {
      "type": "Fire",
      "time": "10:30 a.m.",
      "address": "Av. Principal 123",
      "priority": "High",
      "priorityColor": Colors.redAccent,
      "icon": Icons.local_fire_department,
      "imageUrl": "",
    },
    {
      "type": "Robbery",
      "time": "01:00 p.m.",
      "address": "Av. Principal 123",
      "priority": "Low",
      "priorityColor": Colors.amberAccent,
      "icon": Icons.local_police,
      "imageUrl": "",
    },
    {
      "type": "Accident",
      "time": "03:30 p.m.",
      "address": "Av. Central 55",
      "priority": "Low",
      "priorityColor": Colors.yellow,
      "icon": Icons.warning,
      "imageUrl": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtrado dinámico de alertas según el filtro activo
    final filteredAlerts = activeFilter == "All"
        ? allAlerts
        : allAlerts.where((alert) => alert["type"] == activeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Alertas"),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar alertas...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                // En el futuro podrías aplicar búsqueda en el filtrado
              },
            ),
          ),

          // Filtros de tipo de alerta
          AlertFilterBar(
            activeFilter: activeFilter,
            onFilterSelected: (filter) {
              setState(() {
                activeFilter = filter;
              });
            },
          ),

          const SizedBox(height: 20),

          // Lista de alertas filtradas
          ...filteredAlerts.map((alert) {
            return AlertCard(
              type: alert["type"],
              time: alert["time"],
              address: alert["address"],
              priority: alert["priority"],
              imageUrl: alert["imageUrl"],
              priorityColor: alert["priorityColor"],
              icon: alert["icon"],
              onDetailsPressed: () {
                debugPrint("Ver detalles de ${alert['type']}");
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
