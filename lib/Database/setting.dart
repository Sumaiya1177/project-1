import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final ageController = TextEditingController();
  final nidController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  File? _image; // Profile picture
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// Load profile data
  Future<void> loadProfile() async {
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    email = user.email ?? "";

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        nameController.text = data['name'] ?? "";
        genderController.text = data['gender'] ?? "";
        ageController.text = data['age']?.toString() ?? "";
        nidController.text = data['nid_number'] ?? "";
        addressController.text = data['address'] ?? "";
        phoneController.text = data['phone'] ?? "";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Pick image from gallery only
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Save profile
  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final upsertData = {
      'user_id': user.id,
      'name': nameController.text.trim(),
      'gender': genderController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'nid_number': nidController.text.trim(),
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      // store profile picture path if needed
    };

    try {
      await supabase.from('profiles').upsert(upsertData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2FB9B3)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        title: const Text(
          "My Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E6F6B),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF6FD6CF)),
        )
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            /// Profile picture
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFBFEFED),
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildField("Full Name", nameController),
            const SizedBox(height: 16),
            _buildField("Gender", genderController),
            const SizedBox(height: 16),
            _buildField("Age", ageController, isNumber: true),
            const SizedBox(height: 16),
            _buildField("NID Number", nidController),
            const SizedBox(height: 16),
            _buildField("Address", addressController),
            const SizedBox(height: 16),
            _buildField("Phone Number", phoneController),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FD6CF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: saveProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E6F6B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text field widget
  Widget _buildField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFEFED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        controller: controller,
        style: const TextStyle(color: Color(0xFF163B38)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4F6F6C)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// Email field (read-only)
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFEFED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Email", style: TextStyle(color: Color(0xFF4F6F6C))),
          const SizedBox(height: 6),
          Text(email, style: const TextStyle(color: Color(0xFF163B38))),
        ],
      ),
    );
  }
}
