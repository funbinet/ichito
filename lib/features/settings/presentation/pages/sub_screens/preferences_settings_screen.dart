import 'package:ichito/shared/providers/language_provider.dart';
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
        title: Text('Preferences'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return ListView(
            padding: EdgeInsets.all(16).copyWith(bottom: 120),
            children: [
              // Display Preferences
              SettingsTile(
                title: 'Display Preferences'.t(context),
                children: [
                  SettingsDropdown<String>(
                    label: 'Default View'.t(context),
                    value: prefs.defaultView,
                    description: 'Grid or List view for entity lists',
                    items: [
                      DropdownMenuItem(value: 'grid', child: Text('Grid'.t(context))),
                      DropdownMenuItem(value: 'list', child: Text('List'.t(context))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultView(value);
                      }
                    },
                  ),
                  SettingsDropdown<int>(
                    label: 'Grid Density'.t(context),
                    value: prefs.gridDensity,
                    description: 'Items per row in grid view',
                    items: [
                      DropdownMenuItem(value: 4, child: Text('4 items'.t(context))),
                      DropdownMenuItem(value: 8, child: Text('8 items'.t(context))),
                      DropdownMenuItem(value: 16, child: Text('16 items'.t(context))),
                      DropdownMenuItem(value: 32, child: Text('32 items'.t(context))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setGridDensity(value);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Note Settings
              SettingsTile(
                title: 'Note Settings'.t(context),
                children: [
                  SettingsToggle(
                    label: 'Auto-Save Notes'.t(context),
                    description: 'Automatically save notes after inactivity',
                    value: prefs.autoSaveNotes,
                    onChanged: (value) {
                      prefs.setAutoSaveNotes(value);
                    },
                  ),
                  if (prefs.autoSaveNotes)
                    SettingsDropdown<int>(
                      label: 'Auto-Save Interval'.t(context),
                      value: prefs.autoSaveIntervalSeconds,
                      description: 'Wait time before auto-saving',
                      items: [
                        DropdownMenuItem(value: 1, child: Text('1 second'.t(context))),
                        DropdownMenuItem(value: 3, child: Text('3 seconds'.t(context))),
                        DropdownMenuItem(value: 5, child: Text('5 seconds'.t(context))),
                        DropdownMenuItem(value: 10, child: Text('10 seconds'.t(context))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          prefs.setAutoSaveIntervalSeconds(value);
                        }
                      },
                    ),
                ],
              ),
              SizedBox(height: 12),

              // Interaction Preferences
              SettingsTile(
                title: 'Interaction Preferences'.t(context),
                children: [
                  SettingsToggle(
                    label: 'Haptic Feedback'.t(context),
                    description: 'Vibration on button taps',
                    value: prefs.hapticFeedbackEnabled,
                    onChanged: (value) {
                      prefs.setHapticFeedback(value);
                    },
                  ),
                  SettingsToggle(
                    label: 'Confirm Deletions'.t(context),
                    description: 'Show confirmation before deleting items',
                    value: prefs.confirmDeletions,
                    onChanged: (value) {
                      prefs.setConfirmDeletions(value);
                    },
                  ),
                  SettingsToggle(
                    label: 'Show Full Order Numbers'.t(context),
                    description: 'Display complete order ID on cards',
                    value: prefs.showOrderNumberOnCards,
                    onChanged: (value) {
                      prefs.setShowOrderNumberOnCards(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Sort Preferences
              SettingsTile(
                title: 'Default Sort Order'.t(context),
                children: [
                  SettingsDropdown<String>(
                    label: 'Sort Customers By'.t(context),
                    value: prefs.defaultCustomerSort,
                    items: [
                      DropdownMenuItem(value: 'name', child: Text('Name'.t(context))),
                      DropdownMenuItem(value: 'orders', child: Text('Number of Orders'.t(context))),
                      DropdownMenuItem(value: 'spent', child: Text('Total Spent'.t(context))),
                      DropdownMenuItem(value: 'recent', child: Text('Recently Added'.t(context))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultCustomerSort(value);
                      }
                    },
                  ),
                  SettingsDropdown<String>(
                    label: 'Sort Orders By'.t(context),
                    value: prefs.defaultOrderSort,
                    items: [
                      DropdownMenuItem(value: 'date', child: Text('Date Created'.t(context))),
                      DropdownMenuItem(value: 'due', child: Text('Due Date'.t(context))),
                      DropdownMenuItem(value: 'amount', child: Text('Amount'.t(context))),
                      DropdownMenuItem(value: 'status', child: Text('Status'.t(context))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultOrderSort(value);
                      }
                    },
                  ),
                  SettingsDropdown<String>(
                    label: 'Sort Notes By'.t(context),
                    value: prefs.defaultNoteSort,
                    items: [
                      DropdownMenuItem(value: 'newest', child: Text('Newest First'.t(context))),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest First'.t(context))),
                      DropdownMenuItem(value: 'title', child: Text('Title'.t(context))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        prefs.setDefaultNoteSort(value);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.1),
                  borderRadius: theme.cornerRadius,
                  border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  'Preferences are applied immediately to your view. Sort preferences affect how lists are displayed.'.t(context),
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
