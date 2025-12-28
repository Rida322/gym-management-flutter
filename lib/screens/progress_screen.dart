import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 🔁 IMPORT YOUR OTHER SCREENS
import 'member_dashboard_screen.dart';
import 'ai_workout_screen.dart';

class ProgressScreen extends StatefulWidget {
  final int userId;
  const ProgressScreen({super.key, required this.userId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // ================= DATA =================
  double weight = 0;
  int height = 0;
  String experience = "-";
  int totalWorkouts = 0;
  int workoutsThisWeek = 0;

  List<Map<String, String>> workoutHistory = [];
  List<Map<String, dynamic>> aiPlans = [];

  String selectedPlan = "Select a workout to view AI plan";

  // ================= HELPERS =================
  double get bmi =>
      height == 0 ? 0 : weight / ((height / 100) * (height / 100));

  // ================= API =================
  Future<void> fetchDashboard() async {
    final res = await http.get(
      Uri.parse(
        "http://localhost:8080/api/member/dashboard/${widget.userId}",
      ),
    );

    final data = jsonDecode(res.body);

    setState(() {
      weight = (data["weight"] ?? 0).toDouble();
      height = data["height"] ?? 0;
      experience = data["experience"] ?? "-";
      totalWorkouts = data["totalWorkouts"] ?? 0;
      workoutsThisWeek = data["workoutsThisWeek"] ?? 0;
    });
  }

  Future<void> fetchWorkoutHistory() async {
    final res = await http.get(
      Uri.parse(
        "http://localhost:8080/api/member/workout-history/${widget.userId}",
      ),
    );

    final List<dynamic> list = jsonDecode(res.body);

    setState(() {
      workoutHistory = list
          .map<Map<String, String>>((e) => {
        "date": e["workoutDate"],
        "name": e["workoutName"],
      })
          .toList();
    });
  }

  Future<void> fetchAIPlans() async {
    final res = await http.get(
      Uri.parse(
        "http://localhost:8080/api/member/workout-plan/${widget.userId}",
      ),
    );

    final List<dynamic> list = jsonDecode(res.body);

    setState(() {
      aiPlans = list
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchDashboard();
    fetchWorkoutHistory();
    fetchAIPlans();

  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F19),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget _buildSidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF0A0A14),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(Icons.bar_chart, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            "Member Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          _sidebarButton(
            "Dashboard",
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MemberDashboardScreen(userId: widget.userId),
                ),
              );

              // refresh when user comes back
              fetchDashboard();
              fetchWorkoutHistory();
              fetchAIPlans();
            },
          ),


          _sidebarButton(
            "AI Workout Plan",
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AIWorkoutScreen(userId: widget.userId),
                ),
              );

              // refresh after saving workout
              fetchDashboard();
              fetchWorkoutHistory();
              fetchAIPlans();
            },
          ),


          _sidebarButton(
            "Progress & History",
            active: true,
          ),

          const Spacer(),

          _sidebarButton(
            "Logout",
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _sidebarButton(
      String title, {
        bool active = false,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3C78FA) : const Color(0xFF1E1E2D),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= MAIN =================
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress & History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          Expanded(child: _buildBottomSection()),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _statCard("Weight", "${weight.toStringAsFixed(1)} kg"),
        _statCard("Height", "$height cm"),
        _statCard("BMI", bmi.toStringAsFixed(2)),
        _statCard("Experience", experience),
        _statCard("Total Workouts", "$totalWorkouts"),
        _statCard("This Week", "$workoutsThisWeek"),
        Container(),
        Container(),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(color: Color(0xFF1E1E32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFB4B4D0),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM =================
  Widget _buildBottomSection() {
    return Row(
      children: [
        Expanded(child: _workoutHistoryTable()),
        const SizedBox(width: 16),
        Expanded(child: _aiPlanView()),
      ],
    );
  }

  Widget _workoutHistoryTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF19192A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Workout History",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: workoutHistory.isEmpty
                ? const Center(
              child: Text(
                "No workouts yet",
                style: TextStyle(color: Color(0xFFB0B0C5)),
              ),
            )
                : ListView.builder(
              itemCount: workoutHistory.length,
              itemBuilder: (context, index) {
                final item = workoutHistory[index];

                return ListTile(
                  title: Text(
                    item["name"]!,
                    style:
                    const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    item["date"]!,
                    style: const TextStyle(
                      color: Color(0xFFB0B0C5),
                    ),
                  ),
                  onTap: () {
                    final match = aiPlans.firstWhere(
                          (p) => p["createdAt"]
                          .toString()
                          .startsWith(item["date"]!),
                      orElse: () => {},
                    );

                    setState(() {
                      selectedPlan = match.isNotEmpty
                          ? match["plan"]
                          : "No AI plan saved for this workout.";
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiPlanView() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF19192A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Training Details",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                selectedPlan,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "monospace",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
