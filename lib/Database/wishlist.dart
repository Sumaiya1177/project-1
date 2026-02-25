import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> wishlist = [];

  // Theme colors
  static const bgAqua = Color(0xFFE8F8F7);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  /// Load wishlist items from Supabase
  Future<void> loadWishlist() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('wishlist')
        .select('id, post_id, title, price, area, location, phone, available_from, image_url, category')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (response != null && response is List) {
      wishlist = List<Map<String, dynamic>>.from(response);
      setState(() {});
    }
  }

  /// Remove an item from wishlist
  Future<void> removeFromWishlist(int id) async {
    await supabase.from('wishlist').delete().eq('id', id);
    await loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Wishlist",
          style: TextStyle(
            color: tealDark,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ),
      body: wishlist.isEmpty
          ? const Center(
        child: Text(
          "No items in wishlist",
          style: TextStyle(
            color: tealDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: wishlist.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (_, i) {
          final w = wishlist[i];

          return Card(
            color: featureCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: verdeBorder),
            ),
            child: Column(
              children: [
                Expanded(
                  child: w['image_url'] != null && w['image_url'].toString().isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      w['image_url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Icon(Icons.image, size: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: tealDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "📍 ${w['location'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "📐 ${w['area'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "৳ ${w['price'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: tealDark,
                        ),
                      ),
                      Text(
                        "📞 ${w['phone'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => removeFromWishlist(w['id']),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}