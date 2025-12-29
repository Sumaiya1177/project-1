import 'package:flutter/material.dart';
import 'package:flutter_project1/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Pastel Aqua Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8F8F7), // soft pastel aqua
            ),
          ),

          Center(
            child: Column(
              children: [
                SizedBox(height: height * 0.16),

                // Logo
                Image.asset(
                  "image/logo.png",
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),

                // Tight gap (logo → title)
                const SizedBox(height: 6),

                // App Name
                const Text(
                  "StayEase",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2FB9B3), // pastel teal
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    "Discover, Book, Stay – Comfort Anywhere.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F6F6C), // muted teal-gray
                    ),
                  ),
                ),

                const Spacer(),

                // 🌿 Get Started Button (Pastel Teal)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FD6CF), // pastel teal
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF6FD6CF).withOpacity(0.4),
                    minimumSize: const Size(240, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
