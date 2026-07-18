import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/ichito_scaffold.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/widgets/auth_delete_dialog.dart';
import '../../../security/services/security_service.dart';
import '../../data/models/fabric.dart';
import '../../data/repositories/fabric_repository.dart';
import '../widgets/fabric_form_dialog.dart';

class FabricDetailScreen extends StatefulWidget {
  final Fabric fabric;

  const FabricDetailScreen({super.key, required this.fabric});

  @override
  State<FabricDetailScreen> createState() => _FabricDetailScreenState();
}

class _FabricDetailScreenState extends State<FabricDetailScreen> with ThemeAwareMixin {
  late Fabric _fabric;
  final FabricRepository _repository = FabricRepository();

  @override
  void initState() {
    super.initState();
    _fabric = widget.fabric;
  }

  void _editFabric() async {
    final result = await showDialog<Fabric>(
      context: context,
      builder: (context) => FabricFormDialog(fabric: _fabric),
    );

    if (result != null) {
      await _repository.updateFabric(result);
      setState(() {
        _fabric = result;
      });
    }
  }

  void _deleteFabric() {
    showDialog(
      context: context,
      builder: (context) => AuthDeleteDialog(
        itemName: _fabric.name,
        securityService: SecurityService(),
        onDelete: () async {
          await _repository.deleteFabric(_fabric.id!);
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
          _fabric.name,
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
            onPressed: _editFabric,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteFabric,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_fabric.category != null && _fabric.category!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _fabric.category!,
                                style: TextStyle(
                                  color: theme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: theme.fontSize * 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            lang.formatCurrency(_fabric.pricePerUnit),
                            style: TextStyle(
                              color: theme.accentColor,
                              fontSize: theme.fontSize * 1.5,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'per ${_fabric.unit}',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: theme.fontSize * 0.9,
                              fontFamily: theme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                      if (_fabric.color != null && _fabric.color!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.borderColor),
                            image: _fabric.imagePath != null
                                ? DecorationImage(
                                    image: MemoryImage(base64Decode(_fabric.imagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Color',
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: theme.fontSize * 0.8,
                                ),
                              ),
                              Text(
                                _fabric.color!,
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    lang.t('description') ?? 'Description',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: theme.fontSize * 0.9,
                      fontFamily: theme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fabric.description ?? '-',
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
    if (_fabric.imagePath != null && _fabric.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(_fabric.imagePath!);
        return Hero(
          tag: 'fabric_image_${_fabric.id}',
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
          Icons.texture_outlined,
          size: 80,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
