class RawMaterial {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RawMaterial({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory RawMaterial.fromJson(Map<String, dynamic> json) {
    return RawMaterial(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'category': category};
  }
}
