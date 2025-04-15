import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'Food';
  String _type = 'Income';

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (!mounted) return; // Guard BuildContext usage
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }

      final transaction = {
        'amount': double.parse(_amountController.text),
        'category': _category,
        'description': _descriptionController.text,
        'type': _type,
        'userId': userId,
      };

      try {
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('transactions')
            .add(transaction);

        // Save to Hive
        final box = await Hive.openBox('transactions');
        await box.add(transaction);

        // Clear fields after saving
        setState(() {
          _amountController.clear();
          _descriptionController.clear();
          _category = 'Food'; // Reset category
          _type = 'Income'; // Reset type
        });

        if (!mounted) return; // Guard BuildContext usage
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!')),
        );

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return; // Guard BuildContext usage
        // Handle errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center the form
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      ['Food', 'Travel', 'Subscriptions', 'Shopping']
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items:
                      ['Income', 'Expense']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
