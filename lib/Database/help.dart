import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Privacy Policy"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          /// ❓ Question 1
          PolicyTile(
            question: "How do we use your personal information?",
            answer:
            "We use your personal information such as name, phone number, "
                "and address only to provide better service inside the app. "
                "Your data is never used for any illegal or harmful purpose.",
          ),

          /// ❓ Question 2
          PolicyTile(
            question: "Is my data safe in this app?",
            answer:
            "Yes. Your data is securely stored and protected. "
                "Only you can view or edit your personal information "
                "after logging into your account.",
          ),

          /// ❓ Question 3
          PolicyTile(
            question: "Can I edit or update my profile information?",
            answer:
            "Yes. You can edit your name, phone number, and address "
                "from the Settings page anytime. The updated information "
                "will be saved automatically.",
          ),

          /// ❓ Question 4
          PolicyTile(
            question: "Do you share my personal data with others?",
            answer:
            "No. We do not share, sell, or distribute your personal data "
                "with any third-party organization or individual.",
          ),

          /// ❓ Question 5
          PolicyTile(
            question: "How can I contact support?",
            answer:
            "If you face any problem while using the app, you can contact "
                "our support team through the official contact section "
                "available in the app.",
          ),
        ],
      ),
    );
  }
}

/// 🔹 Reusable Expansion Tile Widget
class PolicyTile extends StatelessWidget {
  final String question;
  final String answer;

  const PolicyTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
