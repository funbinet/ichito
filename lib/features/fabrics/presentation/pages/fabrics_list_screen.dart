import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/page_action_button.dart';
import '../widgets/fabric_card.dart';
import '../widgets/fabric_form_dialog.dart';
import '../../data/models/fabric.dart';
import '../../data/repositories/fabric_repository.dart';
import 'fabric_detail_screen.dart';

enum ViewMode { grid, list }

class FabricsListScreen extends StatefulWidget {
  const FabricsListScreen({super.key});

  @override
  State<FabricsListScreen> createState() => _FabricsListScreenState();
}

class _FabricsListScreenState extends State<FabricsListScreen> with ThemeAwareMixin {
  final FabricRepository _repository = FabricRepository();
  List<Fabric> _fabrics = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _loadFabrics();
  }

  Future<void> _loadFabrics() async {
    setState(() => _isLoading = true);
    final results = _searchQuery.isEmpty 
        ? await _repository.getAllFabrics()
        : await _repository.searchFabrics(_searchQuery);
        
    setState(() {
      _fabrics = results;
      _isLoading = false;
    });
  }

  void _showAddDialog() async {
    final result = await showDialog<Fabric>(
      context: context,
      builder: (context) => const FabricFormDialog(),
    );

    if (result != null) {
      await _repository.addFabric(result);
      _loadFabrics();
    }
  }

  void _navigateToDetail(Fabric fabric) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FabricDetailScreen(fabric: fabric),
      ),
    );
    
    // Refresh list in case it was edited or deleted
    if (result == true) {
      _loadFabrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          lang.t('fabrics'),
          style: TextStyle(
            color: theme.textPrimary,
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      pageActionButton: PageActionButton(
        label: lang.t('add_fabric'),
        icon: Icons.texture_outlined,
        onPressed: _showAddDialog,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildViewControls(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                : _fabrics.isEmpty
                    ? _buildEmptyState()
                    : _buildFabricList(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('View:'.t(context), style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily)),
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (val) {
          _searchQuery = val;
          _loadFabrics();
        },
        style: TextStyle(color: theme.textPrimary),
        decoration: InputDecoration(
          hintText: lang.t('search'),
          hintStyle: TextStyle(color: theme.textSecondary),
          prefixIcon: Icon(Icons.search, color: theme.textSecondary),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: theme.cornerRadius,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.texture_outlined,
            size: 64,
            color: theme.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            lang.t('fabrics'),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: theme.fontSize,
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricList() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 180),
        itemCount: _fabrics.length,
        itemBuilder: (context, index) {
          return FabricListTile(
            fabric: _fabrics[index],
            onTap: () => _navigateToDetail(_fabrics[index]),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 180),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _fabrics.length,
        itemBuilder: (context, index) {
          return FabricCard(
            fabric: _fabrics[index],
            onTap: () => _navigateToDetail(_fabrics[index]),
          );
        },
      );
    }
  }
}
