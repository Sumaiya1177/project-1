import 'package:flutter/material.dart';

class BestDealsPage extends StatelessWidget {
  final VoidCallback onBackToExplore;

  const BestDealsPage({super.key, required this.onBackToExplore, required void Function() onBack});

  // 🌊 theme
  static const bgAqua = Color(0xFFE8F8F7);
  static const ocean = Color(0xFF1F8C8A);
  static const oceanDark = Color(0xFF0F4F4E);
  static const oceanMuted = Color(0xFF4F6F6C);
  static const cardBg = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,

      appBar: AppBar(
        backgroundColor: bgAqua,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ocean),
          onPressed: onBackToExplore,
        ),
        title: const Text(
          "Best Deals",
          style: TextStyle(
            color: oceanDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _DealCard(
            title: "Family House – 20% OFF",
            subtitle: "Near Dum Dum Metro",
          ),
          _DealCard(
            title: "Office Space – Limited Offer",
            subtitle: "Salt Lake Sector V",
          ),
          _DealCard(
            title: "Hostel – Best Price",
            subtitle: "Walking distance from college",
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DealCard({required this.title, required this.subtitle});

  static const ocean = Color(0xFF1F8C8A);
  static const oceanDark = Color(0xFF0F4F4E);
  static const oceanMuted = Color(0xFF4F6F6C);
  static const cardBg = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: verdeBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: ocean, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: oceanDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: oceanMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
