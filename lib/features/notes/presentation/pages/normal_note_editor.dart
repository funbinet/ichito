import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';

class NormalNoteEditor extends StatefulWidget {
  final Note? note;

  const NormalNoteEditor({super.key, this.note});

  @override
  State<NormalNoteEditor> createState() => _NormalNoteEditorState();
}

class _NormalNoteEditorState extends State<NormalNoteEditor> with ThemeAwareMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteRepository _repository = NoteRepository();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: 'normal',
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
            Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _saveNote,
              child: Text('Save Note'.t(context), style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: theme.fontSize * 2,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Title'.t(context),
                hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 16),
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
                  hintText: 'Start typing...'.t(context),
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
}
