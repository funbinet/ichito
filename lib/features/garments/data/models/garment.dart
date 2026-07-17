import 'dart:convert';

class Garment {
  final String? id;
  final String name;
  final String category; // 'men', 'women', 'unisex'
  final String? description;
  final List<String> measurementFields;
  final double? defaultPrice;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Garment({
    this.id,
    required this.name,
    required this.category,
    this.description,
    required this.measurementFields,
    this.defaultPrice,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'measurement_fields': jsonEncode(measurementFields),
      'default_price': defaultPrice,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Garment.fromMap(Map<String, dynamic> map) {
    return Garment(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      measurementFields: List<String>.from(jsonDecode(map['measurement_fields'] ?? '[]')),
      defaultPrice: map['default_price'],
      usageCount: map['usage_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
