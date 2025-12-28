import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ===== THEME COLORS (same spirit as Java) =====
  static const Color bgDark = Color(0xFF12121C);
  static const Color cardDark = Color(0xFF21212D);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFB4B9C3);
  static const Color accent = Color(0xFF7C5CFC);
  static const Color accent2 = Color(0xFFFF5F23);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topHeader(context),
              const SizedBox(height: 40),
              _welcomeCard(context),
              const SizedBox(height: 24),
              _infoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP HEADER =================
  Widget _topHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "FitZone Gym",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        Row(
          children: [
            _gradientButton(
              "Login",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            _gradientButton(
              "Join Now",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ================= WELCOME CARD =================
  Widget _welcomeCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to FitZone Gym",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Transform Your Body, Elevate Your Life.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "State-of-the-art equipment, certified trainers, and smart tracking.\n"
                "Personal Training • Group Classes • Nutrition Plans",
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // ===== CHIPS =====
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(text: "Personal Training", icon: Icons.fitness_center),
              _Chip(text: "Group Classes", icon: Icons.groups),
              _Chip(text: "Nutrition Plans", icon: Icons.restaurant),
              _Chip(text: "Progress Tracker", icon: Icons.show_chart),
            ],
          ),

          const SizedBox(height: 18),

          // ===== CTA BUTTONS (WORKING) =====
          Row(
            children: [
              _gradientButton(
                "Login",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _gradientButton(
                "Join Now",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard() {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _infoSection(
              title: "Why Join a Gym?",
              content: """
• Faster fat loss & muscle growth
• Professional equipment & trainers
• Better discipline and motivation
• Improved mental health & confidence
• Stronger immunity & energy levels
""",
              extraTitle: "Dangerous Mistakes To Avoid",
              extraContent: """
• Skipping warm-up
• Training with bad form
• Training when injured
• Not drinking water
• Overtraining without rest
""",
              danger: true,
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: _infoSection(
              title: "What To Do BEFORE Training",
              content: """
• Eat light meal 60–90 minutes before
• Drink enough water
• Warm up properly
• Wear proper gym shoes
• Sleep well the night before
""",
              extraTitle: "What To Do AFTER Training",
              extraContent: """
• Drink water immediately
• Eat protein within 30–60 minutes
• Stretch your muscles
• Get enough rest
• Avoid junk food
""",
            ),
          ),
        ],
      ),
    );
  }

  // ================= REUSABLE WIDGETS =================

  Widget _gradientButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [accent, accent2],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _infoSection({
    required String title,
    required String content,
    required String extraTitle,
    required String extraContent,
    bool danger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, color: textSecondary),
        ),
        const SizedBox(height: 18),
        Text(
          extraTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: danger ? accent2 : textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          extraContent,
          style: const TextStyle(fontSize: 16, color: textSecondary),
        ),
      ],
    );
  }
}

// ================= CHIP =================
class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
