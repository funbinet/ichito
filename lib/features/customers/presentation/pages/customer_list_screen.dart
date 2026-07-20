import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/page_action_button.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../data/models/customer.dart';
import '../widgets/customer_components.dart';
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';

enum ViewMode { grid, list }
enum SortOption { name, orders, spent, recent }

class CustomerFilter {
  final String label;
  final String value;
  CustomerFilter(this.label, this.value);
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> with ThemeAwareMixin, NavigationMixin {
  List<Customer> _filteredCustomers = [];
  bool _isInit = false;
  
  final TextEditingController _searchController = TextEditingController();
  
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.name;
  
  final List<CustomerFilter> _filters = [
    CustomerFilter('All', 'all'),
    CustomerFilter('Male', 'male'),
    CustomerFilter('Female', 'female'),
    CustomerFilter('VIP', 'vip'),
    CustomerFilter('New', 'new'),
    CustomerFilter('Frequent', 'frequent'),
  ];
  CustomerFilter _activeFilter = CustomerFilter('All', 'all');

  @override
  void initState() {
    super.initState();
    _activeFilter = _filters.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _applyFilterAndSort();
      _isInit = true;
    }
  }

  // Loaded from Provider now

  void _onSearchChanged(String query) {
    // Simple inline debounce
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text == query) {
        _applyFilterAndSort();
      }
    });
  }

  void _applyFilterAndSort() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    
    List<Customer> temp = provider.customers.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(query) || c.phone.contains(query);
      if (!matchesSearch) return false;
      
      switch (_activeFilter.value) {
        case 'male':
          return c.gender.toLowerCase() == 'male';
        case 'female':
          return c.gender.toLowerCase() == 'female';
        case 'vip':
          return c.loyaltyStatus.toUpperCase() == 'VIP';
        case 'new':
          return c.totalOrders <= 1;
        case 'frequent':
          return c.totalOrders >= 5;
        case 'all':
        default:
          return true;
      }
    }).toList();

    temp.sort((a, b) {
      switch (_sortOption) {
        case SortOption.name:
          return a.name.compareTo(b.name);
        case SortOption.orders:
          return b.totalOrders.compareTo(a.totalOrders);
        case SortOption.spent:
          return b.totalSpent.compareTo(a.totalSpent);
        case SortOption.recent:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    setState(() {
      _filteredCustomers = temp;
    });
  }

  void _showCustomerStats() {
    // Implement bottom sheet with customer stats
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
        title: Text(lang.t('customers'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_outlined, color: theme.textPrimary),
            onPressed: _showCustomerStats,
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          // Sync logic continuously applied when provider updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _applyFilterAndSort();
          });

          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              _buildViewControls(),
              Expanded(
                child: provider.isLoading 
                  ? Center(child: CircularProgressIndicator(color: theme.accentColor))
                  : _filteredCustomers.isEmpty 
                    ? _buildEmptyState() 
                    : _buildCustomerList(),
              ),
              SizedBox(height: 80), // Padding for RadialMenu
            ],
          );
        },
      ),
      pageActionButton: PageActionButton(
        label: 'Add Client'.t(context),
        icon: Icons.add,
        onPressed: () => navigateTo('/customers/new'),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: AdaptiveTextField(
        label: '',
        hint: 'Search by name or phone...'.t(context),
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
  
  Widget _buildViewControls() {
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
          DropdownButton<SortOption>(
            value: _sortOption,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textSecondary),
            style: TextStyle(fontSize: 12, color: theme.textPrimary, fontFamily: theme.fontFamily),
            dropdownColor: theme.cardColor,
            items: [
              DropdownMenuItem(value: SortOption.name, child: Text('Name'.t(context))),
              DropdownMenuItem(value: SortOption.orders, child: Text('Orders'.t(context))),
              DropdownMenuItem(value: SortOption.spent, child: Text('Spent'.t(context))),
              DropdownMenuItem(value: SortOption.recent, child: Text('Recent'.t(context))),
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
          Icon(Icons.people_outline, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          SizedBox(height: 16),
          Text('No clients found'.t(context), style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          final c = _filteredCustomers[index];
          return CustomerListTile(
            customer: c,
            onTap: () => navigateTo('/customers/detail', arguments: c.id),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          final c = _filteredCustomers[index];
          return CustomerCard(
            customer: c,
            onTap: () => navigateTo('/customers/detail', arguments: c.id),
          );
        },
      );
    }
  }
}
