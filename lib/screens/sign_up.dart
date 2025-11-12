import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quicksosapp/screens/auth.dart';

// Variables Globales (SOLO las que NO son de estado)
bool _obscurePassword = true;
final List<String> _genderOptions = [
  'Male',
  'Female',
  'Other',
  'Prefer not to say',
];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 🌟 CAMBIO CLAVE 1: Mover _selectedGender DENTRO del State 🌟
  String? _selectedGender;
  // No se necesita _genderController ya que Dropdown usa la variable de estado

  var logger = Logger(
    // ... (Configuración del Logger) ...
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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  void _register() async {
    // 🌟 VALIDACIÓN BÁSICA 🌟
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un género.')),
      );
      return; // Detiene el registro si falta el género
    }

    try {
      final user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Guardar documento en Firestore con el UID del usuario
        // 🌟 CAMBIO CLAVE 2: Usar _selectedGender en lugar de un controlador 🌟
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImage': '',
          'username': _usernameController.text.trim(),
          'email': user.email,
          'phone': _phoneController.text.trim(),
          'gender':
              _selectedGender, // EL VALOR YA ESTÁ EN LA VARIABLE DE ESTADO
          'createdAt': FieldValue.serverTimestamp(),
        });

        logger.i('Usuario registrado y perfil creado para: ${user.email}');

        // Navegar al login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Cuenta creada con éxito!')),
      );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrarse.')),
          );
        }
      }
    } catch (e) {
      logger.e('Error en _register: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 9, 9),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            child: Column(
              children: [
                const SizedBox(height: 100),

                // ... (Logo y Texto de Bienvenida) ...
                const SizedBox(
                  height: 175.0,
                  width: 175.0,
                  child: Image(image: AssetImage('assets/images/Icon.png')),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Bienvenido a Quick SOS",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25.0),

                // --- CAMPO USERNAME ---
                _buildTextField(_usernameController, "Username"),
                const SizedBox(height: 10.0),

                // --- CAMPO EMAIL ---
                _buildTextField(_emailController, "Email"),
                const SizedBox(height: 10.0),

                // --- CAMPO TELÉFONO ---
                _buildTextField(_phoneController, "Telefono"),
                const SizedBox(height: 10.0),

                // --- CAMPO GENDER (DROPDOWN) ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: DropdownButtonFormField<String>(
                    // 1. Valor actual seleccionado (ahora usa el estado local)
                    value: _selectedGender,

                    // 2. Estilo para el texto seleccionado (Asegura color negro sobre fondo blanco)
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "samsungsharpsans",
                      fontWeight: FontWeight.w800,
                    ),

                    hint: const Text(
                      "Gender",
                      style: TextStyle(
                        fontFamily: "samsungsharpsans",
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ), // Ajuste a 5.0 para coincidir con los TextFormField
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
                        _selectedGender = newValue; // 🌟 ACTUALIZA EL ESTADO
                      });
                    },

                    items: _genderOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
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

                // --- CAMPO CONTRASEÑA ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,

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
                      hintText: "Password",
                      hintStyle: const TextStyle(
                        fontFamily: "samsungsharpsans",
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15.0),

                // --- BOTÓN REGISTRARSE ---
                GestureDetector(
                  // 🌟 CORRECCIÓN: Llamar solo a _register() 🌟
                  // La navegación debe ocurrir SOLO después del registro exitoso
                  onTap: () => {
                    _register(),
                    Navigator.pushNamed(context, '/login'),
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(horizontal: 125),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        "Registarse",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // ... (Login Prompt y Navegación) ...
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ya tienes una Cuenta?",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      child: Text(
                        "Iniciar sesion",
                        style: TextStyle(
                          color: Colors.purple[300],
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ],
            ),
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
