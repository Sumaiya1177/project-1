import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_project1/auth/auth_service.dart';
import 'package:flutter_project1/pages/explore_page.dart';
import 'package:flutter_project1/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _loading = true);

    try {
      await authService.signInWithEmailPassword(email, password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Login Successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExplorePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ Pastel Teal "glass" field
  InputDecoration _glassField({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF2E6F6B)), // teal text
      prefixIcon: Icon(icon, color: const Color(0xFF2FB9B3)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.65),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBFEFED), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBFEFED), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2FB9B3), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Pastel Aqua Background
          Positioned.fill(
            child: Container(color: const Color(0xFFE8F8F7)),
          ),

          // ✅ Top bar: back + centered title (pastel teal)
          Positioned(
            top: topPad + 6,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF2FB9B3), // pastel teal
                      ),
                    ),
                  ),
                  const Text(
                    "StayEase",
                    style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E6F6B),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Logo (image asset) near top-center
          Positioned(
            top: topPad + height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFBFEFED),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  "image/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ✅ Bottom "soft glass" sheet (pastel teal theme)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: height * 0.58,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(
                      color: const Color(0xFFBFEFED),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E6F6B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sign in to continue your StayEase journey",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4F6F6C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF163B38)),
                        decoration: _glassField(
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        style: const TextStyle(color: Color(0xFF163B38)),
                        decoration: _glassField(
                          label: "Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF2FB9B3),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Sign in button (pastel teal)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6FD6CF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Color(0xFF4F6F6C)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2FB9B3),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
