import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  
  // Keys
  static const String _themeModeKey = 'themeMode';
  static const String _languageKey = 'language';
  static const String _currencyKey = 'currency';
  static const String _measurementUnitKey = 'measurementUnit';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _businessNameKey = 'businessName';

  Box get _box => Hive.box(_boxName);

  // Read Methods
  String getThemeMode() => _box.get(_themeModeKey, defaultValue: 'amoledDark');
  String getLanguage() => _box.get(_languageKey, defaultValue: 'english');
  String getCurrency() => _box.get(_currencyKey, defaultValue: 'KES');
  String getMeasurementUnit() => _box.get(_measurementUnitKey, defaultValue: 'cm');
  bool isOnboardingComplete() => _box.get(_onboardingCompleteKey, defaultValue: false);
  String getBusinessName() => _box.get(_businessNameKey, defaultValue: 'My Tailor Shop');

  // Write Methods
  Future<void> setThemeMode(String mode) async => await _box.put(_themeModeKey, mode);
  Future<void> setLanguage(String lang) async => await _box.put(_languageKey, lang);
  Future<void> setCurrency(String curr) async => await _box.put(_currencyKey, curr);
  Future<void> setMeasurementUnit(String unit) async => await _box.put(_measurementUnitKey, unit);
  Future<void> setOnboardingComplete(bool complete) async => await _box.put(_onboardingCompleteKey, complete);
  Future<void> setBusinessName(String name) async => await _box.put(_businessNameKey, name);
}
