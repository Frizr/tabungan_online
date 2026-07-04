import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SettingsState {
  final bool isBiometricEnabled;
  final bool isBiometricSupported;

  const SettingsState({
    this.isBiometricEnabled = false,
    this.isBiometricSupported = false,
  });

  SettingsState copyWith({
    bool? isBiometricEnabled,
    bool? isBiometricSupported,
  }) {
    return SettingsState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricSupported: isBiometricSupported ?? this.isBiometricSupported,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricKey = 'use_biometric';

  @override
  SettingsState build() {
    _init();
    return const SettingsState();
  }

  Future<void> _init() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_biometricKey) ?? false;
      
      state = state.copyWith(
        isBiometricSupported: isSupported && canCheck,
        isBiometricEnabled: isEnabled,
      );
    } catch (e) {
      // Ignored
    }
  }

  Future<bool> setBiometricEnabled(bool value) async {
    if (value) {
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: 'Verifikasi sidik jari/FaceID untuk mengaktifkan',
        );
        if (!didAuthenticate) return false;
      } catch (e) {
        return false;
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
    state = state.copyWith(isBiometricEnabled: value);
    return true;
  }

  Future<bool> authenticate() async {
    if (!state.isBiometricEnabled) return true;
    try {
      return await _auth.authenticate(
        localizedReason: 'Silakan verifikasi untuk membuka TabunganKu',
      );
    } catch (e) {
      return false;
    }
  }
}

final settingsControllerProvider = NotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});

