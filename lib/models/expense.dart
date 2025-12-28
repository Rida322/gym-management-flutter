class Expense {
  final int id;
  final String entity;
  final double cost;
  final DateTime date;

  Expense({
    required this.id,
    required this.entity,
    required this.cost,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      entity: json['entity'] ?? '',            // ✅ FIX
      cost: (json['cost'] as num).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),                    // ✅ FIX
    );
  }
}
