import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ===== IMPORT YOUR OTHER SCREENS =====
import 'member_dashboard_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';

class AIWorkoutScreen extends StatefulWidget {
  final int userId;

  const AIWorkoutScreen({super.key, required this.userId});

  @override
  State<AIWorkoutScreen> createState() => _AIWorkoutScreenState();
}


class _AIWorkoutScreenState extends State<AIWorkoutScreen> {
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final workoutNameCtrl = TextEditingController();

  String gender = 'Male';
  String goal = 'Build Muscle';
  String level = 'Beginner';

  bool loading = false;
  String output = 'Fill your information and generate your workout plan.';

  // ================= BACKEND CALL =================
  Future<void> generateWorkout() async {
    if (weightCtrl.text.isEmpty ||
        heightCtrl.text.isEmpty ||
        ageCtrl.text.isEmpty) {
      setState(() {
        output = "Please fill all fields.";
      });
      return;
    }

    setState(() {
      loading = true;
      output = 'Talking to your AI coach...';
    });

    final response = await http.post(
      Uri.parse("http://localhost:8080/api/member/ai-workout"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "gender": gender,
        "age": int.parse(ageCtrl.text),
        "weight": double.parse(weightCtrl.text),
        "height": double.parse(heightCtrl.text),
        "goal": goal,
        "level": level,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        output = data['workoutPlan'];
        loading = false;
      });
    } else {
      setState(() {
        output = "Server error: ${response.body}";
        loading = false;
      });
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191923),
      body: Row(
        children: [
          _sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Workout Generator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        _formPanel(),
                        const SizedBox(width: 20),
                        _outputPanel(),
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
  Widget _sidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF14141E),
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text(
            "Member Panel",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          _navButton ("Dashboard", Icons.dashboard, () async {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MemberDashboardScreen(userId: widget.userId),
              ),
            );
          }),

          _navButton("AI Workout Plan", Icons.auto_awesome, () {} , active: true),

          _navButton("Progress & History", Icons.show_chart, () async {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressScreen(userId: widget.userId),
              ),
            );
          }),

          const Spacer(),

          _navButton("Logout", Icons.logout, () {
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

  Widget _navButton(String text, IconData icon, VoidCallback onTap, {bool active = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3C78FA) : const Color(0xFF1E1E2D),
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

  // ================= FORM =================
  Widget _formPanel() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _input('Weight (kg)', weightCtrl),
          _input('Height (cm)', heightCtrl),
          _input('Age', ageCtrl),
          _textInput('Workout Name', workoutNameCtrl),
          _dropdown('Gender', gender, ['Male', 'Female'],
                  (v) => setState(() => gender = v)),
          _dropdown('Goal', goal,
              ['Build Muscle', 'Lose Fat', 'Stay Fit'],
                  (v) => setState(() => goal = v)),
          _dropdown('Level', level,
              ['Beginner', 'Intermediate', 'Advanced'],
                  (v) => setState(() => level = v)),

          const SizedBox(height: 20),

          // 🔵 Generate AI workout
          ElevatedButton(
            onPressed: loading ? null : generateWorkout,
            child: const Text('Generate Workout'),
          ),

          // ✅ ADD THIS PART (RIGHT HERE)
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: saveWorkout,
            icon: const Icon(Icons.save),
            label: const Text("Save Workout"),
          ),


        ],
      ),
    );
  }


  // ================= OUTPUT =================
  Widget _outputPanel() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Text(
            output,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ================= INPUT HELPERS =================
  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
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

  Widget _dropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2A2A40),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
  Future<void> saveWorkout() async {
    // 🔴 Validate first
    if (output.startsWith("Fill") ||
        workoutNameCtrl.text.isEmpty ||
        weightCtrl.text.isEmpty ||
        heightCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please generate workout and fill all fields")),
      );
      return;
    }

    final res = await http.post(
      Uri.parse("http://localhost:8080/api/member/workout/save"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,

        // 🔹 AI plan
        "plan": output,

        // 🔹 Workout history
        "workoutName": workoutNameCtrl.text,

        // 🔹 MemberInfo (for dashboard + progress cards)
        "weight": double.parse(weightCtrl.text),
        "height": int.parse(heightCtrl.text),
        "experience": level, // Beginner / Intermediate / Advanced
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Workout saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save failed: ${res.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Widget _textInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2A2A40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }



}
