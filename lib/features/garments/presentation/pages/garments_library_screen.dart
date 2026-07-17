import 'package:flutter/material.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../data/models/garment.dart';
import '../../data/repositories/garment_repository.dart';

class GarmentsLibraryScreen extends StatefulWidget {
  const GarmentsLibraryScreen({super.key});

  @override
  State<GarmentsLibraryScreen> createState() => _GarmentsLibraryScreenState();
}

class _GarmentsLibraryScreenState extends State<GarmentsLibraryScreen> with ThemeAwareMixin, NavigationMixin {
  final GarmentRepository _repository = GarmentRepository();
  List<Garment> _garments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  Future<void> _loadGarments() async {
    setState(() => _isLoading = true);
    final garments = await _repository.getAllGarments();
    setState(() {
      _garments = garments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('garments_library'), style: headingStyle),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.accentColor))
        : _garments.isEmpty 
          ? _buildEmptyState() 
          : _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGarmentDialog(),
        backgroundColor: theme.accentColor,
        foregroundColor: theme.onAccent,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 80, color: theme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No garments added yet',
            style: subtitleStyle,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showAddGarmentDialog(),
            child: Text('Add Garment', style: TextStyle(color: theme.accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _garments.length,
      itemBuilder: (context, index) {
        final g = _garments[index];
        return Card(
          color: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
          child: ListTile(
            title: Text(g.name, style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${g.category} • ${g.measurementFields.length} measurements', style: subtitleStyle),
            trailing: Icon(Icons.chevron_right_outlined, color: theme.textSecondary),
            onTap: () {
              // Navigate to details or edit
            },
          ),
        );
      },
    );
  }

  void _showAddGarmentDialog() {
    // Add logic here to add a simple garment or navigate to full form
  }
}
