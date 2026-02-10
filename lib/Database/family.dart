// family_page.dart
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
  int bottomIndex = 0; // Bottom nav index

  // 🌊 Theme Colors from ExplorePage
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
    loadPosts();
  }

  Future<void> loadPosts() async {
    final data = await supabase
        .from('rent_posts')
        .select()
        .eq('category', 'family')
        .order('created_at', ascending: false);

    posts = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final file = File(image.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('rent_images').upload('family/$fileName', file);

    return supabase.storage.from('rent_images').getPublicUrl('family/$fileName');
  }

  Future<void> addPostDialog() async {
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
        title: const Text("Add Family Rent", style: TextStyle(color: tealDark)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _inputField(title, "Title"),
              _inputField(location, "Location"),
              _inputField(area, "Area"),
              _inputField(price, "Price"),
              _inputField(phone, "Phone"),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: teal),
                onPressed: () async => imageUrl = await uploadImage(),
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: teal),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await supabase.from('rent_posts').insert({
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

  Future<void> addToWishlist(Map post) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('wishlist').insert({
      'user_id': user.id,
      'post_id': post['id'],
      'title': post['title'],
      'price': post['price'],
      'area': post['area'],
      'location': post['location'],
      'phone': post['phone'],
      'available_from': post['available_from'],
      'image_url': post['image_url'],
      'category': post['category'],
    });
  }

  void _onBottomTap(int index) {
    setState(() => bottomIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExplorePage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

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
            borderSide: BorderSide(color: verdeBorder),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // No background
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Family Rentals",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: tealDark, // same as StayEase
            fontSize: 22,
          ),
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final p = posts[i];
          return Card(
            color: featureCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: p['image_url'] != null
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(p['image_url'], fit: BoxFit.cover, width: double.infinity),
                  )
                      : const Icon(Icons.image, size: 80, color: tealMuted),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: tealDark)),
                      Text("৳ ${p['price']}", style: const TextStyle(color: tealDark)),
                      Text("📞 ${p['phone']}", style: const TextStyle(color: tealDark)),
                      Text("📅 ${p['available_from'] ?? ''}", style: const TextStyle(color: tealDark)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.pink),
                          onPressed: () async {
                            await addToWishlist(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to Wishlist")));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        onTap: _onBottomTap,
        selectedItemColor: teal,
        unselectedItemColor: tealMuted.withOpacity(0.75),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
