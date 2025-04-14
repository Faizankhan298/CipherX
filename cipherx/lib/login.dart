import 'package:cipherx/forget.dart';
import 'package:cipherx/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cipherx/homepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  login() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    Get.to(const Homepage());
  }

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: 'Password'),
            ),
            ElevatedButton(
              onPressed: (() => signIn()),
              child: const Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (() => Get.to(Signup())),
              child: const Text('Register Now'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (() => Get.to(Forgot())),
              child: const Text('Forgot Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (() => login()),
              child: const Text('Login with Google'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
