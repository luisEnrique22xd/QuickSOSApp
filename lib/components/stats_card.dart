import 'package:flutter/material.dart';
import 'dart:math' as math; // Necesario para el seno y coseno en CustomPainter

class StatsCard extends StatelessWidget {
  final double data1Value; // Valor para la primera sección del gráfico (ej: alertas activas)
  final double data2Value; // Valor para la segunda sección (ej: alertas resueltas)
  final Color data1Color;
  final Color data2Color;
  final String data1Label;
  final String data2Label;

  const StatsCard({
    super.key,
    required this.data1Value,
    required this.data2Value,
    this.data1Color = Colors.orange, // Naranja por defecto, como en tu diseño
    this.data2Color = Colors.grey,   // Gris por defecto
    this.data1Label = 'Data 1',
    this.data2Label = 'Data 2',
  });

  @override
  Widget build(BuildContext context) {
    // Calcula el total para los porcentajes
    final double total = data1Value + data2Value;
    // Calcula los porcentajes para el CustomPainter (de 0 a 1)
    final double data1Percentage = total == 0 ? 0 : data1Value / total;
    final double data2Percentage = total == 0 ? 0 : data2Value / total;

    return Card(
      color: Colors.grey[800], // Fondo oscuro de la tarjeta
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // La columna solo ocupa el espacio necesario
          children: [
            SizedBox(
              width: 100, // Ancho fijo para el gráfico y el texto central
              height: 100, // Altura fija para el gráfico y el texto central
              child: CustomPaint(
                painter: CircularProgressPainter(
                  data1Percentage: data1Percentage,
                  data2Percentage: data2Percentage,
                  data1Color: data1Color,
                  data2Color: data2Color,
                  strokeWidth: 12.0, // Grosor del anillo
                ),
                // Dentro del CustomPaint, puedes añadir un texto central si lo deseas
                // Para tu diseño, el texto está abajo del gráfico
                child: Center(
                  // Puedes poner un ícono o un porcentaje total aquí si quieres
                  // Text('${(total).toInt()}%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el gráfico y las etiquetas

            // Etiquetas de Data 1 y Data 2 con sus colores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(data1Color, data1Label),
                const SizedBox(width: 10),
                _buildLegendItem(data2Color, data2Label),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las leyendas (cuadrito de color + texto)
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

// CustomPainter para dibujar el gráfico circular de progreso
class CircularProgressPainter extends CustomPainter {
  final double data1Percentage; // Porcentaje de 0 a 1
  final double data2Percentage; // Porcentaje de 0 a 1
  final Color data1Color;
  final Color data2Color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.data1Percentage,
    required this.data2Percentage,
    required this.data1Color,
    required this.data2Color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Fondo del círculo (si quieres un anillo completo detrás)
    final backgroundPaint = Paint()
      ..color = Colors.grey[700]! // Un gris más oscuro para el fondo
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Extremos redondeados

    // Dibuja el círculo de fondo completo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Pintura para la primera sección
    final data1Paint = Paint()
      ..color = data1Color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Pintura para la segunda sección
    final data2Paint = Paint()
      ..color = data2Color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Dibuja la primera sección
    double startAngle1 = -math.pi / 2; // Empieza desde arriba
    double sweepAngle1 = 2 * math.pi * data1Percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle1,
      sweepAngle1,
      false, // false para que no cierre el arco al centro
      data1Paint,
    );

    // Dibuja la segunda sección (continuando desde el final de la primera)
    double startAngle2 = startAngle1 + sweepAngle1;
    double sweepAngle2 = 2 * math.pi * data2Percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle2,
      sweepAngle2,
      false,
      data2Paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repinta solo si los porcentajes o colores han cambiado
    final oldPainter = oldDelegate as CircularProgressPainter;
    return oldPainter.data1Percentage != data1Percentage ||
           oldPainter.data2Percentage != data2Percentage ||
           oldPainter.data1Color != data1Color ||
           oldPainter.data2Color != data2Color;
  }
}