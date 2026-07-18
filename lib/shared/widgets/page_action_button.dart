import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PageActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PageActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Positioned(
      bottom: 100, // Just above the radial menu
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: theme.enableShadows
                ? [
                    BoxShadow(
                      color: theme.accentColor.withOpacity(theme.shadowIntensity),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: ElevatedButton.icon(
            icon: Icon(icon, size: 20),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: theme.onAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0, // Handled by container shadow for color matching
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
