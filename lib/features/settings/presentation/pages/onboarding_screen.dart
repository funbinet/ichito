import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/profile_provider.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import '../../../../shared/widgets/square_avatar.dart';
import 'package:provider/provider.dart';
import '../../../security/services/security_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with ThemeAwareMixin, NavigationMixin {
  final SettingsRepository _settings = SettingsRepository();

  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 2; // Only 2 pages now!

  // Controllers - Basic Details
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  
  // Profile photo as base64
  String? _profilePhotoBase64;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _pickProfilePhoto() async {
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
      _profilePhotoBase64 = base64Encode(croppedBytes);
    });
  }

  Future<void> _completeOnboarding() async {
    // Save profile to SQLite via ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.saveProfile(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      location: '', // default empty
      defaultLaborCost: 1500.0,
      profilePhoto: _profilePhotoBase64,
    );

    // Finalize
    await _settings.setOnboardingComplete(true);
    
    if (mounted) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.initialize(); // Reload state
      navigateAndReplace('/dashboard');
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildIdentityPage(),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Text('Back'.t(context), style: TextStyle(color: theme.textSecondary)),
            )
          else
            SizedBox(width: 64),
          
          Row(
            children: List.generate(_totalPages, (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? theme.accentColor : theme.textSecondary.withOpacity(0.3),
              ),
            )),
          ),
          
          AdaptiveButton(
            text: _currentPage == _totalPages - 1 ? 'Complete' : 'Next',
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // --- PAGE 1: Welcome ---
  
  Widget _buildWelcomePage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_white.png', height: 120),
            SizedBox(height: 32),
            Text('Welcome to ICHITO'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 2)),
            SizedBox(height: 16),
            Text('The complete offline management system designed specifically for tailors.'.t(context), 
                 textAlign: TextAlign.center, style: subtitleStyle.copyWith(fontSize: theme.fontSize)),
          ],
        ),
      ),
    );
  }

  // --- PAGE 2: Creating Identity ---

  Widget _buildIdentityPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Text('Creating Identity'.t(context), style: headingStyle),
          SizedBox(height: 8),
          Text('Let\'.t(context)s set up your personal and business details.', style: subtitleStyle),
          SizedBox(height: 24),

          // Profile Photo Square Avatar
          Center(
            child: GestureDetector(
              onTap: _pickProfilePhoto,
              child: Stack(
                children: [
                  SquareAvatar(
                    size: 100,
                    base64Image: _profilePhotoBase64,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: theme.cornerRadius,
                        border: Border.all(color: theme.backgroundColor, width: 2),
                      ),
                      child: Icon(Icons.edit, color: theme.onAccent, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          AdaptiveTextField(
            controller: _businessNameCtrl,
            label: 'Business Name'.t(context),
            prefixIcon: Icons.storefront_outlined,
          ),
          SizedBox(height: 12),
          AdaptiveTextField(
            controller: _ownerNameCtrl,
            label: 'Owner Name'.t(context),
            prefixIcon: Icons.person_outlined,
          ),
          SizedBox(height: 12),
          AdaptiveTextField(
            controller: _phoneCtrl,
            label: 'Phone Number'.t(context),
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12),
          AdaptiveTextField(
            controller: _emailCtrl,
            label: 'Email Address'.t(context),
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
