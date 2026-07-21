import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/widgets/page_action_button.dart';
import 'order_detail_screen.dart';

enum ViewMode { grid, list }
enum OrderSortOption { newest, oldest, dueSoon }

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with ThemeAwareMixin, NavigationMixin {
  final OrderRepository _repository = OrderRepository();
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All'; // All, pending, in_progress, trial, completed
  ViewMode _viewMode = ViewMode.list;
  OrderSortOption _sortOption = OrderSortOption.newest;

  final List<String> _statusFilters = ['All', 'pending', 'in_progress', 'trial', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _repository.getAllOrders();
    setState(() {
      _allOrders = orders;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Order> temp = _allOrders.where((o) {
      final matchesSearch = o.orderNumber.toLowerCase().contains(_searchQuery) ||
          (o.customerName != null && o.customerName!.toLowerCase().contains(_searchQuery));
          
      if (!matchesSearch) return false;

      if (_selectedStatus == 'All') return true;
      return o.status == _selectedStatus;
    }).toList();

    temp.sort((a, b) {
      switch (_sortOption) {
        case OrderSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case OrderSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case OrderSortOption.dueSoon:
          return a.dueDate.compareTo(b.dueDate);
      }
    });

    _filteredOrders = temp;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'trial': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return theme.textSecondary;
    }
  }

  String _formatStatusLabel(String status) {
    if (status == 'in_progress') return 'In Progress';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(lang.t('orders'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      pageActionButton: PageActionButton(
        label: 'New Order'.t(context),
        icon: Icons.add_shopping_cart_outlined,
        onPressed: () => navigateTo('/order_wizard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by Order # or Client...'.t(context),
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
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _statusFilters.map((filter) {
                final isSelected = _selectedStatus == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_formatStatusLabel(filter), style: TextStyle(color: isSelected ? Colors.white : theme.textPrimary, fontFamily: theme.fontFamily)),
                    selected: isSelected,
                    selectedColor: theme.accentColor,
                    backgroundColor: theme.cardColor,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedStatus = filter;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          _buildViewControls(),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: theme.accentColor))
              : _filteredOrders.isEmpty 
                ? _buildEmptyState() 
                : _buildList(),
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
          Icon(Icons.receipt_long_outlined, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          SizedBox(height: 16),
          Text('No orders found'.t(context), style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildViewControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
          const Spacer(),
          Text('Sort: '.t(context), style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textSecondary, fontFamily: theme.fontFamily)),
          DropdownButton<OrderSortOption>(
            value: _sortOption,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textSecondary),
            style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.textPrimary, fontFamily: theme.fontFamily),
            dropdownColor: theme.cardColor,
            items: [
              DropdownMenuItem(value: OrderSortOption.newest, child: Text('Newest'.t(context))),
              DropdownMenuItem(value: OrderSortOption.oldest, child: Text('Oldest'.t(context))),
              DropdownMenuItem(value: OrderSortOption.dueSoon, child: Text('Due Soon'.t(context))),
            ],
            onChanged: (option) {
              if (option != null) {
                setState(() {
                  _sortOption = option;
                  _applyFilters();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      );
    }
  }

  Widget _buildOrderCard(Order order) {
    final isOverdue = order.isOverdue;
    
    return Card(
      color: theme.cardColor,
      margin: _viewMode == ViewMode.list ? EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOverdue ? const BorderSide(color: Colors.red, width: 1) : BorderSide(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      elevation: theme.cardShadow != null ? 2 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id!),
            ),
          );
          if (result == true) _loadOrders();
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: theme.fontSize, color: theme.textPrimary, fontFamily: theme.fontFamily)),
                  if (_viewMode == ViewMode.list)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatStatusLabel(order.status),
                        style: TextStyle(color: _getStatusColor(order.status), fontSize: theme.fontSize * 0.75, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              if (_viewMode == ViewMode.grid)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatStatusLabel(order.status),
                    style: TextStyle(color: _getStatusColor(order.status), fontSize: theme.fontSize * 0.75, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: theme.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(order.customerName ?? 'Unknown', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.checkroom_outlined, size: 16, color: theme.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(order.garmentName ?? 'Unknown', style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.62, fontFamily: theme.fontFamily)),
                      Text(lang.formatDate(order.dueDate), style: TextStyle(color: isOverdue ? Colors.red : theme.textPrimary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily, fontSize: theme.fontSize * 0.75)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Balance'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.62, fontFamily: theme.fontFamily)),
                      Text(
                        lang.formatCurrency(order.balance),
                        style: TextStyle(
                          color: order.isFullyPaid ? Colors.green : theme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFamily: theme.fontFamily,
                          fontSize: theme.fontSize * 0.75,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
