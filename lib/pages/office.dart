import 'package:flutter/material.dart';

class OfficePage extends StatefulWidget {
  final VoidCallback onBackToExplore;

  const OfficePage({super.key, required this.onBackToExplore});

  @override
  State<OfficePage> createState() => _OfficePageState();
}

class _OfficePageState extends State<OfficePage> {
  // 🌊 theme
  static const bgAqua = Color(0xFFE8F8F7);
  static const ocean = Color(0xFF1F8C8A);
  static const oceanDark = Color(0xFF0F4F4E);
  static const oceanMuted = Color(0xFF4F6F6C);

  static const cardBg = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  int bottomIndex = 0;

  final List<_RentPost> posts = [
    _RentPost(
      title: "Office Flat (2 Rooms)",
      location: "Motijheel, Dhaka",
      price: "৳ 25,000 / month",
      distance: "3.10 km",
      image: "image/office_icon.jpg",
    ),
    _RentPost(
      title: "Office Space (Small)",
      location: "Gulshan 1, Dhaka",
      price: "৳ 40,000 / month",
      distance: "5.40 km",
      image: "image/office_icon.jpg",
    ),
  ];

  void _onBottomTap(int idx) {
    setState(() => bottomIndex = idx);
    if (idx == 0) return; // Explore -> do nothing
    if (idx == 1) {
      widget.onBackToExplore(); // Home -> ExplorePage
      return;
    }
    if (idx == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message clicked")),
      );
    } else if (idx == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile clicked")),
      );
    }
  }

  void _filterAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filter clicked")),
    );
  }

  Future<void> _addPostDialog() async {
    final titleC = TextEditingController();
    final locC = TextEditingController();
    final priceC = TextEditingController();
    final distC = TextEditingController();

    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Office Rent Post"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleC, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: locC, decoration: const InputDecoration(labelText: "Location")),
                TextField(controller: priceC, decoration: const InputDecoration(labelText: "Price (e.g. ৳ 25000 / month)")),
                TextField(controller: distC, decoration: const InputDecoration(labelText: "Distance (e.g. 3.1 km)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Add")),
          ],
        );
      },
    );

    if (res == true) {
      setState(() {
        posts.insert(
          0,
          _RentPost(
            title: titleC.text.trim().isEmpty ? "Office Space" : titleC.text.trim(),
            location: locC.text.trim().isEmpty ? "Unknown location" : locC.text.trim(),
            price: priceC.text.trim().isEmpty ? "৳ -- / month" : priceC.text.trim(),
            distance: distC.text.trim().isEmpty ? "—" : distC.text.trim(),
            image: "image/office_icon.jpg",
          ),
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post added")),
      );
    }

    titleC.dispose();
    locC.dispose();
    priceC.dispose();
    distC.dispose();
  }

  void _deletePost(int index) {
    final removed = posts[index];
    setState(() => posts.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted: ${removed.title}"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => setState(() => posts.insert(index, removed)),
        ),
      ),
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
          "Office Rentals",
          style: TextStyle(color: oceanDark, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _filterAction,
            icon: const Icon(Icons.tune_rounded, color: ocean),
          ),
          const SizedBox(width: 6),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: ocean,
        foregroundColor: Colors.white,
        onPressed: _addPostDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ocean.withOpacity(0.18)),
                  ),
                  child: const Text(
                    "Tap + to add post",
                    style: TextStyle(color: oceanMuted, fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                ),
                const Spacer(),
                Text(
                  "${posts.length} posts",
                  style: TextStyle(color: oceanMuted.withOpacity(0.9), fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                itemCount: posts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, i) {
                  return _RentCard(
                    post: posts[i],
                    onDelete: () => _deletePost(i),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white.withOpacity(0.78),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.search, label: "Explore", active: bottomIndex == 0, onTap: () => _onBottomTap(0)),
              _NavItem(icon: Icons.grid_view_rounded, label: "Home", active: bottomIndex == 1, onTap: () => _onBottomTap(1)),
              const SizedBox(width: 46),
              _NavItem(icon: Icons.chat_bubble_outline, label: "Message", active: bottomIndex == 2, onTap: () => _onBottomTap(2)),
              _NavItem(icon: Icons.person_outline, label: "Profile", active: bottomIndex == 3, onTap: () => _onBottomTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  static const ocean = Color(0xFF1F8C8A);
  static const oceanMuted = Color(0xFF4F6F6C);

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? ocean : oceanMuted.withOpacity(0.75);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _RentCard extends StatelessWidget {
  final _RentPost post;
  final VoidCallback onDelete;

  static const ocean = Color(0xFF1F8C8A);
  static const oceanDark = Color(0xFF0F4F4E);
  static const oceanMuted = Color(0xFF4F6F6C);
  static const cardBg = Color(0xFFDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);

  const _RentCard({required this.post, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${post.title} clicked"))),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: verdeBorder, width: 1.6),
          boxShadow: [BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.06), offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      post.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: ocean.withOpacity(0.10),
                        child: Icon(Icons.image, size: 34, color: ocean.withOpacity(0.55)),
                      ),
                    ),
                  ),
                  if (post.distance.trim().isNotEmpty && post.distance != "—")
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: ocean.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                        child: Text(post.distance, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: verdeBorder.withOpacity(0.8)),
                        ),
                        child: const Icon(Icons.delete_outline, color: ocean, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: oceanDark)),
                  const SizedBox(height: 6),
                  Text(post.price, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: ocean.withOpacity(0.95))),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: ocean.withOpacity(0.85)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.location,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: oceanMuted, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentPost {
  final String title;
  final String location;
  final String price;
  final String distance;
  final String image;

  _RentPost({required this.title, required this.location, required this.price, required this.distance, required this.image});
}
