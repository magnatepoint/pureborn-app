class Expense {
  final String id;
  final DateTime date;
  final String name;
  final String description;
  final String category;
  final Payment payment;
  final double total;
  final double balanceDue;

  Expense({
    required this.id,
    required this.date,
    required this.name,
    required this.description,
    required this.category,
    required this.payment,
    required this.total,
    required this.balanceDue,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      description: json['description'],
      category: json['category'],
      payment: Payment.fromJson(json['payment']),
      total: json['total'].toDouble(),
      balanceDue: json['balanceDue'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'name': name,
      'description': description,
      'category': category,
      'payment': payment.toJson(),
      'total': total,
      'balanceDue': balanceDue,
    };
  }
}

class Payment {
  final double cash;
  final double online;
  final double credit;

  Payment({this.cash = 0, this.online = 0, this.credit = 0});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      cash: (json['cash'] ?? 0).toDouble(),
      online: (json['online'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cash': cash, 'online': online, 'credit': credit};
  }
}
