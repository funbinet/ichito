import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/customers/presentation/pages/customer_list_screen.dart';
import '../../features/orders/presentation/pages/order_list_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/onboarding_screen.dart';
import '../../features/settings/presentation/pages/profile_screen.dart';
import '../../features/notes/presentation/pages/notes_list_screen.dart';
import '../../features/garments/presentation/pages/garments_library_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/orders/presentation/pages/order_wizard_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/designs/presentation/pages/designs_list_screen.dart';
import '../../features/fabrics/presentation/pages/fabrics_list_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/profile_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/appearance_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/security_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/language_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/preferences_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/business_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/storage_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/advanced_settings_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/help_screen.dart';
import '../../features/settings/presentation/pages/sub_screens/about_screen.dart';
import '../../features/security/presentation/pages/pin_lock_screen.dart';
import '../../features/security/presentation/pages/pin_setup_screen.dart';
import '../../shared/data/local/settings_repository.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/':
        final SettingsRepository settingsRepo = SettingsRepository();
        final bool isComplete = settingsRepo.isOnboardingComplete();
        page = isComplete ? const DashboardScreen() : const OnboardingScreen();
        break;
      case '/dashboard':
        page = const DashboardScreen();
        break;
      case '/customers':
        page = const CustomerListScreen();
        break;
      case '/orders':
        page = const OrderListScreen();
        break;
      case '/garments':
        page = const GarmentsLibraryScreen();
        break;
      case '/notes':
        page = const NotesListScreen();
        break;
      case '/settings':
        page = const SettingsScreen();
        break;
      case '/settings/profile':
        page = const ProfileSettingsScreen();
        break;
      case '/settings/appearance':
        page = const AppearanceSettingsScreen();
        break;
      case '/settings/security':
        page = const SecuritySettingsScreen();
        break;
      case '/settings/language':
        page = const LanguageSettingsScreen();
        break;
      case '/settings/preferences':
        page = const PreferencesSettingsScreen();
        break;
      case '/settings/business':
        page = const BusinessSettingsScreen();
        break;
      case '/settings/storage':
        page = const StorageSettingsScreen();
        break;
      case '/settings/advanced':
        page = const AdvancedSettingsScreen();
        break;
      case '/settings/help':
        page = const HelpScreen();
        break;
      case '/settings/about':
        page = const AboutScreen();
        break;
      case '/setup_pin':
        page = const PinSetupScreen();
        break;
      case '/lock_screen':
        page = PinLockScreen(onUnlocked: () {});
        break;
      case '/analytics':
        page = const AnalyticsScreen();
        break;
      case '/order_wizard':
        page = const OrderWizardScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/notifications':
        page = const NotificationsScreen();
        break;
      case '/designs':
        page = const DesignsListScreen();
        break;
      case '/fabrics':
        page = const FabricsListScreen();
        break;
      case '/designs/detail':
      case '/designs/form':
      case '/garments/detail':
      case '/garments/form':
      case '/notes/new/normal':
      case '/notes/new/church':
      case '/notes/new/chama':
      case '/settings/pin-setup':
      case '/settings/security-key':
      case '/lock':
      case '/customers/new':
      case '/customers/detail':
      case '/order_detail':
        page = _comingSoonRoute(settings.name!);
        break;
      default:
        page = _errorRoute(settings.name);
    }

    // Default transition (Fade + slight slide)
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutQuart;
        var slideTween = Tween(begin: const Offset(0.05, 0.0), end: Offset.zero).chain(CurveTween(curve: curve));
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Widget _comingSoonRoute(String routeName) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('The feature "$routeName" is under construction.', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  static Widget _errorRoute(String? routeName) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Not Found')),
      body: Center(
        child: Text('ERROR: The route "$routeName" could not be found.'),
      ),
    );
  }
}
