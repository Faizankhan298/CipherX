import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:cipherx/models/transaction_model.dart';

class TransactionTab extends StatefulWidget {
  final List<TransactionModel> transactions;

  const TransactionTab({super.key, required this.transactions});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredTransactions =
        widget.transactions.where((transaction) {
          final matchesSearch = transaction.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == 'All' ||
              transaction.category == _selectedCategory;
          final matchesType =
              _selectedType == 'All' || transaction.type == _selectedType;
          return matchesSearch && matchesCategory && matchesType;
        }).toList();

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
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return Dismissible(
                key: Key(transaction.id),
                onDismissed: (direction) => _deleteTransaction(transaction),
                child: ListTile(
                  leading: Icon(
                    transaction.type == 'Income'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color:
                        transaction.type == 'Income'
                            ? Colors.green
                            : Colors.red,
                  ),
                  title: Text(transaction.category),
                  subtitle: Text(transaction.description),
                  trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.id)
        .delete();
    // Delete from Hive
    final box = await Hive.openBox('transactions');
    await box.delete(transaction.id);
    // Update state
    setState(() {
      widget.transactions.remove(transaction);
    });
  }
}
