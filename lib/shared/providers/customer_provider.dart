import 'package:flutter/material.dart';
import '../../features/customers/data/models/customer.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/notifications/data/services/notification_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository = CustomerRepository();
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customers = await _repository.getAllCustomers();
    } catch (e) {
      debugPrint('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    await _repository.createCustomer(customer);
    await NotificationService().showModelNotification(action: 'Created', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _repository.updateCustomer(customer);
    await NotificationService().showModelNotification(action: 'Updated', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    final customer = getCustomerById(id);
    await _repository.deleteCustomer(id);
    if (customer != null) {
      await NotificationService().showModelNotification(action: 'Deleted', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name);
    }
    await loadCustomers();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
