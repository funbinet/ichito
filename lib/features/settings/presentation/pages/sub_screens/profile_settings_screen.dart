import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';
import '../../../../../shared/providers/profile_provider.dart';
import '../../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../../shared/widgets/image_crop_dialog.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> with ThemeAwareMixin {
  late TextEditingController _nameController;
  late TextEditingController _businessController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    _nameController = TextEditingController(text: profile.ownerName);
    _businessController = TextEditingController(text: profile.businessName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerDialog.show(context);
    if (source == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile == null) return;
    if (!mounted) return;
    final croppedBytes = await ImageCropDialog.show(context, File(pickedFile.path));
    if (croppedBytes == null) return;
    
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    await profile.updateProfilePhoto(base64Encode(croppedBytes));
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);

    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.accentColor.withOpacity(0.2),
                    backgroundImage: profile.profilePhotoBytes != null
                        ? MemoryImage(profile.profilePhotoBytes!)
                        : null,
                    child: profile.profilePhotoBytes == null
                        ? Icon(Icons.person, size: 50, color: theme.accentColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, size: 20, color: theme.onAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController, Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField('Business Name', _businessController, Icons.storefront_outlined),
          const SizedBox(height: 16),
          _buildTextField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<ProfileProvider>(context, listen: false).saveProfile(
                ownerName: _nameController.text.trim(),
                businessName: _businessController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                location: profile.location,
                defaultLaborCost: profile.defaultLaborCost,
                profilePhoto: profile.profilePhotoBase64,
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
            ),
            child: Text('Save Changes', style: TextStyle(color: theme.onAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        prefixIcon: Icon(icon, color: theme.textSecondary),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: theme.cornerRadius,
          borderSide: BorderSide(color: theme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: theme.cornerRadius,
          borderSide: BorderSide(color: theme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: theme.cornerRadius,
          borderSide: BorderSide(color: theme.accentColor),
        ),
      ),
    );
  }
}
