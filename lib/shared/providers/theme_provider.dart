import 'package:flutter/material.dart';
import '../data/local/settings_repository.dart';

enum AppThemeMode { light, dark, amoledDark, system }
enum CornerStyle {
  rounded, sharp
}

class ThemeProvider extends ChangeNotifier {
  final SettingsRepository? _settings;

  AppThemeMode _themeMode = AppThemeMode.system;
  Color _accentColor = const Color(0xFFFFD700); // Default Gold
  bool _useGradients = false;
  int? _gradientId; // ID of selected gradient (null = no gradient)
  CornerStyle _cornerStyle = CornerStyle.rounded;
  String _fontFamily = 'Roboto';
  double _fontSize = 16.0;
  bool _enableShadows = true;
  double _shadowIntensity = 0.15;

  ThemeProvider({SettingsRepository? settings}) : _settings = settings;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get useGradients => _useGradients;
  int? get gradientId => _gradientId;
  CornerStyle get cornerStyle => _cornerStyle;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get enableShadows => _enableShadows;
  double get shadowIntensity => _shadowIntensity;
  bool get isLightMode => _themeMode == AppThemeMode.light;

  void loadFromSettings(String modeStr) {
    if (modeStr == 'light') {
      _themeMode = AppThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = AppThemeMode.dark;
    } else {
      _themeMode = AppThemeMode.amoledDark;
    }
    // Load gradient preference from repository
    if (_settings != null) {
      _gradientId = _settings!.getGradientId();
      _useGradients = _gradientId != null;
      _fontSize = _settings!.getFontSize();
      _fontFamily = _settings!.getFontFamily();
    }
    notifyListeners();
  }

  // Colors based on theme mode
  Color get backgroundColor {
    switch (_themeMode) {
      case AppThemeMode.light:
        return const Color(0xFFF5F5F5);
      case AppThemeMode.dark:
        return const Color(0xFF1E1E1E);
      case AppThemeMode.amoledDark:
      case AppThemeMode.system:
        return Colors.black;
    }
  }

  Color get surfaceColor {
    switch (_themeMode) {
      case AppThemeMode.amoledDark: return const Color(0xFF0A0A0A);
      case AppThemeMode.dark: return const Color(0xFF1E1E1E);
      case AppThemeMode.light: return const Color(0xFFFFFFFF);
      case AppThemeMode.system: return const Color(0xFF0A0A0A);
    }
  }

  Color get cardColor {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Colors.white;
      case AppThemeMode.dark:
        return const Color(0xFF2C2C2C);
      case AppThemeMode.amoledDark:
      case AppThemeMode.system:
        return const Color(0xFF121212);
    }
  }

  Color get textPrimary {
    return _themeMode == AppThemeMode.light ? Colors.black87 : Colors.white;
  }

  Color get textSecondary {
    return _themeMode == AppThemeMode.light ? Colors.black54 : Colors.white70;
  }

  Color get borderColor {
    return _themeMode == AppThemeMode.light ? Colors.grey.shade300 : Colors.grey.shade800;
  }

  Color get accentLight => _accentColor.withOpacity(0.15);
  Color get onAccent => _accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  // Corner definitions
  BorderRadius get cornerRadius {
    switch (_cornerStyle) {
      case CornerStyle.sharp: return BorderRadius.zero;
      case CornerStyle.rounded:
      default: return BorderRadius.circular(16);
    }
  }

  BorderRadius get buttonRadius {
    switch (_cornerStyle) {
      case CornerStyle.sharp: return BorderRadius.zero;
      case CornerStyle.rounded:
      default: return BorderRadius.circular(12);
    }
  }

  // Shadow definitions
  BoxShadow? get cardShadow {
    if (!_enableShadows) return null;
    return BoxShadow(
      color: _themeMode == AppThemeMode.light 
          ? Colors.black.withOpacity(_shadowIntensity) 
          : Colors.black.withOpacity(_shadowIntensity * 1.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    );
  }

  // Setters with notifyListeners
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    if (_accentColor != color) {
      _accentColor = color;
      notifyListeners();
    }
  }

  void setUseGradients(bool value) {
    if (_useGradients != value) {
      _useGradients = value;
      notifyListeners();
    }
  }

  /// Sets gradient ID and persists to settings.
  Future<void> setGradientId(int? gradientId) async {
    if (_gradientId != gradientId) {
      _gradientId = gradientId;
      _useGradients = gradientId != null;
      if (_settings != null) {
        await _settings!.setGradientId(gradientId);
      }
      notifyListeners();
    }
  } 

  void setCornerStyle(CornerStyle style) {
    _cornerStyle = style;
    notifyListeners();
  }

  void setFontFamily(String family) {
    if (_fontFamily != family) {
      _fontFamily = family;
      if (_settings != null) {
        _settings!.setFontFamily(family);
      }
      notifyListeners();
    }
  }

  void setFontSize(double size) {
    _fontSize = size;
    if (_settings != null) {
      _settings!.setFontSize(size);
    }
    notifyListeners();
  }

  void setShadowsEnabled(bool enabled) {
    _enableShadows = enabled;
    notifyListeners();
  }

  void setShadowIntensity(double intensity) {
    _shadowIntensity = intensity;
    notifyListeners();
  }
}
