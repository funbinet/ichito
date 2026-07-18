import 'package:uuid/uuid.dart';

class Design {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? imagePath;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Design({
    String? id,
    required this.name,
    this.description,
    this.category,
    this.imagePath,
    this.usageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'image_path': imagePath,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Design.fromMap(Map<String, dynamic> map) {
    return Design(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      imagePath: map['image_path'],
      usageCount: map['usage_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Design copyWith({
    String? name,
    String? description,
    String? category,
    String? imagePath,
    int? usageCount,
  }) {
    return Design(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
