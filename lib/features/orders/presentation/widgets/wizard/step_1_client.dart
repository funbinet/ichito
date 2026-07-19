import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../customers/data/models/customer.dart';
import '../../../../customers/data/repositories/customer_repository.dart';
import '../../../../customers/presentation/widgets/customer_components.dart';

class Step1Client extends StatefulWidget {
  final String? selectedCustomerId;
  final Function(String) onCustomerSelected;
  final VoidCallback onNext;

  const Step1Client({
    Key? key,
    this.selectedCustomerId,
    required this.onCustomerSelected,
    required this.onNext,
  }) : super(key: key);

  @override
  State<Step1Client> createState() => _Step1ClientState();
}

class _Step1ClientState extends State<Step1Client> with ThemeAwareMixin {
  late CustomerRepository _customerRepo;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'Recent', 'All', 'Frequent', 'VIP'
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _customerRepo = CustomerRepository();
    _loadCustomers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _customerRepo.getAll();
      setState(() {
        _customers = customers;
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading customers: $e')));
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

  Future<void> _showAddClientDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final genderCtrl = TextEditingController(text: 'Unisex');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Add New Client', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdaptiveTextField(
                  controller: nameCtrl,
                  label: 'Full Name',
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                AdaptiveTextField(
                  controller: phoneCtrl,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                AdaptiveTextField(
                  controller: genderCtrl,
                  label: 'Gender (Men/Women/Unisex)',
                ),
              ],
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
                  final newCustomer = Customer(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    gender: genderCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _customerRepo.create(newCustomer);
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
      await _loadCustomers();
      if (_customers.isNotEmpty) {
        widget.onCustomerSelected(_customers.last.id!);
      }
    }
  }

  void _applyFilters() {
    _filteredCustomers = _customers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery) ||
          (c.phone != null && c.phone!.contains(_searchQuery));
      
      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Recent':
          return c.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)));
        case 'Frequent':
          return true; 
        case 'VIP':
          return true;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = _customers.where((c) => c.id == widget.selectedCustomerId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 1: Select Client',
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
              hintText: 'Search by name or phone...',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Recent', 'All', 'Frequent', 'VIP'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : theme.textPrimary, fontFamily: theme.fontFamily)),
                    selected: isSelected,
                    selectedColor: theme.accentColor,
                    backgroundColor: theme.cardColor,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found',
                          style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          final isSelected = widget.selectedCustomerId == customer.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? theme.accentColor.withOpacity(0.05) : theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: theme.accentColor, width: 2) : Border.all(color: theme.borderColor, width: 0.5),
                              ),
                              child: CustomerCard(
                                customer: customer,
                                onTap: () {
                                  widget.onCustomerSelected(customer.id!);
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          AdaptiveButton(
            text: '+ Add New Client',
            onPressed: _showAddClientDialog,
            isPrimary: false,
          ),
          const SizedBox(height: 16),
          if (selectedCustomer != null)
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'Selected: ${selectedCustomer.name}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AdaptiveButton(
            text: 'Next Step',
            onPressed: widget.selectedCustomerId != null ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
