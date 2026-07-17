import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  
  // Keys
  static const String _themeModeKey = 'themeMode';
  static const String _languageKey = 'language';
  static const String _currencyKey = 'currency';
  static const String _measurementUnitKey = 'measurementUnit';
  static const String _dateFormatKey = 'dateFormat';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _businessNameKey = 'businessName';
  static const String _businessLocationKey = 'businessLocation';
  static const String _businessPhoneKey = 'businessPhone';
  static const String _businessEmailKey = 'businessEmail';
  static const String _defaultLaborCostKey = 'defaultLaborCost';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _appPinKey = 'appPin';

  Box get _box => Hive.box(_boxName);

  // Read Methods
  String getThemeMode() => _box.get(_themeModeKey, defaultValue: 'amoledDark');
  String getLanguage() => _box.get(_languageKey, defaultValue: 'english');
  String getCurrency() => _box.get(_currencyKey, defaultValue: 'KES');
  String getMeasurementUnit() => _box.get(_measurementUnitKey, defaultValue: 'cm');
  String getDateFormat() => _box.get(_dateFormatKey, defaultValue: 'DD/MM/YYYY');
  bool isOnboardingComplete() => _box.get(_onboardingCompleteKey, defaultValue: false);
  
  String getBusinessName() => _box.get(_businessNameKey, defaultValue: '');
  String getBusinessLocation() => _box.get(_businessLocationKey, defaultValue: '');
  String getBusinessPhone() => _box.get(_businessPhoneKey, defaultValue: '');
  String getBusinessEmail() => _box.get(_businessEmailKey, defaultValue: '');
  double getDefaultLaborCost() => _box.get(_defaultLaborCostKey, defaultValue: 1500.0);

  bool getAppLockEnabled() => _box.get(_appLockEnabledKey, defaultValue: false);
  String? getAppPin() => _box.get(_appPinKey);

  // Write Methods
  Future<void> setThemeMode(String mode) async => await _box.put(_themeModeKey, mode);
  Future<void> setLanguage(String lang) async => await _box.put(_languageKey, lang);
  Future<void> setCurrency(String curr) async => await _box.put(_currencyKey, curr);
  Future<void> setMeasurementUnit(String unit) async => await _box.put(_measurementUnitKey, unit);
  Future<void> setDateFormat(String format) async => await _box.put(_dateFormatKey, format);
  Future<void> setOnboardingComplete(bool complete) async => await _box.put(_onboardingCompleteKey, complete);
  
  Future<void> setBusinessName(String name) async => await _box.put(_businessNameKey, name);
  Future<void> setBusinessLocation(String loc) async => await _box.put(_businessLocationKey, loc);
  Future<void> setBusinessPhone(String phone) async => await _box.put(_businessPhoneKey, phone);
  Future<void> setBusinessEmail(String email) async => await _box.put(_businessEmailKey, email);
  Future<void> setDefaultLaborCost(double cost) async => await _box.put(_defaultLaborCostKey, cost);

  Future<void> setAppLockEnabled(bool enabled) async => await _box.put(_appLockEnabledKey, enabled);
  Future<void> setAppPin(String pin) async => await _box.put(_appPinKey, pin);
}
