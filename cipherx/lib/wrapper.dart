
import 'package:cipherx/homepage.dart';
import 'package:cipherx/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state changes
      builder: (context,snapshot){
        if(snapshot.hasData){
          return const Homepage();
        }
        else{
          return const Login();
        }
    
      }),
    );
  }
}