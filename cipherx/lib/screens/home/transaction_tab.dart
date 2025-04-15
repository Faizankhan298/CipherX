import 'package:flutter/material.dart';

import 'package:cipherx/models/transaction_model.dart';

class TransactionTab extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions available.'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          title: Text(transaction.description),
          subtitle: Text('${transaction.category} - ${transaction.type}'),
          trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
