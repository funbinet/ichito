import 'package:flutter/material.dart';
import '../mixins/theme_aware_mixin.dart';

class ThemedLogo extends StatefulWidget {
  final double size;
  final Color? color;
  const ThemedLogo({Key? key, this.size = 40.0, this.color}) : super(key: key);

  @override
  State<ThemedLogo> createState() => _ThemedLogoState();
}

class _ThemedLogoState extends State<ThemedLogo> with ThemeAwareMixin {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_white.png',
      width: widget.size,
      height: widget.size,
      color: widget.color ?? theme.accentColor,
    );
  }
}
