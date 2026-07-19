import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../widgets/index.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with ThemeAwareMixin {
  final List<_HelpTopic> _topics = [
    _HelpTopic(
      title: 'Getting Started',
      content: 'Welcome to ICHITO! Here\'s how to get started:\n\n1. Complete your business profile on the first launch\n2. Set up your measurements and preferences\n3. Create your first customer\n4. Use the Order Wizard to process orders\n\nThat\'s it! You\'re ready to manage your tailoring business.',
    ),
    _HelpTopic(
      title: 'Managing Customers',
      content: 'Keep track of your customers:\n\n• Add customer details (name, contact, address)\n• Store customer measurements and photo\n• Track customer loyalty tiers\n• View customer order history\n• Search and filter customers easily',
    ),
    _HelpTopic(
      title: 'Creating Orders',
      content: 'Use the 6-step Order Wizard:\n\n1. Select customer\n2. Choose garments\n3. Add measurements\n4. Set pricing\n5. Add delivery date\n6. Review and confirm\n\nOrders are automatically saved with order numbers.',
    ),
    _HelpTopic(
      title: 'Using the Order Wizard',
      content: 'The Order Wizard guides you through order creation step-by-step:\n\n• Select from predefined garments\n• Use customer saved measurements\n• Add custom measurements on the fly\n• Calculate total with labor costs and tax\n• Set delivery expectations',
    ),
    _HelpTopic(
      title: 'Managing Garments, Fabrics & Designs',
      content: 'Customize your inventory:\n\n• Create garment categories\n• Add fabric types with pricing\n• Upload design inspirations\n• Reuse items across multiple orders\n• Edit and organize your library',
    ),
    _HelpTopic(
      title: 'Taking Notes',
      content: 'Three types of notes:\n\n• General Notes: Regular notes for anything\n• Church Notes: With Bible verse tagging\n• Chama Notes: Track group savings contributions\n\nNotes auto-save and sync across your orders.',
    ),
    _HelpTopic(
      title: 'Understanding Statistics',
      content: 'Track your business with analytics:\n\n• Revenue overview\n• Key metrics (orders, customers, earnings)\n• Monthly trends\n• Top performing garments\n• Customer insights\n• Export reports',
    ),
    _HelpTopic(
      title: 'Customizing Your Theme',
      content: 'Personalize your experience:\n\n• Choose from 3 theme modes (Light, Dark, AMOLED)\n• Select from 30 accent colors\n• Change corner styles\n• Adjust font size\n• Control shadows and effects\n• Create your perfect look',
    ),
    _HelpTopic(
      title: 'Security & App Lock',
      content: 'Protect your business data:\n\n• Set up a PIN code\n• Enable biometric authentication\n• Configure auto-lock timer\n• View security code for recovery\n• Your data is encrypted locally',
    ),
    _HelpTopic(
      title: 'Backup & Restore',
      content: 'Never lose your data:\n\n• Create backups anytime\n• Automatic backup file generation\n• Restore from previous backups\n• Export data as JSON or CSV\n• Keep multiple backup copies',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Help & User Guide', style: headingStyle.copyWith(fontSize: 18)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16).copyWith(bottom: 120),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return HelpTopicTile(
            title: topic.title,
            content: topic.content,
            theme: theme,
          );
        },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: widget.theme.cornerRadius,
        side: BorderSide(color: widget.theme.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: widget.theme.textPrimary,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: widget.theme.accentColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.content,
                style: TextStyle(
                  color: widget.theme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
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
