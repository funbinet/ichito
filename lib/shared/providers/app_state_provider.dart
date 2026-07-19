import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/local/settings_repository.dart';
import '../data/database/database_helper.dart';

class AppStateProvider extends ChangeNotifier {
  final SettingsRepository _settings = SettingsRepository();
  
  bool _isFirstLaunch = true;
  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  int _autoLockSeconds = 300; // default 5m
  bool _performanceMode = false;
  bool _debugLogging = false;
  DateTime? _lastActiveTime;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get autoLockSeconds => _autoLockSeconds;
  bool get performanceMode => _performanceMode;
  bool get debugLogging => _debugLogging;

  void initialize() {
    _isFirstLaunch = !_settings.isOnboardingComplete();
    _isAppLockEnabled = _settings.getAppLockEnabled();
    _isBiometricEnabled = _settings.getBiometricEnabled();
    _autoLockSeconds = _settings.getAutoLockSeconds();
    _performanceMode = _settings.getPerformanceMode();
    _debugLogging = _settings.getDebugLogging();
    
    if (_isAppLockEnabled) {
      _isLocked = true;
    }
    notifyListeners();
  }

  void setFirstLaunchComplete() {
    _isFirstLaunch = false;
    notifyListeners();
  }

  void setAppLockEnabled(bool enabled) {
    _isAppLockEnabled = enabled;
    if (!enabled) {
      _isLocked = false;
      _isBiometricEnabled = false;
    }
    notifyListeners();
  }

  void setBiometricEnabled(bool enabled) {
    if (_isAppLockEnabled) {
      _isBiometricEnabled = enabled;
      _settings.setBiometricEnabled(enabled);
      notifyListeners();
    }
  }

  void setAutoLockSeconds(int seconds) {
    _autoLockSeconds = seconds;
    _settings.setAutoLockSeconds(seconds);
    notifyListeners();
  }

  /// Enable/disable performance mode (reduces animations, shadows, etc.).
  Future<void> setPerformanceMode(bool enabled) async {
    _performanceMode = enabled;
    await _settings.setPerformanceMode(enabled);
    notifyListeners();
  }

  /// Enable/disable debug logging.
  Future<void> setDebugLogging(bool enabled) async {
    _debugLogging = enabled;
    await _settings.setDebugLogging(enabled);
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    _lastActiveTime = DateTime.now();
    notifyListeners();
  }

  void lock() {
    if (_isAppLockEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void updateLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lastActiveTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkAutoLock();
    }
  }

  void _checkAutoLock() {
    if (!_isAppLockEnabled || _autoLockSeconds < 0) return;
    
    if (_lastActiveTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastActiveTime!);
      
      if (difference.inSeconds >= _autoLockSeconds) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }

  /// Factory reset: clears ALL data including database, all settings, and preferences.
  /// This should only be called after user triple confirmation.
  /// After reset, the app should navigate to splash/onboarding screen.
  Future<void> factoryReset() async {
    try {
      // Clear all settings
      await _settings.clearAll();
      
      // Close and delete database
      await DatabaseHelper.instance.close();
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'ichito.db');
      await deleteDatabase(path);
      
      // Reset all in-memory state
      _isFirstLaunch = true;
      _isLocked = false;
      _isAppLockEnabled = false;
      _isBiometricEnabled = false;
      _autoLockSeconds = 300;
      _performanceMode = false;
      _debugLogging = false;
      _lastActiveTime = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during factory reset: $e');
      rethrow;
    }
  }
}
