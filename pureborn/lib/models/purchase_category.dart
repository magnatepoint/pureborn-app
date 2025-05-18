class PurchaseCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseCategory({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseCategory.fromJson(Map<String, dynamic> json) {
    return PurchaseCategory(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
