import 'package:ichito/shared/providers/language_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../../shared/widgets/square_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with ThemeAwareMixin, NavigationMixin {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _laborCostCtrl = TextEditingController();

  String? _newPhotoBase64;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    _businessNameCtrl.text = profile.businessName;
    _ownerNameCtrl.text = profile.ownerName;
    _phoneCtrl.text = profile.phone;
    _emailCtrl.text = profile.email;
    _locationCtrl.text = profile.location;
    _laborCostCtrl.text = profile.defaultLaborCost.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();
    _laborCostCtrl.dispose();
    super.dispose();
  }

  @override
  bool hasUnsavedChanges() => _hasChanges;

  Future<void> _pickAndCropPhoto() async {
    final source = await ImagePickerDialog.show(context);
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    if (!mounted) return;
    final croppedBytes = await ImageCropDialog.show(context, File(pickedFile.path));
    if (croppedBytes == null) return;

    setState(() {
      _newPhotoBase64 = base64Encode(croppedBytes);
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final laborCost = double.tryParse(_laborCostCtrl.text.trim()) ?? 1500.0;

    await profile.saveProfile(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      defaultLaborCost: laborCost,
      profilePhoto: _newPhotoBase64,
    );

    // Also update the default labor cost in settings
    final settings = SettingsRepository();
    // No separate business fields in settings anymore — all in profile

    setState(() {
      _hasChanges = false;
      _isSaving = false;
      _newPhotoBase64 = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile saved successfully!'.t(context)),
          backgroundColor: theme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildProfilePhoto() {
    final profile = Provider.of<ProfileProvider>(context);
    Uint8List? photoBytes;

    if (_newPhotoBase64 != null) {
      photoBytes = base64Decode(_newPhotoBase64!);
    } else {
      photoBytes = profile.profilePhotoBytes;
    }

    return Center(
      child: GestureDetector(
        onTap: _pickAndCropPhoto,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: theme.cornerRadius,
                border: Border.all(color: theme.accentColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: theme.accentColor.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SquareAvatar(
                size: 110,
                base64Image: _newPhotoBase64 ?? profile.profilePhotoBase64,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: theme.cornerRadius,
                  border: Border.all(color: theme.cardColor, width: 2),
                ),
                child: Icon(Icons.camera_alt, color: theme.onAccent, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Business Profile'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.accentColor),
                    )
                  : Text(
                      'Save'.t(context),
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: theme.fontFamily,
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasChanges = true),
          child: ListView(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 100),
            children: [
              _buildProfilePhoto(),
              SizedBox(height: 24),

              // Business Info Section
              _buildSectionLabel('BUSINESS INFO'),
              AdaptiveTextField(
                controller: _businessNameCtrl,
                label: 'Business / Shop Name'.t(context),
                prefixIcon: Icons.storefront_outlined,
                validator: (val) => (val == null || val.isEmpty) ? 'Business name is required' : null,
              ),
              AdaptiveTextField(
                controller: _ownerNameCtrl,
                label: 'Owner Name'.t(context),
                prefixIcon: Icons.person_outlined,
              ),
              AdaptiveTextField(
                controller: _locationCtrl,
                label: 'Location / City'.t(context),
                prefixIcon: Icons.location_on_outlined,
              ),
              AdaptiveTextField(
                controller: _laborCostCtrl,
                label: 'Default Labor Cost'.t(context),
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 16),
              _buildSectionLabel('CONTACT'),
              AdaptiveTextField(
                controller: _phoneCtrl,
                label: 'Business Phone Number'.t(context),
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              AdaptiveTextField(
                controller: _emailCtrl,
                label: 'Business Email Address'.t(context),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 32),

              // Save Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AdaptiveButton(
                  text: 'Save Profile',
                  icon: Icons.save_outlined,
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: subtitleStyle.copyWith(
          color: theme.accentColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
