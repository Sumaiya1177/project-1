import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project1/Database//explore_page.dart'; // Make sure these pages exist
import 'package:flutter_project1/Database/profile.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> unverifiedUsers = [];
  bool _loading = true;

  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _initializeAdmin();
  }

  Future<void> _initializeAdmin() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        Navigator.pop(context);
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      if (profile['is_admin'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Access denied: Not admin")),
        );
        Navigator.pop(context);
        return;
      }

      await fetchUnverifiedUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> fetchUnverifiedUsers() async {
    setState(() => _loading = true);

    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, email')
          .eq('is_verified', false);

      setState(() {
        unverifiedUsers = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Fetch failed: $e")),
      );
    }
  }

  Future<void> verifyUser(String userId, String fullName) async {
    try {
      await supabase
          .from('profiles')
          .update({'is_verified': true})
          .eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ $fullName verified")),
      );

      await fetchUnverifiedUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Verification failed: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ExplorePage()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F7), // bgAqua
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Color(0xFF2E6F6B)), // tealDark
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : unverifiedUsers.isEmpty
          ? const Center(child: Text('No unverified users'))
          : ListView.builder(
        itemCount: unverifiedUsers.length,
        itemBuilder: (context, index) {
          final user = unverifiedUsers[index];
          return Card(
            color: const Color(0xFFDFECFF), // featureCard
            margin: const EdgeInsets.symmetric(
                vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(user['full_name'] ?? ''),
              subtitle: Text(user['email'] ?? ''),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2FB9B3), // teal
                ),
                onPressed: () =>
                    verifyUser(user['id'], user['full_name']),
                child: const Text('Verify'),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2FB9B3), // teal
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}