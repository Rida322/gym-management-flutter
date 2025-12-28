import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'member_dashboard_screen.dart';
import 'signup_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  static const bgDark = Color(0xFF14141E);
  static const panelDark = Color(0xFF1E1E2D);
  static const fieldDark = Color(0xFF282837);
  static const borderDark = Color(0xFF46465A);
  static const accent = Color(0xFF325AD8);

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final url = Uri.parse('$baseUrl/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        final String role = data['role'];
        final int userId = data['userId'];

        if (role == "ADMIN") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MemberDashboardScreen(userId: userId),
            ),
          );
        }
      } else {
        _showMessage(data['message'] ?? "Login failed");
      }
    } catch (e) {
      _showMessage("Server error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 35),
            width: 380,
            decoration: BoxDecoration(
              color: panelDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center,
                    size: 70, color: Colors.white),
                const SizedBox(height: 15),
                const Text(
                  "Gym Management System",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                _label("Email"),
                _inputField(
                  controller: emailController,
                  hint: "Enter your email",
                  icon: Icons.email,
                ),

                const SizedBox(height: 15),

                _label("Password"),
                _inputField(
                  controller: passwordController,
                  hint: "Enter your password",
                  icon: Icons.lock,
                  obscure: true,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFF508CFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    "← Back to home",
                    style:
                    TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style:
        const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: fieldDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderDark),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          prefixIcon:
          Icon(icon, color: Colors.white70),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 10),
        ),
      ),
    );
  }
}
