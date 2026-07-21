import 'package:ichito/shared/providers/language_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../mixins/theme_aware_mixin.dart';

class SquareAvatar extends StatefulWidget {
  final double size;
  final String? base64Image;
  final IconData? fallbackIcon;
  final String? fallbackText;
  final bool isCircular;

  const SquareAvatar({
    super.key,
    this.size = 64.0,
    this.base64Image,
    this.fallbackIcon,
    this.fallbackText,
    this.isCircular = false,
  });

  @override
  State<SquareAvatar> createState() => _SquareAvatarState();
}

class _SquareAvatarState extends State<SquareAvatar> with ThemeAwareMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: theme.accentLight,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget.isCircular ? null : theme.cornerRadius, // Follows system corner style
        border: Border.all(
          color: theme.borderColor, // Thin outline
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.base64Image != null && widget.base64Image!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(widget.base64Image!),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // Fallback if decoding fails
      }
    }
    
    if (widget.fallbackIcon != null) {
      return Icon(
        widget.fallbackIcon,
        size: widget.size * 0.5,
        color: theme.accentColor,
      );
    }
    
    if (widget.fallbackText != null && widget.fallbackText!.isNotEmpty) {
      return Center(
        child: Text(
          widget.fallbackText!.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: theme.accentColor,
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
            fontFamily: theme.fontFamily,
          ),
        ),
      );
    }
    
    return Icon(
      Icons.person_outline,
      size: widget.size * 0.5,
      color: theme.accentColor,
    );
  }
}
