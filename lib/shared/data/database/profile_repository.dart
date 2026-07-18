import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// Repository for the business profile stored in SQLite.
/// 
/// The business_profile table has a single row (id=1).
/// Profile photo is stored as a base64-encoded string directly in the database.
class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Returns the profile data as a map, or null if no profile exists.
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await _dbHelper.database;
    final results = await db.query('business_profile', where: 'id = 1');
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Creates or updates the business profile (upsert).
  Future<void> saveProfile({
    required String businessName,
    required String ownerName,
    required String phone,
    String email = '',
    String location = '',
    double defaultLaborCost = 1500.0,
    String? profilePhoto,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final existing = await getProfile();
    if (existing != null) {
      // Update existing profile
      final updateData = <String, dynamic>{
        'business_name': businessName,
        'owner_name': ownerName,
        'phone': phone,
        'email': email,
        'location': location,
        'default_labor_cost': defaultLaborCost,
        'updated_at': now,
      };
      if (profilePhoto != null) {
        updateData['profile_photo'] = profilePhoto;
      }
      await db.update('business_profile', updateData, where: 'id = 1');
    } else {
      // Insert new profile
      await db.insert('business_profile', {
        'id': 1,
        'business_name': businessName,
        'owner_name': ownerName,
        'phone': phone,
        'email': email,
        'location': location,
        'default_labor_cost': defaultLaborCost,
        'profile_photo': profilePhoto,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Updates only the profile photo (base64 string).
  Future<void> updateProfilePhoto(String? base64Photo) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final existing = await getProfile();
    if (existing != null) {
      await db.update(
        'business_profile',
        {'profile_photo': base64Photo, 'updated_at': now},
        where: 'id = 1',
      );
    } else {
      // Create a minimal profile with just the photo
      await db.insert('business_profile', {
        'id': 1,
        'business_name': '',
        'owner_name': '',
        'phone': '',
        'email': '',
        'location': '',
        'default_labor_cost': 1500.0,
        'profile_photo': base64Photo,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Updates a single field in the profile.
  Future<void> updateField(String fieldName, dynamic value) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'business_profile',
      {fieldName: value, 'updated_at': now},
      where: 'id = 1',
    );
  }
}
