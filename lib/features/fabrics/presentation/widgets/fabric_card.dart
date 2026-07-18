import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../data/models/fabric.dart';

class FabricCard extends StatelessWidget  {
  final Fabric fabric;
  final VoidCallback onTap;

  const FabricCard({
    super.key,
    required this.fabric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    
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
                    fabric.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        lang.formatCurrency(fabric.pricePerUnit),
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                          fontSize: theme.fontSize * 0.9,
                        ),
                      ),
                      Text(
                        ' / ${fabric.unit}',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          color: theme.textSecondary,
                          fontSize: theme.fontSize * 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeProvider theme) {
    if (fabric.imagePath != null && fabric.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(fabric.imagePath!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // invalid base64
      }
    }
    
    return Container(
      color: theme.accentColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.texture_outlined,
          size: 40,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
