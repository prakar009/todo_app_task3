import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'todo_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool isLoading = false;

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    User? user;

    if (isLogin) {
      user = await _authService.login(_emailController.text, _passwordController.text);
    } else {
      user = await _authService.signUp(_emailController.text, _passwordController.text);
    }

    setState(() => isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TodoListPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("AUTH ERROR: ACCESS DENIED"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(8, 8), blurRadius: 15),
                      BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(-6, -6), blurRadius: 12),
                    ],
                  ),
                  child: Icon(
                    isLogin ? Icons.person_rounded : Icons.person_add_rounded,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  isLogin ? "LOGIN" : "SIGN UP",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                _inputField(_emailController, "EMAIL", Icons.email_outlined, false),
                const SizedBox(height: 20),
                _inputField(_passwordController, "PASSWORD", Icons.lock_open_rounded, true),
                const SizedBox(height: 40),
                _submitButton(),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "NEW USER? REGISTER" : "HAVE ACCOUNT? LOGIN",
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, IconData icon, bool hide) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161617),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(2, 2), blurRadius: 4, spreadRadius: -1),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: hide,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v!.isEmpty ? "REQUIRED" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white10, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: isLoading ? null : _handleAuth,
      child: Container(
        width: double.infinity,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1B),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), offset: const Offset(6, 6), blurRadius: 12),
            BoxShadow(color: Colors.white.withOpacity(0.04), offset: const Offset(-4, -4), blurRadius: 10),
          ],
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                isLogin ? "LOGIN" : "CREATE",
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
      ),
    );
  }
}