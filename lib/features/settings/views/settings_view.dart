import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../../core/constants/app_colors.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                  title: const Text('Kunci dengan Biometrik', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text(
                    settingsState.isBiometricSupported
                        ? 'Gunakan sidik jari atau FaceID untuk membuka aplikasi'
                        : 'Perangkat tidak mendukung biometrik',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: settingsState.isBiometricEnabled,
                    onChanged: settingsState.isBiometricSupported
                        ? (value) async {
                            final success = await settingsNotifier.setBiometricEnabled(value);
                            if (!success && context.mounted && value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Autentikasi gagal atau dibatalkan')),
                              );
                            }
                          }
                        : null,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const Divider(color: AppColors.background, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text('Keluar (Logout)', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Keluar', style: TextStyle(color: AppColors.textPrimary)),
                        content: const Text('Apakah Anda yakin ingin keluar dari TabunganKu?', style: TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close settings
                              ref.read(authRepositoryProvider).signOut();
                            },
                            child: const Text('Keluar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
