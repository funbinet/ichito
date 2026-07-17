import 'package:flutter/material.dart';

mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  Future<bool> handleWillPop() async {
    if (hasUnsavedChanges()) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  // Override this in your state to indicate if there are unsaved changes
  bool hasUnsavedChanges() => false;

  void navigateTo(String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  void navigateAndReplace(String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
}
