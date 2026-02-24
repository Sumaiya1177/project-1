import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  File? _image;
  String email = "";
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    email = user.email ?? "";

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        nameController.text = data['full_name'] ?? "";
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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    final user = supabase.auth.currentUser;
    if (user == null || _image == null) return;

    try {
      final fileName = "${user.id}.jpg";
      final bytes = await _image!.readAsBytes();

      await supabase.storage
          .from('profile')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl = supabase.storage.from('profile').getPublicUrl(fileName);

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

  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final upsertData = {
      'id': user.id,
      'email': user.email, // make sure email is stored
      'full_name': nameController.text.trim(),
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

      // Return avatarUrl to ProfilePage
      Navigator.pop(context, avatarUrl);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Account",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E6F6B), fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2FB9B3)))
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

          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF9FE7D3)),
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
                    Icon(Icons.image, size: 40, color: Color(0xFF2FB9B3)),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2FB9B3)),
              onPressed: saveProfile,
              child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF3FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9FE7D3))),
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
        fillColor: const Color(0xFFF3FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9FE7D3))),
      ),
    );
  }
}