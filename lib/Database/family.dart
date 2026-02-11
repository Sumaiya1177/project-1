import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile.dart';
import 'explore_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key, required void Function() onBack});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> posts = [];
  String userRole = "user";
  int bottomIndex = 0;

  // 🎨 Theme Colors
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const tealMuted = Color(0xFF4F6F6C);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  @override
  void initState() {
    super.initState();
    loadUserRole();
    loadPosts();
  }

  // ================= USER ROLE =================
  Future<void> loadUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('user_id', user.id)
        .single();

    userRole = data['role'] ?? "user";
    setState(() {});
  }

  // ================= LOAD POSTS =================
  Future<void> loadPosts() async {
    final data = await supabase
        .from('rent_posts')
        .select()
        .eq('category', 'family')
        .order('created_at', ascending: false);

    posts = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  // ================= IMAGE UPLOAD =================
  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final file = File(image.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('rent_images')
        .upload('family/$fileName', file);

    return supabase.storage
        .from('rent_images')
        .getPublicUrl('family/$fileName');
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

    DateTime? availableFrom;
    String? imageUrl;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: featureCard,
        title: const Text("Add Family Rent",
            style: TextStyle(color: tealDark)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _inputField(title, "Title"),
              _inputField(location, "Location"),
              _inputField(area, "Area"),
              _inputField(price, "Price"),
              _inputField(phone, "Phone"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: teal),
                onPressed: () async =>
                imageUrl = await uploadImage(),
                child: const Text("Pick Image"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: tealDark),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  availableFrom = date;
                },
                child: const Text("Select Available Date"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: teal),
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
        'available_from': availableFrom?.toIso8601String(),
        'image_url': imageUrl,
        'category': 'family',
      });

      loadPosts();
    }
  }

  // ================= DELETE POST =================
  Future<void> confirmDelete(int postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: featureCard,
        title: const Text("Delete Post",
            style: TextStyle(color: tealDark)),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: teal),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (ok == true) {
      await supabase.from('rent_posts').delete().eq('id', postId);
      loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted")),
      );
    }
  }

  // ================= WISHLIST TOGGLE =================
  Future<void> toggleWishlist(int postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existing = await supabase
        .from('wishlist')
        .select()
        .eq('user_id', user.id)
        .eq('post_id', postId);

    if (existing.isNotEmpty) {
      // remove from wishlist
      await supabase
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('post_id', postId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from wishlist")),
      );
    } else {
      // add to wishlist
      await supabase.from('wishlist').insert({
        'user_id': user.id,
        'post_id': postId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to wishlist")),
      );
    }

    setState(() {});
  }

  // ================= UI HELPERS =================
  Widget _inputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: tealDark),
          filled: true,
          fillColor: innerBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: verdeBorder),
          ),
        ),
      ),
    );
  }

  void _onBottomTap(int index) {
    setState(() => bottomIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExplorePage()));
    } else if (index == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Family Rentals",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 22,
              color: tealDark),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: addPostDialog,
        child: const Icon(Icons.add),
      ),
      body: posts.isEmpty
          ? const Center(child: Text("No posts yet"))
          : GridView.builder(
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
          final isOwner = currentUser?.id == p['user_id'];
          final isAdmin = userRole == "admin";

          return Card(
            color: featureCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Expanded(
                  child: p['image_url'] != null
                      ? ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      p['image_url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Icon(Icons.image,
                      size: 80, color: tealMuted),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(p['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tealDark)),
                      Text("৳ ${p['price']}",
                          style: const TextStyle(
                              color: tealDark)),
                      Text("📞 ${p['phone']}",
                          style: const TextStyle(
                              color: tealDark)),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.pink),
                            onPressed: () =>
                                toggleWishlist(p['id']),
                          ),
                          if (isOwner || isAdmin)
                            IconButton(
                              icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  confirmDelete(p['id']),
                            ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        onTap: _onBottomTap,
        selectedItemColor: teal,
        unselectedItemColor: tealMuted,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
