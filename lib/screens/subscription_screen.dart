import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ PAGES
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'members_screen.dart';
import 'payment_screen.dart';
import 'reports_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // ===== THEME =====
  static const bgDark = Color(0xFF14141E);
  static const sidebarDark = Color(0xFF191923);
  static const cardDark = Color(0xFF232332);

  List subscriptions = [];
  bool loading = false;

  String get baseUrl => dotenv.env['API_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    loadExpiringSoon();
  }

  // ================= API =================

  Future<void> loadExpiringSoon() async {
    setState(() => loading = true);

    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/subscriptions/expiring-soon'),
    );

    setState(() {
      subscriptions = jsonDecode(res.body);
      loading = false;
    });
  }

  Future<void> loadExpired() async {
    setState(() => loading = true);

    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/subscriptions/expired'),
    );

    setState(() {
      subscriptions = jsonDecode(res.body);
      loading = false;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      drawer: _drawer(context),
      appBar: AppBar(
        backgroundColor: sidebarDark,
        title: const Text("Subscriptions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _title(),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 25),
            _banner(),
            const SizedBox(height: 25),
            Expanded(child: loading ? _loader() : _table()),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Column(
      children: const [
        Text(
          "Subscriptions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Track expiring & expired memberships",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }

  Widget _toolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _button("Expired", Colors.red, loadExpired),
        const SizedBox(width: 15),
        _button("7 Days Till Expired", Colors.orange, loadExpiringSoon),
        const SizedBox(width: 15),
        _button("Send Message", Colors.blue, sendWhatsAppReminders),
      ],
    );
  }

  Widget _banner() {
    return Card(
      color: cardDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("📅", style: TextStyle(fontSize: 40)),
            SizedBox(width: 15),
            Column(
              children: [
                Text(
                  "Keep your members motivated!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Timely reminders improve retention",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _loader() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _table() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Phone")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Method")),
          DataColumn(label: Text("Start")),
          DataColumn(label: Text("End")),
          DataColumn(label: Text("Days Left")),
        ],
        rows: subscriptions.map<DataRow>((s) {
          final daysLeft = s['daysLeft'];
          final color = daysLeft < 0
              ? Colors.red
              : daysLeft <= 4
              ? Colors.orange
              : Colors.green;

          return DataRow(cells: [
            DataCell(Text(s['name'] ?? "-")),
            DataCell(Text(s['phone'] ?? "-")),
            DataCell(Text("\$${s['amount']}")),
            DataCell(Text(s['method'])),
            DataCell(Text(s['startDate'])),
            DataCell(Text(s['endDate'])),
            DataCell(Text(
              daysLeft.toString(),
              style:
              TextStyle(color: color, fontWeight: FontWeight.bold),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ================= ACTIONS =================

  Widget _button(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(text),
    );
  }

  void sendWhatsAppReminders() async {
    for (var s in subscriptions) {
      final int daysLeft = s['daysLeft'];

      if (daysLeft >= 0 && daysLeft <= 4) {
        final msg =
            "Hey ${s['name']} 💪 Your gym membership will expire in $daysLeft days. Renew now!";
        final url =
            "https://wa.me/${s['phone']}?text=${Uri.encodeComponent(msg)}";

        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  // ================= DRAWER (FIXED) =================

  Drawer _drawer(BuildContext context) {
    return Drawer(
      backgroundColor: sidebarDark,
      child: Column(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("📅", style: TextStyle(fontSize: 32)),
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

          _nav(context, "Dashboard", const AdminDashboardScreen()),
          _nav(context, "Members", const MembersScreen()),
          _nav(context, "Payments", const PaymentScreen()),
          _nav(context, "Subscriptions", const SubscriptionScreen()),
          _nav(context, "Reports",  ReportsScreen()),

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

  ListTile _nav(BuildContext context, String title, Widget page) {
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
}
