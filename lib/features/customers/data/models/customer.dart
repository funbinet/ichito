import 'dart:convert';

class Customer {
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String gender;
  final String? location;
  final String? photoPath;
  final Map<String, double>? measurements;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Virtual properties computed by DB/UI
  int totalOrders;
  double totalSpent;
  double averageOrderValue;
  DateTime? lastOrderDate;
  List<String> preferredGarments;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.gender,
    this.location,
    this.photoPath,
    this.measurements,
    required this.createdAt,
    required this.updatedAt,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.averageOrderValue = 0,
    this.lastOrderDate,
    this.preferredGarments = const [],
  });

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String get loyaltyStatus {
    if (totalSpent > 50000) return 'VIP';
    if (totalSpent > 20000) return 'Regular';
    if (totalOrders > 3) return 'Loyal';
    return 'New';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'location': location,
      'photo_path': photoPath,
      'measurements': measurements != null ? jsonEncode(measurements) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    Map<String, double>? parsedMeasurements;
    if (map['measurements'] != null && map['measurements'].toString().isNotEmpty) {
      final decoded = jsonDecode(map['measurements']) as Map<String, dynamic>;
      parsedMeasurements = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    return Customer(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      gender: map['gender'] ?? 'unisex',
      location: map['location'],
      photoPath: map['photo_path'],
      measurements: parsedMeasurements,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
