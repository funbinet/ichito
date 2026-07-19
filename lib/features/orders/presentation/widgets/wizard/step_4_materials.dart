import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../garments/data/models/materials.dart';
import '../../../../garments/data/repositories/materials_repository.dart';

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

class _Step4MaterialsState extends State<Step4Materials> with ThemeAwareMixin {
  late FabricRepository _fabricRepo;
  late DesignRepository _designRepo;

  List<Fabric> _fabrics = [];
  List<Design> _designs = [];
  bool _isLoading = true;

  String? _currentFabricId;
  String? _currentDesignId;

  @override
  void initState() {
    super.initState();
    _fabricRepo = FabricRepository();
    _designRepo = DesignRepository();
    _currentFabricId = widget.selectedFabricId;
    _currentDesignId = widget.selectedDesignId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final fabrics = await _fabricRepo.getAll();
      final designs = await _designRepo.getAll();
      
      if (mounted) {
        setState(() {
          _fabrics = fabrics;
          _designs = designs.where((d) => d.category == 'All' || d.category == 'General').toList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddFabricDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    final unitCtrl = TextEditingController(text: 'm');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Add New Fabric', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdaptiveTextField(
                    controller: nameCtrl,
                    label: 'Fabric Name',
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AdaptiveTextField(
                    controller: priceCtrl,
                    label: 'Price Per Unit',
                    keyboardType: TextInputType.number,
                  ),
                  AdaptiveTextField(
                    controller: unitCtrl,
                    label: 'Unit (e.g. m, yard, piece)',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newFabric = Fabric(
                    name: nameCtrl.text.trim(),
                    pricePerUnit: double.tryParse(priceCtrl.text) ?? 0.0,
                    unit: unitCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _fabricRepo.createFabric(newFabric);
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final fabrics = await _fabricRepo.getAll();
      setState(() {
        _fabrics = fabrics;
      });
      if (_fabrics.isNotEmpty) {
        setState(() => _currentFabricId = _fabrics.last.id!);
      }
    }
  }

  void _saveAndNext() {
    widget.onMaterialsSelected(_currentFabricId, _currentDesignId);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: theme.accentColor)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 4: Materials & Design',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Fabric', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
              TextButton.icon(
                onPressed: _showAddFabricDialog,
                icon: Icon(Icons.add, size: 16, color: theme.accentColor),
                label: Text('Add New', style: TextStyle(fontSize: 12, color: theme.accentColor, fontFamily: theme.fontFamily)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _fabrics.isEmpty
            ? Center(child: Text('No fabrics in library.', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)))
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _fabrics.length,
                  itemBuilder: (context, index) {
                    final fabric = _fabrics[index];
                    final isSelected = _currentFabricId == fabric.id;
                    return GestureDetector(
                      onTap: () => setState(() => _currentFabricId = fabric.id),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.texture_outlined, size: 32, color: isSelected ? theme.accentColor : theme.textSecondary),
                            const SizedBox(height: 8),
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
                ),
              ),
          
          const SizedBox(height: 24),
          Text('Select Design Pattern', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary, fontFamily: theme.fontFamily)),
          const SizedBox(height: 8),
          _designs.isEmpty
            ? Center(child: Text('No designs in library.', style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)))
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _designs.length,
                  itemBuilder: (context, index) {
                    final design = _designs[index];
                    final isSelected = _currentDesignId == design.id;
                    return GestureDetector(
                      onTap: () => setState(() => _currentDesignId = design.id),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? theme.accentColor : theme.borderColor, width: isSelected ? 2 : 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.palette_outlined, size: 32, color: isSelected ? theme.accentColor : theme.textSecondary),
                            const SizedBox(height: 8),
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
                ),
              ),

          const Spacer(),
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  text: 'Back',
                  onPressed: widget.onBack,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 16),
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
}
