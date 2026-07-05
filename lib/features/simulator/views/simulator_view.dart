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
                    Text(
                      'Rekomendasi Nabung',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Bulanan',
                      amount: formatter.format(_monthly),
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Mingguan',
                      amount: formatter.format(_weekly),
                      icon: Icons.date_range_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildResultCard(
                      title: 'Harian',
                      amount: formatter.format(_daily),
                      icon: Icons.today_rounded,
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

  Widget _buildResultCard({required String title, required String amount, required IconData icon}) {
    return Tilt(
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
                  Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
