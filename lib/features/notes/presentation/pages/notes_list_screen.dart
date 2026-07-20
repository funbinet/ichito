import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';
import '../widgets/note_components.dart';
import '../widgets/note_type_selector_dialog.dart';
import 'normal_note_editor.dart';
import 'church_note_editor.dart';
import 'chama_note_editor.dart';
import '../../../../shared/widgets/page_action_button.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';

enum ViewMode { grid, list }
enum NoteSortOption { newest, oldest, titleAsc, titleDesc }

class NoteFilter {
  final String label;
  final String value;
  NoteFilter(this.label, this.value);
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> with ThemeAwareMixin, NavigationMixin {
  final NoteRepository _repository = NoteRepository();
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();
  NoteSortOption _sortOption = NoteSortOption.newest;
  ViewMode _viewMode = ViewMode.list;
  
  final List<NoteFilter> _filters = [
    NoteFilter('All', 'all'),
    NoteFilter('Normal', 'normal'),
    NoteFilter('Church', 'church'),
    NoteFilter('Chama', 'chama'),
  ];
  NoteFilter _activeFilter = NoteFilter('All', 'all');

  @override
  void initState() {
    super.initState();
    _activeFilter = _filters.first;
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _repository.getAllNotes();
    setState(() {
      _allNotes = notes;
      _isLoading = false;
    });
    _applyFilterAndSort();
  }

  void _onSearchChanged(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text == query) {
        _applyFilterAndSort();
      }
    });
  }

  void _applyFilterAndSort() {
    final query = _searchController.text.toLowerCase();
    
    List<Note> temp = _allNotes.where((n) {
      bool matchesSearch = n.title.toLowerCase().contains(query) || (n.content?.toLowerCase().contains(query) ?? false);
      if (!matchesSearch) return false;
      
      if (_activeFilter.value == 'all') return true;
      return n.type.toLowerCase() == _activeFilter.value;
    }).toList();

    temp.sort((a, b) {
      switch (_sortOption) {
        case NoteSortOption.newest:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSortOption.oldest:
          return a.updatedAt.compareTo(b.updatedAt);
        case NoteSortOption.titleAsc:
          return a.title.compareTo(b.title);
        case NoteSortOption.titleDesc:
          return b.title.compareTo(a.title);
      }
    });

    setState(() {
      _filteredNotes = temp;
    });
  }

  void _showAddNoteSheet() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => const NoteTypeSelectorDialog(),
    );
    
    if (type != null) {
      _navigateToEditor(type, null);
    }
  }

  void _navigateToEditor(String type, Note? note) async {
    Widget page;
    switch (type) {
      case 'church':
        page = ChurchNoteEditor(note: note);
        break;
      case 'chama':
        page = ChamaNoteEditor(note: note);
        break;
      default:
        page = NormalNoteEditor(note: note);
        break;
    }

    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    if (result == true) {
      _loadNotes();
    }
  }
  
  void _deleteNoteWithAuth(Note note) {
    showDialog(
      context: context,
      builder: (context) => AuthDeleteDialog(
        itemName: note.title,
        securityService: SecurityService(),
        onDelete: () async {
          await _repository.deleteNote(note.id!);
          _loadNotes();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(lang.t('notes'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
      ),
      pageActionButton: PageActionButton(
        label: lang.t('create_note'),
        icon: Icons.note_add_outlined,
        onPressed: _showAddNoteSheet,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildSortControls(),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: theme.accentColor))
              : _filteredNotes.isEmpty 
                ? _buildEmptyState() 
                : _buildNotesList(),
          ),
          SizedBox(height: 80), // Padding for RadialMenu
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: AdaptiveTextField(
        label: '',
        hint: 'Search notes...'.t(context),
        prefixIcon: Icons.search,
        controller: _searchController,
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) =>
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label, style: TextStyle(color: _activeFilter == filter ? theme.onAccent : theme.textPrimary, fontFamily: theme.fontFamily)),
              selected: _activeFilter == filter,
              onSelected: (selected) {
                setState(() => _activeFilter = selected ? filter : _filters.first);
                _applyFilterAndSort();
              },
              selectedColor: theme.accentColor,
              backgroundColor: theme.cardColor,
              checkmarkColor: theme.onAccent,
              side: BorderSide(
                color: _activeFilter == filter ? theme.accentColor : theme.borderColor,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildSortControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('View:'.t(context), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.grid_view_outlined,
              color: _viewMode == ViewMode.grid ? theme.accentColor : theme.textSecondary,
            ),
            onPressed: () => setState(() => _viewMode = ViewMode.grid),
            iconSize: 20,
            constraints: BoxConstraints(),
            padding: EdgeInsets.all(4),
          ),
          IconButton(
            icon: Icon(
              Icons.view_list_outlined,
              color: _viewMode == ViewMode.list ? theme.accentColor : theme.textSecondary,
            ),
            onPressed: () => setState(() => _viewMode = ViewMode.list),
            iconSize: 20,
            constraints: BoxConstraints(),
            padding: EdgeInsets.all(4),
          ),
          const Spacer(),
          Text('Sort: '.t(context), style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          DropdownButton<NoteSortOption>(
            value: _sortOption,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textSecondary),
            style: TextStyle(fontSize: 12, color: theme.textPrimary, fontFamily: theme.fontFamily),
            dropdownColor: theme.cardColor,
            items: [
              DropdownMenuItem(value: NoteSortOption.newest, child: Text('Newest'.t(context))),
              DropdownMenuItem(value: NoteSortOption.oldest, child: Text('Oldest'.t(context))),
              DropdownMenuItem(value: NoteSortOption.titleAsc, child: Text('Title A-Z'.t(context))),
              DropdownMenuItem(value: NoteSortOption.titleDesc, child: Text('Title Z-A'.t(context))),
            ],
            onChanged: (option) {
              if (option != null) {
                setState(() => _sortOption = option);
                _applyFilterAndSort();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          SizedBox(height: 16),
          Text('No notes found'.t(context), style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return NoteCard(
            note: note,
            onTap: () => _navigateToEditor(note.type, note),
            onLongPress: () => _showDeleteOptions(note),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          // We wrap NoteCard to make it fit Grid better or just use it.
          return NoteCard(
            note: note,
            onTap: () => _navigateToEditor(note.type, note),
            onLongPress: () => _showDeleteOptions(note),
          );
        },
      );
    }
  }

  void _showDeleteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Note'.t(context), style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteNoteWithAuth(note);
              },
            ),
          ],
        ),
      ),
    );
  }
}
