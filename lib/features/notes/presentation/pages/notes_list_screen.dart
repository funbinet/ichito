import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/note.dart';
import '../../data/repositories/note_repository.dart';
import 'widgets/note_components.dart';

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
                child: Text('What type of note?', style: headingStyle),
              ),
              ListTile(
                leading: Icon(Icons.note_outlined, color: theme.accentColor),
                title: Text('Normal Note', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                subtitle: Text('General notes and reminders', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                onTap: () {
                  Navigator.pop(context);
                  // navigateTo('/notes/new', arguments: 'normal');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.church_outlined, color: Color(0xFF9C27B0)),
                title: Text('Church Note', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                subtitle: Text('Sermon notes and Bible study', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                onTap: () {
                  Navigator.pop(context);
                  // navigateTo('/notes/new', arguments: 'church');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.groups_outlined, color: Color(0xFF4CAF50)),
                title: Text('Chama Note', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                subtitle: Text('Group savings meeting records', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                onTap: () {
                  Navigator.pop(context);
                  // navigateTo('/notes/new', arguments: 'chama');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
        title: Text(lang.t('notes', defaultValue: 'Notes'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.add, size: 18, color: theme.accentColor),
            label: Text('New Note', style: TextStyle(color: theme.accentColor, fontFamily: theme.fontFamily)),
            onPressed: _showAddNoteSheet,
          ),
        ],
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
          const SizedBox(height: 80), // Padding for RadialMenu
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: AdaptiveTextField(
        label: '',
        hint: 'Search notes...',
        prefixIcon: Icons.search,
        controller: _searchController,
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) =>
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
              shape: RoundedRectangleBorder(borderRadius: theme.chipRadius),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildSortControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('Sort: ', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          DropdownButton<NoteSortOption>(
            value: _sortOption,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textSecondary),
            style: TextStyle(fontSize: 12, color: theme.textPrimary, fontFamily: theme.fontFamily),
            dropdownColor: theme.cardColor,
            items: const [
              DropdownMenuItem(value: NoteSortOption.newest, child: Text('Newest')),
              DropdownMenuItem(value: NoteSortOption.oldest, child: Text('Oldest')),
              DropdownMenuItem(value: NoteSortOption.titleAsc, child: Text('Title A-Z')),
              DropdownMenuItem(value: NoteSortOption.titleDesc, child: Text('Title Z-A')),
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
          const SizedBox(height: 16),
          Text('No notes found', style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return NoteCard(
          note: note,
          onTap: () {
            // navigateTo('/notes/detail', arguments: note.id);
          },
        );
      },
    );
  }
}
