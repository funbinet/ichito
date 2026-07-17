import 'package:flutter/material.dart';
import 'radial_menu.dart';

class IchitoScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showRadialMenu;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const IchitoScaffold({
    required this.body,
    this.appBar,
    this.showRadialMenu = true,
    this.backgroundColor,
    this.floatingActionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          if (showRadialMenu) const Positioned.fill(child: RadialMenu()),
        ],
      ),
    );
  }
}
