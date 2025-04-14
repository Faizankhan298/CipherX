import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    // Sign out the google user
    await GoogleSignIn().signOut();
    // Sign out the user
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(child: Text('${user?.email}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => signout(),
        child: const Icon(Icons.logout),
      ),
    );
  }
}
