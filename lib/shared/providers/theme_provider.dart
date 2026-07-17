import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, amoledDark }
enum CornerStyle {
  rounded, sharp, pill, notched, teardrop,
  beveled, asymmetric, cascading, soft, modern,
  classic, playful, elegant, industrial, organic
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.amoledDark;
  Color _accentColor = const Color(0xFFFFD700); // Default Gold
  CornerStyle _cornerStyle = CornerStyle.rounded;
  String _fontFamily = 'Roboto';
  double _fontSize = 16.0;
  bool _enableShadows = true;
  double _shadowIntensity = 0.15;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  CornerStyle get cornerStyle => _cornerStyle;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get enableShadows => _enableShadows;
  double get shadowIntensity => _shadowIntensity;

  void loadFromSettings(String modeStr) {
    if (modeStr == 'light') {
      _themeMode = AppThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = AppThemeMode.dark;
    } else {
      _themeMode = AppThemeMode.amoledDark;
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
        return Colors.black;
    }
  }

  Color get surfaceColor {
    switch (_themeMode) {
      case AppThemeMode.amoledDark: return const Color(0xFF0A0A0A);
      case AppThemeMode.dark: return const Color(0xFF1E1E1E);
      case AppThemeMode.light: return const Color(0xFFFFFFFF);
    }
  }

  Color get cardColor {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Colors.white;
      case AppThemeMode.dark:
        return const Color(0xFF2C2C2C);
      case AppThemeMode.amoledDark:
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
      case CornerStyle.rounded: return BorderRadius.circular(12);
      case CornerStyle.sharp: return BorderRadius.zero;
      case CornerStyle.pill: return BorderRadius.circular(50);
      case CornerStyle.notched:
        // Requires custom path/clipper for true notched, using beveled as fallback in BorderRadius
        return BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(16));
      case CornerStyle.teardrop:
        return BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(4));
      case CornerStyle.beveled:
        return BorderRadius.circular(12); // Best effort without CustomPainter
      case CornerStyle.asymmetric:
        return BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(24));
      case CornerStyle.cascading:
        return BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(8));
      case CornerStyle.soft: return BorderRadius.circular(16);
      case CornerStyle.modern: return BorderRadius.circular(8);
      case CornerStyle.classic: return BorderRadius.circular(4);
      case CornerStyle.playful: return BorderRadius.circular(20);
      case CornerStyle.elegant: return BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12));
      case CornerStyle.industrial: return BorderRadius.zero;
      case CornerStyle.organic: return BorderRadius.circular(24);
    }
  }

  BorderRadius get buttonRadius {
    switch (_cornerStyle) {
      case CornerStyle.pill: return BorderRadius.circular(50);
      case CornerStyle.sharp: return BorderRadius.zero;
      default: return BorderRadius.circular(8);
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
    _accentColor = color;
    notifyListeners();
  }

  void setCornerStyle(CornerStyle style) {
    _cornerStyle = style;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
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
