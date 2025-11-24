import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String SUPABASE_URL = 'https://hilwgntzgnhqusinzwsr.supabase.co'; 
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbHdnbnR6Z25ocXVzaW56d3NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3OTI1ODksImV4cCI6MjA3ODM2ODU4OX0.-_5EHP45jmOeVTgQmiXLs95ga2NiicqbQJB_kKxv1cs';
const String SUPABASE_BUCKET_NAME = 'alertsImages';

final List<String> _alertOptions = [
  'Incendio',
  'Robo',
  'Accidente',
];

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

class CreateAlert extends StatefulWidget {
  const CreateAlert({super.key}); // Corregido: añadido const

  @override
  State<CreateAlert> createState() => _CreateAlertState();
}

class _CreateAlertState extends State<CreateAlert> {
final _descriptionController = TextEditingController();
final _titleAlertController = TextEditingController();

String? _selectedAlert;
File? _capturedImage;
  // 🌟 VARIABLES DE ESTADO NECESARIAS 🌟
  // ⬅️ CAMBIO CLAVE 1: Iniciar en FALSE para que muestre el botón de "Obtener Ubicación"
bool _isLoadingLocation = false; 
LatLng? _currentPosition; // Usa LatLng de latlong2
String? _locationError; 
bool _isSending = false;
late final SupabaseClient _supabase;
final user = FirebaseAuth.instance.currentUser;
  
 @override
  void initState() {
    super.initState();
    // Inicializar Supabase
    _supabase = SupabaseClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
            _isLoadingLocation = false;
        });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleAlertController.dispose();
    super.dispose();
  } 

void _capturePhoto() async {
  final result = await takePictureFromCamera();
  if (result != null) {
    setState(() {
      _capturedImage = result;
    });
    // Aquí puedes subir el archivo a Firebase Storage si es una alerta
  }
}

// 🔴 FUNCIÓN AUXILIAR: SUBIR IMAGEN A SUPABASE 🔴
  Future<String?> _uploadImageToSupabase(String userId) async {
    if (_capturedImage == null) return null;

    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}${(_capturedImage!.path)}';
    final filePath = 'alerts/$fileName'; 

    try {
      // 1. Subir la imagen al bucket
      await _supabase.storage
          .from(SUPABASE_BUCKET_NAME)
          .upload(
            filePath, 
            _capturedImage!,
            fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
                contentType: 'image/jpeg',
            ),
          );

      // 2. Obtener la URL pública para guardar en Firestore
      final imageUrl = _supabase.storage.from(SUPABASE_BUCKET_NAME).getPublicUrl(filePath);
      return imageUrl;

    } on StorageException catch (e) {
      print('Error de Storage en Supabase: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: ${e.message}')),
        );
      }
      return null;
    } catch (e) {
      print('Error desconocido al subir imagen: $e');
      return null;
    }
  }

// 🌟 FUNCIÓN DE ENVÍO FINAL (Añadida la llamada a _sendAlert) 🌟
void _sendAlert() async {
  // 0. OBTENER USUARIO AUTENTICADO (CRÍTICO)
  if (_isSending) return;
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    // Manejar el caso de no autenticado (opcional, pero buena práctica)
    print("Usuario no autenticado al intentar enviar alerta.");
    return;
  }

  // 1. Cláusula de Guardia: TÍTULO
  if (_titleAlertController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Por favor, proporciona un título a la alerta.',style: TextStyle(fontFamily: "samsungsharpsans", fontSize: 12, fontWeight: FontWeight.bold),),backgroundColor: Colors.red[400],),
      );
      return;
  }
  
  // 2. Cláusula de Guardia: DESCRIPCIÓN
  if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Por favor, proporciona una descripcion a la alerta.',style: TextStyle(fontFamily: "samsungsharpsans", fontSize: 12, fontWeight: FontWeight.bold),),backgroundColor: Colors.red[400],),
      );
      return;
  }
  
  // 3. Cláusula de Guardia: TIPO DE ALERTA
  if (_selectedAlert == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un tipo de alerta.',style: TextStyle(fontFamily: "samsungsharpsans", fontSize: 12, fontWeight: FontWeight.bold),),backgroundColor: Colors.red[400],),
    );
    return;
  }
  
  // 4. Cláusula de Guardia: UBICACIÓN
  if (_currentPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Esperando ubicación GPS...',style: TextStyle(fontFamily: "samsungsharpsans", fontSize: 12, fontWeight: FontWeight.bold),),backgroundColor: Colors.red[400],),
    );
    return;
  }
 
  setState(() { _isSending = true; });

    String? imageUrl;
    
    try {
      // 1. Lógica de Subida
      if (_capturedImage != null) {
        imageUrl = await _uploadImageToSupabase(user.uid);
        if (imageUrl == null) {
           if (mounted) setState(() { _isSending = false; });
           return; // Falló la subida de imagen, detenemos el proceso
        }
      }

      // 2. Guardar los metadatos en Firestore
      await FirebaseFirestore.instance.collection('alerts').doc().set({ 
        'uid': user.uid, 
        'title': _titleAlertController.text.trim(),
        'description': _descriptionController.text.trim(), 
        'alertType': _selectedAlert,
        'location': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        'imageUrl': imageUrl, // ⬅️ URL de Supabase guardada aquí
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active', 
      });

      // 3. Limpiar y Navegar
      _titleAlertController.clear();
      _descriptionController.clear();
      setState(() {
        
        _capturedImage = null; 
      });

    // 🌟 MOSTRAR ÉXITO ANTES DE NAVEGAR 🌟
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Alerta de $_selectedAlert enviada con éxito!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
    );

    // Navegar después de la confirmación y el guardado
    if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
    }
  } catch (e) {
    // Manejar error de conexión o escritura en Firestore
    print('Error al guardar la alerta en Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar alerta: $e', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
        ),
    );
  }
}

/// 🌟 FUNCIÓN DE UBICACIÓN (Implementación completa) 🌟
  void _getLocation() async {
    // Si ya estamos cargando, salir.
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    // 1. Verificar si los servicios están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _isLoadingLocation = false; _locationError = 'GPS apagado.'; });
      return;
    }

    // 2. Verificar y solicitar Permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _isLoadingLocation = false; _locationError = 'Permiso denegado.'; });
      return;
    }
    
    // 3. Obtener Posición
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Error de conexión GPS.';
        });
      }
      print("Geolocator Error: $e");
    }
  }
  
  
  // 🌟 WIDGET PARA DETERMINAR EL ESTADO DEL BOTÓN 🌟
  Map<String, dynamic> _getButtonState() {
    if (_isLoadingLocation) {
      return {
        'text': 'Obteniendo Ubicación...',
        'color': Colors.blueGrey,
        'enabled': false,
      };
    } else if (_locationError != null) {
      return {
        'text': 'ERROR: $_locationError (Reintentar)',
        'color': Colors.red[800],
        'enabled': true, 
      };
    } else if (_currentPosition != null) {
      return {
        // Muestra la ubicación obtenida
        'text': 'Localizado: Lat ${_currentPosition!.latitude.toStringAsFixed(4)}',
        'color': Colors.green[700],
        // Permitimos reintentar si el usuario quiere una lectura más reciente
        'enabled': true, 
      };
    } else {
      // Estado predeterminado cuando no hay ubicación y no está cargando
      return {
        'text': 'Obtener Ubicación',
        'color': Colors.blue[600],
        'enabled': true,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonState = _getButtonState();
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Alerta"),
      actions: [IconButton(icon:const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),onPressed: () => {
        // CORREGIDO: Usar pushNamedAndRemoveUntil para navegar
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false)
      },), ],
      
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              
              // --- TITULO DE ALERTA ---
              _buildTextField(_titleAlertController, "Titulo de alerta"),
              const SizedBox(height: 10.0),
              
              // --- DESCRIPCIÓN ---
              _buildTextField(_descriptionController, "Descripcion"),
              const SizedBox(height: 10.0),
              
              // --- TIPO DE ALERTA (DROPDOWN) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedAlert,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "samsungsharpsans",
                    fontWeight: FontWeight.w800,
                  ),
                  hint: const Text(
                    "Tipo de alerta",
                    style: TextStyle(
                      fontFamily: "samsungsharpsans",
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAlert = newValue;
                    });
                  },
                  items: _alertOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: "samsungsharpsans",
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              
              
              // --- BOTÓN TOMAR FOTO ---
              ElevatedButton(
                onPressed: _capturePhoto, 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(50, 50),
                ),
                child: const Text("Tomar foto"),
              ),
              
              const SizedBox(height: 20,),
              
              // --- VISTA PREVIA DE IMAGEN ---
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _capturedImage != null
                    ? Image.file(_capturedImage!, fit: BoxFit.cover)
                    : const Center(child: Text("No hay imagen capturada"),),
              ),
              
              const SizedBox(height: 20,),
              
              // --- BOTONES DE ACCIÓN (UBICACIÓN Y ENVIAR) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding para la Row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    // 1. BOTÓN UBICACIÓN (Expanded)
                    Expanded(
                      child: ElevatedButton(
                        // ⬅️ onTAp: Llama a la función _getLocation solo si está habilitado
                        onPressed: buttonState['enabled'] ? _getLocation : null, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonState['color'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          buttonState['text'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Texto más pequeño para que quepa
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 10), // Espacio entre botones

                    // 2. BOTÓN ENVIAR (Expanded)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendAlert, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                         child: const Text("Enviar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  // Función auxiliar para construir TextFields repetitivos
  Widget _buildTextField(TextEditingController controller, String hint) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextFormField(
        controller: controller,
        obscureText: false,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "samsungsharpsans",
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}