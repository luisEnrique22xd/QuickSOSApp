import 'package:flutter/material.dart';

// Definición de la paleta de colores principales observados en la imagen
class AppColors {
  // Colores principales de la UI
  static const Color primaryBlue = Color(0xFF1E88E5); // Azul principal para botones, iconos activos, etc.
  static const Color backgroundDark = Color(0xFF1C1C1C); // Fondo general en modo oscuro
  static const Color textDark = Color(0xFFFFFFFF); // Texto principal en modo oscuro
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Texto secundario en modo oscuro
  static const Color textDark2 = Color.fromARGB(255, 0, 0, 0); // Otro tono de texto claro para contraste

  // Colores para las tarjetas/contenedores de información (se ven más oscuros que el fondo general)
  static const Color cardDark = Color(0xFF282828);

  // Colores de alerta (Robbery, Fire, Accident)
  static const Color alertFire = Color(0xFFE53935); // Rojo para Fire/Alerta general
  static const Color alertRobbery = Color(0xFFFF9800); // Naranja para Robbery
  static const Color alertAccident = Color(0xFF42A5F5); // Azul claro para Accident/Accidente
  static const Color alertLow = Color(0xFF4CAF50); // Verde para "Low"
  static const Color alertMedium = Color(0xFFFFC107); // Amarillo para "Medium"
  static const Color alertHigh = Color(0xFFE53935); // Rojo para "High"
  static const Color inputs = Color.fromARGB(255, 255, 255, 255); // Rojo para "High"

}

// Tema Oscuro (DarkTheme) - Predominante en la imagen
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  // Colores primarios y de esquema
  primaryColor: AppColors.primaryBlue,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryBlue, // Color principal
    secondary: AppColors.alertAccident, // Color de fondo
    surface: AppColors.cardDark, // Color para tarjetas y superficies
    error: AppColors.alertFire, // Color de error
    onPrimary: AppColors.textDark, // Color de texto sobre el fondo
    onSurface: AppColors.textDark, // Color de texto sobre las superficies
  ),

  // Scaffold (Fondo general)
  scaffoldBackgroundColor: AppColors.backgroundDark,

  // AppBar (Si se usa, aunque en la imagen no es visible)
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.textDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Botones (Estilo general)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.textDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),

  // Card Theme (Para las tarjetas de estadísticas o alertas)
  cardTheme: CardThemeData(
    color: AppColors.cardDark,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),

  // Input Decoration Theme (Para campos de texto como Email y Password)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputs, // Fondo del campo de texto
    hintStyle: const TextStyle(color: AppColors.textDark2),
    labelStyle: const TextStyle(color: AppColors.textDark2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none, // Borde invisible (se usa el relleno)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2), // Borde azul al enfocar
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
  ),

  // Text Theme
  textTheme: const TextTheme(
    // Estilo para títulos/encabezados grandes
    headlineLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 32),
    // Estilo para títulos de sección (p. ej., "Alerts", "Profile")
    titleLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 24),
    // Estilo para el texto de las tarjetas o subtítulos
    titleMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 18),
    // Texto de cuerpo normal
    bodyLarge: TextStyle(color: AppColors.textDark2, fontSize: 16),
    // Texto secundario (como el de la información del perfil)
    bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
  ),

  // Bottom Navigation Bar Theme (Barra de navegación inferior)
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.cardDark,
    selectedItemColor: AppColors.primaryBlue, // Icono activo
    unselectedItemColor: AppColors.textSecondaryDark, // Icono inactivo
    type: BottomNavigationBarType.fixed, // Asegura que los ítems no se muevan
  ),
);

// Tema Claro (LightTheme) - Sugerido para completitud, invirtiendo la paleta
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryBlue,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryBlue,
    secondary: AppColors.alertAccident, // Fondo claro
    surface: Color(0xFFFFFFFF), // Superficie/Tarjetas claras
    error: AppColors.alertFire,
    onPrimary: AppColors.textDark, // Texto negro sobre fondo claro
    onSurface: Color(0xFF000000), // Texto negro sobre superficie clara
  ),

  scaffoldBackgroundColor: const Color(0xFFF5F5F5),

  // ... (otros temas como Card, Input, Text, etc., se adaptarían invirtiendo colores
  // de fondo y texto, manteniendo el AppColors.primaryBlue)
);