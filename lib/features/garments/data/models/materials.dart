class Fabric {
  final String? id;
  final String name;
  final String? description;
  final double pricePerUnit;
  final String unit;
  final String? category;
  final String? color;
  final String? imagePath;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fabric({
    this.id,
    required this.name,
    this.description,
    required this.pricePerUnit,
    required this.unit,
    this.category,
    this.color,
    this.imagePath,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_unit': pricePerUnit,
      'unit': unit,
      'category': category,
      'color': color,
      'image_path': imagePath,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Fabric.fromMap(Map<String, dynamic> map) {
    return Fabric(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      pricePerUnit: map['price_per_unit'],
      unit: map['unit'],
      category: map['category'],
      color: map['color'],
      imagePath: map['image_path'],
      usageCount: map['usage_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class Design {
  final String? id;
  final String name;
  final String? description;
  final String? category;
  final String? imagePath;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Design({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.imagePath,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

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
}
