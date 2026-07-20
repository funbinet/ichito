import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../shared/data/local/settings_repository.dart';

class SecurityService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SettingsRepository _settings = SettingsRepository();

  static const String _pinKey = 'user_pin_hash';
  static const String _securityKeyKey = 'security_key_hash';
  static const String _recoveryDateKey = 'recovery_date_hash';

  // Hashing method
  String _hashData(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Setup PIN/Password
  Future<void> setupSecurity(String pin, String securityKey, String recoveryDate) async {
    await _secureStorage.write(key: _pinKey, value: _hashData(pin));
    await _secureStorage.write(key: _securityKeyKey, value: _hashData(securityKey));
    await _secureStorage.write(key: _recoveryDateKey, value: _hashData(recoveryDate));
    
    await _settings.setAppLockEnabled(true);
  }
  
  // Update PIN/Password
  Future<void> updatePin(String newPin) async {
    await _secureStorage.write(key: _pinKey, value: _hashData(newPin));
  }

  Future<void> setPin(String pin) async {
    await updatePin(pin);
    await _settings.setAppLockEnabled(true);
  }

  // Verify PIN/Password
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;
    return storedHash == _hashData(pin);
  }

  // Verify Security Key
  Future<bool> verifySecurityKey(String securityKey) async {
    final storedHash = await _secureStorage.read(key: _securityKeyKey);
    if (storedHash == null) return false;
    return storedHash == _hashData(securityKey);
  }
  
  // Verify Recovery Date
  Future<bool> verifyRecoveryDate(String recoveryDate) async {
    final storedHash = await _secureStorage.read(key: _recoveryDateKey);
    if (storedHash == null) return false;
    return storedHash == _hashData(recoveryDate);
  }

  // Verify full recovery
  Future<bool> verifyRecoveryCode(String code, String dob) async {
    return await verifySecurityKey(code) && await verifyRecoveryDate(dob);
  }

  // Setup Recovery Info Only
  Future<void> setupRecoveryInfo(String code, String dob) async {
    await _secureStorage.write(key: _securityKeyKey, value: _hashData(code));
    await _secureStorage.write(key: _recoveryDateKey, value: _hashData(dob));
  }

  // Biometrics
  Future<bool> canUseBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return canCheck || isSupported;
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    if (!await canUseBiometrics()) return false;
    
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }

  // Clear Security (for Factory Reset)
  Future<void> clearSecurity() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _securityKeyKey);
    await _secureStorage.delete(key: _recoveryDateKey);
    await _settings.setAppLockEnabled(false);
    await _settings.setBiometricEnabled(false);
  }
  
  Future<bool> isSecuritySetup() async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    return storedHash != null;
  }
}
