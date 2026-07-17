import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../../../shared/providers/language_provider.dart';
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

  final TextEditingController _businessNameController = TextEditingController();
  String _selectedCurrency = 'KES';
  AppLanguage _selectedLanguage = AppLanguage.english;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final name = _businessNameController.text.trim();
    if (name.isNotEmpty) {
      await _settings.setBusinessName(name);
    }
    await _settings.setCurrency(_selectedCurrency);
    await _settings.setLanguage(_selectedLanguage == AppLanguage.english ? 'english' : 'sheng');
    await _settings.setOnboardingComplete(true);
    
    if (mounted) {
      Provider.of<LanguageProvider>(context, listen: false).setLanguage(_selectedLanguage);
      Provider.of<LanguageProvider>(context, listen: false).setCurrency(_selectedCurrency);
      navigateAndReplace('/dashboard');
    }
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
                  _buildLanguagePage(),
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
                    children: List.generate(3, (index) => Container(
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
                    text: _currentPage == 2 ? 'Get Started' : 'Next',
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
            Image.asset('assets/images/logo_white.png', height: 120), // Fallback to white logo
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your business', style: headingStyle),
          const SizedBox(height: 32),
          AdaptiveTextField(
            controller: _businessNameController,
            label: 'Shop / Business Name',
            prefixIcon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 24),
          Text('Primary Currency', style: bodyStyle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            dropdownColor: theme.cardColor,
            style: bodyStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
            ),
            items: const [
              DropdownMenuItem(value: 'KES', child: Text('Kenyan Shilling (KES)')),
              DropdownMenuItem(value: 'UGX', child: Text('Ugandan Shilling (UGX)')),
              DropdownMenuItem(value: 'TZS', child: Text('Tanzanian Shilling (TZS)')),
              DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedCurrency = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your language', style: headingStyle),
          const SizedBox(height: 16),
          Text('ICHITO fully supports English and authentic Kenyan Sheng.', style: subtitleStyle),
          const SizedBox(height: 32),
          RadioListTile<AppLanguage>(
            title: Text('English', style: bodyStyle),
            value: AppLanguage.english,
            groupValue: _selectedLanguage,
            activeColor: theme.accentColor,
            onChanged: (val) => setState(() => _selectedLanguage = val!),
          ),
          RadioListTile<AppLanguage>(
            title: Text('Sheng (Kenyan Slang)', style: bodyStyle),
            subtitle: Text('Saka, Wacha, Iko Jikoni...', style: subtitleStyle),
            value: AppLanguage.sheng,
            groupValue: _selectedLanguage,
            activeColor: theme.accentColor,
            onChanged: (val) => setState(() => _selectedLanguage = val!),
          ),
        ],
      ),
    );
  }
}
