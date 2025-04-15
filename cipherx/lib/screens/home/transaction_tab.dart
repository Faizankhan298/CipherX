import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cipherx/models/transaction_model.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  String _selectedFilter = 'All';
  List<TransactionModel> _localTransactions =
      []; // Local cache for transactions

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              items:
                  ['All', 'Food', 'Travel', 'Shopping', 'Subscriptions']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedType,
              items:
                  ['All', 'Income', 'Expense']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedFilter,
              items:
                  ['All', 'Today', 'Week', 'Month', 'Year']
                      .map(
                        (filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('transactions')
                    .where(
                      'userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  itemCount: _localTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _localTransactions[index];
                    return _buildTransactionTile(transaction);
                  },
                );
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading transactions.'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No transactions found.'));
              }

              final transactions =
                  snapshot.data!.docs.map((doc) {
                    return TransactionModel.fromFirestore(doc);
                  }).toList();

              // Update local cache without calling setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _localTransactions = transactions;
              });

              final filteredTransactions =
                  transactions.where((transaction) {
                    final now = DateTime.now();
                    final matchesSearch = transaction.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    final matchesCategory =
                        _selectedCategory == 'All' ||
                        transaction.category == _selectedCategory;
                    final matchesType =
                        _selectedType == 'All' ||
                        transaction.type == _selectedType;

                    final matchesFilter = () {
                      switch (_selectedFilter) {
                        case 'Today':
                          return transaction.timestamp.day == now.day &&
                              transaction.timestamp.month == now.month &&
                              transaction.timestamp.year == now.year;
                        case 'Week':
                          final startOfWeek = now.subtract(
                            Duration(days: now.weekday - 1),
                          );
                          return transaction.timestamp.isAfter(startOfWeek) &&
                              transaction.timestamp.isBefore(
                                now.add(const Duration(days: 1)),
                              );
                        case 'Month':
                          return transaction.timestamp.month == now.month &&
                              transaction.timestamp.year == now.year;
                        case 'Year':
                          return transaction.timestamp.year == now.year;
                        default:
                          return true;
                      }
                    }();

                    return matchesSearch &&
                        matchesCategory &&
                        matchesType &&
                        matchesFilter;
                  }).toList();

              return ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];
                  return _buildTransactionTile(transaction);
                },
              );
            },
          ),
        ),
      ],
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
