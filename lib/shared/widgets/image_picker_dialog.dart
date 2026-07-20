import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// A centered popup dialog that lets the user choose between
/// taking a photo with the camera or selecting from the gallery.
/// 
/// Returns 'camera' or 'gallery' as a string, or null if dismissed.
class ImagePickerDialog extends StatelessWidget {
  const ImagePickerDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const ImagePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Photo'.t(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Select a source for your profile photo'.t(context),
              style: TextStyle(
                fontSize: 13,
                color: theme.textSecondary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _OptionCard(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera'.t(context),
                    onTap: () => Navigator.pop(context, 'camera'),
                    theme: theme,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _OptionCard(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery'.t(context),
                    onTap: () => Navigator.pop(context, 'gallery'),
                    theme: theme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                'Cancel'.t(context),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeProvider theme;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.accentLight,
          borderRadius: theme.cornerRadius,
          border: Border.all(color: theme.accentColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.accentColor, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
