import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              title: Text(user?.email ?? 'Guest'),
              subtitle: const Text('User Profile'),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false, // Replace with actual dark mode state
            onChanged: (value) {
              // Replace with actual dark mode toggle logic
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _exportData(context),
            icon: const Icon(Icons.download),
            label: const Text('Export Data'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    // Logic to export data as CSV or JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully!')),
    );
  }
}
