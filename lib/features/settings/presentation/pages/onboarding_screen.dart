import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

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

  // Controllers
  final _businessNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _laborCostCtrl = TextEditingController(text: '1500');
  
  String _selectedCurrency = 'KES';
  String _selectedUnit = 'cm';
  String _selectedDateFormat = 'DD/MM/YYYY';
  AppLanguage _selectedLanguage = AppLanguage.english;
  bool _enableAppLock = false;
  String _pin = '';

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final name = _businessNameCtrl.text.trim();
    if (name.isNotEmpty) await _settings.setBusinessName(name);
    
    await _settings.setBusinessLocation(_locationCtrl.text.trim());
    await _settings.setBusinessPhone(_phoneCtrl.text.trim());
    await _settings.setBusinessEmail(_emailCtrl.text.trim());
    
    final labor = double.tryParse(_laborCostCtrl.text.trim());
    if (labor != null) await _settings.setDefaultLaborCost(labor);

    await _settings.setCurrency(_selectedCurrency);
    await _settings.setMeasurementUnit(_selectedUnit);
    await _settings.setDateFormat(_selectedDateFormat);
    await _settings.setLanguage(_selectedLanguage == AppLanguage.english ? 'english' : 'sheng');
    
    if (_enableAppLock && _pin.length >= 4) {
      await _settings.setAppLockEnabled(true);
      await _settings.setAppPin(_pin);
    }

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
            Padding(
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? theme.accentColor : theme.textSecondary.withOpacity(0.3),
                      ),
                    )),
                  ),
                  
                  AdaptiveButton(
                    text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildBusinessDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text('Business Details', style: headingStyle),
          const SizedBox(height: 8),
          Text('Let\'s setup your tailoring business profile.', style: subtitleStyle),
          const SizedBox(height: 32),
          AdaptiveTextField(
            controller: _businessNameCtrl,
            label: 'Shop / Business Name',
            prefixIcon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 16),
          AdaptiveTextField(
            controller: _locationCtrl,
            label: 'Location / City',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
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
            onChanged: (val) => setState(() => _selectedLanguage = val ?? AppLanguage.english),
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
            onChanged: (val) => setState(() => _selectedCurrency = val ?? 'KES'),
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
            onChanged: (val) => setState(() => _selectedUnit = val ?? 'cm'),
          ),
          const SizedBox(height: 16),
          Text('Date Format', style: subtitleStyle),
          DropdownButtonFormField<String>(
            value: _selectedDateFormat,
            dropdownColor: theme.cardColor,
            style: bodyStyle,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: theme.cornerRadius)),
            items: const [
              DropdownMenuItem(value: 'DD/MM/YYYY', child: Text('DD/MM/YYYY')),
              DropdownMenuItem(value: 'MM/DD/YYYY', child: Text('MM/DD/YYYY')),
              DropdownMenuItem(value: 'YYYY-MM-DD', child: Text('YYYY-MM-DD')),
            ],
            onChanged: (val) => setState(() => _selectedDateFormat = val ?? 'DD/MM/YYYY'),
          ),
        ],
      ),
    );
  }

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
}
