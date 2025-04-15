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
      []; // Local cache for transactions
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  String _selectedFilter = 'Today';

  final List<String> _titles = [
    'Home',
    'Transactions',
    'Add Transaction',
    'Budget',
    'Profile',
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const TransactionTab(), // Removed `transactions` parameter
    const AddTransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    if (user == null) return [];

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user!.uid)
              .orderBy('timestamp', descending: true)
              .limit(5) // Limit to 5 recent transactions
              .get();

      final transactions =
          querySnapshot.docs.map((doc) {
            return TransactionModel.fromFirestore(doc);
          }).toList();

      _localTransactions = transactions; // Update local cache
      _transactions = transactions; // Update UI transactions
      _calculateTotals(); // Recalculate totals after fetching

      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  void _calculateTotals() {
    final now = DateTime.now();
    final filteredTransactions =
        _transactions.where((t) {
          switch (_selectedFilter) {
            case 'Today':
              return t.timestamp.day == now.day &&
                  t.timestamp.month == now.month &&
                  t.timestamp.year == now.year;
            case 'Week':
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              return t.timestamp.isAfter(startOfWeek) &&
                  t.timestamp.isBefore(now.add(const Duration(days: 1)));
            case 'Month':
              return t.timestamp.month == now.month &&
                  t.timestamp.year == now.year;
            case 'Year':
              return t.timestamp.year == now.year;
            default:
              return true;
          }
        }).toList();

    _totalIncome = filteredTransactions
        .where((t) => t.type == 'Income')
        .fold(0.0, (total, transaction) => total + transaction.amount);
    _totalExpenses = filteredTransactions
        .where((t) => t.type == 'Expense')
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
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
                  _buildFilterRow(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('transactions')
                              .where('userId', isEqualTo: user?.uid)
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListView.builder(
                            itemCount: _localTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _localTransactions[index];
                              return _buildTransactionTile(transaction);
                            },
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error loading transactions.'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No transactions found.'),
                          );
                        }

                        final transactions =
                            snapshot.data!.docs.map((doc) {
                              return TransactionModel.fromFirestore(doc);
                            }).toList();

                        // Update local cache without calling setState
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _localTransactions = transactions;
                          _transactions = transactions;
                          _calculateTotals();
                        });

                        return ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return _buildTransactionTile(transaction);
                          },
                        );
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
              '₹${value.toStringAsFixed(2)}', // Use Indian Rupee symbol
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['Today', 'Week', 'Month', 'Year'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          filters.map((filter) {
            return ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                  _calculateTotals(); // Recalculate totals when filter changes
                });
              },
            );
          }).toList(),
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
        '${transaction.type == 'Income' ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.type == 'Income' ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
