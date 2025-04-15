import 'package:cipherx/screens/auth/login_screen.dart';
import 'package:cipherx/screens/home/add_transaction_screen.dart';
import 'package:cipherx/screens/home/budget_screen.dart';
import 'package:cipherx/screens/home/profile_screen.dart';
import 'package:cipherx/screens/home/transaction_tab.dart';
import 'package:cipherx/screens/home/shared_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:cipherx/models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;
  List<TransactionModel> _transactions = [];

  final List<String> _titles = [
    'Home',
    'Transactions',
    'Add Transaction',
    'Budget',
    'Profile',
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Home')), // Added 'const' to the constructor
    const TransactionTab(transactions: []), // Added 'const' to the constructor
    const AddTransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user!.uid)
              .orderBy('timestamp', descending: true)
              .get();

      final transactions =
          querySnapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();

      // Sync with Hive (local storage)
      final box = await Hive.openBox('transactions');
      await box.clear(); // Clear old data
      await box.addAll(transactions.map((t) => t.toMap()));

      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      setState(() {
        _transactions = [];
      });
      debugPrint('Error fetching transactions: $e');
    }
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: signout),
        ],
      ),
      body:
          _currentIndex == 1
              ? TransactionTab(
                transactions: _transactions,
              ) // Use _transactions directly
              : _screens[_currentIndex], // Use _screens for other tabs
      bottomNavigationBar: SharedButtons(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
