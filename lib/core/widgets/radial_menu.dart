import 'package:flutter/material.dart';
import 'dart:math';
import '../../shared/mixins/theme_aware_mixin.dart';
import '../../shared/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../routes/route_generator.dart';
import '../../shared/widgets/themed_logo.dart';

class RadialMenuItem {
  final String label;
  final IconData icon;
  final String route;
  final int ring; // 1, 2, or 3

  RadialMenuItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.ring,
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

  // Ring 1 (innermost): New Order
  // Ring 2 (middle): Customers, Orders, Profile, Notifications
  // Ring 3 (outermost): Garments, Fabrics, Designs, Notes, Statistics, Settings
  final List<RadialMenuItem> _items = [
    // Ring 1 — center top
    RadialMenuItem(label: 'New Order', icon: Icons.add_shopping_cart_outlined, route: '/order_wizard', ring: 1),
    // Ring 2 — 4 items spread in arc
    RadialMenuItem(label: 'Customers', icon: Icons.people_outlined, route: '/customers', ring: 2),
    RadialMenuItem(label: 'Orders', icon: Icons.shopping_bag_outlined, route: '/orders', ring: 2),
    RadialMenuItem(label: 'Profile', icon: Icons.person_outlined, route: '/profile', ring: 2),
    RadialMenuItem(label: 'Notifications', icon: Icons.notifications_outlined, route: '/notifications', ring: 2),
    // Ring 3 — 6 items in wider arc
    RadialMenuItem(label: 'Garments', icon: Icons.checkroom_outlined, route: '/garments', ring: 3),
    RadialMenuItem(label: 'Fabrics', icon: Icons.texture_outlined, route: '/fabrics', ring: 3),
    RadialMenuItem(label: 'Designs', icon: Icons.palette_outlined, route: '/designs', ring: 3),
    RadialMenuItem(label: 'Notes', icon: Icons.note_outlined, route: '/notes', ring: 3),
    RadialMenuItem(label: 'Statistics', icon: Icons.bar_chart_outlined, route: '/analytics', ring: 3),
    RadialMenuItem(label: 'Settings', icon: Icons.settings_outlined, route: '/settings', ring: 3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 280),
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

  /// Calculate position for each item based on its ring and index within that ring.
  /// Items are arranged in concentric semicircular arcs above the FAB.
  List<Widget> _buildRadialItems() {
    final List<Widget> items = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;

    // Ring configurations: radius, items in ring, angular span
    const ring1Radius = 85.0;
    const ring2Radius = 145.0;
    const ring3Radius = 210.0;

    // Separate items by ring
    final ring1 = _items.where((i) => i.ring == 1).toList();
    final ring2 = _items.where((i) => i.ring == 2).toList();
    final ring3 = _items.where((i) => i.ring == 3).toList();

    // Build each ring
    _buildRing(items, ring1, ring1Radius, pi * 0.15, centerX, 0);
    _buildRing(items, ring2, ring2Radius, pi * 0.65, centerX, ring1.length);
    _buildRing(items, ring3, ring3Radius, pi * 0.80, centerX, ring1.length + ring2.length);

    return items;
  }

  void _buildRing(List<Widget> items, List<RadialMenuItem> ringItems,
      double radius, double arcSpan, double centerX, int indexOffset) {
    for (int i = 0; i < ringItems.length; i++) {
      final item = ringItems[i];
      final totalItems = ringItems.length;

      // Distribute items evenly within the arc span, centered on the vertical
      // The arc spans from (-pi/2 - arcSpan/2) to (-pi/2 + arcSpan/2)
      double angle;
      if (totalItems == 1) {
        angle = -pi / 2; // straight up
      } else {
        final step = arcSpan / (totalItems - 1);
        angle = (-pi / 2 - arcSpan / 2) + (i * step);
      }

      final globalIndex = indexOffset + i;
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (globalIndex * 0.04).clamp(0.0, 0.6),
            1.0,
            curve: Curves.easeOutBack,
          ),
        ),
      );

      items.add(
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double x = cos(angle) * radius * animation.value;
            final double y = sin(angle) * radius * animation.value;

            return Positioned(
              bottom: 40 + -y,
              left: centerX - 24 + x,
              child: Transform.scale(
                scale: animation.value,
                child: Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.accentColor.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FloatingActionButton.small(
                          heroTag: 'radial_fab_$globalIndex',
                          onPressed: () {
                            _toggle();
                            Future.delayed(const Duration(milliseconds: 150), () {
                              Navigator.pushNamed(context, item.route);
                            });
                          },
                          backgroundColor: theme.cardColor,
                          foregroundColor: theme.accentColor,
                          elevation: 0,
                          child: Icon(item.icon),
                        ),
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
                          style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
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
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.accentColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: FloatingActionButton(
              heroTag: 'radial_main_fab',
              onPressed: _toggle,
              backgroundColor: theme.accentColor,
              elevation: 8,
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: ThemedLogo(
                  size: 28,
                  color: theme.onAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
