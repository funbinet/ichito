import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/fabric.dart';

class FabricFormDialog extends StatefulWidget {
  final Fabric? fabric;

  const FabricFormDialog({super.key, this.fabric});

  @override
  State<FabricFormDialog> createState() => _FabricFormDialogState();
}

class _FabricFormDialogState extends State<FabricFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _colorController = TextEditingController();
  
  String? _imagePath;
  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.fabric != null) {
      _nameController.text = widget.fabric!.name;
      _descriptionController.text = widget.fabric!.description ?? '';
      _categoryController.text = widget.fabric!.category ?? '';
      _priceController.text = widget.fabric!.pricePerUnit.toString();
      _unitController.text = widget.fabric!.unit;
      _colorController.text = widget.fabric!.color ?? '';
      _imagePath = widget.fabric!.imagePath;
    } else {
      _unitController.text = 'meter';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _colorController.dispose();
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
    
    setState(() => _isPickingImage = true);
    
    final croppedBytes = await ImageCropDialog.show(context, File(pickedFile.path));
    
    if (croppedBytes != null) {
      setState(() {
        _imagePath = base64Encode(croppedBytes);
      });
    }
    
    setState(() => _isPickingImage = false);
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final fabric = Fabric(
        id: widget.fabric?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
        pricePerUnit: double.tryParse(_priceController.text.trim()) ?? 0.0,
        unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'meter',
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
        imagePath: _imagePath,
        usageCount: widget.fabric?.usageCount ?? 0,
        createdAt: widget.fabric?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, fabric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isEditing = widget.fabric != null;

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? lang.t('edit') ?? 'Edit' : lang.t('add_fabric') ?? 'Add Fabric',
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: theme.fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                
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
                          ? _isPickingImage 
                            ? Center(child: CircularProgressIndicator())
                            : Icon(Icons.add_a_photo, color: theme.textSecondary, size: 40)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Fields
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(lang.t('name') ?? 'Name', theme),
                  style: TextStyle(color: theme.textPrimary),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        decoration: _inputDecoration(lang.t('price_per_unit') ?? 'Price', theme),
                        style: TextStyle(color: theme.textPrimary),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitController,
                        decoration: _inputDecoration('Unit', theme),
                        style: TextStyle(color: theme.textPrimary),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: _inputDecoration(lang.t('category') ?? 'Category', theme),
                  style: TextStyle(color: theme.textPrimary),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _colorController,
                  decoration: _inputDecoration('Color', theme),
                  style: TextStyle(color: theme.textPrimary),
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(lang.t('description') ?? 'Description', theme),
                  style: TextStyle(color: theme.textPrimary),
                  maxLines: 3,
                ),
                SizedBox(height: 32),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        lang.t('cancel') ?? 'Cancel',
                        style: TextStyle(color: theme.textSecondary),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        foregroundColor: theme.onAccent,
                        shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                      ),
                      child: _isSaving 
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(lang.t('save') ?? 'Save'),
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

  InputDecoration _inputDecoration(String label, ThemeProvider theme) {
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
