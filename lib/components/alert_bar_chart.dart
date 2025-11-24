import 'package:flutter/material.dart';

class AlertBarChart extends StatelessWidget {
  final String type;
  final int count;
  final int maxCount; // Para calcular el ancho relativo
  final Color color;

  const AlertBarChart({
    super.key,
    required this.type,
    required this.count,
    required this.maxCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula el factor de ancho de la barra (de 0.1 a 1.0)
    final double widthFactor = maxCount == 0 ? 0.1 : (count / maxCount).clamp(0.1, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Etiqueta (Tipo de alerta)
          SizedBox(
            width: 80,
            child: Text(
              type,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Barra de Gráfico (Expandida y Limitada)
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor, // Aplica el ancho relativo aquí
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // 3. Valor (Conteo exacto)
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}