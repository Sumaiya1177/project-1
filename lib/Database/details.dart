import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wishlist.dart';

class RentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const RentDetailsPage({super.key, required this.post});

  @override
  State<RentDetailsPage> createState() => _RentDetailsPageState();
}

class _RentDetailsPageState extends State<RentDetailsPage> {
  final supabase = Supabase.instance.client;

  bool isWishlisted = false;
  bool isBooked = false;
  String currentUserId = '';
  DateTime? availableDate;

  // Owner Data
  String ownerName = 'Loading...';
  String ownerPhone = '';
  String ownerEmail = '';

  // Colors
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xFFDFECFF);

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    currentUserId = user?.id ?? '';
    isBooked = widget.post['is_booked'] ?? false;

    if (widget.post['available_from'] != null) {
      availableDate = DateTime.tryParse(widget.post['available_from']);
    }

    _fetchOwnerProfile();
    _checkWishlist();
  }

  /// Fetch Owner Info
  Future<void> _fetchOwnerProfile() async {
    try {
      final ownerId = widget.post['user_id'];
      if (ownerId == null) return;

      final data = await supabase
          .from('profiles')
          .select('full_name, phone, email')
          .eq('id', ownerId)
          .maybeSingle();

      setState(() {
        ownerName = data?['full_name'] ?? 'No Name';
        ownerPhone = data?['phone'] ?? '';
        ownerEmail = data?['email'] ?? '';
      });
    } catch (e) {
      debugPrint("Owner fetch error: $e");
      setState(() {
        ownerName = 'Owner not found';
      });
    }
  }

  /// Check if post already wishlisted
  Future<void> _checkWishlist() async {
    if (currentUserId.isEmpty) return;
    final postId = widget.post['id'];
    if (postId == null) return;

    final response = await supabase
        .from('wishlist')
        .select()
        .eq('user_id', currentUserId)
        .eq('post_id', postId)
        .maybeSingle();

    setState(() {
      isWishlisted = response != null;
    });
  }

  /// Toggle Wishlist
  Future<void> toggleWishlist() async {
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    final postId = widget.post['id'];
    if (postId == null) return;

    try {
      if (!isWishlisted) {
        await supabase.from('wishlist').insert({
          'user_id': currentUserId,
          'post_id': postId,
          'title': widget.post['title'] ?? '',
          'price': widget.post['price']?.toString() ?? '',
          'area': widget.post['area']?.toString() ?? '',
          'location': widget.post['location'] ?? '',
          'phone': widget.post['phone'] ?? '',
          'available_from': widget.post['available_from'],
          'image_url': (widget.post['images'] != null &&
              widget.post['images'] is List &&
              (widget.post['images'] as List).isNotEmpty)
              ? widget.post['images'][0]
              : null,
          'category': widget.post['category'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', currentUserId)
            .eq('post_id', postId);
      }

      setState(() {
        isWishlisted = !isWishlisted;
      });
    } catch (e) {
      debugPrint("Wishlist toggle error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update wishlist")),
      );
    }
  }

  /// Call Owner
  Future<void> _callOwner() async {
    if (ownerPhone.isEmpty) return;
    final Uri uri = Uri.parse("tel:$ownerPhone");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Toggle Availability (Owner Only)
  Future<void> toggleAvailable() async {
    final ownerId = widget.post['user_id'];
    if (currentUserId != ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only owner can change availability")),
      );
      return;
    }

    final postId = widget.post['id'];
    final newStatus = !isBooked;

    await supabase
        .from('rent_posts')
        .update({'is_booked': newStatus})
        .eq('id', postId);

    setState(() {
      isBooked = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = post['images'] as List?;
    String formattedDate = availableDate != null
        ? DateFormat('dd MMM yyyy').format(availableDate!)
        : '';

    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        backgroundColor: bgAqua,
        elevation: 0,
        iconTheme: const IconThemeData(color: tealDark),
        title: Text(
          "${post['category'] ?? 'Rental'} Details",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: tealDark),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slider
            if (images != null && images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (_, index) =>
                      Image.network(images[index], fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: Text("No Image")),
              ),
            // Details Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: featureCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['location'] ?? '',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text("📐 Area: ${post['area'] ?? ''}"),
                    const SizedBox(height: 8),
                    Text(
                      "💰 Price: ৳ ${post['price'] ?? ''}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text("📅 Available From: $formattedDate"),
                    const Divider(height: 30),
                    const Text(
                      "Owner Information",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("👤 Name: $ownerName"),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _callOwner,
                      child: Text(
                        "📞 Phone: $ownerPhone",
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("📧 Email: $ownerEmail"),
                    const SizedBox(height: 16),
                    // Buttons Row
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: toggleWishlist,
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: Text(
                            isWishlisted
                                ? "Added to Wishlist"
                                : "Add to Wishlist",
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tealDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: toggleAvailable,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isBooked ? Colors.red : teal,
                          ),
                          child: Text(
                            isBooked ? "🔒 Booked" : "✅ Available",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}