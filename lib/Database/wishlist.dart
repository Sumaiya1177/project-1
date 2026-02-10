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
        .select()
        .order('created_at', ascending: false);

    wishlist = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Wishlist")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: wishlist.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final w = wishlist[i];
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: w['image_url'] != null
                      ? Image.network(w['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.image),
                ),
                Text(w['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("৳ ${w['price']}"),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await supabase.from('wishlist').delete().eq('id', w['id']);
                    loadWishlist();
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
