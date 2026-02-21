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

  // Controllers for form fields
  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final ageController = TextEditingController();
  final nidController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  File? _image; // local picked image
  String email = "";
  String? avatarUrl; // Supabase storage image URL
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile(); // Load user data from Supabase
  }

  /// Load Profile Data from Supabase Table
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
        avatarUrl = data['image_url'];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Pick Image from Gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await uploadImage();
    }
  }

  /// Upload Image to Supabase Storage Bucket 'profile'
  Future<void> uploadImage() async {
    final user = supabase.auth.currentUser;
    if (user == null || _image == null) return;

    try {
      final fileName = "${user.id}.jpg";
      final bytes = await _image!.readAsBytes();

      await supabase.storage
          .from('profile') // bucket name
          .uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final imageUrl =
      supabase.storage.from('profile').getPublicUrl(fileName);

      setState(() {
        avatarUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Uploaded Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  }

  /// Save Profile Data to Supabase Table 'profiles'
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
      'image_url': avatarUrl,
    };

    try {
      await supabase.from('profiles').upsert(upsertData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  /// ===============================
  /// UI Build
  /// ===============================
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
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF6FD6CF)),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const SizedBox(height: 16),

          /// Image Upload Section
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFEFED)),
              ),
              child: avatarUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image,
                        size: 40, color: Color(0xFF6FD6CF)),
                    SizedBox(height: 8),
                    Text("Upload Profile Picture"),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FD6CF),
              ),
              onPressed: saveProfile,
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E6F6B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// Text Field Widget
  /// ===============================
  Widget _buildField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: email),
      decoration: InputDecoration(
        labelText: "Email",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
