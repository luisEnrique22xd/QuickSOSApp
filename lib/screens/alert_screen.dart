import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quicksosapp/components/alert_card.dart';
import 'package:quicksosapp/components/alert_filters.dart';
import 'package:quicksosapp/screens/details_screen.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final TextEditingController _searchController = TextEditingController();
  String activeFilter = "All";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Alertas"),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 12,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar alertas...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 🧭 Filtros
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: AlertFilterBar(
              activeFilter: activeFilter,
              onFilterSelected: (filter) {
                setState(() {
                  activeFilter = filter;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📡 Lista dinámica
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alerts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay alertas disponibles.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final alerts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return {
                    "id": doc.id,
                    "uid": data["uid"] ?? "",
                    "type": data['alertType'] ?? 'Desconocido',
                    "time": _formatDate(data['createdAt']),
                    "address": data['description'] ?? 'Sin dirección',
                    "priority": data['status'] ?? 'Normal',
                    "priorityColor": _getPriorityColor(data['status']),
                    "icon": _getAlertIcon(data['alertType']),
                    "imageUrl": data['imageUrl'] ?? '',
                  };
                }).toList();

                // 🔍 Filtro y búsqueda
                final filteredAlerts = alerts.where((alert) {
                  final matchesFilter =
                      activeFilter == "All" ||
                      alert["type"].toString().toLowerCase().contains(
                        activeFilter.toLowerCase(),
                      );

                  final matchesSearch = alert["address"]
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());

                  return matchesFilter && matchesSearch;
                }).toList();

                // ✅ ListView sin overflow
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final safeWidth =
                        constraints.maxWidth; // 🔒 ancho exacto del layout

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      itemCount: filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = filteredAlerts[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Align(
                            alignment: Alignment
                                .center, // 📏 centra y recorta automáticamente
                            child: SizedBox(
                              width:
                                  safeWidth - 16, // 🧩 evita el overflow exacto
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // evita sombras fuera del frame
                                child: AlertCard(
                                  type: alert["type"],
                                  time: alert["time"],
                                  description: alert["address"],
                                  priority: alert["priority"],
                                  imageUrl: alert["imageUrl"],
                                  priorityColor: alert["priorityColor"],
                                  icon: alert["icon"],
                                  onDetailsPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(
                                          alertId:
                                              snapshot.data!.docs[index].id,
                                          alert: {
                                            "id": snapshot.data!.docs[index].id,
                                            "type": alert["type"],
                                            "time": alert["time"],
                                            "description": alert["address"],
                                            "priority": alert["priority"],
                                            "priorityColor":
                                                alert["priorityColor"],
                                            "imageUrl": alert["imageUrl"],
                                            "creatorId": alert["uid"] ?? "",
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Formatear fecha legible
  static String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')} • ${date.day}/${date.month}/${date.year}";
  }

  // 🔥 Íconos por tipo
  static IconData _getAlertIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'incendio':
      case 'fire':
        return Icons.local_fire_department;
      case 'robo':
      case 'robbery':
        return Icons.local_police;
      case 'accidente':
      case 'accident':
        return Icons.warning;
      default:
        return Icons.error_outline;
    }
  }

  // 🚨 Color según prioridad
  static Color _getPriorityColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.redAccent;
      case 'resolved':
        return Colors.greenAccent;
      default:
        return Colors.amberAccent;
    }
  }
}
