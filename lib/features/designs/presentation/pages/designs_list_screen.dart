import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/page_action_button.dart';
import '../widgets/design_card.dart';
import '../widgets/design_form_dialog.dart';
import '../../data/models/design.dart';
import '../../data/repositories/design_repository.dart';
import 'design_detail_screen.dart';

class DesignsListScreen extends StatefulWidget {
  const DesignsListScreen({super.key});

  @override
  State<DesignsListScreen> createState() => _DesignsListScreenState();
}

class _DesignsListScreenState extends State<DesignsListScreen> with ThemeAwareMixin {
  final DesignRepository _repository = DesignRepository();
  List<Design> _designs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    setState(() => _isLoading = true);
    final results = _searchQuery.isEmpty 
        ? await _repository.readAll()
        : await _repository.search(_searchQuery);
        
    setState(() {
      _designs = results;
      _isLoading = false;
    });
  }

  void _showAddDialog() async {
    final result = await showDialog<Design>(
      context: context,
      builder: (context) => const DesignFormDialog(),
    );

    if (result != null) {
      await _repository.create(result);
      _loadDesigns();
    }
  }

  void _navigateToDetail(Design design) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignDetailScreen(design: design),
      ),
    );
    
    // Refresh list in case it was edited or deleted
    if (result == true) {
      _loadDesigns();
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
          lang.t('designs'),
          style: TextStyle(
            color: theme.textPrimary,
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      pageActionButton: PageActionButton(
        label: lang.t('add_design'),
        icon: Icons.add_photo_alternate_outlined,
        onPressed: _showAddDialog,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                : _designs.isEmpty
                    ? _buildEmptyState()
                    : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (val) {
          _searchQuery = val;
          _loadDesigns();
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
            Icons.palette_outlined,
            size: 64,
            color: theme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            lang.t('designs'),
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

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 180),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _designs.length,
      itemBuilder: (context, index) {
        return DesignCard(
          design: _designs[index],
          onTap: () => _navigateToDetail(_designs[index]),
        );
      },
    );
  }
}
