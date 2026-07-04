import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';

class LoopingBackground extends StatefulWidget {
  const LoopingBackground({super.key});

  @override
  State<LoopingBackground> createState() => _LoopingBackgroundState();
}

class _LoopingBackgroundState extends State<LoopingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value * 2 * pi;
          
          return Stack(
            children: [
              Positioned(
                left: -100 + sin(value) * 70,
                top: -50 + cos(value) * 70,
                child: _buildOrb(opacity: 0.15, size: 350),
              ),
              Positioned(
                right: -150 + cos(value) * 80,
                bottom: -50 + sin(value) * 80,
                child: _buildOrb(opacity: 0.12, size: 400),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 150 + cos(value + pi) * 50,
                top: MediaQuery.of(context).size.height / 3 + sin(value + pi) * 50,
                child: _buildOrb(opacity: 0.08, size: 300),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrb({required double opacity, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: opacity),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

