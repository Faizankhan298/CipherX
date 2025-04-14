import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../wrapper.dart';
import 'forgot_password_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAll(() => const Wrapper());
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Get.to(() => const ForgotPasswordScreen()),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Or with'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {}, // Add Google signup logic here
              icon: Image.asset('assets/icons/google.png', height: 24),
              label: const Text(
                'Google',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.back(),
              child: const Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
