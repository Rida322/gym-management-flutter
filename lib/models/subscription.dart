class Subscription {
  String name;
  String phone;
  double amount;
  String method;
  DateTime startDate;
  DateTime endDate;
  int daysLeft;

  Subscription({
    required this.name,
    required this.phone,
    required this.amount,
    required this.method,
    required this.startDate,
    required this.endDate,
    required this.daysLeft,
  });
}
