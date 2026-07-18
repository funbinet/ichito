import 'package:flutter/material.dart';
import '../data/local/settings_repository.dart';

class AppStateProvider extends ChangeNotifier {
  final SettingsRepository _settings = SettingsRepository();
  
  bool _isFirstLaunch = true;
  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  int _autoLockMinutes = 5;
  DateTime? _lastActiveTime;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get autoLockMinutes => _autoLockMinutes;

  void initialize() {
    _isFirstLaunch = !_settings.isOnboardingComplete();
    _isAppLockEnabled = _settings.getAppLockEnabled();
    
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
      notifyListeners();
    }
  }

  void setAutoLockMinutes(int minutes) {
    _autoLockMinutes = minutes;
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
    if (!_isAppLockEnabled || _autoLockMinutes < 0) return;
    
    if (_lastActiveTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastActiveTime!);
      
      if (difference.inMinutes >= _autoLockMinutes) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }
}
