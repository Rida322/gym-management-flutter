import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'admin_dashboard_screen.dart';
import 'payment_screen.dart';
import 'subscription_screen.dart';
import 'reports_screen.dart';
import 'home_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  // ===== THEME =====
  static const bgDark = Color(0xFF14141E);
  static const cardDark = Color(0xFF28283C);
  static const sidebarDark = Color(0xFF191923);

  bool isLoading = true;

  List<dynamic> members = [];
  List<dynamic> filteredMembers = [];

  int totalMembers = 0;
  int activeMembers = 0;
  int expiringSoon = 0;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  // ================= API =================
  Future<void> fetchMembers() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final url = Uri.parse('$baseUrl/api/admin/members');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          members = data;
          filteredMembers = data;

          totalMembers = members.length;
          activeMembers =
              members.where((m) => m['status'] == 'ACTIVE').length;
          expiringSoon =
              members.where((m) => m['expiringSoon'] == true).length;


          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Members API error: $e");
    }
  }

  // ================= SEARCH =================
  void searchMembers(String keyword) {
    setState(() {
      filteredMembers = members.where((m) {
        return m['name']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase()) ||
            m['email']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            m['phoneNumber'].toString().contains(keyword);
      }).toList();
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      drawer: _drawer(context),
      appBar: AppBar(
        title: const Text("Member Management"),
        backgroundColor: sidebarDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Column(
          children: [
            _topCards(),
            const SizedBox(height: 20),
            _searchBar(),
            const SizedBox(height: 20),
            Expanded(child: _membersTable()),
          ],
        ),
      ),
    );
  }

  // ================= TOP CARDS =================
  Widget _topCards() {
    return Row(
      children: [
        _infoCard("Total Members", totalMembers.toString()),
        _infoCard("Active Members", activeMembers.toString()),
        _infoCard("Expiring Soon", expiringSoon.toString()),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: searchMembers,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search name, phone or email",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => searchMembers(searchController.text),
          child: const Text("Search"),
        )
      ],
    );
  }

  // ================= TABLE =================
  Widget _membersTable() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(cardDark),
        dataRowColor: MaterialStateProperty.all(bgDark),
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Phone")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Status")),
        ],
        rows: filteredMembers.map((m) {
          Color statusColor;
          switch (m['status']) {
            case 'ACTIVE':
              statusColor = Colors.green;
              break;
            case 'EXPIRED':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.orange;
          }

          return DataRow(cells: [
            DataCell(Text(m['name'],
                style: const TextStyle(color: Colors.white))),
            DataCell(Text(m['phoneNumber'],
                style: const TextStyle(color: Colors.white))),
            DataCell(Text(m['email'],
                style: const TextStyle(color: Colors.white))),
            DataCell(Text(
              m['status'],
              style: TextStyle(
                  color: statusColor, fontWeight: FontWeight.bold),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ================= DRAWER =================
  Drawer _drawer(BuildContext context) {
    return Drawer(
      backgroundColor: sidebarDark,
      child: Column(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("👋", style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text("Admin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _drawerItem(context, "Dashboard", const AdminDashboardScreen()),
          _drawerItem(context, "Members", const MembersScreen()),
          _drawerItem(context, "Payments", const PaymentScreen()),
          _drawerItem(context, "Subscriptions", const SubscriptionScreen()),
          _drawerItem(context, "Reports", ReportsScreen()),
          const Spacer(),
          _drawerItem(context, "Logout", const HomeScreen(), logout: true),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, String title, Widget page,
      {bool logout = false}) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white)),
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
