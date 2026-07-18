import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';

class NoteTypeSelectorDialog extends StatelessWidget {
  const NoteTypeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'What type of note?',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _buildTypeOption(
              context,
              theme,
              lang.t('normal_note') ?? 'Normal Note',
              'General notes and reminders',
              Icons.note_outlined,
              theme.accentColor,
              () => Navigator.pop(context, 'normal'),
            ),
            const Divider(height: 1),
            _buildTypeOption(
              context,
              theme,
              lang.t('church_note') ?? 'Church Note',
              'Sermon notes and Bible study',
              Icons.church_outlined,
              const Color(0xFF9C27B0),
              () => Navigator.pop(context, 'church'),
            ),
            const Divider(height: 1),
            _buildTypeOption(
              context,
              theme,
              lang.t('chama_note') ?? 'Chama Note',
              'Group savings meeting records',
              Icons.groups_outlined,
              const Color(0xFF4CAF50),
              () => Navigator.pop(context, 'chama'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(BuildContext context, ThemeProvider theme, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontSize: theme.fontSize * 1.1,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontSize: theme.fontSize * 0.9,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }
}
