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
  final String userId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.type,
    required this.userId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: data['amount'] as double,
      category: data['category'] as String,
      description: data['description'] as String,
      type: data['type'] as String,
      userId: data['userId'] as String,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransactionModel(
      id: id ?? '',
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      type: map['type'],
      userId: map['userId'],
    );
  }

  factory TransactionModel.fromHive(Map<dynamic, dynamic> data) {
    return TransactionModel(
      id: data['id'] as String? ?? '', // Provide default value if null
      amount: data['amount'] as double? ?? 0.0, // Provide default value if null
      category: data['category'] as String? ?? 'Unknown', // Default category
      description: data['description'] as String? ?? 'No description', // Default description
      type: data['type'] as String? ?? 'Unknown', // Default type
      userId: data['userId'] as String? ?? '', // Provide default value if null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'type': type,
      'userId': userId,
    };
  }

  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'type': type,
      'userId': userId,
    };
  }
}
