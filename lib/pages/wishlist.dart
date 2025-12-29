import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  final VoidCallback onBackToExplore;

  const WishlistPage({super.key, required this.onBackToExplore});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // 🌊 theme
  static const bgAqua = Color(0xFFE8F8F7);
  static const ocean = Color(0xFF1F8C8A);
  static const oceanDark = Color(0xFF0F4F4E);
  static const oceanMuted = Color(0xFF4F6F6C);
  static const cardBg = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  final List<String> wishlist = [
    "Family House - Dum Dum",
    "Office Space - Salt Lake",
    "Bachelor Room - Ultadanga",
  ];

  void _removeItem(int index) {
    final removed = wishlist[index];
    setState(() => wishlist.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Removed: $removed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,

      appBar: AppBar(
        backgroundColor: bgAqua,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ocean),
          onPressed: widget.onBackToExplore,
        ),
        title: const Text(
          "Wishlist",
          style: TextStyle(
            color: oceanDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: wishlist.isEmpty
          ? Center(
        child: Text(
          "No items in wishlist 💔",
          style: TextStyle(
            color: oceanMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: verdeBorder, width: 1.4),
            ),
            child: ListTile(
              title: Text(
                wishlist[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: oceanDark,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: ocean),
                onPressed: () => _removeItem(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
