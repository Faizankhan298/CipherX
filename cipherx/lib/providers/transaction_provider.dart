import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class TransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  Future<void> fetchTransactions(String userId) async {
    _transactions = await _firestoreService.fetchTransactions(userId);
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestoreService.addTransaction(transaction);
    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestoreService.deleteTransaction(transactionId);
    _transactions.removeWhere((txn) => txn.id == transactionId);
    notifyListeners();
  }
}
