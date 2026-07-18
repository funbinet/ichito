import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';

class ChamaNoteEditor extends StatefulWidget {
  final Note? note;

  const ChamaNoteEditor({super.key, this.note});

  @override
  State<ChamaNoteEditor> createState() => _ChamaNoteEditorState();
}

class _ChamaNoteEditorState extends State<ChamaNoteEditor> with ThemeAwareMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _recipientController = TextEditingController();
  final _expectedTotalController = TextEditingController();
  
  final NoteRepository _repository = NoteRepository();
  bool _isSaving = false;
  
  DateTime _meetingDate = DateTime.now();
  Map<String, double> _contributions = {}; // memberName: amount

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content ?? '';
      _recipientController.text = widget.note!.recipient ?? '';
      _expectedTotalController.text = widget.note!.expectedTotal?.toString() ?? '';
      _meetingDate = widget.note!.meetingDate ?? DateTime.now();
      
      if (widget.note!.contributions != null) {
        widget.note!.contributions!.forEach((k, v) {
          _contributions[k] = (v as num).toDouble();
        });
      }
    } else {
      _titleController.text = 'Meeting - ${_meetingDate.day}/${_meetingDate.month}/${_meetingDate.year}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recipientController.dispose();
    _expectedTotalController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    double totalCollected = _contributions.values.fold(0, (sum, val) => sum + val);

    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: 'chama',
      meetingDate: _meetingDate,
      members: _contributions.keys.toList(),
      contributions: _contributions,
      totalCollected: totalCollected,
      expectedTotal: double.tryParse(_expectedTotalController.text.trim()),
      recipient: _recipientController.text.trim().isNotEmpty ? _recipientController.text.trim() : null,
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

  void _addContribution() {
    String name = '';
    String amount = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Add Contribution', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Member Name'),
              style: TextStyle(color: theme.textPrimary),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: theme.textPrimary),
              onChanged: (v) => amount = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                setState(() {
                  _contributions[name.trim()] = double.tryParse(amount) ?? 0;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCollected = _contributions.values.fold(0, (sum, val) => sum + val);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: theme.fontSize * 1.5,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Meeting Title',
                hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            
            // Meta Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildMetaField(Icons.calendar_today, 'Date', '${_meetingDate.day}/${_meetingDate.month}/${_meetingDate.year}', onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _meetingDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _meetingDate = date);
                    }
                  }),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _recipientController,
                          style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Recipient (Who receives today?)',
                            hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 20, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _expectedTotalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Expected Total Amount',
                            hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contributions',
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: theme.fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addContribution,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF4CAF50)),
                )
              ],
            ),
            const SizedBox(height: 8),
            
            if (_contributions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No contributions yet',
                    style: TextStyle(color: theme.textSecondary),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contributions.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.borderColor),
                  itemBuilder: (context, index) {
                    final key = _contributions.keys.elementAt(index);
                    final val = _contributions[key];
                    return ListTile(
                      title: Text(key, style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            val.toString(),
                            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                _contributions.remove(key);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total Collected: ',
                  style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                ),
                Text(
                  totalCollected.toString(),
                  style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: theme.fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'Meeting Minutes / Notes',
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: theme.fontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.borderColor),
                borderRadius: BorderRadius.circular(12),
                color: theme.cardColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write notes here...',
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

  Widget _buildMetaField(IconData icon, String hint, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            ),
          ),
          if (onTap != null)
            Icon(Icons.edit, size: 16, color: theme.textSecondary),
        ],
      ),
    );
  }
}
