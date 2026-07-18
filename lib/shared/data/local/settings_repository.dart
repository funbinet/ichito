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

  static const String _themeModeKey = 'themeMode';
  static const String _accentColorKey = 'accentColor';
  static const String _cornerStyleKey = 'cornerStyle';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _fontSizeKey = 'fontSize';
  static const String _enableShadowsKey = 'enableShadows';
  static const String _shadowIntensityKey = 'shadowIntensity';
  static const String _languageKey = 'language';
  static const String _currencyKey = 'currency';
  static const String _measurementUnitKey = 'measurementUnit';
  static const String _dateFormatKey = 'dateFormat';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _appPinKey = 'appPin';
  static const String _measurementSchemaKey = 'measurementSchema';

  // ─── Read Methods (synchronous from cache) ─────────────────────

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

  String getLanguage() => _getString(_languageKey, 'english');
  String getCurrency() => _getString(_currencyKey, 'KES');
  String getMeasurementUnit() => _getString(_measurementUnitKey, 'cm');
  String getDateFormat() => _getString(_dateFormatKey, 'DD/MM/YYYY');
  bool isOnboardingComplete() => _getBool(_onboardingCompleteKey, false);

  bool getAppLockEnabled() => _getBool(_appLockEnabledKey, false);
  String? getAppPin() => _cache[_appPinKey];

  List<String> getMeasurementSchema() {
    final val = _cache[_measurementSchemaKey];
    if (val == null || val.isEmpty) return [];
    return val.split('||');
  }

  // ─── Write Methods (async, updates cache + SQLite) ─────────────

  Future<void> setThemeMode(String mode) => _set(_themeModeKey, mode);
  Future<void> setAccentColor(int colorValue) => _set(_accentColorKey, colorValue);
  Future<void> setCornerStyle(String style) => _set(_cornerStyleKey, style);
  Future<void> setFontFamily(String family) => _set(_fontFamilyKey, family);
  Future<void> setFontSize(double size) => _set(_fontSizeKey, size);
  Future<void> setEnableShadows(bool enabled) => _set(_enableShadowsKey, enabled ? '1' : '0');
  Future<void> setShadowIntensity(double intensity) => _set(_shadowIntensityKey, intensity);

  Future<void> setLanguage(String lang) => _set(_languageKey, lang);
  Future<void> setCurrency(String curr) => _set(_currencyKey, curr);
  Future<void> setMeasurementUnit(String unit) => _set(_measurementUnitKey, unit);
  Future<void> setDateFormat(String format) => _set(_dateFormatKey, format);
  Future<void> setOnboardingComplete(bool complete) => _set(_onboardingCompleteKey, complete ? '1' : '0');

  Future<void> setAppLockEnabled(bool enabled) => _set(_appLockEnabledKey, enabled ? '1' : '0');
  Future<void> setAppPin(String pin) => _set(_appPinKey, pin);

  Future<void> setMeasurementSchema(List<String> schema) => _set(_measurementSchemaKey, schema.join('||'));
}
