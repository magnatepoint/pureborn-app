class DayCounter {
  final String? id;
  final DateTime date;
  final double openingBalance;
  final Payments payments;
  final double expenses;
  final double totalDayCounter;
  final double cashHandOver;
  final double actualClosingCounter;
  final double closingBalance;
  final double difference;
  final String remarks;

  DayCounter({
    this.id,
    required this.date,
    required this.openingBalance,
    required this.payments,
    required this.expenses,
    required this.totalDayCounter,
    required this.cashHandOver,
    required this.actualClosingCounter,
    required this.closingBalance,
    required this.difference,
    required this.remarks,
  });

  factory DayCounter.fromJson(Map<String, dynamic> json) {
    try {
      return DayCounter(
        id: json['_id'],
        date: DateTime.parse(json['date']),
        openingBalance: (json['openingBalance'] as num).toDouble(),
        payments: Payments.fromJson(json['payments']),
        expenses: (json['expenses'] as num).toDouble(),
        totalDayCounter: (json['totalDayCounter'] as num).toDouble(),
        cashHandOver: (json['cashHandOver'] as num).toDouble(),
        actualClosingCounter: (json['actualClosingCounter'] as num).toDouble(),
        closingBalance: (json['closingBalance'] as num).toDouble(),
        difference: (json['difference'] as num).toDouble(),
        remarks: json['remarks'] ?? '',
      );
    } catch (e) {
      throw Exception('DayCounter.fromJson error: \$e, json: \$json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'openingBalance': openingBalance,
      'payments': payments.toJson(),
      'expenses': expenses,
      'totalDayCounter': totalDayCounter,
      'cashHandOver': cashHandOver,
      'actualClosingCounter': actualClosingCounter,
      'closingBalance': closingBalance,
      'difference': difference,
      'remarks': remarks,
    };
  }

  // Computed properties for UI
  double get amount => totalDayCounter;
  double get balanceDue => difference;
  String get description => remarks;
  String get paymentMethod {
    final methods = <String>[];
    if (payments.cash > 0) methods.add('Cash');
    if (payments.upi > 0) methods.add('UPI');
    if (payments.card > 0) methods.add('Card');
    if (payments.credit > 0) methods.add('Credit');
    return methods.isEmpty ? 'None' : methods.join(', ');
  }
}

class Payments {
  final double cash;
  final double upi;
  final double card;
  final double credit;

  Payments({
    required this.cash,
    required this.upi,
    required this.card,
    required this.credit,
  });

  factory Payments.fromJson(Map<String, dynamic> json) {
    try {
      return Payments(
        cash: (json['cash'] as num).toDouble(),
        upi: (json['upi'] as num).toDouble(),
        card: (json['card'] as num).toDouble(),
        credit: (json['credit'] as num).toDouble(),
      );
    } catch (e) {
      throw Exception('Payments.fromJson error: \$e, json: \$json');
    }
  }

  Map<String, dynamic> toJson() {
    return {'cash': cash, 'upi': upi, 'card': card, 'credit': credit};
  }
}
