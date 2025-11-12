import 'package:flutter/material.dart';

class AlertFilterBar extends StatelessWidget {
  final Function(String) onFilterSelected;
  final String activeFilter;

  const AlertFilterBar({
    super.key,
    required this.onFilterSelected,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filters = [
    
    {
      'label': 'Incendios',
      'color': Colors.redAccent,
      'icon': Icons.local_fire_department,
      'value': 'Incendio'
    },
    {
      'label': 'Robos',
      'color': Colors.blueGrey,
      'icon': Icons.local_police,
      'value': 'Robo'
    },
    {
      'label': 'Accidentes',
      'color': Colors.amber,
      'icon': Icons.warning,
      'value': 'Accidente'
    },
  ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Botón "All" especial
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: ChoiceChip(
              label: const Text("Todo"),
              selected: activeFilter == "All",
              onSelected: (_) => onFilterSelected("All"),
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(
                color: activeFilter == "All" ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Chips personalizados con íconos
          ...filters.map((filter) {
            final bool isActive = activeFilter == filter['value'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: ChoiceChip(
                avatar: Icon(
                  filter['icon'],
                  color: isActive ? Colors.white : filter['color'],
                  size: 18,
                ),
                label: Text(
                  filter['label'],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isActive,
                onSelected: (_) => onFilterSelected(filter['value']),
                selectedColor: filter['color'],
                backgroundColor: Colors.grey[200],
                elevation: isActive ? 3 : 0,
                pressElevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
