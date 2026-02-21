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

  // 🎨 Theme Colors
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('wishlist')
        .select('id, post_id, rent_posts(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    wishlist = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

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
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (_, i) {
          final w = wishlist[i];
          final post = w['rent_posts'];

          return Card(
            color: featureCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: verdeBorder),
            ),
            child: Column(
              children: [
                Expanded(
                  child: post['image_url'] != null
                      ? ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      post['image_url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Icon(Icons.image, size: 50),
                ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? '',
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
                        "📍 ${post['location'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "📐 ${post['area'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "৳ ${post['price'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: tealDark,
                        ),
                      ),
                      Text(
                        "📞 ${post['phone'] ?? ''}",
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
                    onPressed: () =>
                        removeFromWishlist(w['id']),
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