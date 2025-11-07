import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 60, // 🔽 altura reducida sin overflow
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_filled,
              index: 0,
              context: context,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.warning,
              index: 1,
              context: context,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.location_on,
              index: 2,
              context: context,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.account_circle_outlined,
              index: 3,
              context: context,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required BuildContext context,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[400]?.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.blue[400] : Colors.white,
        ),
      ),
    );
  }
}
