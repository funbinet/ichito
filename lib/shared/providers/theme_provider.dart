import 'package:flutter/material.dart';

enum ThemeMode { amoledDark, dark, light }
enum CornerStyle {
  rounded, sharp, pill, notched, teardrop,
  beveled, asymmetric, cascading, soft, modern,
  classic, playful, elegant, industrial, organic
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.amoledDark;
  Color _accentColor = const Color(0xFFFFD700); // Default Gold
  CornerStyle _cornerStyle = CornerStyle.rounded;
  String _fontFamily = 'Roboto';
  double _fontSize = 16.0;
  bool _enableShadows = true;
  double _shadowIntensity = 0.15;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  CornerStyle get cornerStyle => _cornerStyle;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get enableShadows => _enableShadows;
  double get shadowIntensity => _shadowIntensity;

  // Colors based on theme mode
  Color get backgroundColor {
    switch (_themeMode) {
      case ThemeMode.amoledDark: return const Color(0xFF000000);
      case ThemeMode.dark: return const Color(0xFF121212);
      case ThemeMode.light: return const Color(0xFFF5F5F5);
    }
  }

  Color get surfaceColor {
    switch (_themeMode) {
      case ThemeMode.amoledDark: return const Color(0xFF0A0A0A);
      case ThemeMode.dark: return const Color(0xFF1E1E1E);
      case ThemeMode.light: return const Color(0xFFFFFFFF);
    }
  }

  Color get cardColor {
    switch (_themeMode) {
      case ThemeMode.amoledDark: return const Color(0xFF111111);
      case ThemeMode.dark: return const Color(0xFF242424);
      case ThemeMode.light: return const Color(0xFFFFFFFF);
    }
  }

  Color get textPrimary {
    return _themeMode == ThemeMode.light ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  Color get textSecondary {
    return _themeMode == ThemeMode.light ? const Color(0xFF666666) : const Color(0xFFAAAAAA);
  }

  Color get borderColor {
    return _themeMode == ThemeMode.light ? const Color(0xFFE0E0E0) : const Color(0xFF333333);
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
      color: _themeMode == ThemeMode.light 
          ? Colors.black.withOpacity(_shadowIntensity) 
          : Colors.black.withOpacity(_shadowIntensity * 1.5),
      blurRadius: 10,
      offset: const Offset(0, 4),
    );
  }

  // Setters with notifyListeners
  void setThemeMode(ThemeMode mode) {
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
