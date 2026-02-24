import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Color Palette
  static const bgAqua = Color(0xFFE8F8F7);
  static const teal = Color(0xFF2FB9B3);
  static const tealDark = Color(0xFF2E6F6B);
  static const featureCard = Color(0xDFECFF);
  static const verdeBorder = Color(0xFF9FE7D3);
  static const innerBg = Color(0xFFF3FAFF);

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    currentUserId = user?.id ?? '';
    isBooked = widget.post['is_booked'] ?? false;

    if (widget.post['available_from'] != null) {
      availableDate = DateTime.parse(widget.post['available_from']);
    }

    _checkWishlist();
  }

  // Check if user already wishlisted
  Future<void> _checkWishlist() async {
    final postId = widget.post['id'];
    final res = await supabase
        .from('wishlists')
        .select()
        .eq('user_id', currentUserId)
        .eq('post_id', postId)
        .maybeSingle();

    setState(() {
      isWishlisted = res != null;
    });
  }

  // Toggle wishlist
  Future<void> toggleWishlist() async {
    final postId = widget.post['id'];
    if (isWishlisted) {
      await supabase
          .from('wishlists')
          .delete()
          .eq('user_id', currentUserId)
          .eq('post_id', postId);
    } else {
      await supabase.from('wishlists').insert({
        'user_id': currentUserId,
        'post_id': postId,
      });
    }

    setState(() {
      isWishlisted = !isWishlisted;
    });
  }

  // Toggle booked/unbooked (only owner)
  Future<void> toggleAvailable() async {
    final ownerId = widget.post['user_id'];
    if (currentUserId != ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only owner can change availability.")),
      );
      return;
    }

    final postId = widget.post['id'];
    final newStatus = !isBooked;

    try {
      await supabase
          .from('rent_posts')
          .update({'is_booked': newStatus})
          .eq('id', postId);

      setState(() {
        isBooked = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Post is now ${isBooked ? 'Booked 🔒' : 'Available ✅'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update post: $e")),
      );
    }
  }

  // Edit available date (only owner)
  Future<void> editAvailableDate() async {
    final ownerId = widget.post['user_id'];
    if (currentUserId != ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only owner can edit date.")),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: availableDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final postId = widget.post['id'];
      try {
        await supabase
            .from('rent_posts')
            .update({'available_from': picked.toIso8601String()})
            .eq('id', postId);

        setState(() {
          availableDate = picked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Available from date updated to ${DateFormat('dd MMM yyyy').format(picked)}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update date: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = post['images'] as List?;
    final profile = post['profiles'];
    final ownerName = profile != null ? profile['name'] ?? '' : '';
    final ownerPhone = profile != null ? profile['phone'] ?? '' : '';
    String formattedDate =
    availableDate != null ? DateFormat('dd MMM yyyy').format(availableDate!) : '';

    return Scaffold(
      backgroundColor: bgAqua,
      appBar: AppBar(
        title: Text(
          "${post['category'] ?? 'Rental'} Details",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: tealDark),
        ),
        backgroundColor: bgAqua,
        elevation: 0,
        iconTheme: const IconThemeData(color: tealDark),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE CAROUSEL
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

            // DETAILS CARD
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
                    Text("💰 Price: ৳ ${post['price'] ?? ''}",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text("📅 Available From: $formattedDate",
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        if (currentUserId == post['user_id'])
                          IconButton(
                            icon: const Icon(Icons.edit, color: teal),
                            onPressed: editAvailableDate,
                          ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text("Owner Information",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("👤 Name: $ownerName"),
                    const SizedBox(height: 6),
                    Text("📞 Phone: $ownerPhone"),
                    const SizedBox(height: 16),

                    // BUTTONS
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: toggleWishlist,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: tealDark),
                          child: Text(isWishlisted
                              ? "💖 Wishlisted"
                              : "🤍 Add to Wishlist"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: toggleAvailable,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isBooked ? Colors.red : teal),
                          child: Text(isBooked ? "🔒 Booked" : "✅ Available"),
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