class Purchase {
  final String? id;
  final DateTime date;
  final String purchaseCategory;
  final String rawMaterial;
  final double pricePerKg;
  final double quantity;
  final double total;
  final String vendor;
  final double payment;
  final String paymentMethod;
  final double balanceDue;

  Purchase({
    this.id,
    required this.date,
    required this.purchaseCategory,
    required this.rawMaterial,
    required this.pricePerKg,
    required this.quantity,
    required this.total,
    required this.vendor,
    required this.payment,
    required this.paymentMethod,
    required this.balanceDue,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      purchaseCategory: json['purchaseCategory'],
      rawMaterial: json['rawMaterial']['name'] ?? json['rawMaterial'],
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      vendor: json['vendor'],
      payment: (json['payment'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      balanceDue: (json['balanceDue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'purchaseCategory': purchaseCategory,
      'rawMaterial': rawMaterial,
      'pricePerKg': pricePerKg,
      'quantity': quantity,
      'total': total,
      'vendor': vendor,
      'payment': payment,
      'paymentMethod': paymentMethod,
      'balanceDue': balanceDue,
    };
  }
}
