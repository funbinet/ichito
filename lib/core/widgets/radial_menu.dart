import 'package:flutter/material.dart';
import 'dart:math';
import '../../shared/mixins/theme_aware_mixin.dart';
import '../../shared/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../routes/route_generator.dart';

class RadialMenuItem {
  final String label;
  final IconData icon;
  final String route;
  final double distance;
  final double angle;

  RadialMenuItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.distance,
    required this.angle,
  });
}

class RadialMenu extends StatefulWidget {
  const RadialMenu({super.key});

  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin, ThemeAwareMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  final List<RadialMenuItem> _items = [
    RadialMenuItem(
      label: 'New Order',
      icon: Icons.add_shopping_cart_outlined,
      route: '/orders/new',
      distance: 90,
      angle: -pi / 2, // Top
    ),
    RadialMenuItem(
      label: 'Customers',
      icon: Icons.people_outlined,
      route: '/customers',
      distance: 140,
      angle: -pi * 0.8,
    ),
    RadialMenuItem(
      label: 'Orders',
      icon: Icons.shopping_bag_outlined,
      route: '/orders',
      distance: 140,
      angle: -pi * 0.2,
    ),
    RadialMenuItem(
      label: 'Garments',
      icon: Icons.checkroom_outlined,
      route: '/garments',
      distance: 140,
      angle: -pi,
    ),
    RadialMenuItem(
      label: 'Fabrics',
      icon: Icons.texture_outlined,
      route: '/fabrics',
      distance: 140,
      angle: 0,
    ),
    RadialMenuItem(
      label: 'Designs',
      icon: Icons.palette_outlined,
      route: '/designs',
      distance: 190,
      angle: -pi * 0.85,
    ),
    RadialMenuItem(
      label: 'Notes',
      icon: Icons.note_outlined,
      route: '/notes',
      distance: 190,
      angle: -pi * 0.5,
    ),
    RadialMenuItem(
      label: 'Statistics',
      icon: Icons.bar_chart_outlined,
      route: '/analytics',
      distance: 190,
      angle: -pi * 0.15,
    ),
    RadialMenuItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: '/settings',
      distance: 240,
      angle: -pi * 0.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  List<Widget> _buildRadialItems() {
    final List<Widget> items = [];
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.05,
            1.0,
            curve: Curves.easeOutBack,
          ),
        ),
      );

      items.add(
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double x = cos(item.angle) * item.distance * animation.value;
            final double y = sin(item.angle) * item.distance * animation.value;

            return Positioned(
              bottom: 40 + -y,
              left: MediaQuery.of(context).size.width / 2 - 28 + x,
              child: Transform.scale(
                scale: animation.value,
                child: Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'radial_fab_$i',
                        onPressed: () {
                          _toggle();
                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.pushNamed(context, item.route);
                          });
                        },
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.accentColor,
                        elevation: 4,
                        child: Icon(item.icon),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: AnimatedOpacity(
              opacity: _isOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(color: Colors.black54),
            ),
          ),
        ..._buildRadialItems(),
        Positioned(
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'radial_main_fab',
            onPressed: _toggle,
            backgroundColor: theme.accentColor,
            elevation: 8,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                theme.isLightMode ? 'assets/images/logo_white.png' : 'assets/images/logo_black.png',
                width: 28,
                height: 28,
                color: theme.isLightMode ? Colors.white : Colors.black, // Force contrast
              ),
            ),
          ),
        ),
      ],
    );
  }
}
