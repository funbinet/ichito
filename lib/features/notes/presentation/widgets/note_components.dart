import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../data/models/note.dart';

class VerseChip extends StatelessWidget {
  final String verse;
  final bool removable;
  final VoidCallback? onRemove;
  
  const VerseChip({
    super.key,
    required this.verse,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final chipColor = const Color(0xFF9C27B0); // Purple for church
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 12, color: chipColor),
          SizedBox(width: 4),
          Text(
            verse,
            style: TextStyle(
              fontSize: theme.fontSize * 0.69,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (removable) ...[
            SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: chipColor),
            ),
          ],
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  void _showQuickActions(BuildContext context) {
    // Show quick actions bottom sheet
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress ?? () => _showQuickActions(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + title
            Row(
              children: [
                Icon(_getNoteIcon(), size: 20, color: _getNoteColor(theme)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: theme.fontSize * 0.94,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      fontFamily: theme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Content preview
            Text(
              (note.content == null || note.content!.isEmpty) ? '(No content)' : note.content!,
              style: TextStyle(fontSize: theme.fontSize * 0.81, color: theme.textSecondary, fontFamily: theme.fontFamily),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Type-specific info
            if (note.type == 'church') ...[
              SizedBox(height: 8),
              if (note.speaker != null && note.speaker!.isNotEmpty)
                Text(
                  'Speaker: ${note.speaker}'.t(context),
                  style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
              if (note.bibleVerses != null && note.bibleVerses!.isNotEmpty) ...[
                SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.bibleVerses!.map((verse) =>
                    VerseChip(verse: verse),
                  ).toList(),
                ),
              ],
            ],
            if (note.type == 'chama') ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Members: ${note.members?.length ?? 0}'.t(context),
                    style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Collected: ${language.formatCurrency(note.totalCollected ?? 0)}'.t(context),
                    style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.accentColor, fontFamily: theme.fontFamily),
                  ),
                ],
              ),
              if (note.recipient != null && note.recipient!.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  'Recipient: ${note.recipient}'.t(context),
                  style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
              ],
            ],
            // Timestamp and type badge
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNoteColor(theme).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getNoteTypeName(),
                    style: TextStyle(fontSize: theme.fontSize * 0.62, color: _getNoteColor(theme), fontFamily: theme.fontFamily),
                  ),
                ),
                const Spacer(),
                Text(
                  timeago.format(note.updatedAt),
                  style: TextStyle(fontSize: theme.fontSize * 0.69, color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getNoteIcon() {
    switch (note.type) {
      case 'church': return Icons.church_outlined;
      case 'chama': return Icons.groups_outlined;
      default: return Icons.note_outlined;
    }
  }
  
  Color _getNoteColor(ThemeProvider theme) {
    switch (note.type) {
      case 'church': return const Color(0xFF9C27B0); // Purple
      case 'chama': return const Color(0xFF4CAF50); // Green
      default: return theme.accentColor;
    }
  }
  
  String _getNoteTypeName() {
    switch (note.type) {
      case 'church': return 'Church';
      case 'chama': return 'Chama';
      default: return 'Normal';
    }
  }
}
