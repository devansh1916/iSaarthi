import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onNavBarTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Do nothing if already on the page

    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Map
        Navigator.pushReplacementNamed(context, '/map');
        break;
      // Add cases for other items later
      case 1: // Explore (Placeholder)
      case 3: // Chatbot (Placeholder)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This feature is coming soon!')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavBarItem(context, Icons.home_outlined, "Home", 0),
              _buildNavBarItem(context, Icons.explore_outlined, "Explore", 1),
              const SizedBox(width: 40), // The space for the FAB
              _buildNavBarItem(context, Icons.map_outlined, "Map", 2),
              _buildNavBarItem(context, Icons.chat_bubble_outline, "Chatbot", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _onNavBarTapped(context, index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon, 
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600], 
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}