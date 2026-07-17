import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../data/models/garment.dart';
import '../../data/repositories/garment_repository.dart';
import 'widgets/garment_components.dart';

enum ViewMode { grid, list }
enum SortOption { name, used, recent }

class GarmentFilter {
  final String label;
  final String value;
  GarmentFilter(this.label, this.value);
}

class GarmentsLibraryScreen extends StatefulWidget {
  const GarmentsLibraryScreen({super.key});

  @override
  State<GarmentsLibraryScreen> createState() => _GarmentsLibraryScreenState();
}

class _GarmentsLibraryScreenState extends State<GarmentsLibraryScreen> with ThemeAwareMixin, NavigationMixin {
  final GarmentRepository _repository = GarmentRepository();
  List<Garment> _allGarments = [];
  List<Garment> _filteredGarments = [];
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();
  
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.name;
  
  final List<GarmentFilter> _filters = [
    GarmentFilter('All', 'all'),
    GarmentFilter('Men', 'men'),
    GarmentFilter('Women', 'women'),
    GarmentFilter('Unisex', 'unisex'),
  ];
  GarmentFilter _activeFilter = GarmentFilter('All', 'all');

  @override
  void initState() {
    super.initState();
    _activeFilter = _filters.first;
    _loadGarments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGarments() async {
    setState(() => _isLoading = true);
    final garments = await _repository.getAllGarments();
    
    // Mock usageCount for MVP
    for (var g in garments) {
      if (g.usageCount == null || g.usageCount == 0) {
        g.usageCount = (g.name.length * 2); // just some deterministic mock data
      }
    }
    
    setState(() {
      _allGarments = garments;
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
    
    List<Garment> temp = _allGarments.where((g) {
      final matchesSearch = g.name.toLowerCase().contains(query) || (g.description?.toLowerCase().contains(query) ?? false);
      if (!matchesSearch) return false;
      
      if (_activeFilter.value == 'all') return true;
      return g.category.toLowerCase() == _activeFilter.value;
    }).toList();

    temp.sort((a, b) {
      switch (_sortOption) {
        case SortOption.name:
          return a.name.compareTo(b.name);
        case SortOption.used:
          return (b.usageCount ?? 0).compareTo(a.usageCount ?? 0);
        case SortOption.recent:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    setState(() {
      _filteredGarments = temp;
    });
  }

  void _showStats() {
    // Implement stats sheet
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
        title: Text(lang.t('garments_library', defaultValue: 'Garments'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.textPrimary),
            onPressed: () {
               // navigateTo('/garments/new');
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart_outlined, color: theme.textPrimary),
            onPressed: _showStats,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildViewControls(),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: theme.accentColor))
              : _filteredGarments.isEmpty 
                ? _buildEmptyState() 
                : _buildGarmentList(),
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
        hint: 'Search garments...',
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

  Widget _buildViewControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('View:', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.grid_view_outlined,
              color: _viewMode == ViewMode.grid ? theme.accentColor : theme.textSecondary,
            ),
            onPressed: () => setState(() => _viewMode = ViewMode.grid),
            iconSize: 20,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          IconButton(
            icon: Icon(
              Icons.view_list_outlined,
              color: _viewMode == ViewMode.list ? theme.accentColor : theme.textSecondary,
            ),
            onPressed: () => setState(() => _viewMode = ViewMode.list),
            iconSize: 20,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          const Spacer(),
          Text('Sort: ', style: TextStyle(fontSize: 12, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          DropdownButton<SortOption>(
            value: _sortOption,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textSecondary),
            style: TextStyle(fontSize: 12, color: theme.textPrimary, fontFamily: theme.fontFamily),
            dropdownColor: theme.cardColor,
            items: const [
              DropdownMenuItem(value: SortOption.name, child: Text('Name')),
              DropdownMenuItem(value: SortOption.used, child: Text('Most Used')),
              DropdownMenuItem(value: SortOption.recent, child: Text('Recent')),
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
          Icon(Icons.checkroom_outlined, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No garments found', style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildGarmentList() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        itemCount: _filteredGarments.length,
        itemBuilder: (context, index) {
          final g = _filteredGarments[index];
          return GarmentListTile(
            garment: g,
            onTap: () {
               // navigateTo('/garments/detail', arguments: g.id);
            },
          );
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemCount: _filteredGarments.length,
        itemBuilder: (context, index) {
          final g = _filteredGarments[index];
          return GarmentCard(
            garment: g,
            onTap: () {
               // navigateTo('/garments/detail', arguments: g.id);
            },
          );
        },
      );
    }
  }
}
