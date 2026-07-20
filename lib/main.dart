import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shared/providers/theme_provider.dart';
import 'shared/providers/language_provider.dart';
import 'shared/providers/app_state_provider.dart';
import 'shared/providers/profile_provider.dart';
import 'shared/providers/notification_provider.dart';
import 'shared/providers/customer_provider.dart';
import 'shared/providers/order_provider.dart';
import 'shared/data/database/database_helper.dart';
import 'shared/data/local/settings_repository.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/security/presentation/pages/pin_lock_screen.dart';
import 'core/routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database (creates/migrates tables)
  await DatabaseHelper.instance.database;

  // Initialize Settings from SQLite
  final settingsRepo = SettingsRepository();
  await settingsRepo.initialize();

  // Initialize Local Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create providers
  final themeProvider = ThemeProvider();
  themeProvider.loadFromSettings(settingsRepo.getThemeMode());
  // Load accent color if saved
  final savedAccent = settingsRepo.getAccentColor();
  if (savedAccent != null) {
    themeProvider.setAccentColor(Color(savedAccent));
  }

  final languageProvider = LanguageProvider();
  final savedLang = settingsRepo.getLanguage();
  languageProvider.setLanguage(
    savedLang == 'sheng' ? AppLanguage.sheng : AppLanguage.english,
  );
  languageProvider.setCurrency(settingsRepo.getCurrency());
  languageProvider.setMeasurementUnit(settingsRepo.getMeasurementUnit());

  final profileProvider = ProfileProvider();
  await profileProvider.loadProfile();

  final notificationProvider = NotificationProvider();
  await notificationProvider.loadNotifications();

  final customerProvider = CustomerProvider();
  await customerProvider.loadCustomers();

  final orderProvider = OrderProvider();
  await orderProvider.loadOrders();

  // Check for due orders and generate notifications
  await notificationProvider.checkOrderDueDates();

  // Show a push notification if there are unread notifications
  if (notificationProvider.unreadCount > 0) {
    final dueNotifications = notificationProvider.notifications
        .where((n) => n.type == 'order_due' && !n.isRead)
        .toList();
    if (dueNotifications.isNotEmpty) {
      final bodies = dueNotifications.take(5).map((n) => n.body).join('\n');
      await notificationService.showOrdersDueSummary(
        count: dueNotifications.length,
        body: bodies,
      );
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => AppStateProvider()..initialize()),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: customerProvider),
        ChangeNotifierProvider.value(value: orderProvider),
      ],
      child: const IchitoApp(),
    ),
  );
}

class IchitoApp extends StatefulWidget {
  const IchitoApp({super.key});

  @override
  State<IchitoApp> createState() => _IchitoAppState();
}

class _IchitoAppState extends State<IchitoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Provider.of<AppStateProvider>(context, listen: false).updateLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ICHITO'.t(context),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: themeProvider.themeMode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: themeProvider.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.accentColor,
          brightness: themeProvider.themeMode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: themeProvider.fontFamily,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        final appState = Provider.of<AppStateProvider>(context);
        final scaledChild = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.fontSize / 16.0),
          ),
          child: child!,
        );
        if (appState.isLocked) {
          return Scaffold(
            body: PinLockScreen(
              onUnlocked: () => appState.unlock(),
            ),
          );
        }
        return scaledChild;
      },
    );
  }
}
