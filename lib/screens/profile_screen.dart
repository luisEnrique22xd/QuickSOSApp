import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quicksosapp/components/local_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 Importación de Firestore 🌟


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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  bool _notificationsEnabled = false;
  File? _imageFile;
  
  @override
  void initState() {
    super.initState();
    _loadSavedImage();
    _checkNotificationStatus();
    
  }
  Key _imageAvatarKey =
      UniqueKey();

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && await File(path).exists()) {
      setState(() {
        _imageFile = File(path);
        _imageAvatarKey = ValueKey(
          path + DateTime.now().toIso8601String(),
        ); 
      });
    }
  }
  Future<void> _checkNotificationStatus() async {
    final status = await Permission.notification.status;

    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    setState(() {
      _notificationsEnabled = status.isGranted || settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  void _toggleNotifications(bool newValue) async {
    if (newValue) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() {
          _notificationsEnabled = true;
        });
      } else if (status.isDenied || status.isPermanentlyDenied) {
        await openAppSettings();
        _checkNotificationStatus(); 
      }
    } else {
      await openAppSettings();
      _checkNotificationStatus(); 
    }
  }

  Future<void> _pickAndSaveImageLocally() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    File originalImage = File(pickedFile.path);

    img.Image? imageToResize = img.decodeImage(originalImage.readAsBytesSync());

    if (imageToResize == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo decodificar la imagen.")),
        );
      }
      logger.e('Error al decodificar la imagen seleccionada.');
      return;
    }

    img.Image resizedImage = img.copyResize(
      imageToResize,
      width: imageToResize.width > imageToResize.height ? 500 : null,
      height: imageToResize.height >= imageToResize.width ? 500 : null,
      interpolation: img.Interpolation.average,
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_image.jpg';
    final localPath = '${directory.path}/$fileName';

    final savedImage = await File(
      localPath,
    ).writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImage.path);

    setState(() {
      _imageFile = savedImage;
      _imageAvatarKey = ValueKey(
        savedImage.path + DateTime.now().toIso8601String(),
      ); 
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
    }
    logger.i('Imagen de perfil guardada y redimensionada localmente.');
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
  
  // Widget auxiliar para construir el cuerpo de la pantalla después de cargar los datos
  Widget _buildProfileBody(Map<String, dynamic>? userData, String email) {
    // 🌟 2. Extraer datos de Firestore, usando el operador ?? para un fallback 🌟
    final userNameFromDB = userData?['username'] ?? 'N/A';
    final phoneNumber = userData?['phone'] ?? 'N/A';
    final location = userData?['location'] ?? 'N/A';
    final userGender = userData?['gender'] ?? 'N/A';
    
    IconData iconData;
    if (userGender == 'Male') {
      iconData = Icons.male_rounded;
    } else if (userGender == 'Female') {
      iconData = Icons.female_rounded;
    } else if (userGender == 'Transgender') {
      iconData = Icons.transgender_sharp;
    } else {
      iconData = Icons.person;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // FOTO DE PERFIL
        Center(
          child: GestureDetector(
            onTap: _pickAndSaveImageLocally,
            child: CircleAvatar(
              key: _imageAvatarKey, 
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Hi, $userNameFromDB', // Usamos el nombre de usuario de la DB
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        const Divider(height: 32),
        
        // 🌟 DATOS DE PERFIL (Desde Firestore) 🌟
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.white),
          title: Text(
            'User Name: \n $userNameFromDB', // Usamos el nombre de usuario
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.mail, color: Colors.white),
          title: Text(
            'Email: \n$email', // Usamos el email de Auth
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.phone, color: Colors.white),
          title: Text(
            'Telefono: \n$phoneNumber', // Usamos el teléfono de la DB
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Colors.white),
          title: Text(
            'Ubicacion: \n$location', // Usamos la ubicación de la DB
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ListTile(
          leading: Icon(iconData, color: Colors.white),
          title: Text(
            'Genero: \n$userGender', // Usamos el género de la DB
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const Divider(height: 32,),
        
        // GESTIÓN DE NOTIFICACIONES
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.white),
          title: const Text(
            'Notificaciones',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Switch(
            value: _notificationsEnabled, 
            onChanged: _toggleNotifications, 
            activeColor: Colors.blue[600], 
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[700],
          ),
        ),
        
        // IDIOMA
        ListTile(
          leading: const Icon(Icons.language, color: Colors.white),
          title: const Text(
            'Idioma',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            Localizations.localeOf(context).languageCode == 'es'
                ? 'Español'
                : 'English',
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () {
            final provider = Provider.of<LocaleProvider>(context, listen: false);
            final currentLocale = Localizations.localeOf(context);

            if (currentLocale.languageCode == 'en') {
              provider.setLocale(const Locale('es'));
            } else {
              provider.setLocale(const Locale('en'));
            }
          },
        ),
        // CERRAR SESIÓN
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
          onTap: _logout,
        ),
      ],
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
    
    // 🌟 2. Usar StreamBuilder para escuchar el documento 🌟
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
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