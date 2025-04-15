import 'package:flutter/material.dart';

class SharedButtons extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const SharedButtons({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0), // Add padding to the top
      child: BottomNavigationBar(
        type:
            BottomNavigationBarType.fixed, // Ensure background color is applied
        currentIndex: currentIndex,
        onTap: onTabSelected,
        backgroundColor: Colors.purple, // Set background color to purple
        selectedItemColor: Colors.white, // Set selected icon color to white
        unselectedItemColor:
            Colors.white70, // Set unselected icon color to a lighter white
        iconSize: 30.0, // Increase icon size
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedFontSize: 14.0, // Adjust font size for labels
        unselectedFontSize: 12.0,
        elevation: 10.0, // Add elevation for better visibility
      ),
    );
  }
}
