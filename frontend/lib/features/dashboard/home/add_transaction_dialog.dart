import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabungan_frontend/core/models/transaction_model.dart';
import 'package:tabungan_frontend/core/providers/auth_provider.dart';
import 'package:tabungan_frontend/core/repositories/transaction_repository.dart';
import 'package:tabungan_frontend/features/dashboard/app_theme.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _type = TransactionType.deposit;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    final description = _descriptionController.text.trim();
    if (amount == null || amount <= 0 || description.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final authState = ref.read(authStateChangesProvider).value;
    if (authState == null) {
      Navigator.of(context).pop();
      return;
    }

    final newTransaction = TransactionModel(
      id: '', // Firestore will generate an ID
      userId: authState.uid,
      amount: amount,
      description: description,
      type: _type,
      date: DateTime.now(),
    );

    try {
      await ref.read(transactionRepositoryProvider).addTransaction(newTransaction);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Transaksi',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              items: [
                DropdownMenuItem(value: TransactionType.deposit, child: Text('Pemasukan')),
                DropdownMenuItem(value: TransactionType.withdrawal, child: Text('Pengeluaran')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
              decoration: InputDecoration(labelText: 'Jenis Transaksi'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Keterangan'),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.nearlyDarkBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
