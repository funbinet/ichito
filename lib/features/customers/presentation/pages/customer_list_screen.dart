import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> with ThemeAwareMixin, NavigationMixin {
  final CustomerRepository _repository = CustomerRepository();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final customers = await _repository.getAllCustomers();
    setState(() {
      _customers = customers;
      _filteredCustomers = customers;
      _isLoading = false;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((c) {
        return c.name.toLowerCase().contains(query) || c.phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('customers'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: bodyStyle,
              decoration: InputDecoration(
                hintText: lang.t('search'),
                prefixIcon: Icon(Icons.search_outlined, color: theme.accentColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: theme.cornerRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: theme.accentColor))
              : _filteredCustomers.isEmpty 
                ? _buildEmptyState() 
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add customer form
        },
        backgroundColor: theme.accentColor,
        foregroundColor: theme.onAccent,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No customers found', style: subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final c = _filteredCustomers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.accentLight,
            child: Text(c.initials, style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold)),
          ),
          title: Text(c.name, style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text('${c.phone} • ${c.loyaltyStatus}', style: subtitleStyle),
          trailing: Icon(Icons.chevron_right_outlined, color: theme.textSecondary),
          onTap: () {
            // Navigate to detail
          },
        );
      },
    );
  }
}
