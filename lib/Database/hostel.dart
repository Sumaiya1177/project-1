import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HostelPage extends StatefulWidget {
  const HostelPage({super.key, required Null Function() onBack, required Null Function() onBackToExplore});

  @override
  State<HostelPage> createState() => _HostelPageState();
}

class _HostelPageState extends State<HostelPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> posts = [];
  List<int> wishlistIds = [];

  // 🎨 Theme Colors (Same as FamilyPage)
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  @override
  void initState() {
    super.initState();
    loadPosts();
    loadWishlist();
  }

  // ================= LOAD POSTS =================
  Future<void> loadPosts() async {
    final data = await supabase
        .from('rent_posts')
        .select()
        .eq('category', 'hostel')
        .order('created_at', ascending: false);

    posts = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  // ================= LOAD WISHLIST =================
  Future<void> loadWishlist() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('wishlist')
        .select('post_id')
        .eq('user_id', user.id);

    wishlistIds =
    List<int>.from(data.map((e) => e['post_id'] as int));

    setState(() {});
  }

  // ================= DELETE =================
  Future<void> deletePost(Map<String, dynamic> post) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    if (post['user_id'] != user.id) return;

    await supabase
        .from('rent_posts')
        .delete()
        .eq('id', post['id']);

    if (post['image_url'] != null) {
      final path =
      post['image_url'].toString().split('/rent_images/')[1];
      await supabase.storage
          .from('rent_images')
          .remove([path]);
    }

    await loadPosts();
  }

  // ================= TOGGLE WISHLIST =================
  Future<void> toggleWishlist(int postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (wishlistIds.contains(postId)) {
      await supabase
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('post_id', postId);
      wishlistIds.remove(postId);
    } else {
      await supabase.from('wishlist').insert({
        'user_id': user.id,
        'post_id': postId,
      });
      wishlistIds.add(postId);
    }

    setState(() {});
  }

  // ================= IMAGE UPLOAD =================
  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final image =
    await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final file = File(image.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('rent_images')
        .upload('hostel/$fileName', file);

    return supabase.storage
        .from('rent_images')
        .getPublicUrl('hostel/$fileName');
  }

  // ================= ADD POST =================
  Future<void> addPostDialog() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final title = TextEditingController();
    final location = TextEditingController();
    final area = TextEditingController();
    final price = TextEditingController();
    final phone = TextEditingController();
    DateTime? availableDate;
    String? imageUrl;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: featureCard,
        title: const Text("Add Hostel Rent"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _inputField(title, "Title"),
              _inputField(location, "Location"),
              _inputField(area, "Area"),
              _inputField(price, "Price"),
              _inputField(phone, "Phone"),
              ElevatedButton(
                onPressed: () async =>
                imageUrl = await uploadImage(),
                child: const Text("Pick Image"),
              ),
              ElevatedButton(
                onPressed: () async {
                  availableDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: const Text("Select Date"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Save")),
        ],
      ),
    );

    if (ok == true) {
      await supabase.from('rent_posts').insert({
        'user_id': user.id,
        'title': title.text,
        'location': location.text,
        'area': area.text,
        'price': price.text,
        'phone': phone.text,
        'available_from':
        availableDate?.toIso8601String(),
        'image_url': imageUrl,
        'category': 'hostel',
        'is_booked': false,
      });

      await loadPosts();
    }
  }

  Widget _inputField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: innerBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: verdeBorder),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Hostel Rentals",
          style: TextStyle(
            color: tealDark,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: addPostDialog,
        child: const Icon(Icons.add),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final p = posts[i];
          final isWishlisted =
          wishlistIds.contains(p['id']);
          final isOwner = user?.id == p['user_id'];
          bool isBooked = p['is_booked'] == true;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  p['image_url'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(p['title'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold)),
                      Text("📍 ${p['location']}",
                          style: const TextStyle(
                              color: Colors.white)),
                      Text("📐 ${p['area']}",
                          style: const TextStyle(
                              color: Colors.white)),
                      Text("৳ ${p['price']}",
                          style: const TextStyle(
                              color: Colors.white)),
                      Text("📞 ${p['phone']}",
                          style: const TextStyle(
                              color: Colors.white)),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () => deletePost(p),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.check_box,
                          color: isBooked
                              ? Colors.red
                              : Colors.green,
                          size: 20,
                        ),
                        onPressed: isOwner
                            ? () async {
                          await supabase
                              .from('rent_posts')
                              .update({
                            'is_booked':
                            !isBooked
                          }).eq(
                              'id', p['id']);
                          setState(() {
                            posts[i]
                            ['is_booked'] =
                            !isBooked;
                          });
                        }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.pink,
                          size: 20,
                        ),
                        onPressed: () =>
                            toggleWishlist(p['id']),
                      ),
                    ],
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