import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:cipherx/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false; // Track dark mode state

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load the saved theme preference
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _applyTheme();
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user?.email ?? 'No Email Found'),
              subtitle: const Text('User Profile'),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text(_isDarkMode ? 'Light Mode' : 'Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                _applyTheme();
                _saveThemePreference();
              });
            },
          ),
          const SizedBox(height: 350),
          ElevatedButton.icon(
            onPressed: () => _exportData(context),
            icon: const Icon(
              Icons.download,
              size: 24,
              color: Colors.white,
            ), // White icon
            label: const Text(
              'Export Data',
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Green background
              minimumSize: const Size(double.infinity, 50), // Full-width button
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(const LoginScreen());
            },
            icon: const Icon(
              Icons.logout,
              size: 24,
              color: Colors.white,
            ), // White icon
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red background
              minimumSize: const Size(double.infinity, 50), // Full-width button
            ),
          ),
        ],
      ),
    );
  }

  void _applyTheme() {
    Get.changeTheme(_isDarkMode ? ThemeData.dark() : ThemeData.light());
  }

  Future<void> _exportData(BuildContext context) async {
    // Logic to export data as CSV or JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully!')),
    );
  }
}
