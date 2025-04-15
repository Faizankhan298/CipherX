import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cipherx/models/transaction_model.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  List<TransactionModel> _localTransactions =
      []; // Local cache for transactions

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromHive();
  }

  Future<void> _loadTransactionsFromHive() async {
    final box = await Hive.openBox('transactions');
    final transactions =
        box.values.map((data) {
          return TransactionModel.fromHive(data as Map<dynamic, dynamic>);
        }).toList();

    setState(() {
      _localTransactions = transactions;
    });
  }

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
              setState(() {});
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
            itemCount: _localTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _localTransactions[index];
              return _buildTransactionTile(transaction);
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
