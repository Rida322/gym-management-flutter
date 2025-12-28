import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ PAGES
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'members_screen.dart';
import 'subscription_screen.dart';
import 'reports_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {

  static const bgDark = Color(0xFF14141E);
  static const sidebarDark = Color(0xFF191923);

  late TabController tabController;

  List payments = [];
  List expenses = [];

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  String get baseUrl => dotenv.env['API_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchPayments();
    fetchExpenses();
  }

  // ================= FETCH =================
  Future<void> fetchPayments() async {
    final res = await http.get(Uri.parse('$baseUrl/api/admin/payments'));
    setState(() => payments = jsonDecode(res.body));
  }

  Future<void> fetchExpenses() async {
    final res = await http.get(
      Uri.parse(
          '$baseUrl/api/admin/payments/expenses/filter?month=$month&year=$year'),
    );
    setState(() => expenses = jsonDecode(res.body));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      drawer: _drawer(context), // ✅ ADDED
      appBar: AppBar(
        title: const Text("Payment & Expenses"),
        backgroundColor: sidebarDark,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Payments"),
            Tab(text: "Expenses"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          paymentsTab(),
          expensesTab(),
        ],
      ),
    );
  }

  // ================= PAYMENTS =================
  Widget paymentsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: showRecordPaymentDialog,
              child: const Text("Record Payment"),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Start")),
                DataColumn(label: Text("End")),
                DataColumn(label: Text("Action")),
              ],
              rows: payments.map<DataRow>((p) {
                return DataRow(cells: [
                  DataCell(Text(p['name'] ?? '-')),
                  DataCell(Text(p['email'] ?? '-')),
                  DataCell(Text(p['phone'] ?? '-')),
                  DataCell(Text("\$${p['amount']}")),
                  DataCell(Text(p['startDate'] ?? '-')),
                  DataCell(Text(p['endDate'] ?? '-')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await http.delete(
                          Uri.parse('$baseUrl/api/admin/payments/${p['id']}'),
                        );
                        fetchPayments();
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // ================= EXPENSES =================
  Widget expensesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<int>(
                value: month,
                items: List.generate(12, (i) =>
                    DropdownMenuItem(value: i + 1, child: Text("${i + 1}"))),
                onChanged: (v) => setState(() => month = v!),
              ),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: year,
                items: List.generate(5, (i) =>
                    DropdownMenuItem(value: 2023 + i, child: Text("${2023 + i}"))),
                onChanged: (v) => setState(() => year = v!),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: fetchExpenses,
                child: const Text("Filter"),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: showAddExpenseDialog,
                child: const Text("Add Expense"),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Entity")),
                DataColumn(label: Text("Cost")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Action")),
              ],
              rows: expenses.map<DataRow>((e) {
                return DataRow(cells: [
                  DataCell(Text(e['entity'])),
                  DataCell(Text("\$${e['cost']}")),
                  DataCell(Text(e['date'] ?? '-')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await http.delete(
                          Uri.parse(
                              '$baseUrl/api/admin/payments/expenses/${e['id']}'),
                        );
                        fetchExpenses();
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // ================= RECORD PAYMENT =================
  void showRecordPaymentDialog() {
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: "3");

    String plan = "1 Day (\$3)";
    String method = "Cash";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Record Payment",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                _dialogInput("Search Member (by phone)", phoneCtrl),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    findMemberByPhone(phoneCtrl, nameCtrl, emailCtrl);
                  },
                  child: const Text("Find Member"),
                ),



                const SizedBox(height: 15),
                _dialogInput("Member Name", nameCtrl),
                _dialogInput("Email", emailCtrl),
                _dialogInput("Phone Number", phoneCtrl),

                const SizedBox(height: 10),
                _dialogDropdown(
                  "Subscription Plan",
                  plan,
                  ["1 Day (\$3)", "1 Month (\$25)", "2 Months (\$45)", "3 Months (\$65)"],
                      (v) => plan = v,
                ),

                const SizedBox(height: 8),
                Text("Price: \$${priceCtrl.text}",
                    style: const TextStyle(color: Colors.white70)),

                const SizedBox(height: 10),
                _dialogDropdown(
                  "Payment Method",
                  method,
                  ["Cash", "Card"],
                      (v) => method = v,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await recordPayment(
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                          amount: double.parse(priceCtrl.text),
                        );

                        Navigator.pop(context);
                      },
                      child: const Text("Record Payment"),
                    ),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ================= ADD EXPENSE =================
  void showAddExpenseDialog() {
    final entityCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Expense",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                _dialogInput("Entity", entityCtrl),
                _dialogInput("Cost", costCtrl,
                    type: TextInputType.number),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await http.post(
                          Uri.parse(
                              '$baseUrl/api/admin/payments/expenses'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "entity": entityCtrl.text,
                            "cost": double.parse(costCtrl.text),
                          }),
                        );

                        Navigator.pop(context);
                        fetchExpenses();
                      },
                      child: const Text("Add Expense"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ================= DRAWER (ONLY NEW PART) =================

  Drawer _drawer(BuildContext context) {
    return Drawer(
      backgroundColor: sidebarDark,
      child: Column(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("💳", style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text("Welcome", style: TextStyle(color: Colors.white70)),
                Text(
                  "Admin",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          _navItem(context, "Dashboard", const AdminDashboardScreen()),
          _navItem(context, "Members", const MembersScreen()),
          _navItem(context, "Payments", const PaymentScreen()),
          _navItem(context, "Subscriptions", const SubscriptionScreen()),
          _navItem(context, "Reports",  ReportsScreen()),

          const Spacer(),

          ListTile(
            title: const Text("Logout",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _navItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
  Widget _dialogInput(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2A2A40),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _dialogDropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF2A2A40),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
  Future<void> findMemberByPhone(
      TextEditingController phoneCtrl,
      TextEditingController nameCtrl,
      TextEditingController emailCtrl,
      ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/payments/member/${phoneCtrl.text}'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        nameCtrl.text = data['name'];
        emailCtrl.text = data['email'];
        phoneCtrl.text = data['phoneNumber'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member not found")),
      );
    }
  }
  Future<void> recordPayment({
    required String email,
    required String phone,
    required double amount,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/admin/payments'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "phoneNumber": phone,
        "amount": amount,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      fetchPayments(); // 🔥 refresh table
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${res.body}")),
      );
    }
  }




}
