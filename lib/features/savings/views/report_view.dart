import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';
import 'package:tabungan_frontend/features/savings/controllers/savings_controller.dart';
import 'package:tabungan_frontend/features/savings/views/widgets/looping_background.dart';
import 'dart:ui';

class ReportView extends ConsumerWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsGoalsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MyLaporan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Effect
          const LoopingBackground(),
          SafeArea(
            child: savingsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada data untuk dianalisis.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  );
                }

                final totalTarget = goals.fold<double>(0, (sum, item) => sum + item.targetAmount);
                final totalSavings = goals.fold<double>(0, (sum, item) => sum + item.currentAmount);
                final overallProgress = totalTarget > 0 ? (totalSavings / totalTarget).clamp(0.0, 1.0) : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Global Overview Card (Glassmorphism)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Terkumpul',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currencyFormatter.format(totalSavings),
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.primary.withValues(alpha: 0.5),
                                          blurRadius: 15,
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dari Total Target: ${currencyFormatter.format(totalTarget)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Donut Chart instead of linear progress
                                  SizedBox(
                                    height: 200,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sectionsSpace: 4,
                                            centerSpaceRadius: 70,
                                            startDegreeOffset: -90,
                                            sections: [
                                              PieChartSectionData(
                                                color: AppColors.primary,
                                                value: overallProgress * 100,
                                                title: '',
                                                radius: 12,
                                              ),
                                              PieChartSectionData(
                                                color: AppColors.surfaceHighlight.withValues(alpha: 0.5),
                                                value: (1 - overallProgress) * 100,
                                                title: '',
                                                radius: 12,
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOutCubic,
                                        ),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0, end: overallProgress * 100),
                                          duration: const Duration(milliseconds: 800),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${value.toStringAsFixed(1)}%',
                                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                    color: AppColors.primaryVariant,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text('Tercapai', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                              ],
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        'Rincian Tabungan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Breakdown per Goal (Glassmorphism) with staggered entrance
                      ...goals.asMap().entries.map((entry) {
                        final i = entry.key;
                        final goal = entry.value;
                        final isComplete = goal.progress >= 1.0;
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 400 + (i * 120)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 24 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              goal.title,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isComplete)
                                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            currencyFormatter.format(goal.currentAmount),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: isComplete ? AppColors.success : AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            '${(goal.progress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: isComplete ? AppColors.success : AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: goal.progress),
                                        duration: Duration(milliseconds: 600 + (i * 120)),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, animatedProgress, _) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: LinearProgressIndicator(
                                              value: animatedProgress,
                                              backgroundColor: AppColors.background.withValues(alpha: 0.5),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                isComplete ? AppColors.success : AppColors.primary,
                                              ),
                                              minHeight: 6,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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
}
