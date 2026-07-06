import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tabungan_frontend/core/constants/app_colors.dart';

/// Ambient animated background with slowly drifting gold orbs.
/// Uses a single AnimationController driving sin/cos offsets at
/// different phases for an organic, non-repetitive feel.
class LoopingBackground extends StatefulWidget {
  const LoopingBackground({super.key});

  @override
  State<LoopingBackground> createState() => _LoopingBackgroundState();
}

class _LoopingBackgroundState extends State<LoopingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Each orb has: baseLeft, baseTop, size, baseOpacity,
  //               driftRadius, speedMultiplier, phaseOffset
  static const _orbs = [
    _OrbConfig(
      baseLeft: -30,
      baseTop: 20,
      size: 350,
      baseOpacity: 0.15,
      driftRadius: 20,
      speedX: 1.0,
      speedY: 0.7,
      phaseX: 0.0,
      phaseY: 0.5,
    ),
    _OrbConfig(
      baseLeft: -70,   // will be positioned from right via alignment trick
      baseTop: -30,    // will be positioned from bottom
      size: 400,
      baseOpacity: 0.12,
      driftRadius: 25,
      speedX: 0.6,
      speedY: 1.0,
      phaseX: 2.0,
      phaseY: 1.2,
      anchorRight: true,
      anchorBottom: true,
    ),
    _OrbConfig(
      baseLeft: 0,  // centered — computed dynamically
      baseTop: 0,
      size: 300,
      baseOpacity: 0.08,
      driftRadius: 18,
      speedX: 0.8,
      speedY: 0.9,
      phaseX: 4.0,
      phaseY: 3.5,
      centered: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: AppColors.background,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2.0 * math.pi; // 0 → 2π
            final screenW = MediaQuery.of(context).size.width;
            final screenH = MediaQuery.of(context).size.height;

            return Stack(
              children: _orbs.map((orb) {
                // Compute drift offsets using sin/cos with unique speeds & phases
                final dx = math.sin(t * orb.speedX + orb.phaseX) * orb.driftRadius;
                final dy = math.cos(t * orb.speedY + orb.phaseY) * orb.driftRadius;

                // Breathing opacity: subtle ±20% pulse at a slow rate
                final opacityPulse = 1.0 + 0.2 * math.sin(t * 0.5 + orb.phaseX);
                final opacity = (orb.baseOpacity * opacityPulse).clamp(0.0, 1.0);

                // Compute base position
                double left;
                double top;

                if (orb.centered) {
                  left = screenW / 2 - orb.size / 2 - 50;
                  top = screenH / 3 - 50;
                } else if (orb.anchorRight && orb.anchorBottom) {
                  left = screenW + orb.baseLeft - orb.size;
                  top = screenH + orb.baseTop - orb.size;
                } else {
                  left = orb.baseLeft;
                  top = orb.baseTop;
                }

                return Positioned(
                  left: left + dx,
                  top: top + dy,
                  child: _Orb(opacity: opacity, size: orb.size),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// Stateless orb widget — only rebuilds when opacity/size change.
class _Orb extends StatelessWidget {
  const _Orb({required this.opacity, required this.size});
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: opacity),
              AppColors.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration data for a single orb.
class _OrbConfig {
  const _OrbConfig({
    required this.baseLeft,
    required this.baseTop,
    required this.size,
    required this.baseOpacity,
    required this.driftRadius,
    required this.speedX,
    required this.speedY,
    required this.phaseX,
    required this.phaseY,
    this.anchorRight = false,
    this.anchorBottom = false,
    this.centered = false,
  });

  final double baseLeft;
  final double baseTop;
  final double size;
  final double baseOpacity;
  final double driftRadius;
  final double speedX;
  final double speedY;
  final double phaseX;
  final double phaseY;
  final bool anchorRight;
  final bool anchorBottom;
  final bool centered;
}
