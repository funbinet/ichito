import 'package:ichito/shared/providers/language_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/adaptive_components.dart';
import '../../../../customers/data/models/customer.dart';
import '../../../../customers/data/repositories/customer_repository.dart';
import '../../../../customers/presentation/pages/customer_form_screen.dart';
import '../../../../../shared/widgets/square_avatar.dart';

class Step1Client extends StatefulWidget {
  final String? selectedCustomerId;
  final Function(String) onCustomerSelected;
  final VoidCallback onNext;

  const Step1Client({
    super.key,
    this.selectedCustomerId,
    required this.onCustomerSelected,
    required this.onNext,
  });

  @override
  State<Step1Client> createState() => _Step1ClientState();
}

class _Step1ClientState extends State<Step1Client> with ThemeAwareMixin {
  late CustomerRepository _customerRepo;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  bool _isGridView = true;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading customers: $e'.t(context))));
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

  Future<void> _showAddClientDialog() async {
    // Open full Customer Form Screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );

    if (result == true) {
      await _loadCustomers();
      if (_customers.isNotEmpty) {
        widget.onCustomerSelected(_customers.last.id!); // Assuming the new customer is last
      }
    }
  }

  void _applyFilters() {
    _filteredCustomers = _customers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery) ||
          (c.phone.contains(_searchQuery)); // Phone is not nullable in Customer model

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Recent':
          return c.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)));
        case 'Frequent':
          return c.totalOrders >= 5; 
        case 'VIP':
          return c.loyaltyStatus.toUpperCase() == 'VIP';
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildCustomerGridItem(Customer customer, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onCustomerSelected(customer.id!),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
          borderRadius: theme.cornerRadius,
          border: isSelected 
              ? Border.all(color: theme.accentColor, width: 2) 
              : Border.all(color: theme.borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: SquareAvatar(
                  size: double.infinity,
                  base64Image: customer.photoPath,
                  fallbackText: customer.initials,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                        fontFamily: theme.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      customer.phone,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textSecondary,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerListItem(Customer customer, bool isSelected) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      color: isSelected ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(
          color: isSelected ? theme.accentColor : theme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => widget.onCustomerSelected(customer.id!),
        leading: SquareAvatar(
          size: 40,
          base64Image: customer.photoPath,
          fallbackText: customer.initials,
        ),
        title: Text(customer.name, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily)),
        subtitle: Text(customer.phone, style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
        trailing: isSelected ? Icon(Icons.check_circle, color: theme.accentColor) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = _customers.where((c) => c.id == widget.selectedCustomerId).firstOrNull;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step 1: Select Client'.t(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  fontFamily: theme.fontFamily,
                ),
              ),
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, color: theme.textSecondary),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            onChanged: _onSearchChanged,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...'.t(context),
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
          SizedBox(height: 12),
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Recent', 'All', 'Frequent', 'VIP'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter, style: TextStyle(color: isSelected ? theme.onAccent : theme.textPrimary, fontFamily: theme.fontFamily)),
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
          SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'No clients found'.t(context),
                          style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily),
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Smaller cards
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              final isSelected = widget.selectedCustomerId == customer.id;
                              return _buildCustomerGridItem(customer, isSelected);
                            },
                          )
                        : ListView.builder(
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              final isSelected = widget.selectedCustomerId == customer.id;
                              return _buildCustomerListItem(customer, isSelected);
                            },
                          ),
          ),
          SizedBox(height: 16),
          AdaptiveButton(
            text: '+ Add New Client',
            onPressed: _showAddClientDialog,
            isPrimary: false,
          ),
          SizedBox(height: 16),
          if (selectedCustomer != null)
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.accentColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${selectedCustomer.name}'.t(context),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: theme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          AdaptiveButton(
            text: 'Next Step',
            onPressed: widget.selectedCustomerId != null ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
