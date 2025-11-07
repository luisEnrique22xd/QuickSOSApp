import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
final _descriptionController = TextEditingController();
final _titleAlertController = TextEditingController();
class CreateAlert extends StatefulWidget {
  CreateAlert({super.key});
  
  @override
  State<CreateAlert> createState() => _CreateAlertState();
}

class _CreateAlertState extends State<CreateAlert> {
  String? _selectedAlert;
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
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Crear Alerta"),
      actions: [IconButton(icon:Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),onPressed:  () => {
                   Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false)
                  },), ],
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            
            _buildTextField(_titleAlertController, "Titulo de alerta"),
                  const SizedBox(height: 10.0),
            Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: DropdownButtonFormField<String>(
                    // 1. Valor actual seleccionado (ahora usa el estado local)
                    value: _selectedAlert,

                    // 2. Estilo para el texto seleccionado (Asegura color negro sobre fondo blanco)
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
                        _selectedAlert = newValue; // 🌟 ACTUALIZA EL ESTADO
                      });
                    },

                    items: _alertOptions.map<DropdownMenuItem<String>>((
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
            _buildTextField(_descriptionController, "Descripcion"),
                  const SizedBox(height: 10.0),
            // _buildTextField(_typealertController, "Tipo de Alerta"),
            //       const SizedBox(height: 10.0),
            ElevatedButton(onPressed: _capturePhoto, child: Text("Tomar foto")),
            SizedBox(height:20,),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _capturedImage != null
                  ? Image.file(_capturedImage!, fit: BoxFit.cover)
                  : Center(child: Text("No hay imagen capturada")
            ),),
            SizedBox(height:20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                
                ElevatedButton(onPressed: _capturePhoto, child: Text("Obtener ubicacion")),
                ElevatedButton(onPressed: _capturePhoto, child: Text("Enviar")),
              ],
            ),
        
          ],
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