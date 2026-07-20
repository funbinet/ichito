import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

/// SQLite-backed settings repository.
/// 
/// Uses an in-memory cache for synchronous reads (backward-compatible API)
/// and writes through to SQLite for persistence. Must be initialized via
/// [initialize()] before any reads.
class SettingsRepository {
  static final SettingsRepository _instance = SettingsRepository._internal();

  /// Returns the singleton instance.
  factory SettingsRepository() => _instance;

  SettingsRepository._internal();

  final Map<String, String> _cache = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Loads all settings from SQLite into the in-memory cache.
  /// Must be called once during app startup before any reads.
  Future<void> initialize() async {
    if (_initialized) return;
    final db = await DatabaseHelper.instance.database;
    final results = await db.query('app_settings');
    for (var row in results) {
      final key = row['key'] as String;
      final value = row['value'] as String?;
      if (value != null) {
        _cache[key] = value;
      }
    }
    _initialized = true;
  }

  // ─── Private helpers ───────────────────────────────────────────

  String _getString(String key, String defaultValue) {
    return _cache[key] ?? defaultValue;
  }

  bool _getBool(String key, bool defaultValue) {
    final val = _cache[key];
    if (val == null) return defaultValue;
    return val == '1' || val == 'true';
  }

  double _getDouble(String key, double defaultValue) {
    final val = _cache[key];
    if (val == null) return defaultValue;
    return double.tryParse(val) ?? defaultValue;
  }

  int _getInt(String key, int defaultValue) {
    final val = _cache[key];
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  Future<void> _set(String key, dynamic value) async {
    final strValue = value.toString();
    _cache[key] = strValue;
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': strValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Keys ──────────────────────────────────────────────────────

  // Appearance
  static const String _themeModeKey = 'themeMode';
  static const String _accentColorKey = 'accentColor';
  static const String _cornerStyleKey = 'cornerStyle';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _fontSizeKey = 'fontSize';
  static const String _enableShadowsKey = 'enableShadows';
  static const String _shadowIntensityKey = 'shadowIntensity';
  static const String _gradientIdKey = 'gradientId';

  // Language & Format
  static const String _languageKey = 'language';
  static const String _currencyKey = 'currency';
  static const String _measurementUnitKey = 'measurementUnit';
  static const String _dateFormatKey = 'dateFormat';

  // Security
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _lockTypeKey = 'lockType';
  static const String _appPinKey = 'appPin';
  static const String _biometricEnabledKey = 'biometricEnabled';
  static const String _autoLockSecondsKey = 'autoLockSeconds';
  static const String _encryptionEnabledKey = 'encryptionEnabled';
  static const String _recoveryCodeKey = 'recoveryCode';
  static const String _dateOfBirthKey = 'dateOfBirth';

  // Preferences
  static const String _defaultViewKey = 'defaultView';
  static const String _gridDensityKey = 'gridDensity';
  static const String _autoSaveNotesKey = 'autoSaveNotes';
  static const String _autoSaveIntervalSecondsKey = 'autoSaveIntervalSeconds';
  static const String _hapticFeedbackKey = 'hapticFeedback';
  static const String _confirmDeletionsKey = 'confirmDeletions';
  static const String _showOrderNumberOnCardsKey = 'showOrderNumberOnCards';
  static const String _defaultCustomerSortKey = 'defaultCustomerSort';
  static const String _defaultOrderSortKey = 'defaultOrderSort';
  static const String _defaultNoteSortKey = 'defaultNoteSort';

  // Business
  static const String _businessNameKey = 'businessName';
  static const String _businessLocationKey = 'businessLocation';
  static const String _businessPhoneKey = 'businessPhone';
  static const String _businessEmailKey = 'businessEmail';
  static const String _defaultLaborCostKey = 'defaultLaborCost';
  static const String _taxRateKey = 'taxRate';
  static const String _orderPrefixKey = 'orderPrefix';

  // Advanced
  static const String _performanceModeKey = 'performanceMode';
  static const String _debugLoggingKey = 'debugLogging';

  // System
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _measurementSchemaKey = 'measurementSchema';

  // ─── Read Methods (synchronous from cache) ─────────────────────

  // Appearance
  String getThemeMode() => _getString(_themeModeKey, 'amoledDark');
  int? getAccentColor() {
    final val = _cache[_accentColorKey];
    if (val == null) return null;
    return int.tryParse(val);
  }
  String getCornerStyle() => _getString(_cornerStyleKey, 'rounded');
  String getFontFamily() => _getString(_fontFamilyKey, 'Roboto');
  double getFontSize() => _getDouble(_fontSizeKey, 16.0);
  bool getEnableShadows() => _getBool(_enableShadowsKey, true);
  double getShadowIntensity() => _getDouble(_shadowIntensityKey, 0.15);
  int? getGradientId() {
    final val = _cache[_gradientIdKey];
    if (val == null) return null;
    return int.tryParse(val);
  }

  // Language & Format
  String getLanguage() => _getString(_languageKey, 'english');
  String getCurrency() => _getString(_currencyKey, 'KES');
  String getMeasurementUnit() => _getString(_measurementUnitKey, 'cm');
  String getDateFormat() => _getString(_dateFormatKey, 'DD/MM/YYYY');

  // Security
  bool getAppLockEnabled() => _getBool(_appLockEnabledKey, false);
  String getLockType() => _getString(_lockTypeKey, 'pin');
  String? getAppPin() => _cache[_appPinKey];
  bool getBiometricEnabled() => _getBool(_biometricEnabledKey, false);
  int getAutoLockSeconds() => _getInt(_autoLockSecondsKey, 300);
  bool getEncryptionEnabled() => _getBool(_encryptionEnabledKey, false);
  String? getRecoveryCode() => _cache[_recoveryCodeKey];
  String? getDateOfBirth() => _cache[_dateOfBirthKey];

  // Preferences
  String getDefaultView() => _getString(_defaultViewKey, 'grid');
  int getGridDensity() => _getInt(_gridDensityKey, 8);
  bool getAutoSaveNotes() => _getBool(_autoSaveNotesKey, true);
  int getAutoSaveIntervalSeconds() => _getInt(_autoSaveIntervalSecondsKey, 3);
  bool getHapticFeedback() => _getBool(_hapticFeedbackKey, true);
  bool getConfirmDeletions() => _getBool(_confirmDeletionsKey, true);
  bool getShowOrderNumberOnCards() => _getBool(_showOrderNumberOnCardsKey, true);
  String getDefaultCustomerSort() => _getString(_defaultCustomerSortKey, 'name');
  String getDefaultOrderSort() => _getString(_defaultOrderSortKey, 'date');
  String getDefaultNoteSort() => _getString(_defaultNoteSortKey, 'newest');

  // Business
  String getBusinessName() => _getString(_businessNameKey, '');
  String getBusinessLocation() => _getString(_businessLocationKey, '');
  String getBusinessPhone() => _getString(_businessPhoneKey, '');
  String getBusinessEmail() => _getString(_businessEmailKey, '');
  double getDefaultLaborCost() => _getDouble(_defaultLaborCostKey, 1500.0);
  double getTaxRate() => _getDouble(_taxRateKey, 0.0);
  String getOrderPrefix() => _getString(_orderPrefixKey, 'ICHITO');

  // Advanced
  bool getPerformanceMode() => _getBool(_performanceModeKey, false);
  bool getDebugLogging() => _getBool(_debugLoggingKey, false);

  // System
  bool isOnboardingComplete() => _getBool(_onboardingCompleteKey, false);
  List<String> getMeasurementSchema() {
    final val = _cache[_measurementSchemaKey];
    if (val == null || val.isEmpty) return [];
    return val.split('||');
  }

  // ─── Write Methods (async, updates cache + SQLite) ─────────────

  // Appearance
  Future<void> setThemeMode(String mode) => _set(_themeModeKey, mode);
  Future<void> setAccentColor(int colorValue) => _set(_accentColorKey, colorValue);
  Future<void> setCornerStyle(String style) => _set(_cornerStyleKey, style);
  Future<void> setFontFamily(String family) => _set(_fontFamilyKey, family);
  Future<void> setFontSize(double size) => _set(_fontSizeKey, size);
  Future<void> setEnableShadows(bool enabled) => _set(_enableShadowsKey, enabled ? '1' : '0');
  Future<void> setShadowIntensity(double intensity) => _set(_shadowIntensityKey, intensity);
  Future<void> setGradientId(int? gradientId) =>
      gradientId == null ? _clearKey(_gradientIdKey) : _set(_gradientIdKey, gradientId);

  // Language & Format
  Future<void> setLanguage(String lang) => _set(_languageKey, lang);
  Future<void> setCurrency(String curr) => _set(_currencyKey, curr);
  Future<void> setMeasurementUnit(String unit) => _set(_measurementUnitKey, unit);
  Future<void> setDateFormat(String format) => _set(_dateFormatKey, format);

  // Security
  Future<void> setAppLockEnabled(bool enabled) => _set(_appLockEnabledKey, enabled ? '1' : '0');
  Future<void> setLockType(String type) => _set(_lockTypeKey, type);
  Future<void> setAppPin(String pin) => _set(_appPinKey, pin);
  Future<void> setBiometricEnabled(bool enabled) => _set(_biometricEnabledKey, enabled ? '1' : '0');
  Future<void> setAutoLockSeconds(int seconds) => _set(_autoLockSecondsKey, seconds.toString());
  Future<void> setEncryptionEnabled(bool enabled) =>
      _set(_encryptionEnabledKey, enabled ? '1' : '0');
  Future<void> setRecoveryCode(String code) => _set(_recoveryCodeKey, code);
  Future<void> setDateOfBirth(String dob) => _set(_dateOfBirthKey, dob);

  // Preferences
  Future<void> setDefaultView(String view) => _set(_defaultViewKey, view);
  Future<void> setGridDensity(int density) => _set(_gridDensityKey, density);
  Future<void> setAutoSaveNotes(bool enabled) => _set(_autoSaveNotesKey, enabled ? '1' : '0');
  Future<void> setAutoSaveIntervalSeconds(int seconds) =>
      _set(_autoSaveIntervalSecondsKey, seconds);
  Future<void> setHapticFeedback(bool enabled) => _set(_hapticFeedbackKey, enabled ? '1' : '0');
  Future<void> setConfirmDeletions(bool enabled) =>
      _set(_confirmDeletionsKey, enabled ? '1' : '0');
  Future<void> setShowOrderNumberOnCards(bool show) =>
      _set(_showOrderNumberOnCardsKey, show ? '1' : '0');
  Future<void> setDefaultCustomerSort(String sort) => _set(_defaultCustomerSortKey, sort);
  Future<void> setDefaultOrderSort(String sort) => _set(_defaultOrderSortKey, sort);
  Future<void> setDefaultNoteSort(String sort) => _set(_defaultNoteSortKey, sort);

  // Business
  Future<void> setBusinessName(String name) => _set(_businessNameKey, name);
  Future<void> setBusinessLocation(String location) => _set(_businessLocationKey, location);
  Future<void> setBusinessPhone(String phone) => _set(_businessPhoneKey, phone);
  Future<void> setBusinessEmail(String email) => _set(_businessEmailKey, email);
  Future<void> setDefaultLaborCost(double cost) => _set(_defaultLaborCostKey, cost);
  Future<void> setTaxRate(double rate) => _set(_taxRateKey, rate);
  Future<void> setOrderPrefix(String prefix) => _set(_orderPrefixKey, prefix);

  // Advanced
  Future<void> setPerformanceMode(bool enabled) =>
      _set(_performanceModeKey, enabled ? '1' : '0');
  Future<void> setDebugLogging(bool enabled) => _set(_debugLoggingKey, enabled ? '1' : '0');

  // System
  Future<void> setOnboardingComplete(bool complete) =>
      _set(_onboardingCompleteKey, complete ? '1' : '0');
  Future<void> setMeasurementSchema(List<String> schema) =>
      _set(_measurementSchemaKey, schema.join('||'));

  // ─── Batch Operations ──────────────────────────────────────────

  /// Clears a specific key from cache and database.
  Future<void> _clearKey(String key) async {
    _cache.remove(key);
    final db = await DatabaseHelper.instance.database;
    await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }

  /// Resets all settings to defaults (clears database and cache).
  Future<void> clearAll() async {
    _cache.clear();
    final db = await DatabaseHelper.instance.database;
    await db.delete('app_settings');
  }
}
