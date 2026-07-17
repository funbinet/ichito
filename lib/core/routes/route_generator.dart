import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    Widget page;
    switch (settings.name) {
      case '/':
        // Normally this would be Splash/Onboarding or Home
        page = const Scaffold(body: Center(child: Text('Splash/Onboarding')));
        break;
      case '/dashboard':
        page = const Scaffold(body: Center(child: Text('Dashboard')));
        break;
      case '/customers':
        page = const Scaffold(body: Center(child: Text('Customers')));
        break;
      case '/orders':
        page = const Scaffold(body: Center(child: Text('Orders')));
        break;
      case '/settings':
        page = const Scaffold(body: Center(child: Text('Settings')));
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
