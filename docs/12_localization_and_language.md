# ICHITO -- Localization & Multi-language

**Document**: 12 of 14
**Covers**: Localization architecture, language provider, English vs. Sheng strings, number and currency formatting, date/time formatting

---

## 1. Localization Architecture

ICHITO uses a custom, lightweight localization system built around a `LanguageProvider` rather than heavy external i18n libraries. This ensures complete offline capability, fast startup, and easy management of Sheng terminology.

### 1.1 Language Definitions

All localized strings are stored in static maps within the app.

```dart
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
    
    // Dashboard
    'home': 'Home',
    'welcome_back': 'Welcome back,',
    'quick_actions': 'Quick Actions',
    'recent_orders': 'Recent Orders',
    
    // Customers
    'customers': 'Customers',
    'add_customer': 'Add Customer',
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
  };

  static const Map<String, String> sheng = {
    // General
    'app_name': 'ICHITO',
    'cancel': 'Wacha',
    'save': 'Save',
    'delete': 'Futa',
    'edit': 'Edit',
    'search': 'Saka...',
    
    // Dashboard
    'home': 'Base',
    'welcome_back': 'Karibu tena,',
    'quick_actions': 'Zako za Chap',
    'recent_orders': 'Kazi Ziko',
    
    // Customers
    'customers': 'Wateja',
    'add_customer': 'Mteja Mpyia',
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
  };
}
```

### 1.2 Language Provider Implementation

```dart
class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  
  // Format settings
  String _currency = 'KES';
  String _measurementUnit = 'cm';
  String _dateFormat = 'dd/MM/yyyy';
  
  LanguageProvider() {
    _loadSettings();
  }
  
  // String retrieval
  String t(String key) {
    final map = _currentLanguage == AppLanguage.sheng 
      ? TranslationMaps.sheng 
      : TranslationMaps.en;
      
    // Fallback to English if Sheng string is missing, then fallback to key
    return map[key] ?? TranslationMaps.en[key] ?? key;
  }
  
  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    _saveSettings();
    notifyListeners();
  }
  
  // Formatter methods (see sections below)
  // ...
}
```

### 1.3 Usage in UI

Widgets use the provider to retrieve localized strings:

```dart
Widget build(BuildContext context) {
  // 'lang' handles translations and formatting
  final lang = Provider.of<LanguageProvider>(context);
  
  return Scaffold(
    appBar: AppBar(title: Text(lang.t('customers'))),
    body: Center(
      child: ElevatedButton(
        child: Text(lang.t('add_customer')),
        onPressed: () {},
      ),
    ),
  );
}
```

---

## 2. Terminology Mapping (English to Sheng)

ICHITO uniquely targets East African tailors. Sheng provides a culturally relevant, friendly interface.

| Context | English | Sheng |
|---------|---------|-------|
| **Navigation** | Home, Customers, Orders, Settings | Base, Wateja, Oda, Settings |
| **Actions** | Add, Edit, Delete, Save, Cancel | Weka, Edit, Futa, Save, Wacha |
| **Status** | Pending, In Progress, Trial, Completed | Inangoja, Iko Jikoni, Kupima, Imeweza |
| **Entities** | Garment, Fabric, Design, Note | Nguo, Kitambaa, Design, Mamboch |
| **Finance** | Payment, Deposit, Balance, Total | Malipo, Depo, Baki, Jumla |

*Note: Sheng is highly dynamic. The Sheng translations should prioritize clarity over deep slang to ensure usability.*

---

## 3. Formatting

The `LanguageProvider` handles all data formatting to ensure consistency regardless of the device's locale.

### 3.1 Currency Formatting

```dart
String formatCurrency(double amount, {bool showSymbol = true}) {
  final formatter = NumberFormat.currency(
    symbol: showSymbol ? '$_currency ' : '',
    decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    locale: 'en_KE', // Forces standard comma separators (1,000)
  );
  return formatter.format(amount);
}
```

Examples (`_currency` = 'KES'):
- `formatCurrency(1500)` -> "KES 1,500"
- `formatCurrency(2500.50)` -> "KES 2,500.50"
- `formatCurrency(1500, showSymbol: false)` -> "1,500"

### 3.2 Date Formatting

```dart
String formatDate(DateTime? date, {bool includeTime = false}) {
  if (date == null) return '';
  
  // Format map based on user settings
  String pattern;
  switch (_dateFormat) {
    case 'MM/dd/yyyy': pattern = 'MM/dd/yyyy'; break;
    case 'yyyy-MM-dd': pattern = 'yyyy-MM-dd'; break;
    default: pattern = 'dd/MM/yyyy'; // DD/MM/YYYY
  }
  
  if (includeTime) pattern += ' HH:mm';
  
  return DateFormat(pattern).format(date);
}

String formatTimeAgo(DateTime? date) {
  if (date == null) return '';
  
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays > 7) return formatDate(date);
  if (difference.inDays > 0) return '${difference.inDays} ${t('days_ago')}';
  if (difference.inHours > 0) return '${difference.inHours} ${t('hours_ago')}';
  if (difference.inMinutes > 0) return '${difference.inMinutes} ${t('mins_ago')}';
  return t('just_now');
}
```

### 3.3 Measurement Formatting

```dart
String formatMeasurement(double value) {
  // If user unit is inches, value in DB (cm) must be converted
  if (_measurementUnit == 'inches') {
    // 1 inch = 2.54 cm
    final inches = value / 2.54;
    return '${inches.toStringAsFixed(1)} in';
  } else {
    // Display as cm (native DB storage)
    return '${value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} cm';
  }
}

// Convert from UI input back to DB value (cm)
double parseMeasurementInput(String input) {
  final value = double.tryParse(input) ?? 0;
  if (_measurementUnit == 'inches') {
    return value * 2.54; // Convert back to cm
  }
  return value;
}
```

---

## 4. UI Layout Considerations

- Sheng words can occasionally be longer or shorter than their English counterparts.
- Text widgets should use `overflow: TextOverflow.ellipsis` and avoid hardcoded widths where possible.
- The `AdaptiveTextField` and `AdaptiveCard` components naturally scale to fit text contents.

---

*This is Document 12 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
