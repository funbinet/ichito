# ICHITO -- Architecture & Project Structure

**Document**: 01 of 14
**Covers**: Technology stack, project layout, dependency graph, mixin system, provider architecture, service layer, build configuration, folder conventions

---

## 1. Technology Stack

### 1.1 Core Framework

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | Flutter | 3.x (latest stable) | Cross-platform UI framework, 60fps+ rendering |
| **Language** | Dart | 3.x (latest stable) | Type-safe, AOT-compiled, null-safe |
| **Target** | Android | API 21+ (Lollipop) | Primary platform |

### 1.2 Dependencies

| Package | Version | Purpose | Category |
|---------|---------|---------|----------|
| `sqflite` | ^2.3.0 | SQLite database for all local storage | Data |
| `path_provider` | ^2.1.0 | File system paths for database and images | Data |
| `provider` | ^6.1.0 | State management (theme, language, app state) | State |
| `hive` | ^2.2.0 | Fast key-value cache for settings and preferences | Cache |
| `hive_flutter` | ^1.1.0 | Hive integration with Flutter widgets | Cache |
| `shared_preferences` | ^2.2.0 | Simple key-value pairs for lightweight settings | Cache |
| `image_picker` | ^1.0.0 | Camera and gallery image selection | Media |
| `image_cropper` | ^5.0.0 | Image cropping with aspect ratio control | Media |
| `flutter_image_compress` | ^2.1.0 | Image compression to reduce storage | Media |
| `path` | ^1.8.0 | Path manipulation utilities | Utility |
| `intl` | ^0.19.0 | Internationalization, date/number formatting | Localization |
| `flutter_localizations` | SDK | Flutter localization delegate | Localization |
| `local_auth` | ^2.1.0 | Biometric authentication (fingerprint, face) | Security |
| `flutter_secure_storage` | ^9.0.0 | Encrypted storage for PINs and security codes | Security |
| `crypto` | ^3.0.0 | Hashing for PIN storage (SHA-256) | Security |
| `fl_chart` | ^0.65.0 | Charts and graphs for analytics dashboard | Analytics |
| `google_fonts` | ^6.1.0 | Custom typography (10 font families) | Theming |
| `flutter_screenutil` | ^5.9.0 | Responsive sizing across device sizes | UI |
| `uuid` | ^4.2.0 | Unique ID generation for entities | Utility |

### 1.3 Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit and widget testing |
| `integration_test` | SDK | Integration testing |
| `flutter_lints` | ^3.0.0 | Lint rules enforcement |
| `hive_generator` | ^2.0.0 | Code generation for Hive adapters |
| `build_runner` | ^2.4.0 | Code generation runner |
| `mockito` | ^5.4.0 | Mocking for unit tests |

---

## 2. Project Structure

```
ichito/
├── android/                          # Android platform project
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml   # Permissions, app config
│   │   │   └── res/                  # Android resources
│   │   └── build.gradle              # App-level build config
│   └── build.gradle                  # Project-level build config
├── assets/
│   ├── images/
│   │   ├── logo_black.png            # Sewing machine logo (dark variant)
│   │   ├── logo_white.png            # Sewing machine logo (light variant)
│   │   └── placeholder_avatar.png    # Default customer avatar
│   ├── fonts/
│   │   ├── Roboto/                   # Default font family
│   │   ├── Poppins/
│   │   ├── Montserrat/
│   │   ├── Inter/
│   │   ├── OpenSans/
│   │   ├── Lato/
│   │   ├── Raleway/
│   │   ├── Merriweather/
│   │   ├── PlayfairDisplay/
│   │   └── SFProDisplay/            # 10 font families
│   └── translations/
│       ├── en.json                   # English translations
│       └── sheng.json                # Sheng translations
├── lib/
│   ├── main.dart                     # App entry point, provider setup, MaterialApp
│   ├── app.dart                      # App widget with theme and route config
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # App name, version, email, URLs
│   │   │   ├── color_constants.dart  # Default colors, accent presets
│   │   │   ├── size_constants.dart   # Spacing scale, icon sizes, font sizes
│   │   │   └── route_constants.dart  # Named route strings
│   │   ├── enums/
│   │   │   ├── order_status.dart     # OrderStatus enum
│   │   │   ├── payment_method.dart   # PaymentMethod enum
│   │   │   ├── note_type.dart        # NoteType enum
│   │   │   ├── gender.dart           # Gender enum
│   │   │   ├── corner_style.dart     # CornerStyle enum (15+ values)
│   │   │   ├── font_family.dart      # FontFamily enum (10 values)
│   │   │   ├── theme_mode.dart       # IchitoThemeMode enum
│   │   │   ├── measurement_unit.dart # MeasurementUnit enum
│   │   │   ├── currency.dart         # Currency enum
│   │   │   ├── sort_option.dart      # SortOption enum
│   │   │   └── view_mode.dart        # ViewMode enum (grid/list)
│   │   ├── mixins/
│   │   │   ├── offline_ui_mixin.dart       # Offline state banner, sync indicators
│   │   │   ├── theme_aware_mixin.dart      # Theme property accessors
│   │   │   ├── navigation_mixin.dart       # Common navigation helpers
│   │   │   ├── form_validation_mixin.dart  # Reusable form validators
│   │   │   └── image_handler_mixin.dart    # Image pick, crop, compress helpers
│   │   ├── services/
│   │   │   ├── database_service.dart       # SQLite initialization, migrations, raw queries
│   │   │   ├── image_service.dart          # Image compression, storage, deletion
│   │   │   ├── search_service.dart         # Unified search across entities
│   │   │   ├── export_service.dart         # Data export to JSON/CSV
│   │   │   ├── backup_service.dart         # Full database backup/restore
│   │   │   ├── security_service.dart       # PIN hashing, biometric auth, encryption
│   │   │   ├── notification_service.dart   # Local notification scheduling
│   │   │   └── analytics_service.dart      # Business metric calculations
│   │   ├── providers/
│   │   │   ├── theme_provider.dart         # Accent color, corner style, font, shadows
│   │   │   ├── language_provider.dart      # Active language, translation lookup
│   │   │   ├── app_state_provider.dart     # Global app state (lock status, active screen)
│   │   │   └── connectivity_provider.dart  # Network status (for future sync)
│   │   └── utils/
│   │       ├── date_utils.dart             # Date formatting, relative time
│   │       ├── number_utils.dart           # Currency formatting, number display
│   │       ├── string_utils.dart           # Text truncation, capitalization
│   │       ├── validators.dart             # Phone, email, name validation functions
│   │       └── id_generator.dart           # Order number generation (ICHITO-YYYY-MM-XXX)
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── customer_repository.dart    # Customer CRUD + queries
│   │   │   ├── order_repository.dart       # Order CRUD + queries
│   │   │   ├── garment_repository.dart     # Garment CRUD + queries
│   │   │   ├── fabric_repository.dart      # Fabric CRUD + queries
│   │   │   ├── design_repository.dart      # Design CRUD + queries
│   │   │   ├── note_repository.dart        # Note CRUD + queries
│   │   │   ├── payment_repository.dart     # Payment CRUD + queries
│   │   │   └── settings_repository.dart    # Settings read/write
│   │   └── dao/
│   │       ├── customer_dao.dart           # Raw SQL for customers
│   │       ├── order_dao.dart              # Raw SQL for orders
│   │       ├── garment_dao.dart            # Raw SQL for garments
│   │       ├── fabric_dao.dart             # Raw SQL for fabrics
│   │       ├── design_dao.dart             # Raw SQL for designs
│   │       ├── note_dao.dart               # Raw SQL for notes
│   │       └── payment_dao.dart            # Raw SQL for payments
│   ├── models/
│   │   ├── customer.dart                   # Customer data class
│   │   ├── order.dart                      # Order data class
│   │   ├── garment.dart                    # Garment data class
│   │   ├── fabric.dart                     # Fabric data class
│   │   ├── design.dart                     # Design data class
│   │   ├── note.dart                       # Note data class (Normal/Church/Chama)
│   │   ├── payment.dart                    # Payment data class
│   │   ├── order_status_log.dart           # Status change history entry
│   │   ├── measurement.dart                # Measurement key-value pair
│   │   └── chama_contribution.dart         # Chama member contribution entry
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart          # Animated splash with logo
│   │   ├── lock/
│   │   │   ├── pin_lock_screen.dart        # PIN entry screen
│   │   │   ├── pin_setup_screen.dart       # First-time PIN creation
│   │   │   └── security_code_dialog.dart   # Security code verification popup
│   │   ├── home/
│   │   │   ├── home_screen.dart            # Main dashboard
│   │   │   ├── widgets/
│   │   │   │   ├── stats_carousel.dart     # Animated statistics cards
│   │   │   │   ├── quick_action_grid.dart  # 4x2 action buttons
│   │   │   │   ├── activity_feed.dart      # Recent activity list
│   │   │   │   └── welcome_header.dart     # Greeting + notification bell
│   │   ├── customers/
│   │   │   ├── customer_list_screen.dart   # Grid/list with search, filter, sort
│   │   │   ├── customer_detail_screen.dart # Full profile, measurements, history
│   │   │   ├── customer_form_screen.dart   # Add/edit customer form
│   │   │   └── widgets/
│   │   │       ├── customer_card.dart      # Grid card for customer
│   │   │       ├── customer_list_tile.dart # List tile for customer
│   │   │       ├── measurement_table.dart  # Measurement display/edit table
│   │   │       └── loyalty_badge.dart      # VIP/Loyal/Regular/New badge
│   │   ├── orders/
│   │   │   ├── order_list_screen.dart      # Filterable order list
│   │   │   ├── order_detail_screen.dart    # Full order info + payment tracking
│   │   │   ├── order_wizard/
│   │   │   │   ├── order_wizard_screen.dart     # Wizard container with stepper
│   │   │   │   ├── step_client_selection.dart   # Step 1: Select client
│   │   │   │   ├── step_garment_selection.dart  # Step 2: Select garment
│   │   │   │   ├── step_measurements.dart       # Step 3: Enter measurements
│   │   │   │   ├── step_materials.dart          # Step 4: Select fabric + design
│   │   │   │   ├── step_pricing.dart            # Step 5: Pricing & dates
│   │   │   │   └── step_review.dart             # Step 6: Review & confirm
│   │   │   └── widgets/
│   │   │       ├── order_card.dart              # Order summary card
│   │   │       ├── payment_history_list.dart    # Payment entries list
│   │   │       ├── add_payment_dialog.dart      # Add payment popup
│   │   │       ├── status_badge.dart            # Colored status indicator
│   │   │       └── order_success_dialog.dart    # Creation success popup
│   │   ├── garments/
│   │   │   ├── garment_list_screen.dart    # Grid/list with category filter
│   │   │   ├── garment_detail_screen.dart  # Garment info + measurement fields
│   │   │   ├── garment_form_dialog.dart    # Add/edit garment dialog
│   │   │   └── widgets/
│   │   │       └── garment_card.dart       # Garment grid card
│   │   ├── fabrics/
│   │   │   ├── fabric_list_screen.dart     # Grid with sort, density options
│   │   │   ├── fabric_detail_screen.dart   # Fabric info + image
│   │   │   ├── fabric_form_dialog.dart     # Add/edit fabric dialog
│   │   │   └── widgets/
│   │   │       └── fabric_card.dart        # Fabric grid card with image
│   │   ├── designs/
│   │   │   ├── design_list_screen.dart     # Grid gallery with sort
│   │   │   ├── design_detail_screen.dart   # Design info + full image
│   │   │   ├── design_form_dialog.dart     # Add/edit design dialog
│   │   │   └── widgets/
│   │   │       └── design_card.dart        # Design grid card with image
│   │   ├── notes/
│   │   │   ├── notes_list_screen.dart      # Filtered list by type
│   │   │   ├── normal_note_editor.dart     # Normal note create/edit
│   │   │   ├── church_note_editor.dart     # Church note with verses/speaker
│   │   │   ├── chama_note_editor.dart      # Chama note with contributions
│   │   │   └── widgets/
│   │   │       ├── note_card.dart          # Note preview card
│   │   │       ├── verse_chip.dart         # Bible verse tag chip
│   │   │       └── contribution_row.dart   # Chama member contribution row
│   │   ├── settings/
│   │   │   ├── settings_screen.dart        # Main settings page
│   │   │   ├── profile_section.dart        # Profile info and edit
│   │   │   ├── theme_section.dart          # Theme mode, accent, corners, shadows, font
│   │   │   ├── language_section.dart       # Language, units, currency, date format
│   │   │   ├── security_section.dart       # App lock, PIN, biometrics, encryption
│   │   │   ├── preferences_section.dart    # Default views, auto-save, haptics
│   │   │   ├── business_section.dart       # Business name, location, tax, labor cost
│   │   │   ├── storage_section.dart        # Storage usage, cache, backup/restore
│   │   │   ├── advanced_section.dart       # Developer options, debug, performance
│   │   │   └── help_section.dart           # User guide, tutorials, contact, about
│   │   └── statistics/
│   │       ├── statistics_screen.dart      # Analytics dashboard
│   │       └── widgets/
│   │           ├── revenue_overview_card.dart   # Revenue with growth indicator
│   │           ├── key_metrics_row.dart         # 4-metric summary
│   │           ├── monthly_trend_chart.dart     # Bar chart by month
│   │           ├── top_performers_list.dart     # Customer leaderboard
│   │           └── popular_garments_list.dart   # Garment popularity ranking
│   └── widgets/
│       ├── adaptive/
│       │   ├── adaptive_card.dart          # Card that adapts corner style + shadow
│       │   ├── adaptive_button.dart        # Button that adapts accent + corner style
│       │   ├── adaptive_icon.dart          # Icon that adapts to accent color
│       │   ├── adaptive_text_field.dart    # Input that adapts to theme
│       │   ├── adaptive_dialog.dart        # Dialog that adapts to theme
│       │   ├── adaptive_chip.dart          # Chip that adapts to accent
│       │   └── adaptive_divider.dart       # Divider with accent color tint
│       ├── layout/
│       │   ├── radial_menu.dart            # Radial navigation menu widget
│       │   ├── section_header.dart         # Section title with optional action
│       │   ├── empty_state.dart            # Empty state placeholder widget
│       │   └── loading_indicator.dart      # Themed loading spinner
│       └── common/
│           ├── search_bar.dart             # Themed search input
│           ├── filter_chips.dart           # Horizontal scrollable filter chips
│           ├── sort_dropdown.dart          # Sort option dropdown
│           ├── view_mode_toggle.dart       # Grid/list toggle button
│           ├── image_picker_sheet.dart     # Bottom sheet for camera/gallery choice
│           ├── confirm_dialog.dart         # Confirmation dialog (delete, discard)
│           └── snack_bar_helper.dart        # Themed snackbar utility
├── test/
│   ├── unit/
│   │   ├── models/                        # Model serialization, computed properties
│   │   ├── services/                      # Service logic tests
│   │   ├── repositories/                  # Repository query tests
│   │   └── utils/                         # Utility function tests
│   ├── widget/
│   │   ├── screens/                       # Screen rendering tests
│   │   └── widgets/                       # Individual widget tests
│   └── integration/
│       ├── order_creation_test.dart       # Full order wizard flow
│       ├── customer_management_test.dart  # Customer CRUD flow
│       └── settings_test.dart             # Settings application flow
├── pubspec.yaml                           # Dependencies, assets, fonts
├── analysis_options.yaml                  # Lint rules
└── README.md                             # Project overview
```

---

## 3. Architectural Layers

ICHITO follows a clean layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Screens, Widgets, Animations, Gesture Handlers             │
│  Uses: Providers (read state), Mixins (shared behavior)     │
├─────────────────────────────────────────────────────────────┤
│                    STATE MANAGEMENT LAYER                    │
│  Providers (ThemeProvider, LanguageProvider, AppState)       │
│  Holds: Reactive state, notifies listeners on change        │
├─────────────────────────────────────────────────────────────┤
│                    BUSINESS LOGIC LAYER                      │
│  Services (DatabaseService, ImageService, SecurityService)  │
│  Contains: Business rules, calculations, orchestration      │
├─────────────────────────────────────────────────────────────┤
│                    DATA ACCESS LAYER                         │
│  Repositories (CustomerRepository, OrderRepository, etc.)   │
│  Abstracts: CRUD operations, query building, caching        │
├─────────────────────────────────────────────────────────────┤
│                    DATA LAYER                                │
│  DAOs (CustomerDAO, OrderDAO, etc.)                         │
│  Executes: Raw SQL queries against SQLite                   │
├─────────────────────────────────────────────────────────────┤
│                    STORAGE LAYER                             │
│  SQLite (sqflite) | Hive (cache) | SecureStorage (secrets) │
│  Stores: Structured data, key-value cache, encrypted keys   │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Interaction
      │
      ▼
Screen (StatefulWidget + Mixins)
      │
      ├──reads──▶ Provider (reactive state)
      │
      ├──calls──▶ Repository.method()
      │                │
      │                ▼
      │           DAO.rawQuery()
      │                │
      │                ▼
      │           SQLite Database
      │
      └──calls──▶ Service.process()
                       │
                       ▼
                  Business Logic
                  (calculations, validations,
                   image processing, etc.)
```

---

## 4. Mixin Architecture

Mixins provide reusable UI behavior that multiple screens share. They avoid deep inheritance hierarchies while ensuring consistency.

### 4.1 ThemeAwareMixin

**Purpose**: Gives any `StatefulWidget` direct access to the current theme properties without boilerplate `Provider.of<>` calls.

```dart
mixin ThemeAwareMixin<T extends StatefulWidget> on State<T> {
  // Quick accessors
  Color get accentColor => Provider.of<ThemeProvider>(context, listen: true).accentColor;
  Color get backgroundColor => Provider.of<ThemeProvider>(context, listen: true).backgroundColor;
  Color get surfaceColor => Provider.of<ThemeProvider>(context, listen: true).surfaceColor;
  Color get cardColor => Provider.of<ThemeProvider>(context, listen: true).cardColor;
  Color get textPrimary => Provider.of<ThemeProvider>(context, listen: true).textPrimary;
  Color get textSecondary => Provider.of<ThemeProvider>(context, listen: true).textSecondary;
  BorderRadius get cornerRadius => Provider.of<ThemeProvider>(context, listen: true).cornerRadius;
  BoxShadow? get cardShadow => Provider.of<ThemeProvider>(context, listen: true).cardShadow;
  String get fontFamily => Provider.of<ThemeProvider>(context, listen: true).fontFamily;
  
  // Convenience builders
  BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: cornerRadius,
      boxShadow: cardShadow != null ? [cardShadow!] : null,
    );
  }
  
  TextStyle headingStyle({double? size}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size ?? 20,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    );
  }
  
  TextStyle bodyStyle({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: color ?? textSecondary,
    );
  }
}
```

**Used by**: Every screen and most widgets.

### 4.2 OfflineUIMixin

**Purpose**: Provides consistent offline state handling. Shows a banner when the device goes offline and handles sync state for future cloud backup features.

```dart
mixin OfflineUIMixin<T extends StatefulWidget> on State<T> {
  bool get isOffline => !Provider.of<ConnectivityProvider>(context, listen: true).isConnected;
  
  Widget buildOfflineBanner() {
    if (!isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: Colors.orange.shade800,
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text('Offline Mode', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  void showOfflineSnackBar(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action saved locally. Will sync when online.')),
    );
  }
}
```

**Used by**: Screens that might interact with sync-ready features.

### 4.3 NavigationMixin

**Purpose**: Provides consistent navigation helpers for push, pop, replace, and dialog opening.

```dart
mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  void navigateTo(String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  
  void navigateAndReplace(String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  void navigateBack({dynamic result}) {
    Navigator.pop(context, result);
  }
  
  void navigateAndClearStack(String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (_) => false);
  }
  
  Future<T?> showAdaptiveDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: context,
      builder: (_) => dialog,
    );
  }
  
  Future<T?> showAdaptiveBottomSheet<T>(Widget sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }
}
```

**Used by**: Every screen.

### 4.4 FormValidationMixin

**Purpose**: Reusable validation functions for form fields across the app.

```dart
mixin FormValidationMixin {
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 100) return 'Name must be under 100 characters';
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+?254|0)\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid Kenyan phone number';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional field
    if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
  
  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }
  
  String? validateMeasurement(String? value) {
    if (value == null || value.trim().isEmpty) return 'Measurement is required';
    final measurement = double.tryParse(value);
    if (measurement == null || measurement <= 0) return 'Enter a valid measurement';
    if (measurement > 500) return 'Measurement seems too large';
    return null;
  }
  
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
```

**Used by**: Customer form, order wizard steps, garment form, fabric form, note editors.

### 4.5 ImageHandlerMixin

**Purpose**: Provides consistent image picking, cropping, and compression across all screens that handle photos.

```dart
mixin ImageHandlerMixin<T extends StatefulWidget> on State<T> {
  Future<String?> pickAndProcessImage({
    double maxWidth = 800,
    double maxHeight = 800,
    int quality = 85,
    CropAspectRatio? aspectRatio,
  }) async {
    // 1. Show bottom sheet with camera/gallery choice
    final source = await _showImageSourceSheet();
    if (source == null) return null;
    
    // 2. Pick image
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200);
    if (picked == null) return null;
    
    // 3. Crop image
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Provider.of<ThemeProvider>(context, listen: false).accentColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: aspectRatio != null,
        ),
      ],
    );
    if (cropped == null) return null;
    
    // 4. Compress and save to app directory
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final targetPath = '${appDir.path}/images/$fileName';
    
    final compressed = await FlutterImageCompress.compressAndGetFile(
      cropped.path,
      targetPath,
      quality: quality,
      minWidth: maxWidth.toInt(),
      minHeight: maxHeight.toInt(),
    );
    
    return compressed?.path ?? cropped.path;
  }
  
  Future<void> deleteImage(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined),
              title: Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Used by**: Customer form (avatar), fabric form (fabric photo), design form (design image).

---

## 5. Provider Architecture

Providers hold reactive state that widgets listen to. When state changes, dependent widgets automatically rebuild.

### 5.1 ThemeProvider

**Responsibility**: Manages all visual theming state -- accent color, background mode, corner style, font, shadows.

**State Properties**:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `accentColor` | `Color` | `#FFD700` | Global accent color |
| `themeMode` | `IchitoThemeMode` | `amoledDark` | Dark, light, or AMOLED |
| `cornerStyle` | `CornerStyle` | `rounded` | Active corner style |
| `fontFamily` | `FontFamily` | `roboto` | Active font family |
| `fontSize` | `double` | `16.0` | Base font size |
| `enableShadows` | `bool` | `true` | Whether shadows are rendered |
| `shadowIntensity` | `double` | `0.15` | Shadow opacity multiplier |

**Computed Properties**:

| Property | Type | Derivation |
|----------|------|------------|
| `backgroundColor` | `Color` | Based on `themeMode` |
| `surfaceColor` | `Color` | Based on `themeMode` |
| `cardColor` | `Color` | Based on `themeMode` |
| `textPrimary` | `Color` | Based on `themeMode` |
| `textSecondary` | `Color` | Based on `themeMode` |
| `cornerRadius` | `BorderRadius` | Based on `cornerStyle` |
| `cardShadow` | `BoxShadow?` | Based on `enableShadows`, `shadowIntensity`, `accentColor` |
| `themeData` | `ThemeData` | Full Flutter ThemeData built from all properties |

**Persistence**: All theme settings are persisted to Hive on every change and restored on app launch.

### 5.2 LanguageProvider

**Responsibility**: Manages active language and provides translation lookup.

**State Properties**:

| Property | Type | Default |
|----------|------|---------|
| `activeLanguage` | `AppLanguage` | `english` |
| `measurementUnit` | `MeasurementUnit` | `cm` |
| `currency` | `Currency` | `kes` |
| `dateFormat` | `String` | `DD/MM/YYYY` |

**Methods**:

| Method | Returns | Description |
|--------|---------|-------------|
| `t(String key)` | `String` | Look up translation for given key in active language |
| `setLanguage(AppLanguage)` | `void` | Switch language, persist, notify listeners |
| `formatCurrency(double)` | `String` | Format number with currency prefix (e.g., `KES 4,000`) |
| `formatDate(DateTime)` | `String` | Format date using active date format |
| `formatMeasurement(double)` | `String` | Format measurement with unit suffix |

### 5.3 AppStateProvider

**Responsibility**: Manages global app state that doesn't fit into theme or language.

**State Properties**:

| Property | Type | Default |
|----------|------|---------|
| `isLocked` | `bool` | `false` |
| `isFirstLaunch` | `bool` | `true` |
| `lastActiveTime` | `DateTime?` | `null` |
| `autoLockMinutes` | `int` | `5` |
| `userName` | `String` | `''` |
| `businessName` | `String` | `''` |

---

## 6. Service Layer

Services contain business logic and orchestrate operations across multiple repositories.

### 6.1 DatabaseService

**Responsibility**: SQLite database initialization, migration, and raw access.

**Key Methods**:

| Method | Description |
|--------|-------------|
| `initialize()` | Create/open database, run migrations |
| `getDatabase()` | Return active database instance |
| `runMigration(int oldVersion, int newVersion)` | Execute schema migrations |
| `close()` | Close database connection |
| `deleteDatabase()` | Delete entire database (factory reset) |
| `getDatabaseSize()` | Return size in bytes for storage management |

**See**: [Data Models & Database](02_data_models_and_database.md) -- for complete schema and migration details.

### 6.2 ImageService

**Responsibility**: Image file management -- compression, storage, retrieval, cleanup.

**Key Methods**:

| Method | Description |
|--------|-------------|
| `saveImage(File source, String category)` | Compress and save, return path |
| `deleteImage(String path)` | Delete image file |
| `getImageFile(String path)` | Return File object for display |
| `cleanupOrphans()` | Delete images not referenced by any entity |
| `getTotalImageSize()` | Return total bytes used by images |
| `clearImageCache()` | Delete all cached thumbnails |

**Image Storage Structure**:
```
{appDocDir}/images/
├── customers/          # Customer avatar photos
├── fabrics/            # Fabric sample photos
├── designs/            # Design reference images
└── thumbnails/         # Auto-generated 200x200 thumbnails
```

### 6.3 SecurityService

**Responsibility**: PIN management, biometric auth, encryption.

**Key Methods**:

| Method | Description |
|--------|-------------|
| `setPIN(String pin)` | Hash and store PIN securely |
| `verifyPIN(String pin)` | Verify entered PIN against stored hash |
| `isBiometricAvailable()` | Check device biometric capability |
| `authenticateWithBiometric()` | Trigger biometric auth flow |
| `setSecurityCode(String code)` | Store security code for PIN reset |
| `verifySecurityCode(String code)` | Verify security code |
| `getFailedAttempts()` | Get count of failed PIN attempts |
| `incrementFailedAttempts()` | Increment counter, trigger lockout if threshold reached |
| `resetFailedAttempts()` | Reset counter after successful auth |

**See**: [Security & App Lock](11_security_and_app_lock.md) -- for complete security specification.

### 6.4 AnalyticsService

**Responsibility**: Calculate business metrics from order and payment data.

**Key Methods**:

| Method | Description |
|--------|-------------|
| `getRevenueForPeriod(DateTime start, DateTime end)` | Total revenue in date range |
| `getOrderCountForPeriod(DateTime start, DateTime end)` | Order count in date range |
| `getGrowthPercentage(String metric, DateTime current, DateTime previous)` | % change vs previous period |
| `getTopCustomers(int limit, DateTime start, DateTime end)` | Ranked by order count or spending |
| `getPopularGarments(int limit, DateTime start, DateTime end)` | Ranked by usage count |
| `getMonthlyTrend(String metric, int months)` | Monthly data points for charting |
| `getPaymentMethodBreakdown(DateTime start, DateTime end)` | Distribution by payment method |

**See**: [Analytics & Reporting](13_analytics_and_reporting.md) -- for complete analytics specification.

---

## 7. Repository Pattern

Each entity has a dedicated repository that abstracts data access. Repositories use DAOs for raw SQL execution and return model objects.

### Repository Interface Pattern

```dart
abstract class BaseRepository<T> {
  Future<int> insert(T item);
  Future<int> update(T item);
  Future<int> delete(int id);
  Future<T?> getById(int id);
  Future<List<T>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  });
  Future<List<T>> search(String query);
  Future<int> count();
}
```

Every concrete repository (CustomerRepository, OrderRepository, etc.) implements this interface and adds entity-specific query methods.

**See**: [Data Models & Database](02_data_models_and_database.md) -- for complete repository method signatures.

---

## 8. Build Configuration

### 8.1 pubspec.yaml Key Sections

```yaml
name: ichito
description: ICHITO - Complete Tailor Management System
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/translations/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto/Roboto-Bold.ttf
          weight: 700
        - asset: assets/fonts/Roboto/Roboto-Light.ttf
          weight: 300
    # ... repeated for all 10 font families
```

### 8.2 Android Permissions

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### 8.3 App Entry Point

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for settings cache
  await Hive.initFlutter();
  
  // Initialize database
  await DatabaseService.instance.initialize();
  
  // Load saved settings
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedSettings();
  
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedSettings();
  
  final appState = AppStateProvider();
  await appState.loadSavedState();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => languageProvider),
        ChangeNotifierProvider(create: (_) => appState),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const IchitoApp(),
    ),
  );
}
```

```dart
// app.dart
class IchitoApp extends StatelessWidget {
  const IchitoApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X reference
          builder: (context, child) {
            return MaterialApp(
              title: 'ICHITO',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData,
              initialRoute: Routes.splash,
              onGenerateRoute: RouteGenerator.generateRoute,
            );
          },
        );
      },
    );
  }
}
```

---

## 9. Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold start to splash | < 1 second | Time from launch to splash visible |
| Splash to home | < 3 seconds | Splash animation + DB init |
| Screen transition | < 300ms | Time for route transition animation |
| List scroll | 60 fps | No dropped frames during scrolling |
| Database query | < 50ms | Any single CRUD operation |
| Image load | < 200ms | Compressed image from disk to display |
| Search results | < 100ms | Query response for search input |
| App size (APK) | < 30 MB | Release APK without user data |

---

## 10. Error Handling Strategy

### 10.1 Error Categories

| Category | Handling | Example |
|----------|----------|---------|
| **Validation Error** | Show inline field error, prevent submission | Empty name field, invalid phone |
| **Database Error** | Log error, show retry snackbar | Write failure, corrupt database |
| **File System Error** | Show error dialog, offer fallback | Image save failure, storage full |
| **Security Error** | Lock app, show security dialog | Too many PIN attempts |
| **Unexpected Error** | Log stack trace, show generic error | Null pointer, cast failure |

### 10.2 Error Logging

All errors are logged locally using a rotating log file system:
- Location: `{appDocDir}/logs/`
- Max file size: 1 MB
- Max files: 5 (oldest deleted on rotation)
- Format: `[TIMESTAMP] [LEVEL] [CONTEXT] Message`

Logs are accessible from Settings > Advanced > View Debug Logs.

---

*This is Document 01 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
