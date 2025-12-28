import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';
import 'ai_workout_screen.dart';
import 'progress_screen.dart';


class MemberDashboardScreen extends StatefulWidget {
  final int userId;


  const MemberDashboardScreen({super.key, required this.userId});


  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  bool loading = true;
  bool _loadedOnce = false;

  String memberName = "";
  double weight = 0;
  int height = 0;
  double bmi = 0;
  int totalWorkouts = 0;
  int workoutsThisWeek = 0;
  String experience = "";

  List<double> weightHistory = [];
  Map<String, int> crowdData = {};

  String selectedTime = "10:00";

  final List<String> timeOptions = [
    "06:00","07:00","08:00","09:00","10:00",
    "11:00","12:00","13:00","14:00","15:00",
    "16:00","17:00","18:00","19:00","20:00",
  ];

  @override
  void initState() {
    super.initState();
    if (!_loadedOnce) {
      _loadedOnce = true;
      fetchDashboard();
    }
  }

  // ================= BACKEND =================

  Future<void> fetchDashboard() async {
    setState(() => loading = true);

    final res = await http.get(
      Uri.parse("http://localhost:8080/api/member/dashboard/${widget.userId}"),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        memberName = data['name'] ?? "";
        weight = (data['weight'] ?? 0).toDouble();
        height = data['height'] ?? 0;
        bmi = (data['bmi'] ?? 0).toDouble();
        totalWorkouts = data['totalWorkouts'] ?? 0;
        workoutsThisWeek = data['workoutsThisWeek'] ?? 0;
        experience = data['experience'] ?? "";

        weightHistory = (data['weightHistory'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList();

        crowdData = Map<String, int>.from(data['crowdData'] ?? {});

        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }



  Future<void> saveSchedule() async {
    await http.post(
      Uri.parse("http://localhost:8080/api/member/schedule"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "visitTime": selectedTime,
      }),
    );

  }

  Future<void> deleteSchedule() async {
    await http.delete(
      Uri.parse(
        "http://localhost:8080/api/member/schedule/${widget.userId}",
      ),
    );

    await fetchDashboard();
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF191923),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF191923),
      body: Row(
        children: [
          _sidebar(),
          Expanded(child: _main()),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================

  Widget _sidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF14141E),
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text("Member Panel",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _nav("Dashboard", Icons.dashboard, () {}),
          _nav("AI Workout Plan", Icons.auto_awesome, () async {

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIWorkoutScreen(userId: widget.userId),
              ),
            );
             // 🔥 refresh after save

          }),
          _nav("Progress & History", Icons.show_chart, () async {

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressScreen(userId: widget.userId),
              ),
            );
            // 🔥 refresh stats

          }),

          const Spacer(),

          _nav("Logout", Icons.logout, () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _nav(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= MAIN =================

  Widget _main() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome, $memberName",
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          _stats(),
          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                Expanded(child: _weightHistoryChart()),

                const SizedBox(width: 15),
                Expanded(child: _schedulePanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _stats() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _card("Weight", "$weight kg"),
        _card("Height", "$height cm"),
        _card("BMI", bmi.toStringAsFixed(1)),
        _card("Total Workouts", "$totalWorkouts"),
        _card("This Week", "$workoutsThisWeek"),
        _card("Experience", experience),
      ],
    );
  }

  Widget _card(String t, String v) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= CHART =================

  Widget _weightChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: weightHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
            )
          ],
        ),
      ),
    );
  }

  Widget _weightHistoryChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weight Progress",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ================= SCHEDULE PANEL =================

  Widget _schedulePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: selectedTime,
                dropdownColor: const Color(0xFF1E1E32),
                underline: Container(height: 1, color: Colors.white30),
                style: const TextStyle(color: Colors.white),
                items: timeOptions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => selectedTime = v!),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: saveSchedule,
                child: const Text("Save Schedule"),
              ),
              const SizedBox(width: 10),

            ],
          ),
          const SizedBox(height: 20),

          _tableHeader(),

          Expanded(
            child: ListView(
              children: crowdData.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.key, style: const TextStyle(color: Colors.white)),
                      ),
                      Expanded(
                        child: Text("${e.value}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
      child: const Row(
        children: [
          Expanded(
            child: Text("Time",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text("Members",
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
