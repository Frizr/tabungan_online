import 'package:flutter/material.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';

class LoopingBackground extends StatelessWidget {
  const LoopingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned(
            left: -100 + 70, // Static position instead of sin()
            top: -50 + 70, // Static position instead of cos()
            child: _buildOrb(opacity: 0.15, size: 350),
          ),
          Positioned(
            right: -150 + 80, // Static position
            bottom: -50 + 80, // Static position
            child: _buildOrb(opacity: 0.12, size: 400),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 150 - 50, // Static position
            top: MediaQuery.of(context).size.height / 3 - 50, // Static position
            child: _buildOrb(opacity: 0.08, size: 300),
          ),
        ],
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


