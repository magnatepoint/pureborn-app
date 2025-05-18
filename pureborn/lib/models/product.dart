class Product {
  final String? id;
  final String name;
  final String category;
  final String productCode;
  final double costPrice;
  final double sellingPrice;
  final String hsnCode;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.productCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.hsnCode,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      productCode: json['productCode'],
      costPrice: (json['costPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      hsnCode: json['hsnCode'],
      quantity: json['quantity'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'productCode': productCode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'hsnCode': hsnCode,
      'quantity': quantity,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? productCode,
    double? costPrice,
    double? sellingPrice,
    String? hsnCode,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      productCode: productCode ?? this.productCode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
