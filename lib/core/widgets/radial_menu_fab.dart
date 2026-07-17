import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../shared/providers/theme_provider.dart';

class RadialMenuFAB extends StatefulWidget {
  final VoidCallback onNewOrder;
  final VoidCallback onAddCustomer;
  final VoidCallback onAddNote;

  const RadialMenuFAB({
    super.key,
    required this.onNewOrder,
    required this.onAddCustomer,
    required this.onAddNote,
  });

  @override
  State<RadialMenuFAB> createState() => _RadialMenuFABState();
}

class _RadialMenuFABState extends State<RadialMenuFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Semi-transparent overlay when open
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
          
          // Action Buttons
          _buildActionButton(
            angle: math.pi / 2, // 90 degrees (Up)
            icon: Icons.add_circle_outline,
            tooltip: 'New Order',
            onPressed: widget.onNewOrder,
            theme: theme,
          ),
          _buildActionButton(
            angle: math.pi / 4, // 45 degrees (Top Left)
            icon: Icons.person_add_outlined,
            tooltip: 'Add Customer',
            onPressed: widget.onAddCustomer,
            theme: theme,
          ),
          _buildActionButton(
            angle: 0, // 0 degrees (Left)
            icon: Icons.note_add_outlined,
            tooltip: 'Add Note',
            onPressed: widget.onAddNote,
            theme: theme,
          ),

          // Main FAB
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: 'radial_main_fab',
              backgroundColor: theme.accentColor,
              foregroundColor: theme.onAccent,
              onPressed: _toggleMenu,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required double angle,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required ThemeProvider theme,
  }) {
    const double radius = 80.0;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double currentRadius = radius * _animation.value;
        final double x = currentRadius * math.cos(angle);
        final double y = currentRadius * math.sin(angle);

        return Positioned(
          right: x + 8, // Offset to align with center of main FAB
          bottom: y + 8,
          child: Transform.scale(
            scale: _animation.value,
            child: FloatingActionButton(
              heroTag: tooltip,
              mini: true,
              backgroundColor: theme.themeMode == ThemeMode.light ? Colors.white : Colors.grey[800],
              foregroundColor: theme.textPrimary,
              tooltip: tooltip,
              onPressed: () {
                _toggleMenu();
                onPressed();
              },
              child: Icon(icon),
            ),
          ),
        );
      },
    );
  }
}
