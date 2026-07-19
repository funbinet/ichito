import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/preferences_provider.dart';
import '../widgets/index.dart';

class PreferencesSettingsScreen extends StatefulWidget {
  const PreferencesSettingsScreen({super.key});

  @override
  State<PreferencesSettingsScreen> createState() => _PreferencesSettingsScreenState();
}

class _PreferencesSettingsScreenState extends State<PreferencesSettingsScreen> with ThemeAwareMixin {
  late PreferencesProvider _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = Provider.of<PreferencesProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Preferences', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 120),
            children: [
              // Display Preferences
              SettingsTile(
                title: 'Display Preferences',
                children: [
                  SettingsDropdown<String>(
                    label: 'Default View',
                    value: prefs.defaultView,
                    description: 'Grid or List view for entity lists',
                    items: [
                      const DropdownMenuItem(value: 'grid', child: Text('Grid')),
                      const DropdownMenuItem(value: 'list', child: Text('List')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultView(value);
                      }
                    },
                  ),
                  SettingsDropdown<int>(
                    label: 'Grid Density',
                    value: prefs.gridDensity,
                    description: 'Items per row in grid view',
                    items: [
                      const DropdownMenuItem(value: 4, child: Text('4 items')),
                      const DropdownMenuItem(value: 8, child: Text('8 items')),
                      const DropdownMenuItem(value: 16, child: Text('16 items')),
                      const DropdownMenuItem(value: 32, child: Text('32 items')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setGridDensity(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Note Settings
              SettingsTile(
                title: 'Note Settings',
                children: [
                  SettingsToggle(
                    label: 'Auto-Save Notes',
                    description: 'Automatically save notes after inactivity',
                    value: prefs.autoSaveNotes,
                    onChanged: (value) {
                      prefs.setAutoSaveNotes(value);
                    },
                  ),
                  if (prefs.autoSaveNotes)
                    SettingsDropdown<int>(
                      label: 'Auto-Save Interval',
                      value: prefs.autoSaveIntervalSeconds,
                      description: 'Wait time before auto-saving',
                      items: [
                        const DropdownMenuItem(value: 1, child: Text('1 second')),
                        const DropdownMenuItem(value: 3, child: Text('3 seconds')),
                        const DropdownMenuItem(value: 5, child: Text('5 seconds')),
                        const DropdownMenuItem(value: 10, child: Text('10 seconds')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          prefs.setAutoSaveIntervalSeconds(value);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Interaction Preferences
              SettingsTile(
                title: 'Interaction Preferences',
                children: [
                  SettingsToggle(
                    label: 'Haptic Feedback',
                    description: 'Vibration on button taps',
                    value: prefs.hapticFeedbackEnabled,
                    onChanged: (value) {
                      prefs.setHapticFeedback(value);
                    },
                  ),
                  SettingsToggle(
                    label: 'Confirm Deletions',
                    description: 'Show confirmation before deleting items',
                    value: prefs.confirmDeletions,
                    onChanged: (value) {
                      prefs.setConfirmDeletions(value);
                    },
                  ),
                  SettingsToggle(
                    label: 'Show Full Order Numbers',
                    description: 'Display complete order ID on cards',
                    value: prefs.showOrderNumberOnCards,
                    onChanged: (value) {
                      prefs.setShowOrderNumberOnCards(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sort Preferences
              SettingsTile(
                title: 'Default Sort Order',
                children: [
                  SettingsDropdown<String>(
                    label: 'Sort Customers By',
                    value: prefs.defaultCustomerSort,
                    items: [
                      const DropdownMenuItem(value: 'name', child: Text('Name')),
                      const DropdownMenuItem(value: 'orders', child: Text('Number of Orders')),
                      const DropdownMenuItem(value: 'spent', child: Text('Total Spent')),
                      const DropdownMenuItem(value: 'recent', child: Text('Recently Added')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultCustomerSort(value);
                      }
                    },
                  ),
                  SettingsDropdown<String>(
                    label: 'Sort Orders By',
                    value: prefs.defaultOrderSort,
                    items: [
                      const DropdownMenuItem(value: 'date', child: Text('Date Created')),
                      const DropdownMenuItem(value: 'due', child: Text('Due Date')),
                      const DropdownMenuItem(value: 'amount', child: Text('Amount')),
                      const DropdownMenuItem(value: 'status', child: Text('Status')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultOrderSort(value);
                      }
                    },
                  ),
                  SettingsDropdown<String>(
                    label: 'Sort Notes By',
                    value: prefs.defaultNoteSort,
                    items: [
                      const DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                      const DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                      const DropdownMenuItem(value: 'title', child: Text('Title')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultNoteSort(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.1),
                  borderRadius: theme.cornerRadius,
                  border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  'Preferences are applied immediately to your view. Sort preferences affect how lists are displayed.',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
