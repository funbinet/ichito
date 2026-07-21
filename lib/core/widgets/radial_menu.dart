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
  bool _isOpen = false;

  final List<RadialMenuItem> _menuItems = [
    RadialMenuItem(labelKey: 'home', icon: Icons.home_outlined, route: '/dashboard'),
    RadialMenuItem(labelKey: 'new_order', icon: Icons.add_shopping_cart_outlined, route: '/order_wizard'),
    RadialMenuItem(labelKey: 'customers', icon: Icons.people_outlined, route: '/customers'),
    RadialMenuItem(labelKey: 'orders', icon: Icons.shopping_bag_outlined, route: '/orders'),
    RadialMenuItem(labelKey: 'garments', icon: Icons.checkroom_outlined, route: '/garments'),
    RadialMenuItem(labelKey: 'fabrics', icon: Icons.texture_outlined, route: '/fabrics'),
    RadialMenuItem(labelKey: 'designs', icon: Icons.palette_outlined, route: '/designs'),
    RadialMenuItem(labelKey: 'statistics', icon: Icons.bar_chart_outlined, route: '/analytics'),
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

  Widget _buildGridItem(RadialMenuItem item, int index) {
    return InkWell(
      onTap: () => _navigateTo(item.route),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.accentLight.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: theme.accentColor,
              size: 26,
            ),
          ),
          SizedBox(height: 8),
          Text(
            lang.t(item.labelKey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.fontSize * 0.62,
              color: theme.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: theme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPanel() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          return _buildGridItem(_menuItems[index], index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        
        Positioned(
          bottom: 90,
          left: 16,
          right: 16,
          child: AnimatedOpacity(
            opacity: _isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_isOpen,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
                child: _buildGridPanel(),
              ),
            ),
          ),
        ),
        
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
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
        ),
      ],
    );
  }
}
