import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project1/Database/explore_page.dart'; // Import your ExplorePage
import 'package:flutter_project1/pages/welcome_page.dart' show WelcomePage;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'setting.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  File? _image;
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// ======================
  /// Load User Name from Supabase
  /// ======================
  Future<void> loadUserData() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        setState(() {
          userName = data?['name'] ?? "";
          userEmail = user.email ?? "";
        });
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  /// ======================
  /// Pick Image
  /// ======================
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// ======================
  /// Logout Function
  /// ======================
  Future<void> logout() async {
    await supabase.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
    );
  }

  /// ======================
  /// Logout Dialog
  /// ======================
  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirm Logout",
          style: TextStyle(color: Color(0xFF2E6F6B), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Color(0xFF4F6F6C)),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF2FB9B3))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
            onPressed: logout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F7), // Pastel Aqua bg
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2FB9B3)), // Pastel Teal
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ExplorePage()),
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF2E6F6B), // Dark Teal
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ======================
            /// Profile Header
            /// ======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              color: Colors.white,
              child: Column(
                children: [
                  /// Profile Image Picker
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera, color: Color(0xFF2FB9B3)),
                              title: const Text("Take Photo", style: TextStyle(color: Color(0xFF2E6F6B))),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo, color: Color(0xFF2FB9B3)),
                              title: const Text("Choose from Gallery", style: TextStyle(color: Color(0xFF2E6F6B))),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFBFEFED), // Very Light Teal
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person, size: 50, color: Color(0xFFFFFFFF))
                          : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// User Name
                  Text(
                    userName.isEmpty ? "Loading..." : userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6F6B), // Dark Teal
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// Email
                  Text(
                    userEmail,
                    style: const TextStyle(color: Color(0xFF4F6F6C)), // Grayish Teal
                  ),

                  const SizedBox(height: 15),

                  /// Membership Text
                  const Text(
                    "",
                    style: TextStyle(
                      color: Color(0xFF6FD6CF), // Pastel Mint
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ======================
            /// Menu Section
            /// ======================
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem(
                    icon: Icons.settings,
                    title: " Edit Account",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF2FB9B3), // Pastel Teal
                  ),
                  buildMenuItem(
                    icon: Icons.support_agent,
                    title: "Contact Support",
                    onTap: () {},
                    color: const Color(0xFF2FB9B3),
                  ),
                  buildMenuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    color: Colors.red,
                    onTap: showLogoutDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ======================
  /// Menu Widget
  /// ======================
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF2FB9B3),
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2FB9B3)),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFFBFEFED)),
      ],
    );
  }
}
