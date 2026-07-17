# ICHITO -- Navigation & Routing

**Document**: 03 of 14
**Covers**: Navigation paradigm, named routes, transition animations, deep linking, back-stack management, gesture navigation, route guards, radial menu

---

## 1. Navigation Philosophy

ICHITO uses a hybrid navigation system:

1. **Radial Menu** -- The primary navigation hub, accessible from any screen via a floating action button. Replaces traditional bottom navigation bars.
2. **Named Routes** -- Every screen has a named route for programmatic navigation and deep linking.
3. **Modal Navigation** -- Dialogs, bottom sheets, and overlays for inline creation/editing flows.
4. **Wizard Navigation** -- The order creation wizard uses internal step navigation with back/forward controls.

---

## 2. Route Definitions

### 2.1 Route Constants

```dart
class Routes {
  // Core
  static const String splash = '/';
  static const String home = '/home';
  
  // Auth / Lock
  static const String pinLock = '/lock';
  static const String pinSetup = '/lock/setup';
  
  // Customers
  static const String customerList = '/customers';
  static const String customerDetail = '/customers/detail';    // Args: int customerId
  static const String customerForm = '/customers/form';        // Args: Customer? (null = new)
  
  // Orders
  static const String orderList = '/orders';
  static const String orderDetail = '/orders/detail';          // Args: int orderId
  static const String orderWizard = '/orders/new';             // Args: none
  
  // Garments
  static const String garmentList = '/garments';
  static const String garmentDetail = '/garments/detail';      // Args: int garmentId
  
  // Fabrics
  static const String fabricList = '/fabrics';
  static const String fabricDetail = '/fabrics/detail';        // Args: int fabricId
  
  // Designs
  static const String designList = '/designs';
  static const String designDetail = '/designs/detail';        // Args: int designId
  
  // Notes
  static const String notesList = '/notes';
  static const String normalNoteEditor = '/notes/normal';      // Args: int? noteId (null = new)
  static const String churchNoteEditor = '/notes/church';      // Args: int? noteId (null = new)
  static const String chamaNoteEditor = '/notes/chama';        // Args: int? noteId (null = new)
  
  // Settings
  static const String settings = '/settings';
  
  // Statistics
  static const String statistics = '/statistics';
}
```

### 2.2 Route Generator

```dart
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // === CORE ===
      case Routes.splash:
        return _fadeRoute(const SplashScreen(), settings);
        
      case Routes.home:
        return _fadeRoute(const HomeScreen(), settings);
        
      // === AUTH ===
      case Routes.pinLock:
        return _fadeRoute(const PinLockScreen(), settings);
        
      case Routes.pinSetup:
        return _slideRoute(const PinSetupScreen(), settings);
        
      // === CUSTOMERS ===
      case Routes.customerList:
        return _slideRoute(const CustomerListScreen(), settings);
        
      case Routes.customerDetail:
        final customerId = settings.arguments as int;
        return _slideRoute(CustomerDetailScreen(customerId: customerId), settings);
        
      case Routes.customerForm:
        final customer = settings.arguments as Customer?;
        return _slideUpRoute(CustomerFormScreen(customer: customer), settings);
        
      // === ORDERS ===
      case Routes.orderList:
        return _slideRoute(const OrderListScreen(), settings);
        
      case Routes.orderDetail:
        final orderId = settings.arguments as int;
        return _slideRoute(OrderDetailScreen(orderId: orderId), settings);
        
      case Routes.orderWizard:
        return _slideUpRoute(const OrderWizardScreen(), settings);
        
      // === GARMENTS ===
      case Routes.garmentList:
        return _slideRoute(const GarmentListScreen(), settings);
        
      case Routes.garmentDetail:
        final garmentId = settings.arguments as int;
        return _slideRoute(GarmentDetailScreen(garmentId: garmentId), settings);
        
      // === FABRICS ===
      case Routes.fabricList:
        return _slideRoute(const FabricListScreen(), settings);
        
      case Routes.fabricDetail:
        final fabricId = settings.arguments as int;
        return _slideRoute(FabricDetailScreen(fabricId: fabricId), settings);
        
      // === DESIGNS ===
      case Routes.designList:
        return _slideRoute(const DesignListScreen(), settings);
        
      case Routes.designDetail:
        final designId = settings.arguments as int;
        return _slideRoute(DesignDetailScreen(designId: designId), settings);
        
      // === NOTES ===
      case Routes.notesList:
        return _slideRoute(const NotesListScreen(), settings);
        
      case Routes.normalNoteEditor:
        final noteId = settings.arguments as int?;
        return _slideUpRoute(NormalNoteEditor(noteId: noteId), settings);
        
      case Routes.churchNoteEditor:
        final noteId = settings.arguments as int?;
        return _slideUpRoute(ChurchNoteEditor(noteId: noteId), settings);
        
      case Routes.chamaNoteEditor:
        final noteId = settings.arguments as int?;
        return _slideUpRoute(ChamaNoteEditor(noteId: noteId), settings);
        
      // === SETTINGS ===
      case Routes.settings:
        return _slideRoute(const SettingsScreen(), settings);
        
      // === STATISTICS ===
      case Routes.statistics:
        return _slideRoute(const StatisticsScreen(), settings);
        
      // === FALLBACK ===
      default:
        return _fadeRoute(
          Scaffold(body: Center(child: Text('Route not found: ${settings.name}'))),
          settings,
        );
    }
  }
}
```

---

## 3. Transition Animations

ICHITO uses three distinct transition types to communicate navigation hierarchy:

### 3.1 Fade Transition (Core Screens)

**Used for**: Splash -> Home, Lock -> Home. Screens that represent state changes, not navigation depth.

```dart
static Route<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
```

### 3.2 Slide-Right Transition (Drill-Down Navigation)

**Used for**: List -> Detail, Home -> any section list. Indicates navigating deeper into a hierarchy.

```dart
static Route<T> _slideRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),  // Slide in from right
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ));
      
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}
```

### 3.3 Slide-Up Transition (Modal/Creation Screens)

**Used for**: Order Wizard, Add/Edit forms, Note editors. Indicates a modal action that will return a result.

```dart
static Route<T> _slideUpRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),  // Slide in from bottom
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
```

---

## 4. Radial Menu Navigation

### 4.1 Concept

The radial menu is a floating circular button (FAB) positioned at the bottom-center of the screen. When tapped, it expands into a radial arrangement of navigation options that fan out around it. This replaces a traditional bottom navigation bar with a more thumb-friendly, visually distinctive approach.

### 4.2 Menu Items

When the radial menu opens, the following items appear in a semicircle above the trigger button:

```
          [Statistics]
     [Notes]         [Settings]
  [Designs]             [Customers]
     [Fabrics]       [Orders]
          [Garments]
              
         [+ New Order]   <-- Center/prominent
              
           ( ICHITO )    <-- Trigger FAB (logo icon)
```

| Position | Label | Icon | Route | Priority |
|----------|-------|------|-------|----------|
| Center (prominent) | New Order | `Icons.add_shopping_cart_outlined` | `Routes.orderWizard` | Primary action |
| Inner ring - 1 | Customers | `Icons.people_outlined` | `Routes.customerList` | High |
| Inner ring - 2 | Orders | `Icons.shopping_bag_outlined` | `Routes.orderList` | High |
| Inner ring - 3 | Garments | `Icons.checkroom_outlined` | `Routes.garmentList` | High |
| Outer ring - 1 | Fabrics | `Icons.texture_outlined` | `Routes.fabricList` | Medium |
| Outer ring - 2 | Designs | `Icons.palette_outlined` | `Routes.designList` | Medium |
| Outer ring - 3 | Notes | `Icons.note_outlined` | `Routes.notesList` | Medium |
| Outer ring - 4 | Statistics | `Icons.bar_chart_outlined` | `Routes.statistics` | Medium |
| Outer ring - 5 | Settings | `Icons.settings_outlined` | `Routes.settings` | Low |

### 4.3 Radial Menu Behavior

**Opening Animation** (350ms):
1. FAB rotates 45 degrees (visual feedback)
2. Scrim overlay fades in (semi-transparent black)
3. Menu items scale from 0 to 1 with staggered delays (each item 30ms apart)
4. Items fan out from center to their radial positions

**Closing Animation** (250ms):
1. Items scale from 1 to 0 with staggered delays (reverse order)
2. FAB rotates back to 0 degrees
3. Scrim fades out

**Item Selection**:
1. Tapped item briefly highlights with accent color
2. Menu closes with quick animation (150ms)
3. Navigation to selected route begins
4. Haptic feedback on tap (if enabled)

**Dismissal**:
- Tap scrim overlay to close without navigating
- Swipe down gesture to close
- Physical back button closes menu

### 4.4 Radial Menu Widget Structure

```dart
class RadialMenu extends StatefulWidget {
  const RadialMenu({super.key});
  
  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin, ThemeAwareMixin {
  
  late AnimationController _controller;
  bool _isOpen = false;
  
  // Menu items with their angular positions (in radians)
  final List<RadialMenuItem> _items = [
    RadialMenuItem(
      label: 'New Order',
      icon: Icons.add_shopping_cart_outlined,
      route: Routes.orderWizard,
      distance: 80,   // Closer to center (prominent)
      angle: -pi / 2, // Directly above
    ),
    RadialMenuItem(
      label: 'Customers',
      icon: Icons.people_outlined,
      route: Routes.customerList,
      distance: 130,
      angle: -pi * 0.8,
    ),
    // ... more items positioned radially
  ];
  
  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Scrim overlay
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: AnimatedOpacity(
              opacity: _isOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(color: Colors.black54),
            ),
          ),
        
        // Radial items
        ..._buildRadialItems(),
        
        // Center FAB trigger
        Positioned(
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: accentColor,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                'assets/images/logo_white.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 4.5 Radial Menu Placement

The radial menu is present on these screens:
- Home Dashboard
- Customer List
- Order List
- Garment List
- Fabric List
- Design List
- Notes List
- Statistics Dashboard
- Settings

The radial menu is **NOT** present on:
- Splash Screen
- PIN Lock Screen
- Detail screens (customer detail, order detail, etc.)
- Form/Editor screens
- Order Wizard
- Dialogs and bottom sheets

The `RadialMenu` widget is part of a `Scaffold` wrapper that wraps all list/dashboard screens:

```dart
class IchitoScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showRadialMenu;
  
  const IchitoScaffold({
    required this.body,
    this.appBar,
    this.showRadialMenu = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          body,
          if (showRadialMenu) const Positioned.fill(child: RadialMenu()),
        ],
      ),
    );
  }
}
```

---

## 5. Back-Stack Management

### 5.1 Navigation Stack Rules

| From Screen | Back Button Goes To | Method |
|-------------|-------------------|--------|
| Splash | (none -- auto-navigates) | `pushReplacementNamed` |
| Home | Exit app (with confirmation) | `WillPopScope` |
| Customer List | Home | `pop()` |
| Customer Detail | Customer List | `pop()` |
| Customer Form | Customer List or Detail (depends on origin) | `pop(result)` |
| Order List | Home | `pop()` |
| Order Detail | Order List | `pop()` |
| Order Wizard | Discard confirmation dialog -> Home | `WillPopScope` with dialog |
| Garment List | Home | `pop()` |
| Fabric List | Home | `pop()` |
| Design List | Home | `pop()` |
| Notes List | Home | `pop()` |
| Note Editor | Notes List (with save/discard prompt if unsaved changes) | `WillPopScope` |
| Settings | Home | `pop()` |
| Statistics | Home | `pop()` |
| PIN Lock | (none -- must authenticate) | Blocks back |

### 5.2 Exit Confirmation (Home Screen)

```dart
// On HomeScreen
@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit ICHITO?'),
          content: Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Exit'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    },
    child: IchitoScaffold(/* ... */),
  );
}
```

### 5.3 Unsaved Changes Guard

For form screens (Customer Form, Note Editors), a guard prevents accidental data loss:

```dart
mixin UnsavedChangesGuard<T extends StatefulWidget> on State<T> {
  bool _hasUnsavedChanges = false;
  
  void markAsChanged() {
    _hasUnsavedChanges = true;
  }
  
  void clearChanges() {
    _hasUnsavedChanges = false;
  }
  
  Future<bool> onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text('Discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text('Save'),
          ),
        ],
      ),
    );
    
    switch (result) {
      case 'save':
        await saveChanges(); // Implemented by the screen
        return true;
      case 'discard':
        return true;
      case 'cancel':
      default:
        return false;
    }
  }
  
  // Override in implementing screen
  Future<void> saveChanges();
}
```

---

## 6. Route Guards

### 6.1 App Lock Guard

When app lock is enabled, the PIN lock screen must be shown before any other screen.

```dart
// In main.dart / app initialization
class _IchitoAppState extends State<IchitoApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return MaterialApp(
          // If locked, always show PIN screen
          initialRoute: appState.isLocked ? Routes.pinLock : Routes.splash,
          onGenerateRoute: (settings) {
            // Guard: If app is locked, redirect to lock screen
            if (appState.isLocked && settings.name != Routes.pinLock) {
              return RouteGenerator.generateRoute(
                RouteSettings(name: Routes.pinLock),
              );
            }
            return RouteGenerator.generateRoute(settings);
          },
        );
      },
    );
  }
}
```

### 6.2 Auto-Lock on Background

```dart
// In app.dart
class _IchitoAppState extends State<IchitoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused) {
      // Record time when app went to background
      appState.recordBackgroundTime();
    }
    
    if (state == AppLifecycleState.resumed) {
      // Check if auto-lock timeout has elapsed
      if (appState.shouldAutoLock()) {
        appState.lockApp();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.pinLock,
          (_) => false,
        );
      }
    }
  }
}
```

---

## 7. Screen Transition Map

Complete map of every possible navigation path in ICHITO:

```
SPLASH ──fade──> HOME
                  │
                  ├──slide──> CUSTOMER LIST ──slide──> CUSTOMER DETAIL
                  │                │                        │
                  │                ├──slideUp──> CUSTOMER FORM (new)
                  │                │                        │
                  │                │           ┌──slideUp──> CUSTOMER FORM (edit)
                  │                │           │
                  │                │           └──slide──> ORDER DETAIL
                  │
                  ├──slide──> ORDER LIST ──slide──> ORDER DETAIL
                  │                │                    │
                  │                │            ┌── [Add Payment Dialog]
                  │                │            ├── [Status Change]
                  │                │            └──slide──> CUSTOMER DETAIL
                  │
                  ├──slideUp──> ORDER WIZARD (6 steps internal)
                  │                │
                  │                ├── [Step 1: Client Select] ──slideUp──> CUSTOMER FORM (inline)
                  │                ├── [Step 2: Garment Select] ──dialog──> GARMENT FORM (inline)
                  │                ├── [Step 3: Measurements]
                  │                ├── [Step 4: Materials] ──dialog──> FABRIC FORM / DESIGN FORM (inline)
                  │                ├── [Step 5: Pricing]
                  │                └── [Step 6: Review] ──dialog──> SUCCESS DIALOG ──> HOME/ORDER DETAIL
                  │
                  ├──slide──> GARMENT LIST ──slide──> GARMENT DETAIL
                  │                │
                  │                └──dialog──> GARMENT FORM
                  │
                  ├──slide──> FABRIC LIST ──slide──> FABRIC DETAIL
                  │                │
                  │                └──dialog──> FABRIC FORM
                  │
                  ├──slide──> DESIGN LIST ──slide──> DESIGN DETAIL
                  │                │
                  │                └──dialog──> DESIGN FORM
                  │
                  ├──slide──> NOTES LIST
                  │                │
                  │                ├──slideUp──> NORMAL NOTE EDITOR
                  │                ├──slideUp──> CHURCH NOTE EDITOR
                  │                └──slideUp──> CHAMA NOTE EDITOR
                  │
                  ├──slide──> STATISTICS
                  │
                  └──slide──> SETTINGS
                                   │
                                   ├── [Theme Section] (inline expandable)
                                   ├── [Language Section] (inline expandable)
                                   ├── [Security Section]
                                   │        │
                                   │        ├──slideUp──> PIN SETUP
                                   │        └──dialog──> SECURITY CODE DIALOG
                                   ├── [Storage Section]
                                   │        │
                                   │        └── [Backup/Restore file picker]
                                   └── [About Dialog]


PIN LOCK ──fade──> HOME (after successful authentication)
```

---

## 8. Navigation Within Order Wizard

The Order Wizard has its own internal navigation system with 6 steps. It does NOT use named routes for individual steps -- instead, it uses a `PageView` with controlled page transitions.

### 8.1 Wizard Step Navigation

```dart
class OrderWizardScreen extends StatefulWidget {
  @override
  State<OrderWizardScreen> createState() => _OrderWizardScreenState();
}

class _OrderWizardScreenState extends State<OrderWizardScreen>
    with ThemeAwareMixin, UnsavedChangesGuard {
  
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 6;
  
  // Wizard data accumulated across steps
  Customer? _selectedCustomer;
  Garment? _selectedGarment;
  Map<String, double> _measurements = {};
  Fabric? _selectedFabric;
  Design? _selectedDesign;
  double _totalAmount = 0;
  double _depositAmount = 0;
  DateTime? _dueDate;
  DateTime? _trialDate;
  String? _notes;
  String? _specialInstructions;
  
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }
  
  bool _canProceed() {
    switch (_currentStep) {
      case 0: return _selectedCustomer != null;
      case 1: return _selectedGarment != null;
      case 2: return _measurements.isNotEmpty;
      case 3: return true; // Materials are optional
      case 4: return _totalAmount > 0 && _dueDate != null;
      case 5: return true; // Review step, always valid
      default: return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('New Order'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              if (await onWillPop()) Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressBar(),
            
            // Step content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe
                children: [
                  StepClientSelection(
                    selectedCustomer: _selectedCustomer,
                    onSelect: (c) => setState(() => _selectedCustomer = c),
                  ),
                  StepGarmentSelection(
                    selectedGarment: _selectedGarment,
                    onSelect: (g) => setState(() => _selectedGarment = g),
                  ),
                  StepMeasurements(
                    garment: _selectedGarment,
                    customer: _selectedCustomer,
                    measurements: _measurements,
                    onChanged: (m) => setState(() => _measurements = m),
                  ),
                  StepMaterials(
                    selectedFabric: _selectedFabric,
                    selectedDesign: _selectedDesign,
                    onFabricSelect: (f) => setState(() => _selectedFabric = f),
                    onDesignSelect: (d) => setState(() => _selectedDesign = d),
                  ),
                  StepPricing(
                    totalAmount: _totalAmount,
                    depositAmount: _depositAmount,
                    dueDate: _dueDate,
                    trialDate: _trialDate,
                    onChanged: (data) => setState(() { /* update fields */ }),
                  ),
                  StepReview(
                    customer: _selectedCustomer!,
                    garment: _selectedGarment!,
                    measurements: _measurements,
                    fabric: _selectedFabric,
                    design: _selectedDesign,
                    totalAmount: _totalAmount,
                    depositAmount: _depositAmount,
                    dueDate: _dueDate!,
                    trialDate: _trialDate,
                    notes: _notes,
                    onConfirm: _createOrder,
                    onEditStep: (step) {
                      _pageController.animateToPage(step,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                      setState(() => _currentStep = step);
                    },
                  ),
                ],
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step ${_currentStep + 1} of $_totalSteps',
                style: TextStyle(color: textSecondary, fontSize: 12)),
              Text('${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: surfaceColor,
            valueColor: AlwaysStoppedAnimation(accentColor),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: Icon(Icons.arrow_back),
                label: Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canProceed() ? (_currentStep == _totalSteps - 1 ? _createOrder : _nextStep) : null,
              icon: Icon(_currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == _totalSteps - 1 ? 'Create Order' : 'Next'),
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 8.2 Step Labels

| Step | Index | Title | Subtitle |
|------|-------|-------|----------|
| 1 | 0 | Select Client | Choose or add a customer |
| 2 | 1 | Select Garment | Pick the garment type |
| 3 | 2 | Measurements | Enter body measurements |
| 4 | 3 | Materials | Choose fabric and design |
| 5 | 4 | Pricing & Details | Set price, dates, notes |
| 6 | 5 | Review | Confirm and create order |

---

## 9. Dialog Navigation

Dialogs and bottom sheets are used for lightweight creation/editing that doesn't warrant a full screen.

### 9.1 Full-Screen Dialogs

| Dialog | Trigger | Returns |
|--------|---------|---------|
| Add Payment | "Add Payment" button on Order Detail | `Payment?` (null if cancelled) |
| Success Confirmation | After order creation | `String` ('view' or 'new') |
| Security Code | "Forgot PIN?" on Lock Screen | `bool` (verified or not) |

### 9.2 Standard Dialogs

| Dialog | Trigger | Returns |
|--------|---------|---------|
| Delete Confirmation | Delete button on any entity | `bool` (confirmed or not) |
| Discard Confirmation | Back on unsaved form | `String` ('save', 'discard', 'cancel') |
| Exit Confirmation | Back on Home screen | `bool` (exit or not) |
| Status Change | Status button on Order Detail | `String?` (new status or null) |

### 9.3 Bottom Sheets

| Sheet | Trigger | Returns |
|-------|---------|---------|
| Image Source Picker | Camera icon on any image field | `ImageSource?` |
| Sort Options | Sort button on list screens | `SortOption?` |
| Filter Options | Filter button on list screens | `Map<String, dynamic>?` |
| Note Type Selector | "+" button on Notes List | `NoteType?` |
| Add Garment | "+" during order wizard step 2 | `Garment?` |
| Add Fabric | "+" during order wizard step 4 | `Fabric?` |
| Add Design | "+" during order wizard step 4 | `Design?` |

---

## 10. Gesture Navigation

### 10.1 Swipe Gestures

| Gesture | Screen | Action |
|---------|--------|--------|
| Swipe right from edge | Any detail/form screen | Navigate back (system default) |
| Swipe left on order card | Order List | Reveal status change actions |
| Swipe left on customer card | Customer List | Reveal edit/delete actions |
| Swipe down | Radial menu (when open) | Close menu |
| Pull down | Any list screen | Refresh data |
| Pinch | Image preview | Zoom in/out |

### 10.2 Long Press Actions

| Gesture | Target | Action |
|---------|--------|--------|
| Long press order card | Order List | Show quick actions popup (view, edit status, call customer) |
| Long press customer card | Customer List | Show quick actions popup (view, call, new order) |
| Long press note card | Notes List | Show quick actions popup (edit, delete, share) |
| Long press fabric/design card | Catalog/Gallery | Show full-size image preview |

---

*This is Document 03 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
