import 'package:flutter/material.dart';
import '../../shared/mixins/theme_aware_mixin.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/language_provider.dart';
import '../../shared/widgets/themed_logo.dart';

class RadialMenuItem {
  final String labelKey;
  final IconData icon;
  final String route;

  RadialMenuItem({
    required this.labelKey,
    required this.icon,
    required this.route,
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;

  final List<RadialMenuItem> _topRowItems = [
    RadialMenuItem(labelKey: 'new_order', icon: Icons.add_shopping_cart_outlined, route: '/order_wizard'),
    RadialMenuItem(labelKey: 'customers', icon: Icons.people_outlined, route: '/customers'),
    RadialMenuItem(labelKey: 'orders', icon: Icons.shopping_bag_outlined, route: '/orders'),
    RadialMenuItem(labelKey: 'garments', icon: Icons.checkroom_outlined, route: '/garments'),
    RadialMenuItem(labelKey: 'fabrics', icon: Icons.texture_outlined, route: '/fabrics'),
    RadialMenuItem(labelKey: 'designs', icon: Icons.palette_outlined, route: '/designs'),
    RadialMenuItem(labelKey: 'statistics', icon: Icons.bar_chart_outlined, route: '/analytics'),
  ];

  final List<RadialMenuItem> _bottomRowItems = [
    RadialMenuItem(labelKey: 'notes', icon: Icons.note_outlined, route: '/notes'),
    RadialMenuItem(labelKey: 'profile', icon: Icons.person_outlined, route: '/profile'),
    RadialMenuItem(labelKey: 'notifications', icon: Icons.notifications_outlined, route: '/notifications'),
    RadialMenuItem(labelKey: 'settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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

  void _navigateTo(String route) {
    _toggle();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pushNamed(context, route);
      }
    });
  }

  Widget _buildGridItem(RadialMenuItem item) {
    return Expanded(
      child: InkWell(
        onTap: () => _navigateTo(item.route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: theme.textPrimary.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                lang.t(item.labelKey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridPanel() {
    return Positioned(
      bottom: 16, // Align bottom of container with the screen bottom to encompass the FAB
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.accentColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: theme.enableShadows ? [
                BoxShadow(
                  color: theme.accentColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              ] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _topRowItems.map((item) => _buildGridItem(item)).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGridItem(_bottomRowItems[0]),
                    _buildGridItem(_bottomRowItems[1]),
                    // Empty space for the FAB to sit over
                    const Expanded(flex: 2, child: SizedBox(height: 50)),
                    _buildGridItem(_bottomRowItems[2]),
                    _buildGridItem(_bottomRowItems[3]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedOpacity(
                opacity: _isOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black54),
              ),
            ),
          ),
        
        if (_isOpen) _buildGridPanel(),
        
        Positioned(
          bottom: 24, // Slightly raised so it visually centers in the bottom row's empty space
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
