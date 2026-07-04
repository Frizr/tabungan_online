import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:animations/animations.dart';

import 'package:tabungan_frontend/core/constants/app_colors.dart';
import 'package:tabungan_frontend/features/savings/controllers/savings_controller.dart';
import 'package:tabungan_frontend/features/settings/views/settings_view.dart';
import '../models/savings_goal.dart';
import 'goal_detail_view.dart';
import 'widgets/edit_goal_sheet.dart';
import 'widgets/looping_background.dart';
import 'package:flutter_tilt/flutter_tilt.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TabunganKu'),
        actions: [
          OpenContainer(
            closedShape: const CircleBorder(),
            closedColor: Colors.transparent,
            closedElevation: 0,
            openElevation: 0,
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 400),
            openBuilder: (context, _) => const SettingsView(),
            closedBuilder: (context, openContainer) => IconButton(
              icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
              onPressed: openContainer,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: LoopingBackground()),
          SafeArea(
            child: savingsAsync.when(
              data: (goals) {
            final totalSavings = goals.fold<double>(0, (sum, item) => sum + item.currentAmount);
            
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tilt(
                    tiltConfig: const TiltConfig(
                      angle: 15,
                      enableRevert: true,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Total Saldo Anda',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalSavings),
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: goals.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada target tabungan.\nMulai buat sekarang!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: goals.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return _buildTiltCard(context, goal);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildTiltCard(BuildContext context, SavingsGoal goal) {
    return OpenContainer(
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      openColor: AppColors.background, // Match with GoalDetailView background
      transitionType: ContainerTransitionType.fade, // Softer fade transition
      transitionDuration: const Duration(milliseconds: 750), // Slower, more elegant duration
      useRootNavigator: true,
      openBuilder: (context, _) => GoalDetailView(goal: goal),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) => EditGoalSheet(goal: goal),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(goal.currentAmount),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(goal.targetAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  if (goal.targetDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.event, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Hari H: ${DateFormat('dd MMM yyyy', 'id_ID').format(goal.targetDate!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Builder(builder: (context) {
                          final daysLeft = goal.targetDate!.difference(DateTime.now()).inDays;
                          final text = daysLeft > 0 ? '($daysLeft hari lagi)' : (daysLeft == 0 ? '(Hari ini!)' : '(Terlewat ${daysLeft.abs()} hari)');
                          final color = daysLeft > 0 ? AppColors.success : (daysLeft == 0 ? Colors.orangeAccent : AppColors.error);
                          return Text(
                            text,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Colors.black26,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.progress >= 1.0 ? AppColors.success : AppColors.primary,
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

