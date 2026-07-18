import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';
import '../../data/models/garment.dart';
import '../../data/repositories/garment_repository.dart';
import '../widgets/garment_form_dialog.dart';

class GarmentDetailScreen extends StatefulWidget {
  final Garment garment;

  const GarmentDetailScreen({super.key, required this.garment});

  @override
  State<GarmentDetailScreen> createState() => _GarmentDetailScreenState();
}

class _GarmentDetailScreenState extends State<GarmentDetailScreen> with ThemeAwareMixin {
  late Garment _garment;
  final GarmentRepository _repository = GarmentRepository();

  @override
  void initState() {
    super.initState();
    _garment = widget.garment;
  }

  void _editGarment() async {
    final result = await showDialog<Garment>(
      context: context,
      builder: (context) => GarmentFormDialog(garment: _garment),
    );

    if (result != null) {
      await _repository.updateGarment(result);
      setState(() {
        _garment = result;
      });
    }
  }

  void _deleteGarment() {
    showDialog(
      context: context,
      builder: (context) => AuthDeleteDialog(
        itemName: _garment.name,
        securityService: SecurityService(),
        onDelete: () async {
          await _repository.deleteGarment(_garment.id!);
          if (mounted) Navigator.pop(context, true); // true indicates deleted
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _garment.name,
          style: TextStyle(
            color: theme.textPrimary,
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editGarment,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteGarment,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _garment.category.toUpperCase(),
                    style: TextStyle(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize * 0.8,
                    ),
                  ),
                ),
                if (_garment.defaultPrice != null)
                  Text(
                    lang.formatCurrency(_garment.defaultPrice!),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize * 1.2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              lang.t('description'),
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: theme.fontSize * 0.9,
                fontFamily: theme.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _garment.description ?? '-',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: theme.fontSize,
                fontFamily: theme.fontFamily,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Required Measurements',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: theme.fontSize * 0.9,
                fontFamily: theme.fontFamily,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _garment.measurementFields.map((field) {
                return Chip(
                  label: Text(field),
                  backgroundColor: theme.cardColor,
                  labelStyle: TextStyle(
                    color: theme.textPrimary,
                    fontFamily: theme.fontFamily,
                  ),
                  side: BorderSide(color: theme.borderColor),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
