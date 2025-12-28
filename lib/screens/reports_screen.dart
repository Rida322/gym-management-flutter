import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymmanagmentsystem/screens/admin_dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'admin_dashboard_screen.dart';
import 'members_screen.dart';
import 'payment_screen.dart';
import 'subscription_screen.dart';
import 'home_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const bgDark = Color(0xFF14141E);
  static const sidebarDark = Color(0xFF191923);

  String get baseUrl => dotenv.env['API_BASE_URL']!;

  // ===== DATA =====
  double totalPayments = 0;
  double totalExpenses = 0;
  double netProfit = 0;
  int newMembers = 0;

  List<double> monthlyExpenses = List.filled(12, 0);
  List<double> monthlyProfit = List.filled(12, 0);

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  // ================= API =================
  Future<void> loadReports() async {
    setState(() => loading = true);

    final summaryRes = await http.get(
      Uri.parse('$baseUrl/api/admin/reports/summary?month=${DateTime.now().month}&year=${DateTime.now().year}'),
    );

    final chartsRes = await http.get(
      Uri.parse('$baseUrl/api/admin/reports/charts?year=${DateTime.now().year}'),
    );

    final summary = jsonDecode(summaryRes.body);
    final charts = jsonDecode(chartsRes.body);

    setState(() {
      totalPayments = summary['totalPayments'];
      totalExpenses = summary['totalExpenses'];
      netProfit = summary['netProfit'];
      newMembers = summary['newMembers'];

      for (var p in charts['monthlyExpenses']) {
        monthlyExpenses[p['month'] - 1] = p['value'].toDouble();
      }

      for (var p in charts['monthlyProfit']) {
        monthlyProfit[p['month'] - 1] = p['value'].toDouble();
      }

      loading = false;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Row(
        children: [
          _sideBar(context),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reports & Analytics",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ===== INFO CARDS =====
                  Row(
                    children: [
                      _infoCard("Net Profit", "\$${netProfit.toInt()}", Colors.green),
                      _infoCard("New Members", "$newMembers", Colors.blue),
                      _infoCard("Expenses", "\$${totalExpenses.toInt()}", Colors.red),
                      _infoCard("Payments", "\$${totalPayments.toInt()}", Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ===== CHARTS =====
                  Expanded(
                    child: Row(
                      children: [
                        _chartContainer(
                          title: "Monthly Net Profit",
                          child: _lineChart(monthlyProfit),
                        ),
                        const SizedBox(width: 20),
                        _chartContainer(
                          title: "Monthly Expenses",
                          child: _barChart(monthlyExpenses),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget _sideBar(BuildContext context) {
    return Container(
      width: 230,
      color: sidebarDark,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("📊", style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          const Text("Welcome", style: TextStyle(color: Colors.white70)),
          const Text("Admin",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _menu(context, "Dashboard", const AdminDashboardScreen()),
          _menu(context, "Members", const MembersScreen()),
          _menu(context, "Payments", const PaymentScreen()),
          _menu(context, "Subscriptions", const SubscriptionScreen()),
          _menu(context, "Reports", const ReportsScreen()),

          const Spacer(),

          _menu(context, "Logout", const HomeScreen(), logout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String title, Widget page, {bool logout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: logout ? Colors.redAccent : const Color(0xFF232332),
          minimumSize: const Size(double.infinity, 44),
        ),
        onPressed: () {
          if (logout) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => page),
                  (_) => false,
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _infoCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF28283A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _chartContainer({required String title, required Widget child}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // ================= CHARTS =================
  Widget _lineChart(List<double> values) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 3,
          )
        ],
      ),
    );
  }

  Widget _barChart(List<double> values) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(
          values.length,
              (i) => BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: values[i], color: Colors.redAccent)],
          ),
        ),
      ),
    );
  }
}
