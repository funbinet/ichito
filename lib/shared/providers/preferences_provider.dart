import 'package:flutter/foundation.dart';
import '../data/local/settings_repository.dart';

/// Provider for user preferences (default views, sort options, toggles, etc.).
/// 
/// Manages all settings from the Preferences section:
/// - Default view (grid/list)
/// - Grid density (4, 8, 16, 32)
/// - Auto-save notes + interval
/// - Haptic feedback, confirm deletions, show order numbers
/// - Default sort for customers, orders, notes
class PreferencesProvider extends ChangeNotifier {
  final SettingsRepository _settings;

  PreferencesProvider(this._settings);

  // ─── Getters (synchronous from cache) ──────────────────────────

  String get defaultView => _settings.getDefaultView();
  int get gridDensity => _settings.getGridDensity();
  bool get autoSaveNotes => _settings.getAutoSaveNotes();
  int get autoSaveIntervalSeconds => _settings.getAutoSaveIntervalSeconds();
  bool get hapticFeedbackEnabled => _settings.getHapticFeedback();
  bool get confirmDeletions => _settings.getConfirmDeletions();
  bool get showOrderNumberOnCards => _settings.getShowOrderNumberOnCards();
  String get defaultCustomerSort => _settings.getDefaultCustomerSort();
  String get defaultOrderSort => _settings.getDefaultOrderSort();
  String get defaultNoteSort => _settings.getDefaultNoteSort();

  // ─── Setters (async, notifies listeners) ──────────────────────

  Future<void> setDefaultView(String view) async {
    await _settings.setDefaultView(view);
    notifyListeners();
  }

  Future<void> setGridDensity(int density) async {
    await _settings.setGridDensity(density);
    notifyListeners();
  }

  Future<void> setAutoSaveNotes(bool enabled) async {
    await _settings.setAutoSaveNotes(enabled);
    notifyListeners();
  }

  Future<void> setAutoSaveIntervalSeconds(int seconds) async {
    await _settings.setAutoSaveIntervalSeconds(seconds);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    await _settings.setHapticFeedback(enabled);
    notifyListeners();
  }

  Future<void> setConfirmDeletions(bool enabled) async {
    await _settings.setConfirmDeletions(enabled);
    notifyListeners();
  }

  Future<void> setShowOrderNumberOnCards(bool show) async {
    await _settings.setShowOrderNumberOnCards(show);
    notifyListeners();
  }

  Future<void> setDefaultCustomerSort(String sort) async {
    await _settings.setDefaultCustomerSort(sort);
    notifyListeners();
  }

  Future<void> setDefaultOrderSort(String sort) async {
    await _settings.setDefaultOrderSort(sort);
    notifyListeners();
  }

  Future<void> setDefaultNoteSort(String sort) async {
    await _settings.setDefaultNoteSort(sort);
    notifyListeners();
  }
}
