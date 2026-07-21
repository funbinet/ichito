import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../shared/providers/language_provider.dart';
import '../../../../../shared/data/local/settings_repository.dart';
import '../widgets/index.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> with ThemeAwareMixin {
  late SettingsRepository _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsRepository();
  }

  void _setLanguage(String lang) {
    _settings.setLanguage(lang);
    final langProv = Provider.of<LanguageProvider>(context, listen: false);
    langProv.setLanguage(lang == 'sheng' ? AppLanguage.sheng : AppLanguage.english);
  }

  Widget _buildLanguageOption(String title, String subtitle, String value, String currentValue) {
    final bool isSelected = value == currentValue;
    
    return GestureDetector(
      onTap: () => _setLanguage(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          border: Border.all(
            color: isSelected ? theme.accentColor : theme.borderColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && theme.enableShadows
              ? <BoxShadow>[BoxShadow(color: theme.accentColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : (theme.cardShadow as List<BoxShadow>?),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.accentColor : theme.textSecondary.withOpacity(0.5),
                    width: isSelected ? 6 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.t(context),
                      style: headingStyle.copyWith(fontSize: theme.fontSize, color: theme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.t(context),
                      style: subtitleStyle.copyWith(color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<LanguageProvider>(context).currentLanguage == AppLanguage.sheng ? 'sheng' : 'english';

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Language'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Select your preferred language. Changes are applied immediately across the entire application.'.t(context),
              style: bodyStyle.copyWith(color: theme.textSecondary),
            ),
          ),
          _buildLanguageOption(
            'English',
            'Full interface language',
            'english',
            currentLanguage,
          ),
          _buildLanguageOption(
            'Sheng',
            'Sheng slang with English fallbacks',
            'sheng',
            currentLanguage,
          ),
        ],
      ),
    );
  }
}
