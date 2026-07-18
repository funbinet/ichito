import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/design.dart';

class DesignCard extends StatelessWidget  {
  final Design design;
  final VoidCallback onTap;

  const DesignCard({
    super.key,
    required this.design,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.borderColor,
            width: 1,
          ),
          boxShadow: theme.enableShadows ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildImage(context, theme),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (design.category != null && design.category!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      design.category!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: theme.fontSize * 0.8,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeProvider theme) {
    if (design.imagePath != null && design.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(design.imagePath!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // Handle invalid base64 silently
      }
    }
    
    return Container(
      color: theme.accentColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.palette_outlined,
          size: 40,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
