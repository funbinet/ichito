import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/theme_provider.dart';

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
        boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : [],
        border: Border.all(color: theme.borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: theme.cornerRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: theme.cornerRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final backgroundColor = isPrimary ? theme.accentColor : Colors.transparent;
    final textColor = isPrimary ? theme.onAccent : theme.accentColor;
    final borderSide = isPrimary ? BorderSide.none : BorderSide(color: theme.accentColor);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: onPressed == null ? theme.cardColor : backgroundColor,
        foregroundColor: onPressed == null ? theme.textSecondary : textColor,
        shape: RoundedRectangleBorder(
          borderRadius: theme.buttonRadius,
          side: borderSide,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: theme.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: theme.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const AdaptiveTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        obscureText: obscureText,
        style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: theme.textSecondary),
          hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: theme.accentColor) : null,
          filled: true,
          fillColor: theme.isLightMode 
              ? Colors.grey.withOpacity(0.1) 
              : Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: theme.cornerRadius,
            borderSide: BorderSide(color: theme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: theme.cornerRadius,
            borderSide: BorderSide(color: theme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: theme.cornerRadius,
            borderSide: BorderSide(color: theme.accentColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: theme.cornerRadius,
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
