import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile',
      theme: ThemeData(
        primaryColor: const Color(0xFF2FB9B3),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      initialRoute: '/profile',
      routes: {
        '/profile': (_) => const ProfilePage(),
        '/help': (_) => const HelpPage(),
        '/welcome': (_) => const WelcomePage(),
      },
    );
  }
}

/* ================= PROFILE PAGE ================= */

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> values) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('profiles')
        .update(values)
        .eq('user_id', user.id);

    _fetchProfile();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2FB9B3), Color(0xFFE8F8F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("My Profile"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (profileData?['profile_url'] != null
                      ? NetworkImage(profileData!['profile_url'])
                      : null) as ImageProvider?,
                  child: _imageFile == null &&
                      profileData?['profile_url'] == null
                      ? Text(
                    profileData?['name']?[0] ?? "U",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2FB9B3),
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profileData?['name'] ?? "User",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              _editableCard(
                "Name",
                profileData?['name'],
                    (v) => _updateProfile({'name': v}),
              ),
              _infoCard("Email", profileData?['email']),
              _editableCard(
                "Phone",
                profileData?['phone'],
                    (v) => _updateProfile({'phone': v}),
              ),
              _editableCard(
                "Address",
                profileData?['address'],
                    (v) => _updateProfile({'address': v}),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF2FB9B3)),
                title: const Text("Help"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),

              ListTile(
                leading:
                const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableCard(
      String label, String? value, Function(String) onSave) {
    final controller = TextEditingController(text: value);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $label",
            border: InputBorder.none,
          ),
          onSubmitted: onSave,
        ),
      ),
    );
  }

  Widget _infoCard(String label, String? value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? ""),
      ),
    );
  }
}

/* ================= WELCOME PAGE ================= */

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          child: const Text("Go to Profile"),
        ),
      ),
    );
  }
}

/* ================= HELP PAGE ================= */

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help")),
      body: const Center(
        child: Text(
          "Need help?\nContact support or check FAQ.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
