import 'package:flutter/material.dart';

import 'family.dart';
import 'office.dart';
import 'bachelor.dart';
import 'hostel.dart';
import 'wishlist.dart';
import 'best deals.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int bottomIndex = 0;

  // 🌊 Theme colors
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const tealMuted = Color(0xFF4F6F6C);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  final features = const [
    {"label": "Family", "image": "image/family_icon.jpg"},
    {"label": "Office", "image": "image/office_icon.jpg"},
    {"label": "Bachelor", "image": "image/bachelor_icon.jpg"},
    {"label": "Hostel", "image": "image/hostel-icon.jpg"},
    {"label": "Wishlist", "image": "image/wishlist.jpg"},
    {"label": "Best Deals", "image": "image/best deals.jpg"},
  ];

  // 🔁 common navigator
  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // 🎯 feature routing
  void _onFeatureTap(String label) {
    switch (label) {
      case "Family":
        _openPage(FamilyPage(onBackToExplore: () => Navigator.pop(context)));
        break;

      case "Office":
        _openPage(OfficePage(onBackToExplore: () => Navigator.pop(context)));
        break;

      case "Bachelor":
        _openPage(BachelorPage(onBackToExplore: () => Navigator.pop(context)));
        break;

      case "Hostel":
        _openPage(HostelPage(onBackToExplore: () => Navigator.pop(context)));
        break;

      case "Wishlist":
        _openPage(WishlistPage(onBackToExplore: () => Navigator.pop(context)));
        break;

      case "Best Deals":
        _openPage(BestDealsPage(onBackToExplore: () => Navigator.pop(context)));
        break;
    }
  }

  // 🔻 bottom navigation
  void _onBottomTap(int index) {
    setState(() => bottomIndex = index);

    if (index == 0) return; // already Explore

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index == 1
              ? "Home clicked"
              : index == 2
              ? "Message clicked"
              : "Profile clicked",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷 App title
              SizedBox(
                height: 52,
                child: Center(
                  child: Text(
                    "StayEase",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: tealDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Features",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: tealDark,
                ),
              ),

              const SizedBox(height: 14),

              // 🧩 Feature Grid
              Expanded(
                child: GridView.builder(
                  itemCount: features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = features[index];
                    final label = item["label"]!;
                    final img = item["image"]!;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _onFeatureTap(label),
                      child: Container(
                        decoration: BoxDecoration(
                          color: featureCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: verdeBorder, width: 1.6),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 74,
                              width: 74,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: verdeBorder, width: 2),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: innerBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    img,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.image_not_supported,
                                      size: 34,
                                      color: tealMuted.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: tealDark,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              height: 3,
                              width: 34,
                              decoration: BoxDecoration(
                                color: teal,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        onTap: _onBottomTap,
        selectedItemColor: teal,
        unselectedItemColor: tealMuted.withOpacity(0.75),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
