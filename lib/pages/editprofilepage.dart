import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageExtension = image.path.split('.').last.toLowerCase();
    final imageBytes = await image.readAsBytes();
    final userID = supabase.auth.currentUser!.id;
    final imagePath = '/$userID/profile';

    // Upload image to Supabase storage
    await supabase.storage.from('profiles').uploadBinary(
          imagePath,
          imageBytes,
          fileOptions:
              FileOptions(upsert: true, contentType: 'image/$imageExtension'),
        );

    // Generate and retrieve the public URL
    String newImageUrl =
        supabase.storage.from('profiles').getPublicUrl(imagePath);
    newImageUrl = Uri.parse(newImageUrl).replace(queryParameters: {
      't': DateTime.now().millisecondsSinceEpoch.toString()
    }).toString();

    setState(() {
      _imageUrl = newImageUrl; // Reflect the new image URL instantly in the app
    });
  }

  Future<void> _updateProfile() async {
    String userID = supabase.auth.currentUser!.id;

    // Update avatarUrl in Supabase `profiles` table if a new image was uploaded
    if (_imageUrl != null) {
      await supabase.from('profiles').update({
        'avatar_url': _imageUrl,
      }).eq('id', userID);
    }

    // Update name and email
    await supabase.from('profiles').update({
      'full_name': _nameController
          .text, // Make sure this field matches your Supabase schema
      'email': _emailController
          .text, // Make sure this field matches your Supabase schema
    }).eq('id', userID);

    // Optionally, navigate back or show a success message
    Navigator.pop(context); // or show a success snackbar
  }

  @override
  Widget build(BuildContext context) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;

    _nameController.text = userData.theusername;
    _emailController.text = userData.theemail;
    if (_imageUrl == null) {
      _imageUrl =
          'assets/cherryBlossomDefaultProfile.jfif'; // Set a default image only if _imageUrl is null
    }
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : const AssetImage(
                                'assets/cherryBlossomDefaultProfile.jfif')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _updateProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
            ),
            const SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // _updateProfile();
                Navigator.pushNamed(context, '/Userprofileview',
                    arguments: userData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
