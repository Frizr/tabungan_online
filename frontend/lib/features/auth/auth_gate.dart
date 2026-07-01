import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabungan_frontend/core/providers/auth_provider.dart';
import 'package:tabungan_frontend/features/dashboard/dashboard_screen.dart';
import 'package:tabungan_frontend/core/models/user_model.dart';
import 'package:tabungan_frontend/core/repositories/user_repository.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAndSignIn();
  }

  Future<void> _checkAndSignIn() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.signInAnonymously();
    if (user != null) {
      // Check if user document exists, if not create one
      final userRepo = ref.read(userRepositoryProvider);
      // Wait a short delay to let stream build
      Future.delayed(const Duration(milliseconds: 500), () async {
        final existingUserSub = userRepo.getUser(user.uid).listen((userData) async {
          if (userData == null) {
            // Create user
            final newUser = UserModel(
              id: user.uid,
              name: 'Nasabah',
              email: 'anonymous@tabungan.online',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await userRepo.createUser(newUser);
          }
        });
        // cancel the subscription after a second since we only needed one check
        Future.delayed(const Duration(seconds: 2), () => existingUserSub.cancel());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Logged in, show the app!
          return DashboardScreen();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, trace) => Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }
}
