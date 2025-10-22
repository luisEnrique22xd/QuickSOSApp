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
      padding: const EdgeInsets.all(16.0), // margen alrededor
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255), // color de fondo
          borderRadius: BorderRadius.circular(30), // esquinas redondeadas
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, // para que se vea el contenedor
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            iconSize: 30,
            showSelectedLabels: false,  // 🔽 Oculta texto seleccionado
            showUnselectedLabels: false,  // 🔽 Oculta texto no seleccionado
            selectedItemColor: Colors.yellow[700],
            unselectedItemColor: Colors.grey[400],
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
