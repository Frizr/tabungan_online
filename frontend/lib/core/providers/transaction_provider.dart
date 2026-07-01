import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabungan_frontend/core/models/transaction_model.dart';
import 'package:tabungan_frontend/core/providers/auth_provider.dart';
import 'package:tabungan_frontend/core/repositories/transaction_repository.dart';

final userTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  
  if (user == null) {
    return Stream.value([]);
  }
  
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return transactionRepo.getUserTransactions(user.uid);
});

final totalBalanceProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(userTransactionsProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      double balance = 0.0;
      for (var tx in transactions) {
        if (tx.type == TransactionType.deposit) {
          balance += tx.amount;
        } else {
          balance -= tx.amount;
        }
      }
      return balance;
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});
