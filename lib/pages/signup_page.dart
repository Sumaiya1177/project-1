import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_project1/auth/auth_service.dart';
import 'package:flutter_project1/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final authService = AuthService();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // 🎨 Pastel Aqua + Pastel Teal palette
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const tealMuted = Color(0xFF4F6F6C);
  static const borderAqua = Color(0xFFBFEFED);
  static const btnTeal = Color(0xFF6FD6CF);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ Pastel teal "glass" input decoration
  InputDecoration _glassField({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: tealDark),
      prefixIcon: Icon(icon, color: teal),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderAqua, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderAqua, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: teal, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.95), width: 1.2),
      ),
    );
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Name required";
    if (RegExp(r'\d').hasMatch(value)) return "Name cannot contain numbers";
    if (!RegExp(r"^[A-Za-z.\- ]+$").hasMatch(value)) return "Only letters and spaces allowed";
    if (value.length < 2) return "Enter a valid name";
    return null;
  }

  String? _validatePhone(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Phone number required";
    if (value.length < 8) return "Enter valid phone number";
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Email required";
    if (!value.contains("@")) return "Enter valid email";

    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Password required";
    if (value.length < 6) return "Min 6 characters";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Password must contain 1 capital letter";
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return "Password must contain 1 special character";

    return null;
  }

  String? _validateConfirmPassword(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Confirm password required";
    if (value != _passwordController.text.trim()) return "Passwords do not match";
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _loading = true);

    try {
      await authService.signUpWithEmailPassword(email, password);

      // Optional profile save
      try {
        await authService.createOrUpdateProfile(
          fullName: name,
          phone: phone,
          email: email,
        );
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Signup Successful. Please login now.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Pastel Aqua Background
          Positioned.fill(
            child: Container(color: bgAqua),
          ),

          // ✅ Top bar: Back + Center Title
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: teal),
                    ),
                  ),
                  const Text(
                    "StayEase",
                    style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: tealDark,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Logo (Image asset)
          Positioned(
            top: topPad + height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 130,
                height: 130,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: borderAqua, width: 1.2),
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

          // ✅ Bottom Glass Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: height * 0.76,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.58),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    border: Border.all(color: borderAqua, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          const Text(
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: tealDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Sign up to start your StayEase journey",
                            style: TextStyle(fontSize: 14, color: tealMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _nameController,
                            validator: _validateName,
                            style: const TextStyle(color: Color(0xFF163B38)),
                            decoration: _glassField(label: "Full Name", icon: Icons.person_outline),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            style: const TextStyle(color: Color(0xFF163B38)),
                            decoration: _glassField(label: "Phone Number", icon: Icons.phone_outlined),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            style: const TextStyle(color: Color(0xFF163B38)),
                            decoration: _glassField(label: "Email", icon: Icons.email_outlined),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePass,
                            validator: _validatePassword,
                            style: const TextStyle(color: Color(0xFF163B38)),
                            decoration: _glassField(
                              label: "Password",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                icon: Icon(
                                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                                  color: teal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            validator: _validateConfirmPassword,
                            style: const TextStyle(color: Color(0xFF163B38)),
                            decoration: _glassField(
                              label: "Confirm Password",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                  color: teal,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: btnTeal,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?",
                                  style: TextStyle(color: tealMuted)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                  );
                                },
                                style: TextButton.styleFrom(foregroundColor: teal),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
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
