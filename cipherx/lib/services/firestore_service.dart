import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).delete();
  }

  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    final querySnapshot =
        await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }
}
