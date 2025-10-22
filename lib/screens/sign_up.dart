import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quicksosapp/screens/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
bool _obscurePassword = true;

class _SignUpScreenState extends State<SignUpScreen> {
  var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No show method name for now
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 50, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.none
  ),
  filter: DevelopmentFilter(), // Solo mostrar logs en modo debug/desarrollo
);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

void _register()async{
  try {
    final user = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      // Guardar documento en Firestore con el UID del usuario
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImage': '',
        'email': user.email, // opcional, útil para administración
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navegar al login
      
      if(mounted){
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrarse.')),
      );
      }
    }
  } catch (e) {
    logger.e('Error en _register: $e');
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ocurrió un error: $e')),
    );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 9, 9, 9),
      body: SingleChildScrollView(
        child: Center(
        child: Form(
          
          child: Column(
            children: [
              SizedBox(height: 100,),
              
              const SizedBox(
                //img size
                height: 175.0,
                width: 175.0,
                child:
                 Image(
                  image: AssetImage('assets/images/Icon.png')//logo
                  )
              ),
              SizedBox(height: 15,),
               Text(
                // AppLocalizations.of(context)!.welcome,
                "Bienvenido a Quick SOS",
              style: TextStyle(fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              )
              ),
              
               const SizedBox(
                height: 25.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:30.0),
              child: TextFormField(
                controller: _emailController,
                obscureText: false,

                decoration:   InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                    ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Email",
                ),
              ),
              
              ),
             const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:30.0),
              child: TextFormField(
              controller: _passwordController,
                obscureText: _obscurePassword,

                decoration:   InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                    ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
              const SizedBox(height: 15.0,),
              // Container(
              // padding: const EdgeInsets.symmetric(horizontal:30.0),
              // child: TextFormField(
              //   // controller: password2controller,
              //   obscureText: true,

              //   decoration:   InputDecoration(
              //     enabledBorder:  OutlineInputBorder(
              //       borderSide: const BorderSide(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(20.0),
              //       ),
              //     focusedBorder: const OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.grey)
              //       ),
              //       fillColor: Colors.grey[800],
              //       filled: true,
              //       hintText: "Re-type your Password",
              //   ),
              // ),
              // ),
              const SizedBox(height: 5.0),
              
              const SizedBox(height: 15.0),
              GestureDetector(
                  onTap: ()=>{  _register()
                  , Navigator.pushNamed(context, '/login')},
                  child: Container(
                    padding: const EdgeInsets.all(15),//tamaño del boton vertical
                    margin: const EdgeInsets.symmetric(horizontal: 125),//tamaño del boton horizontal
                    decoration:  BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(25)),//border
                    child:  Center(
                      child: Text(
                        "Registarse",
                        // AppLocalizations.of(context)!.signUp,
                      style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.bold),),
                      ),
                  ),
                ),
                SizedBox(height: 12,),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    // AppLocalizations.of(context)!.loginPrompt,
                    "Ya tienes una Cuenta?",
                    style: TextStyle(color: Colors.white),
                    
                    ),
                   const SizedBox(width: 5.0,),
                   GestureDetector(
                        child:  Text(
                          //  AppLocalizations.of(context)!.login,
                          "Iniciar sesion",
                          style: TextStyle(
                            color: Colors.purple[300],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline, // Add underlining for emphasis
                          ),
                        ),
                        onTap: () {
                          
                          Navigator.pushNamed(context, '/login');

                        },
                      ),
                ],
              )
            ],
          ),
        ),
      ),
      )
    );
}
}