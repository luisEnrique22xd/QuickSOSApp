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

// Definir una instancia del ImagePicker
final ImagePicker _picker = ImagePicker();

// 🌟 Función para Abrir la Cámara y Tomar una Foto 🌟
Future<File?> takePictureFromCamera() async {
  try {
    // Llama al método para obtener la imagen de la CÁMARA
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024, // Opcional: limita el tamaño para rendimiento
      maxHeight: 1024,
      imageQuality: 80, // Opcional: calidad de compresión
    );

    if (photo != null) {
      // Retorna el archivo File de Dart
      return File(photo.path);
    } else {
      // El usuario canceló la operación
      return null;
    }
  } catch (e) {
    print('Error al acceder a la cámara: $e');
    return null;
  }
}

// 🌟 Función para Abrir la Galería (Ejemplo) 🌟
Future<File?> pickImageFromGallery() async {
  try {
    // Llama al método para obtener la imagen de la GALERÍA
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      return File(image.path);
    } else {
      return null;
    }
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
  File? _capturedImage;

void _capturePhoto() async {
  final result = await takePictureFromCamera();
  if (result != null) {
    setState(() {
      _capturedImage = result;
    });
    // Aquí puedes subir el archivo a Firebase Storage si es una alerta
  }
}
  final String username =
      FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';

Widget _buildProfileBody(Map<String, dynamic>? userData, String email) {
   final userNameFromDB = userData?['username'] ?? 'N/A';
    // final phoneNumber = userData?['phone'] ?? 'N/A';
    // final location = userData?['location'] ?? 'N/A';
    // final userGender = userData?['gender'] ?? 'N/A';
  return SingleChildScrollView(
        child: Column(
          children: [
            // ... (Tarjeta de perfil) ...
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                      Text('Hola, $userNameFromDB', style: TextStyle(fontFamily: 'samsungsharpsans', fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),),
                  
                    SizedBox(width: 20),
                    ElevatedButton(onPressed:()=> Navigator.pushReplacementNamed(context, '/alert'),style: ElevatedButton.styleFrom(fixedSize: const Size( 110,60)),child: Text("Crear una alerta", style: TextStyle(fontFamily: "samsungsharpsans", fontWeight: FontWeight.w500, fontSize:  12),))
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
      );
}
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado', style: TextStyle(color: Colors.white))),
      );
    }
    
    // 1. Obtener la referencia al documento del perfil
    // Usamos 'users' como la colección donde guardas el perfil
    final DocumentReference userDocRef = 
        FirebaseFirestore.instance.collection('users').doc(user.uid); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      // 🌟 CAMBIO NECESARIO 1: Envuelve el cuerpo en SingleChildScrollView 🌟
      // Esto permite el scroll y evita el desbordamiento de la pantalla principal.
      body:  StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            logger.e('Error cargando perfil: ${snapshot.error}');
            return const Center(child: Text('Error al cargar el perfil.', style: TextStyle(color: Colors.white)));
          }
          
          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          if (userData == null) {
            // Este caso ocurre si el documento existe pero está vacío o si no existe
            return Center(child: Text('Perfil no encontrado o vacío. UID: ${user.uid}', style: const TextStyle(color: Colors.white)));
          }
          
          // 3. Renderizar el cuerpo de la pantalla con los datos cargados
          return _buildProfileBody(userData, user.email ?? 'Email no disponible');
        },
      ),
    );
  }
}