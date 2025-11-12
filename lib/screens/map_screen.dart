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
  Map<String, dynamic>? selectedAlert; // Alerta seleccionada en el mapa
  bool showDetails = false; // Controla si se muestra el panel

  void _onAlertSelected(Map<String, dynamic> alert) {
    setState(() {
      selectedAlert = alert;
      showDetails = true;
    });
  }

  void _closeAlertDetails() {
    setState(() {
      showDetails = false;
    });
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                AlertFilterBar(
                  activeFilter: activeFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      activeFilter = filter;
                      showDetails = false; // Oculta el detalle al cambiar filtro
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Mapa con markers filtrados
                AlertMapCard(
                  initialCenter: LatLng(19.312968, -97.922873),
                  filterType: activeFilter, // <- filtrado dinámico
                  onAlertSelected: _onAlertSelected, // <- callback al tocar marcador
                ),

                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  "Estadísticas de Alertas",
                  style: TextStyle(
                    fontFamily: "samsungshapsans",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const StatsCard(
                  data1Value: 75,
                  data2Value: 25,
                  data1Label: "Alertas Activas",
                  data2Label: "Alertas Resueltas",
                ),
                const SizedBox(height: 80), // espacio inferior
              ],
            ),
          ),

          // Panel de detalles animado
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: showDetails ? 0 : -350,
            left: 0,
            right: 0,
            child: selectedAlert != null
                ? Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        const SizedBox(height: 4),
                        Text(
                          selectedAlert!['description'] ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            selectedAlert!['imageUrl'] ?? '',
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tipo: ${selectedAlert!['alertType'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Estado: ${selectedAlert!['status'] ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
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
