import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, withdrawal }

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TransactionModel(
      id: documentId,
      userId: json['userId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      type: json['type'] == 'withdrawal' ? TransactionType.withdrawal : TransactionType.deposit,
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type == TransactionType.withdrawal ? 'withdrawal' : 'deposit',
      'date': Timestamp.fromDate(date),
    };
  }
}
