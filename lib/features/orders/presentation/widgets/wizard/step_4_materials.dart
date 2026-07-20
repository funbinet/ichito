import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../garments/data/models/materials.dart';
import '../../../../garments/data/repositories/materials_repository.dart';
import '../../../../fabrics/presentation/widgets/fabric_form_dialog.dart';
import '../../../../designs/presentation/widgets/design_form_dialog.dart';

class Step4Materials extends StatefulWidget {
  final String garmentId;
  final String? selectedFabricId;
  final String? selectedDesignId;
  final Function(String?, String?) onMaterialsSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4Materials({
    Key? key,
    required this.garmentId,
    this.selectedFabricId,
    this.selectedDesignId,
    required this.onMaterialsSelected,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step4Materials> createState() => _Step4MaterialsState();
}

class _Step4MaterialsState extends State<Step4Materials> with ThemeAwareMixin, SingleTickerProviderStateMixin {
  late FabricRepository _fabricRepo;
  late DesignRepository _designRepo;

  List<Fabric> _fabrics = [];
  List<Design> _designs = [];
  List<Fabric> _filteredFabrics = [];
  List<Design> _filteredDesigns = [];
  bool _isLoading = true;

  String? _currentFabricId;
  String? _currentDesignId;
  
  String _fabricSearchQuery = '';
  String _designSearchQuery = '';
  bool _isFabricGridView = true;
  bool _isDesignGridView = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fabricRepo = FabricRepository();
    _designRepo = DesignRepository();
    _currentFabricId = widget.selectedFabricId;
    _currentDesignId = widget.selectedDesignId;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final fabrics = await _fabricRepo.getAll();
      final designs = await _designRepo.getAll();
      
      if (mounted) {
        setState(() {
          _fabrics = fabrics;
          _filteredFabrics = fabrics;
          _designs = designs.where((d) => d.category == 'All' || d.category == 'General').toList();
          _filteredDesigns = _designs;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e'.t(context))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddFabricDialog() async {
    final result = await showDialog<Fabric>(
      context: context,
      builder: (context) => const FabricFormDialog(),
    );

    if (result != null) {
      await _fabricRepo.createFabric(result);
      final fabrics = await _fabricRepo.getAll();
      setState(() {
        _fabrics = fabrics;
        _applyFabricFilter();
      });
      if (_fabrics.isNotEmpty) {
        setState(() => _currentFabricId = _fabrics.last.id!);
      }
    }
  }

  Future<void> _showAddDesignDialog() async {
    final result = await showDialog<Design>(
      context: context,
      builder: (context) => const DesignFormDialog(),
    );

    if (result != null) {
      await _designRepo.createDesign(result);
      final designs = await _designRepo.getAll();
      setState(() {
        _designs = designs.where((d) => d.category == 'All' || d.category == 'General').toList();
        _applyDesignFilter();
      });
      if (_designs.isNotEmpty) {
        setState(() => _currentDesignId = _designs.last.id!);
      }
    }
  }
  void _applyFabricFilter() {
    setState(() {
      if (_fabricSearchQuery.isEmpty) {
        _filteredFabrics = _fabrics;
      } else {
        _filteredFabrics = _fabrics.where((f) => f.name.toLowerCase().contains(_fabricSearchQuery.toLowerCase())).toList();
      }
    });
  }

  void _applyDesignFilter() {
    setState(() {
      if (_designSearchQuery.isEmpty) {
        _filteredDesigns = _designs;
      } else {
        _filteredDesigns = _designs.where((d) => d.name.toLowerCase().contains(_designSearchQuery.toLowerCase())).toList();
      }
    });
  }
  void _saveAndNext() {
    widget.onMaterialsSelected(_currentFabricId, _currentDesignId);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 4: Materials & Design'.t(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
          ),
          SizedBox(height: 16),
          
          TabBar(
            controller: _tabController,
            labelColor: theme.accentColor,
            unselectedLabelColor: theme.textSecondary,
            indicatorColor: theme.accentColor,
            tabs: const [
              Tab(text: 'Fabric'),
              Tab(text: 'Design Pattern'),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFabricTab(),
                _buildDesignTab(),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  text: 'Back',
                  onPressed: widget.onBack,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AdaptiveButton(
                  text: 'Next Step',
                  onPressed: _saveAndNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildFabricTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) {
                  _fabricSearchQuery = v;
                  _applyFabricFilter();
                },
                decoration: InputDecoration(
                  hintText: 'Search fabrics...'.t(context),
                  hintStyle: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                  prefixIcon: Icon(Icons.search, color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(_isFabricGridView ? Icons.view_list : Icons.grid_view, color: theme.textSecondary),
              onPressed: () => setState(() => _isFabricGridView = !_isFabricGridView),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: theme.accentColor),
              onPressed: _showAddFabricDialog,
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: _filteredFabrics.isEmpty
              ? Center(child: Text('No fabrics found.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)))
              : _isFabricGridView
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _filteredFabrics.length,
                      itemBuilder: (context, index) {
                        final fabric = _filteredFabrics[index];
                        final isSelected = _currentFabricId == fabric.id;
                        return GestureDetector(
                          onTap: () => setState(() => _currentFabricId = fabric.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.texture_outlined, size: 32, color: isSelected ? theme.accentColor : theme.textSecondary),
                                SizedBox(height: 8),
                                Text(
                                  fabric.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredFabrics.length,
                      itemBuilder: (context, index) {
                        final fabric = _filteredFabrics[index];
                        final isSelected = _currentFabricId == fabric.id;
                        return Card(
                          color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: theme.cornerRadius,
                            side: BorderSide(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.texture_outlined, color: isSelected ? theme.accentColor : theme.textSecondary),
                            title: Text(fabric.name, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
                            trailing: isSelected ? Icon(Icons.check_circle, color: theme.accentColor) : null,
                            onTap: () => setState(() => _currentFabricId = fabric.id),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDesignTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) {
                  _designSearchQuery = v;
                  _applyDesignFilter();
                },
                decoration: InputDecoration(
                  hintText: 'Search designs...'.t(context),
                  hintStyle: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                  prefixIcon: Icon(Icons.search, color: theme.textSecondary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(_isDesignGridView ? Icons.view_list : Icons.grid_view, color: theme.textSecondary),
              onPressed: () => setState(() => _isDesignGridView = !_isDesignGridView),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: theme.accentColor),
              onPressed: _showAddDesignDialog,
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: _filteredDesigns.isEmpty
              ? Center(child: Text('No designs found.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)))
              : _isDesignGridView
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _filteredDesigns.length,
                      itemBuilder: (context, index) {
                        final design = _filteredDesigns[index];
                        final isSelected = _currentDesignId == design.id;
                        return GestureDetector(
                          onTap: () => setState(() => _currentDesignId = design.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.palette_outlined, size: 32, color: isSelected ? theme.accentColor : theme.textSecondary),
                                SizedBox(height: 8),
                                Text(
                                  design.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredDesigns.length,
                      itemBuilder: (context, index) {
                        final design = _filteredDesigns[index];
                        final isSelected = _currentDesignId == design.id;
                        return Card(
                          color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: theme.cornerRadius,
                            side: BorderSide(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.palette_outlined, color: isSelected ? theme.accentColor : theme.textSecondary),
                            title: Text(design.name, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
                            trailing: isSelected ? Icon(Icons.check_circle, color: theme.accentColor) : null,
                            onTap: () => setState(() => _currentDesignId = design.id),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
