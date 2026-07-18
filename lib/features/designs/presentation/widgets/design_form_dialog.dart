import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../data/models/design.dart';

class DesignFormDialog extends StatefulWidget {
  final Design? design;

  const DesignFormDialog({super.key, this.design});

  @override
  State<DesignFormDialog> createState() => _DesignFormDialogState();
}

class _DesignFormDialogState extends State<DesignFormDialog> with ThemeAwareMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.design != null) {
      _nameController.text = widget.design!.name;
      _descriptionController.text = widget.design!.description ?? '';
      _categoryController.text = widget.design!.category ?? '';
      _imagePath = widget.design!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerDialog.show(context);
    if (source == null) return;
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
    
    if (pickedFile == null) return;
    
    final croppedBytes = await ImageCropDialog.show(context, File(pickedFile.path));
    
    if (croppedBytes != null) {
      setState(() {
        _imagePath = base64Encode(croppedBytes);
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final design = Design(
        id: widget.design?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
        imagePath: _imagePath,
        usageCount: widget.design?.usageCount ?? 0,
        createdAt: widget.design?.createdAt,
      );

      Navigator.pop(context, design);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isEditing = widget.design != null;

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? lang.t('edit') : lang.t('add_design'),
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: theme.fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.borderColor),
                        image: _imagePath != null
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(_imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imagePath == null
                          ? Icon(Icons.add_a_photo, color: theme.textSecondary, size: 40)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Fields
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(lang.t('name')),
                  style: TextStyle(color: theme.textPrimary),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _categoryController,
                  decoration: _inputDecoration(lang.t('category')),
                  style: TextStyle(color: theme.textPrimary),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(lang.t('description')),
                  style: TextStyle(color: theme.textPrimary),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        lang.t('cancel'),
                        style: TextStyle(color: theme.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        foregroundColor: theme.onAccent,
                        shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                      ),
                      child: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(lang.t('save')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.textSecondary),
      filled: true,
      fillColor: theme.backgroundColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: theme.cornerRadius,
        borderSide: BorderSide(color: theme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: theme.cornerRadius,
        borderSide: BorderSide(color: theme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: theme.cornerRadius,
        borderSide: BorderSide(color: theme.accentColor),
      ),
    );
  }
}
