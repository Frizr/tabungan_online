import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabungan_frontend/features/dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:tabungan_frontend/core/providers/transaction_provider.dart';
import 'package:tabungan_frontend/core/models/transaction_model.dart';
import 'package:intl/intl.dart';

class BalanceSummaryView extends ConsumerStatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BalanceSummaryView({
    super.key,
    this.animationController,
    this.animation,
  });

  @override
  ConsumerState<BalanceSummaryView> createState() => _BalanceSummaryViewState();
}

class _BalanceSummaryViewState extends ConsumerState<BalanceSummaryView> {
  bool _obscureBalance = false;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(totalBalanceProvider);
    final transactionsAsync = ref.watch(userTransactionsProvider);

    double pemasukan = 0;
    double pengeluaran = 0;

    transactionsAsync.whenData((transactions) {
      for (var tx in transactions) {
        if (tx.type == TransactionType.deposit) pemasukan += tx.amount;
        if (tx.type == TransactionType.withdrawal) pengeluaran += tx.amount;
      }
    });

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F766E), // Emerald 700
                      Color(0xFF047857), // Emerald 600
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: AppTheme.grey.withValues(alpha: 0.3),
                        offset: const Offset(1.1, 4.0),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header: Total Saldo & Eye Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Saldo',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppTheme.white.withValues(alpha: 0.8),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _obscureBalance = !_obscureBalance;
                              });
                            },
                            child: Icon(
                              _obscureBalance
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.white.withValues(alpha: 0.8),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Balance Amount
                      Text(
                        _obscureBalance
                            ? 'Rp ••••••••'
                            : currencyFormatter.format(balance),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: AppTheme.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Income and Expense Split
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              icon: Icons.arrow_downward,
                              iconColor: Colors.greenAccent,
                              title: 'Pemasukan',
                              amount: _obscureBalance
                                  ? '••••••••'
                                  : currencyFormatter.format(pemasukan),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: AppTheme.white.withValues(alpha: 0.3),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              icon: Icons.arrow_upward,
                              iconColor: Colors.redAccent,
                              title: 'Pengeluaran',
                              amount: _obscureBalance
                                  ? '••••••••'
                                  : currencyFormatter.format(pengeluaran),
                              isRight: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    bool isRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isRight ? 16.0 : 0.0,
        right: isRight ? 0.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppTheme.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppTheme.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
