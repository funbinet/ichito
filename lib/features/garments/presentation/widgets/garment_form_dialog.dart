import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../data/models/garment.dart';

class GarmentFormDialog extends StatefulWidget {
  final Garment? garment;

  const GarmentFormDialog({super.key, this.garment});

  @override
  State<GarmentFormDialog> createState() => _GarmentFormDialogState();
}

class _GarmentFormDialogState extends State<GarmentFormDialog> with ThemeAwareMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _category = 'unisex';
  List<String> _selectedMeasurements = [];
  List<String> _availableMeasurements = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _availableMeasurements = SettingsRepository().getMeasurementSchema();
    if (_availableMeasurements.isEmpty) {
      _availableMeasurements = ['height', 'chest', 'waist', 'hip', 'shoulder', 'neck', 'sleeve_length', 'bust'];
    }

    if (widget.garment != null) {
      _nameController.text = widget.garment!.name;
      _descriptionController.text = widget.garment!.description ?? '';
      _category = widget.garment!.category;
      _priceController.text = widget.garment!.defaultPrice?.toString() ?? '';
      _selectedMeasurements = List.from(widget.garment!.measurementFields);
    } else {
      _selectedMeasurements = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final fields = _selectedMeasurements;

      final garment = Garment(
        id: widget.garment?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        measurementFields: fields,
        defaultPrice: double.tryParse(_priceController.text.trim()),
        usageCount: widget.garment?.usageCount ?? 0,
        createdAt: widget.garment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, garment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isEditing = widget.garment != null;

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
                  isEditing ? lang.t('edit') : lang.t('add_garment'),
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: theme.fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(lang.t('name')),
                  style: TextStyle(color: theme.textPrimary),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration(lang.t('category')),
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'men', child: Text('Men'.t(context))),
                    DropdownMenuItem(value: 'women', child: Text('Women'.t(context))),
                    DropdownMenuItem(value: 'unisex', child: Text('Unisex'.t(context))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _priceController,
                  decoration: _inputDecoration('Default Price (Optional)'),
                  style: TextStyle(color: theme.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),

                Text('Measurement Fields'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableMeasurements.map((m) {
                    final isSelected = _selectedMeasurements.contains(m);
                    return FilterChip(
                      label: Text(m, style: TextStyle(color: isSelected ? theme.onAccent : theme.textPrimary)),
                      selected: isSelected,
                      selectedColor: theme.accentColor,
                      backgroundColor: theme.backgroundColor.withOpacity(0.5),
                      checkmarkColor: theme.onAccent,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedMeasurements.add(m);
                          } else {
                            _selectedMeasurements.remove(m);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_selectedMeasurements.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Please select at least one measurement field.'.t(context), style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(lang.t('description')),
                  style: TextStyle(color: theme.textPrimary),
                  maxLines: 2,
                ),
                SizedBox(height: 32),
                
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
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving || _selectedMeasurements.isEmpty ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        foregroundColor: theme.onAccent,
                        shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                      ),
                      child: _isSaving 
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
