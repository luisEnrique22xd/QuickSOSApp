
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No show method name for now
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 50, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.none,
    ),
    filter: DevelopmentFilter(), // Solo mostrar logs en modo debug/desarrollo
  );

  // Registro
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      logger.e('Registro error: $e');
      return null;
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      logger.e('Login error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Ver usuario actual
  User? get currentUser => _auth.currentUser;
}
