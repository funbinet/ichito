import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/database/profile_repository.dart';
import '../data/local/settings_repository.dart';

/// Provider that manages the business profile state.
/// 
/// Loads profile data from SQLite on initialization and provides
/// synchronous access to all profile fields. All writes persist to SQLite
/// and SettingsRepository where applicable.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();
  final SettingsRepository _settings = SettingsRepository();

  // Profile fields (from database)
  String _businessName = '';
  String _ownerName = '';
  String _phone = '';
  String _email = '';
  String _location = '';
  double _defaultLaborCost = 1500.0;
  String? _profilePhotoBase64;
  Uint8List? _profilePhotoBytes;

  // Business settings (from repository)
  double _taxRate = 0.0;
  String _orderPrefix = 'ICHITO';

  // Getters - Profile
  String get businessName => _businessName;
  String get ownerName => _ownerName;
  String get phone => _phone;
  String get email => _email;
  String get location => _location;
  double get defaultLaborCost => _defaultLaborCost;
  String? get profilePhotoBase64 => _profilePhotoBase64;
  
  // Getters - Business Settings
  double get taxRate => _taxRate;
  String get orderPrefix => _orderPrefix;
  
  /// Returns the decoded profile photo bytes for use with Image.memory().
  /// Cached to avoid repeated decoding.
  Uint8List? get profilePhotoBytes {
    if (_profilePhotoBase64 == null) return null;
    _profilePhotoBytes ??= base64Decode(_profilePhotoBase64!);
    return _profilePhotoBytes;
  }

  /// Whether a profile has been created (has at least a business name).
  bool get hasProfile => _businessName.isNotEmpty;

  /// Load the profile from SQLite and settings. Call once during app startup.
  Future<void> loadProfile() async {
    final data = await _repo.getProfile();
    if (data != null) {
      _businessName = data['business_name'] ?? '';
      _ownerName = data['owner_name'] ?? '';
      _phone = data['phone'] ?? '';
      _email = data['email'] ?? '';
      _location = data['location'] ?? '';
      _defaultLaborCost = (data['default_labor_cost'] as num?)?.toDouble() ?? 1500.0;
      _profilePhotoBase64 = data['profile_photo'];
      _profilePhotoBytes = null; // Reset cached bytes
    }
    
    // Load business settings from repository
    _taxRate = _settings.getTaxRate();
    _orderPrefix = _settings.getOrderPrefix();
    
    notifyListeners();
  }

  /// Save all profile fields to SQLite.
  Future<void> saveProfile({
    required String businessName,
    required String ownerName,
    required String phone,
    String email = '',
    String location = '',
    double defaultLaborCost = 1500.0,
    String? profilePhoto,
  }) async {
    _businessName = businessName;
    _ownerName = ownerName;
    _phone = phone;
    _email = email;
    _location = location;
    _defaultLaborCost = defaultLaborCost;
    if (profilePhoto != null) {
      _profilePhotoBase64 = profilePhoto;
      _profilePhotoBytes = null; // Reset cached bytes
    }
    notifyListeners();

    await _repo.saveProfile(
      businessName: businessName,
      ownerName: ownerName,
      phone: phone,
      email: email,
      location: location,
      defaultLaborCost: defaultLaborCost,
      profilePhoto: profilePhoto ?? _profilePhotoBase64,
    );
  }

  /// Update only the profile photo.
  Future<void> updateProfilePhoto(String base64Photo) async {
    _profilePhotoBase64 = base64Photo;
    _profilePhotoBytes = null;
    notifyListeners();
    await _repo.updateProfilePhoto(base64Photo);
  }

  /// Remove the profile photo.
  Future<void> removeProfilePhoto() async {
    _profilePhotoBase64 = null;
    _profilePhotoBytes = null;
    notifyListeners();
    await _repo.updateProfilePhoto(null);
  }

  /// Set tax rate (persists to settings repository).
  Future<void> setTaxRate(double rate) async {
    _taxRate = rate;
    notifyListeners();
    await _settings.setTaxRate(rate);
  }

  /// Set order prefix (persists to settings repository).
  Future<void> setOrderPrefix(String prefix) async {
    _orderPrefix = prefix;
    notifyListeners();
    await _settings.setOrderPrefix(prefix);
  }
}
