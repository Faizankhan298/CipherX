import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0) // Assign a unique typeId
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String userId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.userId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: data['amount'],
      category: data['category'],
      description: data['description'],
      type: data['type'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransactionModel(
      id: id ?? '',
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }
}
