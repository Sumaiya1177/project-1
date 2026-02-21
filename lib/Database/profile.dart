import 'package:flutter/material.dart';
import 'package:flutter_project1/Database/explore_page.dart';
import 'package:flutter_project1/pages/welcome_page.dart' show WelcomePage;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'setting.dart';
import 'support.dart'; // <-- Import the separate support page

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  String userName = "";
  String userEmail = "";
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

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
          avatarUrl = data?['image_url'];
          userEmail = user.email ?? "";
          isLoading = false;
        });
      } catch (e) {
        print("Error loading user data: $e");
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Confirm Logout",
          style: TextStyle(
            color: Color(0xFF2E6F6B),
            fontWeight: FontWeight.bold,
          ),
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
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFEF4E4E)),
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
      backgroundColor: const Color(0xFFE8F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2FB9B3)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ExplorePage()),
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF2E6F6B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2FB9B3)))
            : Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFBFEFED),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName.isEmpty ? "No Name" : userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6F6B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Color(0xFF4F6F6C)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem(
                    icon: Icons.settings,
                    title: "Edit Account",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                      loadUserData();
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.support_agent,
                    title: "Contact Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SupportPage()),
                      );
                    },
                  ),
                  buildMenuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    color: const Color(0xFFEF4E4E),
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
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFFBFEFED)),
      ],
    );
  }
}
