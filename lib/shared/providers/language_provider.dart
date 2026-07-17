import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AppLanguage { english, sheng }

class TranslationMaps {
  static const Map<String, String> en = {
    'app_name': 'ICHITO',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'search': 'Search...',
    'home': 'Home',
    'welcome_back': 'Welcome back,',
    'quick_actions': 'Quick Actions',
    'recent_orders': 'Recent Orders',
    'customers': 'Customers',
    'add_customer': 'Add Customer',
    'vip': 'VIP',
    'regular': 'Regular',
    'orders': 'Orders',
    'new_order': 'New Order',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'overdue': 'Overdue',
    'total_amount': 'Total',
    'deposit': 'Deposit',
    'balance': 'Balance',
  };

  static const Map<String, String> sheng = {
    'app_name': 'ICHITO',
    'cancel': 'Wacha',
    'save': 'Save',
    'delete': 'Futa',
    'edit': 'Edit',
    'search': 'Saka...',
    'home': 'Base',
    'welcome_back': 'Karibu tena,',
    'quick_actions': 'Zako za Chap',
    'recent_orders': 'Kazi Ziko',
    'customers': 'Wateja',
    'add_customer': 'Mteja Mpyia',
    'vip': 'Oga',
    'regular': 'Wetu',
    'orders': 'Oda',
    'new_order': 'Oda Mpya',
    'pending': 'Inangoja',
    'in_progress': 'Iko Jikoni',
    'completed': 'Imeweza',
    'overdue': 'Imechelewa',
    'total_amount': 'Jumla',
    'deposit': 'Lipa Kiasi',
    'balance': 'Baki',
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
