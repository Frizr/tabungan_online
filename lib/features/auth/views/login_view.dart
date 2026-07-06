import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../repositories/auth_repository.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  late AnimationController _animationController;

  // Staggered fade animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _emailFade;
  late Animation<double> _emailSlide;
  late Animation<double> _passwordFade;
  late Animation<double> _passwordSlide;
  late Animation<double> _buttonFade;
  late Animation<double> _buttonScale;
  late Animation<double> _toggleFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Logo: fade + scale 0.8→1.0 (0.0 - 0.3)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );

    // Title: fade + slide up (0.15 - 0.45)
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic)),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic)),
    );

    // Subtitle: fade (0.25 - 0.55)
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic)),
    );

    // Email field: fade + slide up 20px (0.35 - 0.65)
    _emailFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic)),
    );
    _emailSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic)),
    );

    // Password field: fade + slide up 20px (0.45 - 0.75)
    _passwordFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)),
    );
    _passwordSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic)),
    );

    // Button: fade + scale 0.9→1.0 (0.6 - 0.9)
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)),
    );
    _buttonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)),
    );

    // Toggle text: fade (0.7 - 1.0)
    _toggleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic)),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      if (_isLogin) {
        await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await auth.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo: fade + scale
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset('assets/images/logo.jpg', width: 100, height: 100),
                  ),
                ),
                const SizedBox(height: 24),

                // Title: fade + slide up
                AnimatedBuilder(
                  animation: _titleSlide,
                  builder: (context, child) => FadeTransition(
                    opacity: _titleFade,
                    child: Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: child,
                    ),
                  ),
                  child: Text(
                    'MyTabungan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primaryVariant,
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle: fade only
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    'Kelola masa depan finansial Anda dengan elegan.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 64),

                // Email field: fade + slide up
                AnimatedBuilder(
                  animation: _emailSlide,
                  builder: (context, child) => FadeTransition(
                    opacity: _emailFade,
                    child: Transform.translate(
                      offset: Offset(0, _emailSlide.value),
                      child: child,
                    ),
                  ),
                  child: _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // Password field: fade + slide up
                AnimatedBuilder(
                  animation: _passwordSlide,
                  builder: (context, child) => FadeTransition(
                    opacity: _passwordFade,
                    child: Transform.translate(
                      offset: Offset(0, _passwordSlide.value),
                      child: child,
                    ),
                  ),
                  child: _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Button: fade + scale with AnimatedSwitcher for text
                FadeTransition(
                  opacity: _buttonFade,
                  child: ScaleTransition(
                    scale: _buttonScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryVariant],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isLoading ? null : _submit,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.background,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) => FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                    child: Text(
                                      _isLogin ? 'Masuk' : 'Daftar',
                                      key: ValueKey<bool>(_isLogin),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppColors.background,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle text: fade
                FadeTransition(
                  opacity: _toggleFade,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    child: Text(
                      _isLogin
                          ? 'Belum punya akun? Daftar di sini'
                          : 'Sudah punya akun? Masuk di sini',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primaryVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
