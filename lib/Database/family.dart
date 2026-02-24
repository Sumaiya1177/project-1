import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project1/Database/details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'explore_page.dart';
import 'profile.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key, required void Function() onBack});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];

  // COLORS
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  /// LOAD RENT POSTS
  Future<void> loadPosts() async {
    try {
      final data = await supabase
          .from('rent_posts')
          .select('*, profiles(id, full_name, phone, image_url)')
          .eq('category', 'family') // you can change category dynamically if needed
          .order('created_at', ascending: false);

      posts = List<Map<String, dynamic>>.from(data);
      setState(() {});
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  /// PICK & UPLOAD IMAGES
  Future<List<String>> uploadImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return [];

    List<String> urls = [];
    for (var image in images) {
      final file = File(image.path);
      final fileName =
          'family/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      await supabase.storage.from('rent_images').upload(fileName, file);
      final url = supabase.storage.from('rent_images').getPublicUrl(fileName);
      urls.add(url);
    }
    return urls;
  }

  /// ADD POST DIALOG
  Future<void> addPostDialog() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileData == null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'full_name': 'Default Name',
        'phone': '0123456789',
      });
    }

    final location = TextEditingController();
    final price = TextEditingController();
    final area = TextEditingController();
    final title = TextEditingController();
    DateTime? availableDate;
    List<String> imageUrls = [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: featureCard,
        title: const Text(
          "Add Family Rent",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                  labelText: "Title",
                  fillColor: innerBg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: verdeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: location,
                decoration: InputDecoration(
                  labelText: "Location / Address",
                  fillColor: innerBg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: verdeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: area,
                decoration: InputDecoration(
                  labelText: "Area",
                  fillColor: innerBg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: verdeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  fillColor: innerBg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: verdeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: teal),
                onPressed: () async {
                  imageUrls = await uploadImages();
                },
                child: const Text("Select Images"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: teal),
                onPressed: () async {
                  availableDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
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
        'images': imageUrls,
        'available_from': availableDate?.toIso8601String(),
        'category': 'family',
        'is_booked': false,
      });

      await loadPosts();
    }
  }

  /// BOTTOM NAV
  void onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ExplorePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        title: const Text(
          "Family Rentals",
          style:
          TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.white,
        foregroundColor: tealDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tealDark),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ExplorePage()));
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final p = posts[i];
          final images = p['images'] as List?;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RentDetailsPage(post: p))); // generic
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (images != null && images.isNotEmpty)
                    Image.network(images.first, fit: BoxFit.cover)
                  else
                    Container(color: Colors.grey),
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🏠 ${p['category'] ?? ''}",
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("📍 ${p['location'] ?? ''}",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: addPostDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.home),
                onPressed: () => onTabTapped(0),
              ),
              const SizedBox(width: 50), // space for FAB
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.person),
                onPressed: () => onTabTapped(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}