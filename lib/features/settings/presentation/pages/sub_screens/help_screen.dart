import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../widgets/index.dart';
import '../../../../../core/widgets/adaptive_components.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with ThemeAwareMixin {
  final Map<String, List<_HelpTopic>> _categorizedTopics = {
    'Getting Started & Basics': [
      _HelpTopic(
        title: 'Welcome to ICHITO'.t(context),
        content: '1. Complete your business profile\n2. Set up your measurements and preferences\n3. Create your first customer\n4. Use the Order Wizard to process orders',
      ),
      _HelpTopic(
        title: 'Customizing Your Theme'.t(context),
        content: 'Personalize your experience:\n\n• Choose from 3 theme modes\n• Select from 30 accent colors\n• Change corner styles and fonts',
      ),
    ],
    'Managing Orders & Clients': [
      _HelpTopic(
        title: 'Managing Customers'.t(context),
        content: 'Keep track of your customers:\n\n• Add customer details\n• Store measurements and photo\n• Track loyalty and history',
      ),
      _HelpTopic(
        title: 'Creating Orders'.t(context),
        content: 'Use the 6-step Order Wizard to select clients, garments, add measurements, pricing, and set due dates.',
      ),
    ],
    'Inventory & Tools': [
      _HelpTopic(
        title: 'Garments, Fabrics & Designs'.t(context),
        content: 'Customize your inventory:\n\n• Create garment categories\n• Add fabric types with pricing\n• Upload design inspirations',
      ),
      _HelpTopic(
        title: 'Taking Notes'.t(context),
        content: 'Three types of notes:\n\n• General Notes\n• Church Notes\n• Chama Notes',
      ),
    ],
    'Data & Security': [
      _HelpTopic(
        title: 'Understanding Statistics'.t(context),
        content: 'Track your business with analytics:\n\n• Revenue overview\n• Key metrics and trends',
      ),
      _HelpTopic(
        title: 'Security & Backup'.t(context),
        content: 'Protect your business data:\n\n• Set up a PIN or Biometrics\n• Create and restore backups',
      ),
    ],
  };

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/254700000000?text=Hello%20ICHITO%20Support');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp'.t(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Help & User Guide'.t(context), style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView(
        padding: EdgeInsets.all(16).copyWith(bottom: 120),
        children: [
          ..._categorizedTopics.entries.map((category) {
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: theme.cornerRadius,
                side: BorderSide(color: theme.borderColor),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    category.key,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary, fontFamily: theme.fontFamily),
                  ),
                  iconColor: theme.accentColor,
                  collapsedIconColor: theme.textSecondary,
                  children: category.value.map((topic) {
                    return HelpTopicTile(
                      title: topic.title,
                      content: topic.content,
                      theme: theme,
                    );
                  }).toList(),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 24),
          AdaptiveButton(
            text: 'Contact WhatsApp Support',
            onPressed: _launchWhatsApp,
            icon: Icons.chat_bubble_outline,
          ),
        ],
      ),
    );
  }
}

class HelpTopicTile extends StatefulWidget {
  final String title;
  final String content;
  final dynamic theme;

  const HelpTopicTile({
    required this.title,
    required this.content,
    required this.theme,
    super.key,
  });

  @override
  State<HelpTopicTile> createState() => _HelpTopicTileState();
}

class _HelpTopicTileState extends State<HelpTopicTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: widget.theme.accentColor, width: 2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: widget.theme.textPrimary,
              fontFamily: widget.theme.fontFamily,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: widget.theme.textSecondary,
            size: 16,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 16),
              child: Text(
                widget.content,
                style: TextStyle(
                  color: widget.theme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                  fontFamily: widget.theme.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  final String title;
  final String content;

  _HelpTopic({required this.title, required this.content});
}
