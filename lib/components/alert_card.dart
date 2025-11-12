import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String type; // Fire, Robbery, Accident
  final String time;
  final String description;
  final String priority;
  final String imageUrl; // Puede ser una URL o asset local
  final Color priorityColor;
  final IconData icon;
  final VoidCallback onDetailsPressed;

  const AlertCard({
    super.key,
    required this.type,
    required this.time,
    required this.description,
    required this.priority,
    required this.imageUrl,
    required this.priorityColor,
    required this.icon,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            // Imagen o icono
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12),
            //   child: imageUrl.isNotEmpty
            //       ? Image.network(
            //           imageUrl,
            //           width: 70,
            //           height: 70,
            //           fit: BoxFit.cover,
            //         )
            //       : Container(
            //           width: 70,
            //           height: 70,
            //           color: Colors.grey[800],
            //           child: Icon(icon, color: Colors.white, size: 36),
            //         ),
            // ),
            const SizedBox(width: 12),

            // Información de alerta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo y hora
                  Row(
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('|',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  //Dirección
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Prioridad + botón detalles
                  Row(
                    children: [
                      Text(
                        'Priority: ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                       const SizedBox(width: 155),
            Column(
              children: [
                Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.white70, size: 22),
                    SizedBox(width: 5),
                    Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 22),
                    
                  ],
                ),
                 GestureDetector(
                        onTap: onDetailsPressed,
                        child: const Text(
                          'See Details',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),

                    ],
                ),
                ],
              ),
            ),

            // Íconos a la derecha
           
          ],
        ),
      ),
    );
  }
}
