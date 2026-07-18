import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../garments/data/models/garment.dart';
import '../../../../garments/data/repositories/garment_repository.dart';
import '../../../../customers/data/repositories/customer_repository.dart';
import '../../../../customers/data/models/customer.dart';
import '../../../../garments/presentation/widgets/garment_components.dart';

class Step2Garment extends StatefulWidget {
  final String? customerId;
  final String? selectedGarmentId;
  final Function(String) onGarmentSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Garment({
    Key? key,
    required this.customerId,
    this.selectedGarmentId,
    required this.onGarmentSelected,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step2Garment> createState() => _Step2GarmentState();
}

class _Step2GarmentState extends State<Step2Garment> with ThemeAwareMixin {
  late GarmentRepository _garmentRepo;
  late CustomerRepository _customerRepo;
  List<Garment> _garments = [];
  List<Garment> _filteredGarments = [];
  Customer? _customer;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGenderFilter = 'All'; // 'Men', 'Women', 'Unisex', 'All'
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _garmentRepo = GarmentRepository();
    _customerRepo = CustomerRepository();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant Step2Garment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customerId != oldWidget.customerId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.customerId == null) return;
    
    setState(() => _isLoading = true);
    try {
      _customer = await _customerRepo.getById(widget.customerId!);
      final garments = await _garmentRepo.getAll();
      
      if (mounted) {
        setState(() {
          _garments = garments;
          // Auto select filter based on customer gender
          if (_customer?.gender != null) {
            final g = _customer!.gender!.toLowerCase();
            if (g == 'male' || g == 'men') {
              _selectedGenderFilter = 'Men';
            } else if (g == 'female' || g == 'women') {
              _selectedGenderFilter = 'Women';
            } else {
              _selectedGenderFilter = 'All';
            }
          }
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _applyFilters();
      });
    });
  }

  void _applyFilters() {
    _filteredGarments = _garments.where((g) {
      final matchesSearch = g.name.toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      switch (_selectedGenderFilter) {
        case 'Men':
          return g.category == 'Men' || g.category == 'Unisex';
        case 'Women':
          return g.category == 'Women' || g.category == 'Unisex';
        case 'Unisex':
          return g.category == 'Unisex';
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGarment = _garments.where((g) => g.id == widget.selectedGarmentId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 2: Select Garment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              fontFamily: theme.fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search garments...',
              hintStyle: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
              prefixIcon: Icon(Icons.search, color: theme.textSecondary),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter tabs
          Row(
            children: ['Men', 'Women', 'All'].map((filter) {
              final isSelected = _selectedGenderFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : theme.textPrimary, fontFamily: theme.fontFamily)),
                  selected: isSelected,
                  selectedColor: theme.accentColor,
                  backgroundColor: theme.cardColor,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGenderFilter = filter;
                      _applyFilters();
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                : _filteredGarments.isEmpty
                    ? Center(
                        child: Text(
                          'No garments found',
                          style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _filteredGarments.length,
                        itemBuilder: (context, index) {
                          final garment = _filteredGarments[index];
                          final isSelected = widget.selectedGarmentId == garment.id;
                          return GestureDetector(
                            onTap: () => widget.onGarmentSelected(garment.id!),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: theme.accentColor, width: 2) : Border.all(color: theme.borderColor, width: 0.5),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.checkroom_outlined, size: 32, color: isSelected ? theme.accentColor : theme.textSecondary),
                                  const SizedBox(height: 8),
                                  Text(
                                    garment.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: theme.textPrimary,
                                      fontFamily: theme.fontFamily,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${garment.measurementFields.length} meas.',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textSecondary,
                                      fontFamily: theme.fontFamily,
                                    ),
                                  ),
                                  Text(
                                    garment.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textSecondary,
                                      fontFamily: theme.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          AdaptiveButton(
            text: '+ Add New Garment',
            onPressed: () {
              // TODO: Open Garment Form
            },
            isPrimary: false,
          ),
          const SizedBox(height: 16),
          if (selectedGarment != null)
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'Selected: ${selectedGarment.name}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
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
                  onPressed: widget.selectedGarmentId != null ? widget.onNext : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
