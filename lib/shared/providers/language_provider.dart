import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AppLanguage { english, sheng }

class TranslationMaps {
  static const Map<String, String> en = {
    // General
    'app_name': 'ICHITO',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'search': 'Search...',
    'home': 'Home',
    'welcome_back': 'Welcome back,',
    'greeting': 'Hello',
    'quick_actions': 'Quick Actions',
    'recent_orders': 'Recent Orders',
    'add': 'Add',
    'create': 'Create',
    
    // Clients
    'customers': 'Clients',
    'add_customer': 'Add Client',
    'client_details': 'Client Details',
    'vip': 'VIP',
    'regular': 'Regular',
    
    // Orders
    'orders': 'Orders',
    'new_order': 'New Order',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'overdue': 'Overdue',
    
    // Financials
    'total_amount': 'Total',
    'deposit': 'Deposit',
    'balance': 'Balance',
    
    // Garments
    'garments': 'Garments',
    'garments_library': 'Garments Library',
    'add_garment': 'Add Garment',
    'no_garments_found': 'No garments found',
    
    // Fabrics
    'fabrics': 'Fabrics',
    'add_fabric': 'Add Fabric',
    'price_per_unit': 'Price per unit',
    
    // Designs
    'designs': 'Designs',
    'add_design': 'Add Design',
    
    // Notes
    'notes': 'Notes',
    'create_note': 'Create Note',
    'normal_note': 'Normal Note',
    'church_note': 'Church Note',
    'chama_note': 'Chama Note',
    
    // Settings & Security
    'settings': 'Settings',
    'appearance': 'Appearance',
    'security': 'Security',
    'app_lock': 'App Lock',
    'biometrics': 'Biometrics',
    'auto_lock': 'Auto Lock',
    'factory_reset': 'Factory Reset',
    
    // Analytics
    'statistics': 'Statistics',
    'analytics': 'Analytics',
    
    // Notifications
    'notifications': 'Notifications',
    'profile': 'Profile',
    
    // Form fields
    'name': 'Name',
    'description': 'Description',
    'category': 'Category',
    
    // Actions
    'view_all': 'View All',
  };

  static const Map<String, String> sheng = {
    // General
    'app_name': 'ICHITO',
    'cancel': 'Wacha',
    'save': 'Save',
    'delete': 'Futa',
    'edit': 'Edit',
    'search': 'Saka...',
    'home': 'Base',
    'welcome_back': 'Karibu tena,',
    'greeting': 'Sasa',
    'quick_actions': 'Zako za Chap',
    'recent_orders': 'Kazi Ziko',
    'add': 'Weka',
    'create': 'Tengeneza',
    
    // Customers (Clients)
    'customers': 'Wateja',
    'add_customer': 'Mteja Mpya',
    'client_details': 'Detail za Mteja',
    'vip': 'Oga',
    'regular': 'Wetu',
    
    // Orders
    'orders': 'Oda',
    'new_order': 'Oda Mpya',
    'pending': 'Inangoja',
    'in_progress': 'Iko Jikoni',
    'completed': 'Imeweza',
    'overdue': 'Imechelewa',
    
    // Financials
    'total_amount': 'Jumla',
    'deposit': 'Lipa Kiasi',
    'balance': 'Baki',
    
    // Garments
    'garments': 'Nguo',
    'garments_library': 'Kabati ya Nguo',
    'add_garment': 'Weka Nguo',
    'no_garments_found': 'Hakuna nguo',
    
    // Fabrics
    'fabrics': 'Vitambaa',
    'add_fabric': 'Weka Kitambaa',
    'price_per_unit': 'Bei',
    
    // Designs
    'designs': 'Design',
    'add_design': 'Weka Design',
    
    // Notes
    'notes': 'Mamboch',
    'create_note': 'Andika Note',
    'normal_note': 'Note ya Kawaida',
    'church_note': 'Note ya Kanisa',
    'chama_note': 'Note ya Chama',
    
    // Settings & Security
    'settings': 'Mipangilio',
    'appearance': 'Muonekano',
    'security': 'Usalama',
    'app_lock': 'Funga App',
    'biometrics': 'Kidole',
    'auto_lock': 'Kujifunga',
    'factory_reset': 'Futa Zote',
    
    // Analytics
    'statistics': 'Hesabu',
    'analytics': 'Hesabu',
    
    // Notifications
    'notifications': 'Ujumbe',
    'profile': 'Profili',
    
    // Form fields
    'name': 'Jina',
    'description': 'Maelezo',
    'category': 'Aina',
    
    // Actions
    'view_all': 'Ona Zote',
  };
}

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  String _currency = 'KES';
  String _measurementUnit = 'cm';
  String _dateFormat = 'dd/MM/yyyy';

  AppLanguage get currentLanguage => _currentLanguage;
  String get currency => _currency;
  String get measurementUnit => _measurementUnit;
  String get dateFormat => _dateFormat;

  String t(String key) {
    final map = _currentLanguage == AppLanguage.sheng 
      ? TranslationMaps.sheng 
      : TranslationMaps.en;
      
    return map[key] ?? TranslationMaps.en[key] ?? key;
  }

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }

  void setMeasurementUnit(String unit) {
    _measurementUnit = unit;
    notifyListeners();
  }

  void setDateFormat(String format) {
    _dateFormat = format;
    notifyListeners();
  }

  String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      symbol: showSymbol ? '$_currency ' : '',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
      locale: 'en_KE',
    );
    return formatter.format(amount);
  }

  String formatDate(DateTime? date, {bool includeTime = false}) {
    if (date == null) return '';
    String pattern = _dateFormat;
    if (includeTime) pattern += ' HH:mm';
    return DateFormat(pattern).format(date);
  }

  String formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays > 7) return formatDate(date);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }

  String formatMeasurement(double value) {
    if (_measurementUnit == 'inches') {
      final inches = value / 2.54;
      return '${inches.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} in';
    } else {
      return '${value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} cm';
    }
  }

  double parseMeasurementInput(String input) {
    final value = double.tryParse(input) ?? 0;
    if (_measurementUnit == 'inches') {
      return value * 2.54;
    }
    return value;
  }
}
