import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';
import '../../data/models/design.dart';
import '../../data/repositories/design_repository.dart';
import '../widgets/design_form_dialog.dart';

class DesignDetailScreen extends StatefulWidget {
  final Design design;

  const DesignDetailScreen({super.key, required this.design});

  @override
  State<DesignDetailScreen> createState() => _DesignDetailScreenState();
}

class _DesignDetailScreenState extends State<DesignDetailScreen> with ThemeAwareMixin {
  late Design _design;
  final DesignRepository _repository = DesignRepository();

  @override
  void initState() {
    super.initState();
    _design = widget.design;
  }

  void _editDesign() async {
    final result = await showDialog<Design>(
      context: context,
      builder: (context) => DesignFormDialog(design: _design),
    );

    if (result != null) {
      await _repository.update(result);
      setState(() {
        _design = result;
      });
    }
  }

  void _deleteDesign() {
    showDialog(
      context: context,
      builder: (context) => AuthDeleteDialog(
        itemName: _design.name,
        securityService: SecurityService(),
        onDelete: () async {
          await _repository.delete(_design.id);
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
          _design.name,
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
            onPressed: _editDesign,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteDesign,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_design.category != null && _design.category!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _design.category!,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: theme.fontSize * 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                    _design.description ?? '-',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: theme.fontSize,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (_design.imagePath != null && _design.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(_design.imagePath!);
        return Hero(
          tag: 'design_image_${_design.id}',
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: MediaQuery.of(context).size.width, // Square aspect ratio
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        // Fallback for invalid base64
      }
    }
    
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width,
      color: theme.accentColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.palette_outlined,
          size: 80,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
