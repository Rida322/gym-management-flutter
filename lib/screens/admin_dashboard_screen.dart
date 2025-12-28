import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'home_screen.dart';
import 'members_screen.dart';
import 'payment_screen.dart';
import 'subscription_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}
int totalMembers = 0;

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ===== THEME =====
  static const bgDark = Color(0xFF14141E);
  static const cardDark = Color(0xFF2A2A3D);
  static const sidebarDark = Color(0xFF191923);
  static const textSecondary = Color(0xFFB4B4C8);

  bool isLoading = true;

  int activeMembers = 0;
  double monthlyRevenue = 0;
  int expiringSoon = 0;
  int newThisMonth = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final url = Uri.parse('$baseUrl/api/admin/members/stats');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          totalMembers = data['totalMembers'];
          activeMembers = data['activeMembers'];
          expiringSoon = data['expiringSoon'];
          monthlyRevenue = (data['monthlyRevenue'] ?? 0).toDouble();
          newThisMonth = data['newThisMonth'];
          isLoading = false;
        });
      }

    } catch (e) {
      debugPrint("Dashboard API error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("Dashboard Overview"),
        backgroundColor: sidebarDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
          child:
          CircularProgressIndicator(color: Colors.white),
        )
            : GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _InfoCard(
              title: "Active Members",
              value: activeMembers.toString(),
              subtitle: "Registered users",
              icon: Icons.people,
            ),
            _InfoCard(
              title: "Monthly Revenue",
              value:
              "\$${monthlyRevenue.toStringAsFixed(2)}",
              subtitle: "This month",
              icon: Icons.attach_money,
            ),
            _InfoCard(
              title: "Expiring Soon",
              value: expiringSoon.toString(),
              subtitle: "Next 7 days",
              icon: Icons.warning,
            ),
            _InfoCard(
              title: "New This Month",
              value: newThisMonth.toString(),
              subtitle: "New signups",
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }

  // ================= DRAWER =================
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: sidebarDark,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: sidebarDark),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("👋", style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text("Welcome",
                    style: TextStyle(
                        color: textSecondary, fontSize: 16)),
                Text("Admin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          _navItem(context, Icons.dashboard, "Dashboard",
              const AdminDashboardScreen()),
          _navItem(context, Icons.groups, "Members",
              const MembersScreen()),
          _navItem(context, Icons.payments, "Payments",
              const PaymentScreen()),
          _navItem(context, Icons.subscriptions, "Subscriptions",
              const SubscriptionScreen()),
          _navItem(context, Icons.bar_chart, "Reports",
             ReportsScreen()),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const HomeScreen()),
                    (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  ListTile _navItem(
      BuildContext context,
      IconData icon,
      String title,
      Widget page,
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}

// ================= INFO CARD =================
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AdminDashboardScreenState.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: _AdminDashboardScreenState
                          .textSecondary,
                      fontSize: 16)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
              const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
