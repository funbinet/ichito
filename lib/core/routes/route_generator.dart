import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/customers/presentation/pages/customer_list_screen.dart';
import '../../features/orders/presentation/pages/order_list_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/onboarding_screen.dart';
import '../../features/notes/presentation/pages/notes_list_screen.dart';
import '../../features/garments/presentation/pages/garments_library_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/orders/presentation/pages/order_wizard_screen.dart';
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
      case '/analytics':
        page = const AnalyticsScreen();
        break;
      case '/order_wizard':
        page = const OrderWizardScreen();
        break;
      default:
        page = _errorRoute();
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

  static Widget _errorRoute() {
    return const Scaffold(
      body: Center(
        child: Text('ERROR: Route not found.'),
      ),
    );
  }
}
