import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> with ThemeAwareMixin, SingleTickerProviderStateMixin {
  final NoteRepository _repository = NoteRepository();
  late TabController _tabController;
  
  List<Note> _allNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _repository.getAllNotes();
    setState(() {
      _allNotes = notes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.accentColor,
          unselectedLabelColor: theme.textSecondary,
          indicatorColor: theme.accentColor,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Church'),
            Tab(text: 'Chama'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.accentColor))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildNotesList('normal'),
              _buildNotesList('church'),
              _buildNotesList('chama'),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        backgroundColor: theme.accentColor,
        foregroundColor: theme.onAccent,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Widget _buildNotesList(String type) {
    final filtered = _allNotes.where((n) => n.type == type).toList();
    
    if (filtered.isEmpty) {
      return Center(
        child: Text('No $type notes found.', style: subtitleStyle),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final note = filtered[index];
        return Card(
          color: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
          child: ListTile(
            title: Text(note.title, style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(
              note.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle,
            ),
            trailing: Text(lang.formatDate(note.updatedAt), style: subtitleStyle.copyWith(fontSize: 10)),
            onTap: () {
              // Navigate to note detail
            },
          ),
        );
      },
    );
  }

  void _showAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: theme.cornerRadius.topLeft)),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Create Note', style: headingStyle),
              ),
              ListTile(
                leading: Icon(Icons.note_alt_outlined, color: theme.accentColor),
                title: const Text('General Note'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.church_outlined, color: theme.accentColor),
                title: const Text('Church Sermon'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.group_outlined, color: theme.accentColor),
                title: const Text('Chama Meeting'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
