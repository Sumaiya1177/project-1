import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const tealMuted = Color(0xFF4F6F6C);
  static const featureCard = Color(0xFFDFECFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: bgAqua,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: tealDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: teal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              "1. Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tealDark),
            ),
            Text(
              "Email: support@rentapp.com\nPhone: +880 1234-567890",
              style: TextStyle(fontSize: 16, color: tealMuted),
            ),
            SizedBox(height: 20),
            Text(
              "2. Support Hours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tealDark),
            ),
            Text(
              "Our support team is available from Sunday to Thursday, 9:00 AM to 6:00 PM.",
              style: TextStyle(fontSize: 16, color: tealMuted),
            ),
            SizedBox(height: 20),
            Text(
              "3. User Responsibilities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tealDark),
            ),
            Text(
              "Users must provide accurate information while posting rent details. False info may result in account suspension.",
              style: TextStyle(fontSize: 16, color: tealMuted),
            ),
            SizedBox(height: 20),
            Text(
              "4. Privacy Policy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tealDark),
            ),
            Text(
              "We respect your privacy. Your personal info will not be shared without consent.",
              style: TextStyle(fontSize: 16, color: tealMuted),
            ),
            SizedBox(height: 20),
            Text(
              "5. Reporting Issues",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tealDark),
            ),
            Text(
              "If you find fake or inappropriate rent posts, report immediately through the app.",
              style: TextStyle(fontSize: 16, color: tealMuted),
            ),
          ],
        ),
      ),
    );
  }
}
