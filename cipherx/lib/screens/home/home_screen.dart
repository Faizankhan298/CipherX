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
import 'package:cipherx/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _localTransactions =
      []; 
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  final List<String> _titles = [
    'Home',
    'Transactions',
    'Add Transaction',
    'Budget',
    'Profile',
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const TransactionTab(),
    const AddTransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromHive();
    _syncTransactionsWithFirestore();
  }

  Future<void> _loadTransactionsFromHive() async {
    final box = await Hive.openBox('transactions');
    final transactions =
        box.values.map((data) {
          return TransactionModel.fromHive(data as Map<dynamic, dynamic>);
        }).toList();

    setState(() {
      _localTransactions = transactions;
      _transactions = transactions;
      _calculateTotals();
    });
  }

  Future<void> _syncTransactionsWithFirestore() async {
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user!.uid)
              .get();

      final transactions =
          querySnapshot.docs.map((doc) {
            return TransactionModel.fromFirestore(doc);
          }).toList();

      final box = await Hive.openBox('transactions');
      await box.clear(); 
      for (var transaction in transactions) {
        await box.add(transaction.toHive());
      }

      setState(() {
        _localTransactions = transactions;
        _transactions = transactions;
        _calculateTotals();
      });
    } catch (e) {
      debugPrint('Error syncing transactions: $e');
    }
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == 'Income')
        .fold(0.0, (total, transaction) => total + transaction.amount);
    _totalExpenses = _transactions
        .where((t) => t.type == 'Expense')
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Get.offAll(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {

    final refresh = Get.arguments?['refresh'] ?? false;
    if (refresh) {
      _syncTransactionsWithFirestore();
    
      Get.arguments?['refresh'] = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body:
          _currentIndex == 0
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Account Balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Income',
                          _totalIncome,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          'Expenses',
                          _totalExpenses,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _localTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _localTransactions[index];
                        return _buildTransactionTile(transaction);
                      },
                    ),
                  ),
                ],
              )
              : _screens[_currentIndex],
      bottomNavigationBar: SharedButtons(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          
            if (_currentIndex == 0) {
              _syncTransactionsWithFirestore();
            }
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    return ListTile(
      leading: Icon(
        transaction.type == 'Income'
            ? Icons.arrow_upward
            : Icons.arrow_downward,
        color: transaction.type == 'Income' ? Colors.green : Colors.red,
      ),
      title: Text(transaction.category),
      subtitle: Text(transaction.description),
      trailing: Text(
        '₹${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.type == 'Income' ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
