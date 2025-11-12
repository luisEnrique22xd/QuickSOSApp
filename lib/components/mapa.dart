import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertMapCard extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final String filterType;
final Function(Map<String, dynamic>) onAlertSelected;


  const AlertMapCard({
    super.key,
    required this.initialCenter,
    this.initialZoom = 15.0,
    required this.filterType,
    required this.onAlertSelected,
  });

  @override
  State<AlertMapCard> createState() => _AlertMapCardState();
}

class _AlertMapCardState extends State<AlertMapCard> {
  LatLng? selectedPoint;
  Map<String, dynamic>? selectedAlert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: Colors.grey[850],
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('alerts')
                    .where('status', isEqualTo: 'active')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final alerts = snapshot.data!.docs;

                  return SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: widget.initialCenter,
                        initialZoom: widget.initialZoom,
                        onTap: (tapPosition, point) {
                          setState(() {
                            selectedPoint = null;
                            selectedAlert = null;
                          });
                        },
                      ),
                      children: [
                        // Capa base del mapa (OpenStreetMap)
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.yourcompany.yourappname',
                        ),

                        // Marcadores dinámicos
                        MarkerLayer(
                          markers: alerts.map((alertDoc) {
                            final data =
                                alertDoc.data() as Map<String, dynamic>;
                            final location = data['location'];
                            final LatLng point = LatLng(
                              (location['latitude'] as num).toDouble(),
                              (location['longitude'] as num).toDouble(),
                            );

                            Color markerColor;
                            switch (data['alertType']) {
                              case 'Incendio':
                                markerColor = Colors.redAccent;
                                break;
                              case 'Robo':
                                markerColor = Colors.blueAccent;
                                break;
                              case 'Accidente':
                                markerColor = Colors.amberAccent;
                                break;
                              default:
                                markerColor = Colors.grey;
                            }

                            return Marker(
                              width: 60,
                              height: 60,
                              point: point,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPoint = point;
                                    selectedAlert = data;
                                  });
                                },
                                child: Icon(
                                  Icons.location_pin,
                                  color: markerColor,
                                  size: 40,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Leyenda
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("🔴 Incendio",
                      style: TextStyle(fontFamily: 'samsungsharpssans')),
                  SizedBox(width: 8),
                  Text("🔵 Robo",
                      style: TextStyle(fontFamily: 'samsungsharpssans')),
                  SizedBox(width: 8),
                  Text("🟡 Accidente",
                      style: TextStyle(fontFamily: 'samsungsharpssans')),
                ],
              ),

              const SizedBox(height: 10),

              // Card con la información de la alerta seleccionada
              // Card con animación al aparecer/desaparecer
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: child,
  ),
  child: selectedAlert != null
      ? _buildAlertInfoCard(selectedAlert!)
      : const SizedBox.shrink(),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertInfoCard(Map<String, dynamic> alert) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Stack(
      children: [
        // --- Contenido principal ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alert['imageUrl'] != null && alert['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  alert['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'samsungsharpssans',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    alert['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'samsungsharpssans',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Tipo: ${alert['alertType']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontFamily: 'samsungsharpssans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // --- Botón de cerrar ---
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedAlert = null; // 🔥 Oculta la card
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
