import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';

class ChurchNoteEditor extends StatefulWidget {
  final Note? note;

  const ChurchNoteEditor({super.key, this.note});

  @override
  State<ChurchNoteEditor> createState() => _ChurchNoteEditorState();
}

class _ChurchNoteEditorState extends State<ChurchNoteEditor> with ThemeAwareMixin {
  final _titleController = TextEditingController();
  final _speakerController = TextEditingController();
  final _versesController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteRepository _repository = NoteRepository();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _speakerController.text = widget.note!.speaker ?? '';
      _versesController.text = widget.note!.bibleVerses?.join(', ') ?? '';
      _contentController.text = widget.note!.content ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _speakerController.dispose();
    _versesController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final bibleVerses = _versesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: 'church',
      speaker: _speakerController.text.trim().isNotEmpty ? _speakerController.text.trim() : null,
      bibleVerses: bibleVerses.isNotEmpty ? bibleVerses : null,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.note == null) {
      await _repository.createNote(note);
    } else {
      await _repository.updateNote(note);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _saveNote,
              child: Text('Save Note', style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: theme.fontSize * 1.8,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Sermon Title',
                hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildMetaField(Icons.person_outline, 'Speaker', _speakerController),
                  const Divider(height: 24),
                  _buildMetaField(Icons.menu_book_outlined, 'Bible Verses (e.g. John 3:16)', _versesController),
                ],
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize * 1.1,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write sermon notes here...',
                  hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaField(IconData icon, String hint, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9C27B0)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
