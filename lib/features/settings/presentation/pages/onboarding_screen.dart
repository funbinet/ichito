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
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import 'package:provider/provider.dart';
import '../../../security/services/security_service.dart';

// Removed garment and fabric imports as they are moved to Order Wizard

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with ThemeAwareMixin, NavigationMixin {
  final SettingsRepository _settings = SettingsRepository();

  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  // Controllers - Basic Details
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _laborCostCtrl = TextEditingController(text: '1500');
  
  // No garment/fabric setup controllers in onboarding anymore

  // State Variables
  String _selectedCurrency = 'KES';
  String _selectedUnit = 'cm';
  String _selectedDateFormat = 'DD/MM/YYYY';
  AppLanguage _selectedLanguage = AppLanguage.english;
  bool _enableAppLock = false;
  String _pin = '';

  // Profile photo as base64
  String? _profilePhotoBase64;

  // No dynamic data lists for measurements/garments/fabrics in onboarding

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
    // 1. Save profile to SQLite via ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.saveProfile(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      defaultLaborCost: double.tryParse(_laborCostCtrl.text.trim()) ?? 1500.0,
      profilePhoto: _profilePhotoBase64,
    );

    // 2. Save preferences to SQLite via SettingsRepository
    await _settings.setCurrency(_selectedCurrency);
    await _settings.setMeasurementUnit(_selectedUnit);
    await _settings.setDateFormat(_selectedDateFormat);
    await _settings.setLanguage(_selectedLanguage == AppLanguage.english ? 'english' : 'sheng');
    
    // 3. Security
    if (_enableAppLock && _pin.length >= 4) {
      await SecurityService().setPin(_pin);
      // setAppLockEnabled is already called inside setPin, but just to be sure
      await _settings.setAppLockEnabled(true);
    }

    // 4. Finalize
    await _settings.setOnboardingComplete(true);
    
    if (mounted) {
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      langProvider.setLanguage(_selectedLanguage);
      langProvider.setCurrency(_selectedCurrency);
      langProvider.setMeasurementUnit(_selectedUnit);

      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.initialize(); // Reload state
      
      navigateAndReplace('/dashboard');
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _laborCostCtrl.dispose();
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
                  _buildBusinessDetailsPage(),
                  _buildContactPage(),
                  _buildPreferencesPage(),
                  _buildSecurityPage(),
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
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Text('Back', style: TextStyle(color: theme.textSecondary)),
            )
          else
            const SizedBox(width: 64),
          
          Row(
            children: List.generate(_totalPages, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_white.png', height: 120),
            const SizedBox(height: 32),
            Text('Welcome to ICHITO', style: headingStyle.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            Text('The complete offline management system designed specifically for tailors.', 
                 textAlign: TextAlign.center, style: subtitleStyle.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // --- PAGE 2: Business Details + Profile Photo ---

  Widget _buildBusinessDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Business Details', style: headingStyle),
          const SizedBox(height: 8),
          Text('Let\'s setup your tailoring business profile.', style: subtitleStyle),
          const SizedBox(height: 24),

          // Profile Photo Avatar
          Center(
            child: GestureDetector(
              onTap: _pickProfilePhoto,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.accentColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.accentLight,
                      backgroundImage: _profilePhotoBase64 != null
                          ? MemoryImage(base64Decode(_profilePhotoBase64!))
                          : null,
                      child: _profilePhotoBase64 == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: theme.accentColor, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.accentColor,
                                    fontFamily: theme.fontFamily,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  if (_profilePhotoBase64 != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.backgroundColor, width: 2),
                        ),
                        child: Icon(Icons.edit, color: theme.onAccent, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          AdaptiveTextField(
            controller: _businessNameCtrl,
            label: 'Shop / Business Name',
            prefixIcon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 12),
          AdaptiveTextField(
            controller: _ownerNameCtrl,
            label: 'Owner Name',
            prefixIcon: Icons.person_outlined,
          ),
          const SizedBox(height: 12),
          AdaptiveTextField(
            controller: _locationCtrl,
            label: 'Location / City',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          AdaptiveTextField(
            controller: _laborCostCtrl,
            label: 'Default Labor Cost (Base Price)',
            prefixIcon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // --- PAGE 3: Contact Info ---

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text('Contact Information', style: headingStyle),
          const SizedBox(height: 8),
          Text('This will appear on your printed receipts.', style: subtitleStyle),
          const SizedBox(height: 32),
          AdaptiveTextField(
            controller: _phoneCtrl,
            label: 'Business Phone Number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AdaptiveTextField(
            controller: _emailCtrl,
            label: 'Business Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // --- PAGE 4: Preferences ---

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text('Preferences', style: headingStyle),
          const SizedBox(height: 32),
          Text('Language', style: subtitleStyle),
          DropdownButtonFormField<AppLanguage>(
            value: _selectedLanguage,
            dropdownColor: theme.cardColor,
            style: bodyStyle,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: theme.cornerRadius)),
            items: const [
              DropdownMenuItem(value: AppLanguage.english, child: Text('English')),
              DropdownMenuItem(value: AppLanguage.sheng, child: Text('Sheng (Kenyan Slang)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedLanguage = val);
                Provider.of<LanguageProvider>(context, listen: false).setLanguage(val);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Currency', style: subtitleStyle),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            dropdownColor: theme.cardColor,
            style: bodyStyle,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: theme.cornerRadius)),
            items: const [
              DropdownMenuItem(value: 'KES', child: Text('Kenyan Shilling (KES)')),
              DropdownMenuItem(value: 'UGX', child: Text('Ugandan Shilling (UGX)')),
              DropdownMenuItem(value: 'TZS', child: Text('Tanzanian Shilling (TZS)')),
              DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedCurrency = val);
                Provider.of<LanguageProvider>(context, listen: false).setCurrency(val);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Measurement Unit', style: subtitleStyle),
          DropdownButtonFormField<String>(
            value: _selectedUnit,
            dropdownColor: theme.cardColor,
            style: bodyStyle,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: theme.cornerRadius)),
            items: const [
              DropdownMenuItem(value: 'cm', child: Text('Centimeters (cm)')),
              DropdownMenuItem(value: 'inches', child: Text('Inches (in)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedUnit = val);
                Provider.of<LanguageProvider>(context, listen: false).setMeasurementUnit(val);
              }
            },
          ),
        ],
      ),
    );
  }

  // --- PAGE 5: Security ---

  Widget _buildSecurityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text('App Security', style: headingStyle),
          const SizedBox(height: 8),
          Text('Protect your business data.', style: subtitleStyle),
          const SizedBox(height: 32),
          SwitchListTile(
            title: Text('Enable PIN Lock', style: bodyStyle),
            subtitle: Text('Require a PIN to open the app', style: subtitleStyle.copyWith(fontSize: 12)),
            value: _enableAppLock,
            activeColor: theme.accentColor,
            onChanged: (val) => setState(() => _enableAppLock = val),
            contentPadding: EdgeInsets.zero,
          ),
          if (_enableAppLock) ...[
            const SizedBox(height: 24),
            AdaptiveTextField(
              label: 'Enter a 4+ digit PIN',
              prefixIcon: Icons.lock_outlined,
              keyboardType: TextInputType.number,
              obscureText: true,
              onChanged: (val) => _pin = val,
            ),
          ]
        ],
      ),
    );
  }

  // Garment, Fabric, and Measurement setup moved to Order Wizard
}
