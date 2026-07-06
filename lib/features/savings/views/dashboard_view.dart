import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';
import 'package:tabungan_frontend/features/savings/controllers/savings_controller.dart';
import 'package:tabungan_frontend/features/settings/views/settings_view.dart';
import '../models/savings_goal.dart';
import 'goal_detail_view.dart';
import 'widgets/edit_goal_sheet.dart';
import 'widgets/looping_background.dart';
import 'package:flutter_tilt/flutter_tilt.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {

  @override
  Widget build(BuildContext context) {
    final savingsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MyTabungan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SettingsView(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
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
                              // Counting-up balance animation
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: totalSavings),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) {
                                    return Text(
                                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value),
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
                                    );
                                  },
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
                              // Staggered entrance: each card delayed by 100ms * index
                              return _StaggeredEntrance(
                                index: index,
                                child: _buildTiltCard(context, goal),
                              );
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GoalDetailView(goal: goal),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
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
                  // Animated progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: goal.progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.black26,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.progress >= 1.0 ? AppColors.success : AppColors.primary,
                          ),
                          minHeight: 10,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

/// Staggered entrance animation — fades in + slides up from 30px below.
/// Each card is delayed by 100ms × its index for a cascade effect.
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Cap delay so deep lists don't wait forever
    final delayMs = (index * 100).clamp(0, 600);
    final totalMs = 500 + delayMs; // animation duration + delay

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Curves.linear, // we handle curve internally via Interval
      builder: (context, raw, _) {
        // Interval: delay portion is idle, then ease out for the animation
        final delayed = Interval(
          delayMs / totalMs,
          1.0,
          curve: Curves.easeOutCubic,
        ).transform(raw);

        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - delayed)),
            child: child,
          ),
        );
      },
    );
  }
}
