import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      dev.log('Error checking biometric availability: $e', name: 'BiometricService');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      dev.log('Error getting available biometrics: $e', name: 'BiometricService');
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({String reason = 'Please authenticate to unlock the app'}) async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fallback to pin/pattern if biometrics fail or not available
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      dev.log('Error during authentication: $e', name: 'BiometricService');
      return false;
    }
  }
}
