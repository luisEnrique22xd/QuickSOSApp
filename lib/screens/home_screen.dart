import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:quicksosapp/components/mapa.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
  filter: DevelopmentFilter(),
);

final ImagePicker _picker = ImagePicker();
String activeFilter = "All";

Future<File?> takePictureFromCamera() async {
  try {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    return photo != null ? File(photo.path) : null;
  } catch (e) {
    print('Error al acceder a la cámara: $e');
    return null;
  }
}

Future<File?> pickImageFromGallery() async {
  try {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  } catch (e) {
    print('Error al acceder a la galería: $e');
    return null;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeFilter = "All";
  Map<String, dynamic>? selectedAlert; // Alerta seleccionada en el mapa
  bool showDetails = false; // Controla si se muestra el panel
  File? _capturedImage;

  void _capturePhoto() async {
    final result = await takePictureFromCamera();
    if (result != null) {
      setState(() {
        _capturedImage = result;
      });
    }
  }
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

  final String username =
      FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';

  // 🔥 --- Contadores dinámicos de alertas ---
  Widget _buildAlertStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay alertas registradas',
              style: TextStyle(color: Colors.white, fontFamily: 'samsungsharpsans'),
            ),
          );
        }

        final alerts = snapshot.data!.docs;
        Map<String, int> counts = {
          'Incendio': 0,
          'Robo': 0,
          'Accidente': 0,
        };

        for (var doc in alerts) {
          final data = doc.data() as Map<String, dynamic>;
          final type = data['alertType'] ?? '';
          if (counts.containsKey(type)) {
            counts[type] = counts[type]! + 1;
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAlertCard(
                title: 'Incendios',
                total: counts['Incendio'] ?? 0,
                imagePath: 'assets/images/fire.png',
              ),
              const SizedBox(width: 8),
              _buildAlertCard(
                title: 'Robos',
                total: counts['Robo'] ?? 0,
                imagePath: 'assets/images/robbery.png',
              ),
              const SizedBox(width: 8),
              _buildAlertCard(
                title: 'Accidentes',
                total: counts['Accidente'] ?? 0,
                imagePath: 'assets/images/accident.png',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertCard({
    required String title,
    required int total,
    required String imagePath,
  }) {
    return SizedBox(
      width: 140,
      child: Card(
        color: Colors.grey[800],
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'samsungsharpsans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Totales: $total',
                style: const TextStyle(
                  fontFamily: 'samsungsharpsans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Image.asset(imagePath, width: 28, height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBody(Map<String, dynamic>? userData, String email) {
    final userNameFromDB = userData?['username'] ?? 'N/A';

    return Stack(
      children:[ SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Hola, $userNameFromDB',
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/alert'),
                    style: ElevatedButton.styleFrom(fixedSize: const Size(110, 60)),
                    child: const Text(
                      "Crear una alerta",
                      style: TextStyle(
                        fontFamily: "samsungsharpsans",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildAlertStats(), // 🔥 Contadores dinámicos
            const SizedBox(height: 20),
            AlertMapCard(
              initialCenter: LatLng(19.312968, -97.922873),
               filterType: activeFilter, // <- filtrado dinámico
              onAlertSelected: _onAlertSelected,
            ),
            // Panel de detalles animado
            
            const SizedBox(height: 8),
          ],
        ),
      ),
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
          ),]
    );
  }

  @override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Error: Usuario no autenticado',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

  return Scaffold(
    appBar: AppBar(title: const Text('Inicio')),
    body: Stack(
      children: [
        // --- CONTENIDO PRINCIPAL SCROLLEABLE ---
        StreamBuilder<DocumentSnapshot>(
          stream: userDocRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              logger.e('Error cargando perfil: ${snapshot.error}');
              return const Center(
                child: Text('Error al cargar el perfil.',
                  style: TextStyle(color: Colors.white)),
              );
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            if (userData == null) {
              return Center(
                child: Text(
                  'Perfil no encontrado o vacío. UID: ${user.uid}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // --- SALUDO Y BOTÓN ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Hola, ${userData['username'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontFamily: 'samsungsharpsans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/alert'),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(110, 60)),
                        child: const Text(
                          "Crear una alerta",
                          style: TextStyle(
                            fontFamily: "samsungsharpsans",
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- TARJETAS DE ESTADISTICAS ---
                  _buildAlertStats(),

                  const SizedBox(height: 20),

                  // --- MAPA ---
                  AlertMapCard(
                    initialCenter: LatLng(19.312968, -97.922873),
                    filterType: activeFilter,
                    onAlertSelected: _onAlertSelected,
                  ),

                  const SizedBox(height: 200), // espacio extra para panel flotante
                ],
              ),
            );
          },
        ),

        // --- PANEL DE DETALLES FLOTANTE ---
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
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Estado: ${selectedAlert!['status'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
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
