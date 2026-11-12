import 'package:flutter/foundation.dart' show debugPrint;
import 'package:local_auth/local_auth.dart';

/// Service wrapping LocalAuthentication (local_auth 3.0.1).
///
/// IMPORTANT: local_auth 3.0.0+ uses [LocalAuthException] — NOT [PlatformException].
/// Never catch PlatformException from local_auth calls.
class BiometricService {
  BiometricService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  /// Returns true if the device supports biometrics or device credential auth.
  Future<bool> canAuthenticate() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isSupported;
    } on LocalAuthException catch (e) {
      debugPrint(
        '[BiometricService.canAuthenticate] LocalAuthException: ${e.code}',
      );
      return false;
    } catch (e) {
      debugPrint('[BiometricService.canAuthenticate] unexpected: $e');
      return false;
    }
  }

  /// Performs the biometric authentication prompt.
  ///
  /// Returns true if authenticated, false if cancelled or failed.
  /// Catches [LocalAuthException] (3.0.x API) — never [PlatformException].
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on LocalAuthException catch (e) {
      debugPrint(
        '[BiometricService.authenticate] LocalAuthException: ${e.code}',
      );
      return false;
    } catch (e) {
      debugPrint('[BiometricService.authenticate] unexpected: $e');
      return false;
    }
  }
}
