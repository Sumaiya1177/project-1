import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'explore_page.dart';
import 'profile.dart';

class BestDealsPage extends StatefulWidget {
  const BestDealsPage({super.key, required Null Function() onBack, required Null Function() onBackToExplore});

  @override
  State<BestDealsPage> createState() => _BestDealsPageState();
}

class _BestDealsPageState extends State<BestDealsPage> {
  // 🎨 THEME COLORS
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  final supabase = Supabase.instance.client;

  int? selectedRent;
  String? selectedCategory;

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  // ================= APPLY FILTER =================
  Future<void> applyFilter() async {
    setState(() => isLoading = true);

    var query = supabase.from('rent_posts').select();

    if (selectedRent != null) {
      query = query.lte('price', selectedRent!);
    }

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      query = query.eq('category', selectedCategory!.toLowerCase());
    }

    final data = await query.order('created_at', ascending: false);

    results = List<Map<String, dynamic>>.from(data);

    setState(() => isLoading = false);
  }

  // ================= NAVIGATION =================
  void goToExplore() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ExplorePage()),
    );
  }

  void goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: teal),
          onPressed: goToExplore,
        ),
        title: const Text(
          "Best Deals",
          style: TextStyle(
            color: tealDark,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ================= MAX RENT =================
          const Text("Max Rent"),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: selectedRent,
            items: List.generate(
              50,
                  (index) => DropdownMenuItem(
                value: (index + 1) * 1000,
                child: Text("৳ ${(index + 1) * 1000}"),
              ),
            ),
            onChanged: (value) => setState(() => selectedRent = value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // ================= CATEGORY =================
          const Text("Category"),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: const [
              DropdownMenuItem(value: "bachelor", child: Text("Bachelor")),
              DropdownMenuItem(value: "office", child: Text("Office")),
              DropdownMenuItem(value: "family", child: Text("Family")),
              DropdownMenuItem(value: "hostel", child: Text("Hostel")),
            ],
            onChanged: (value) => setState(() => selectedCategory = value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          // ================= APPLY BUTTON =================
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: applyFilter,
            child: const Text("Apply Filter"),
          ),

          const SizedBox(height: 20),

          // ================= LOADING =================
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          // ================= NO DATA =================
          if (!isLoading && results.isEmpty)
            const Center(
              child: Text(
                "No Data Found",
                style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),

          // ================= RESULTS =================
          if (!isLoading && results.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemCount: results.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, i) {
                final item = results[i];
                return Card(
                  color: featureCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: verdeBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: item['image_url'] != null
                            ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            item['image_url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                            : const Icon(Icons.image, size: 50),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: tealDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "📍 ${item['location'] ?? ''}",
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "📐 ${item['area'] ?? ''}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "৳ ${item['price'] ?? ''}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "📞 ${item['phone'] ?? ''}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Available: ${item['available_from'] ?? ''}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: teal,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            goToExplore();
          } else {
            goToProfile();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}