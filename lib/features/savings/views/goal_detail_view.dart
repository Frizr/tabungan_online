import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';
import '../models/savings_goal.dart';
import '../controllers/savings_controller.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/edit_transaction_sheet.dart';
import 'widgets/looping_background.dart';

class GoalDetailView extends ConsumerWidget {
  final SavingsGoal goal;

  const GoalDetailView({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need real-time updates for the goal itself so the progress ring updates immediately
    final savingsAsync = ref.watch(savingsGoalsProvider);
    final currentGoal = savingsAsync.value?.firstWhere((g) => g.id == goal.id, orElse: () => goal) ?? goal;
    
    final transactionsAsync = ref.watch(transactionsProvider(goal.id));
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(currentGoal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Stack(
        children: [
          const LoopingBackground(),
          Column(
            children: [
              // Header section (Glassmorphism & Glowing Ring)
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Glowing background for the ring
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (currentGoal.progress >= 1.0 ? AppColors.success : AppColors.primary).withValues(alpha: 0.2),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: currentGoal.progress),
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, animatedProgress, _) {
                                      return CircularProgressIndicator(
                                        value: animatedProgress,
                                        strokeWidth: 14,
                                        backgroundColor: AppColors.background.withValues(alpha: 0.5),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          currentGoal.progress >= 1.0 ? AppColors.success : AppColors.primary,
                                        ),
                                        strokeCap: StrokeCap.round,
                                      );
                                    },
                                  ),
                                  Center(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: (currentGoal.progress * 100).clamp(0, 100)),
                                      duration: const Duration(milliseconds: 700),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, _) {
                                        return Text(
                                          '${value.toStringAsFixed(0)}%',
                                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                color: AppColors.primaryVariant,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: AppColors.primary.withValues(alpha: 0.5),
                                                    blurRadius: 10,
                                                  )
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              currencyFormatter.format(currentGoal.currentAmount),
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Target: ${currencyFormatter.format(currentGoal.targetAmount)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: AppColors.textSecondary),
                            ),
                            if (currentGoal.targetDate != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hari H: ${DateFormat('dd MMM yyyy', 'id_ID').format(currentGoal.targetDate!)}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Builder(builder: (context) {
                                      final daysLeft = currentGoal.targetDate!.difference(DateTime.now()).inDays;
                                      final text = daysLeft > 0 ? '($daysLeft hari lagi)' : (daysLeft == 0 ? '(Hari ini!)' : '(Terlewat ${daysLeft.abs()} hari)');
                                      final color = daysLeft > 0 ? AppColors.success : (daysLeft == 0 ? Colors.orangeAccent : AppColors.error);
                                      return Text(
                                        text,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Transactions List section
              Expanded(
                child: Container(
                  color: Colors.transparent,
              child: transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada riwayat transaksi.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isDeposit = tx.amount >= 0;
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index.clamp(0, 10) * 80)),
                        curve: Curves.easeOutCubic,
                        builder: (context, anim, child) {
                          return Opacity(
                            opacity: anim,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - anim)),
                              child: child,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppColors.background,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    builder: (context) => EditTransactionSheet(transaction: tx),
                                  );
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (isDeposit ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                    color: isDeposit ? AppColors.success : AppColors.error,
                                  ),
                                ),
                                title: Text(
                                  isDeposit ? 'Setor Tabungan' : 'Tarik Saldo',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (tx.note.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(tx.note, style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '${isDeposit ? '+' : ''}${currencyFormatter.format(tx.amount)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: isDeposit ? AppColors.success : AppColors.error,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
            ],
          ),
        ],
      ),
      floatingActionButton: OpenContainer(
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        closedColor: AppColors.primary,
        closedElevation: 0,
        openElevation: 0,
        openColor: AppColors.surface,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 400),
        openBuilder: (context, _) => Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AddTransactionSheet(goal: currentGoal),
              ),
            ),
          ),
        ),
        closedBuilder: (context, openContainer) => FloatingActionButton.extended(
          onPressed: openContainer,
          backgroundColor: AppColors.primary,
          elevation: 0,
          icon: const Icon(Icons.add, color: AppColors.background),
          label: const Text(
            'Transaksi',
            style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
