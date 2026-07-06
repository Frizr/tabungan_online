import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import '../../../core/constants/app_colors.dart';
import '../../savings/views/widgets/looping_background.dart';
class SimulatorView extends StatefulWidget {
  const SimulatorView({super.key});

  @override
  State<SimulatorView> createState() => _SimulatorViewState();
}

class _SimulatorViewState extends State<SimulatorView> {
  // Key to force TweenAnimationBuilder restart on recalculation
  int _calcKey = 0;
  final _amountController = TextEditingController();
  
  double _durationMonths = 12.0;
  
  double? _daily;
  double? _weekly;
  double? _monthly;

  void _calculate() {
    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (amountStr.isEmpty) {
      setState(() {
        _daily = null;
        _weekly = null;
        _monthly = null;
      });
      return;
    }
    
    final amount = double.tryParse(amountStr);
    final months = _durationMonths.toInt();
    
    if (amount == null || months <= 0) return;
    
    final totalDays = months * 30;
    final totalWeeks = months * 4;
    
    setState(() {
      _daily = amount / totalDays;
      _weekly = amount / totalWeeks;
      _monthly = amount / months;
      _calcKey++;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MyKalkulator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const LoopingBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kalkulator Pintar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hitung berapa yang harus ditabung untuk mencapai target Anda.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  // Glassmorphism Card for Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Dana', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                                decoration: InputDecoration(
                                  hintText: 'Rp 0',
                                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background.withValues(alpha: 0.5),
                                ),
                                onChanged: (_) => _calculate(),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Waktu Target', style: Theme.of(context).textTheme.titleSmall),
                                  Text(
                                    '${_durationMonths.toInt()} Bulan',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: _durationMonths,
                                min: 1,
                                max: 120,
                                divisions: 119,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                                onChanged: (val) {
                                  setState(() {
                                    _durationMonths = val;
                                  });
                                  _calculate();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  if (_monthly != null) ...[
                    AnimatedOpacity(
                      opacity: _monthly != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: Text(
                        'Rekomendasi Nabung',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Bulanan',
                      rawAmount: _monthly!,
                      formatter: formatter,
                      icon: Icons.calendar_month_rounded,
                      index: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Mingguan',
                      rawAmount: _weekly!,
                      formatter: formatter,
                      icon: Icons.date_range_rounded,
                      index: 1,
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Harian',
                      rawAmount: _daily!,
                      formatter: formatter,
                      icon: Icons.today_rounded,
                      index: 2,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required double rawAmount,
    required NumberFormat formatter,
    required IconData icon,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('result_${index}_$_calcKey'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, anim, child) {
        return Opacity(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - anim)),
            child: child,
          ),
        );
      },
      child: Tilt(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primaryVariant.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      key: ValueKey('amount_${index}_$_calcKey'),
                      tween: Tween<double>(begin: 0, end: rawAmount),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          formatter.format(value),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
