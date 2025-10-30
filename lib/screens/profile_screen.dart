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
import 'package:firebase_messaging/firebase_messaging.dart'; // Para Notificaciones


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
  final String userGender = "Male";
  bool _notificationsEnabled = false;
  File? _imageFile;
  // <--- NUEVO: Añade una Key para forzar la reconstrucción de la imagen --->
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
        // <--- NUEVO: Actualiza la key también al cargar la imagen inicial --->
        _imageAvatarKey = ValueKey(
          path + DateTime.now().toIso8601String(),
        ); // Usa path + timestamp para asegurar unicidad
      });
    }
  }
  Future<void> _checkNotificationStatus() async {
    final status = await Permission.notification.status;

    // Firebase Messaging también proporciona información de estado
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    setState(() {
      // Si el estado es concedido (o autorizado por FCM), el switch debe estar encendido
      _notificationsEnabled = status.isGranted || settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  // 3. Lógica para manejar el cambio de switch
  void _toggleNotifications(bool newValue) async {
    if (newValue) {
      // Si el usuario quiere activarlas, las solicitamos
      final status = await Permission.notification.request();
      if (status.isGranted) {
        // Si se concedió el permiso
        setState(() {
          _notificationsEnabled = true;
        });
        // Opcional: Manejar la suscripción a temas de FCM aquí
      } else if (status.isDenied || status.isPermanentlyDenied) {
        // Si el usuario denegó o denegó permanentemente, lo llevamos a la configuración
        await openAppSettings();
        // Después de que el usuario regrese de la configuración, comprobamos de nuevo
        _checkNotificationStatus(); 
      }
    } else {
      // Si el usuario quiere desactivarlas, lo llevamos a la configuración para que las apague
      await openAppSettings();
      _checkNotificationStatus(); // Comprobamos el estado al regresar
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

    // Guardamos la imagen redimensionada, sobrescribiendo la anterior
    final savedImage = await File(
      localPath,
    ).writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImage.path);

    setState(() {
      _imageFile = savedImage;
      // <--- CLAVE: Actualiza la key cada vez que la imagen es guardada --->
      _imageAvatarKey = ValueKey(
        savedImage.path + DateTime.now().toIso8601String(),
      ); // Nueva key basada en path y timestamp
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
  @override
  Widget build(BuildContext context) {
    IconData iconData;

    if (userGender == 'Male') {
      iconData = Icons.male_rounded;
    } else if (userGender == 'Female') {
      iconData = Icons.female_rounded;
    } else if (userGender == 'Transgender') {
      iconData = Icons.transgender_sharp;
    } else {
      iconData = Icons.person; // Default or unknown gender icon
    }

    final String username =
        FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';
    return  Scaffold(
      appBar: AppBar(
        // title:  Text(AppLocalizations.of(context)!.account,),
        title: const Text("Perfil"),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickAndSaveImageLocally,
              child: CircleAvatar(
                key: _imageAvatarKey, // <--- APLICA LA KEY AQUÍ --->
                radius: 50,
                backgroundColor: Colors.grey[800],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              // // 'Hi, $username 👋',
              // AppLocalizations.of(context)!.hiUser(username),
              'Hi, $username',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'User Name: \n Kike22',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'Email: \n$username',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'Telefono: \n2471399840',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'Ubicacion: \nHuamantla,Tlaxcala',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading:  Icon(iconData, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'Genero: \nMasculino',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Divider(height: 32,),
          
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: Text(
              // AppLocalizations.of(context)!.notifications,
              'Notificaciones',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Switch(value: _notificationsEnabled, onChanged: (newValue) {
              _toggleNotifications(newValue);
            },activeColor: Colors.blue[600], // Color cuando está activo
    inactiveThumbColor: Colors.grey[400],
    inactiveTrackColor: Colors.grey[700],),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title:  Text(
              // AppLocalizations.of(context)!.language,
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
              final provider = Provider.of<LocaleProvider>(
                context,
                listen: false,
              );
              final currentLocale = Localizations.localeOf(context);

              if (currentLocale.languageCode == 'en') {
                provider.setLocale(const Locale('es'));
              } else {
                provider.setLocale(const Locale('en'));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            // title:  Text(AppLocalizations.of(context)!.logOut, style: TextStyle(color: Colors.red)),
            title:  Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}