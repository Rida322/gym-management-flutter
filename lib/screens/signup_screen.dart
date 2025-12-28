import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';




class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;

  // ===== COLORS (same theme) =====
  static const bgDark = Color(0xFF14141E);
  static const panelDark = Color(0xFF1E1E2D);
  static const fieldDark = Color(0xFF282837);
  static const borderDark = Color(0xFF46465A);
  static const accent = Color(0xFF325AD8);

  Future<void> handleSignUp() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // ===== VALIDATIONS =====
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (password != confirm) {
      _showMessage("Passwords do not match");
      return;
    }

    if (!RegExp(r'^(03|70|71|76|78|79|81)[0-9]{6}$').hasMatch(phone)) {
      _showMessage("Invalid Lebanese phone number\nExample: 76123456");
      return;
    }

    if (!RegExp(r'^[a-z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
      _showMessage("Please enter a valid Gmail address");
      return;
    }

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final url = Uri.parse('$baseUrl/api/auth/signup');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "phoneNumber": phone,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        _showMessage("Account created successfully ✅");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showMessage(data['message'] ?? "Sign up failed");
      }
    } catch (e) {
      _showMessage("Server error: $e");
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(
                horizontal: 40, vertical: 35),
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
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _label("Full Name"),
                _input(nameController, Icons.person),

                _label("Phone Number"),
                _input(phoneController, Icons.phone,
                    keyboard: TextInputType.phone),

                _label("Email"),
                _input(emailController, Icons.email),

                _label("Password"),
                _input(passwordController, Icons.lock,
                    obscure: !showPassword),

                _label("Confirm Password"),
                _input(confirmPasswordController, Icons.lock_outline,
                    obscure: !showPassword),

                Row(
                  children: [
                    Checkbox(
                      value: showPassword,
                      onChanged: (v) =>
                          setState(() => showPassword = v!),
                    ),
                    const Text("Show Password",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "← Back to Login",
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
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14)),
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      IconData icon, {
        bool obscure = false,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fieldDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderDark),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
