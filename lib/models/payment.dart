class Payment {
  final int id;
  final String email;
  final String phone;
  final double amount;
  final String method;
  final DateTime startDate;
  final DateTime endDate;

  Payment({
    required this.id,
    required this.email,
    required this.phone,
    required this.amount,
    required this.method,
    required this.startDate,
    required this.endDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      email: json['email'] ?? '',              // ✅ FIX
      phone: json['phoneNumber'] ?? '',        // ✅ FIX
      amount: (json['amount'] as num).toDouble(),
      method: json['paymentMethod'] ?? 'Cash',// ✅ FIX
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),                    // ✅ FIX
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),                    // ✅ FIX
    );
  }
}
