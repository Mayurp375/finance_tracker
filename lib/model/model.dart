class Expense {
  final double amount;
  final String category;
  final String? subCategory;
  final DateTime date;
  final String paymentMode;
  final String? vehicle;
  final double? liters;
  
  Expense({
    required this.amount,
    required this.category,
    this.subCategory,
    required this.date,
    required this.paymentMode,
    this.vehicle,
    this.liters,
  });
}

class Income {
  final double amount;
  final String type;
  final DateTime date;
  
  Income({required this.amount, required this.type, required this.date});
}
