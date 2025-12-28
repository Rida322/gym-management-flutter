import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class _BasePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _BasePage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191923),
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white70),
            const SizedBox(height: 15),
            Text(title,
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Page connected successfully",
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
