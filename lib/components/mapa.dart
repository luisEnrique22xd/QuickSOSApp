import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AlertMapCard extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final Function(LatLng)? onMapTap;

  const AlertMapCard({
    super.key,
    required this.initialCenter,
    this.initialZoom = 15.0,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: Colors.grey[800],
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: initialZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (tapPosition, point) {
                      if (onMapTap != null) {
                        onMapTap!(point);
                      }
                    },
                  ),
                  children: [
                    // Capa base del mapa (OpenStreetMap)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yourcompany.yourappname',
                    ),
                    // Ejemplo: marcador inicial
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: initialCenter,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.redAccent,
                            size: 35.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Text(
                    "🔴 Incendio",
                    style: TextStyle(fontFamily: 'samsungsharpssans'),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "🔵 Robo",
                    style: TextStyle(fontFamily: 'samsungsharpssans'),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "🟡 Accidente",
                    style: TextStyle(fontFamily: 'samsungsharpssans'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
