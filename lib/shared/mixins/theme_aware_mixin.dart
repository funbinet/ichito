import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

mixin ThemeAwareMixin<T extends StatefulWidget> on State<T> {
  late ThemeProvider theme;
  late LanguageProvider lang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of<ThemeProvider>(context);
    lang = Provider.of<LanguageProvider>(context);
  }

  TextStyle get headingStyle => TextStyle(
    fontFamily: theme.fontFamily,
    fontSize: theme.fontSize * 1.5,
    fontWeight: FontWeight.bold,
    color: theme.textPrimary,
  );

  TextStyle get bodyStyle => TextStyle(
    fontFamily: theme.fontFamily,
    fontSize: theme.fontSize,
    color: theme.textPrimary,
  );

  TextStyle get subtitleStyle => TextStyle(
    fontFamily: theme.fontFamily,
    fontSize: theme.fontSize * 0.875,
    color: theme.textSecondary,
  );
}
