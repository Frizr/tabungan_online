import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabungan_frontend/core/models/transaction_model.dart';
import 'package:tabungan_frontend/core/providers/firestore_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(firestoreProvider));
});

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore.collection('transactions').add(transaction.toJson());
  }

  // Get stream of user transactions ordered by date descending
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
          .toList();
      // Sort locally to avoid requiring Firestore composite index
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }
}
