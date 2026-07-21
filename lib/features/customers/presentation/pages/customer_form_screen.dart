import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../shared/mixins/navigation_mixin.dart';
import '../../../../core/widgets/adaptive_components.dart';
import '../../../../shared/widgets/image_picker_dialog.dart';
import '../../../../shared/widgets/image_crop_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../../../shared/data/local/settings_repository.dart';
import '../../data/models/customer.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> with ThemeAwareMixin, NavigationMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  
  String _selectedGender = 'female';
  String _selectedRole = 'regular';
  String? _photoPath;
  
  // Measurement controllers
  final Map<String, TextEditingController> _measurementControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _locationController = TextEditingController(text: widget.customer?.location ?? '');
    
    if (widget.customer != null) {
      _selectedGender = widget.customer!.gender;
      _selectedRole = widget.customer!.role;
      _photoPath = widget.customer!.photoPath;
      
      // Initialize existing measurements
      widget.customer?.measurements?.forEach((key, value) {
        _measurementControllers[key] = TextEditingController(text: value.toString());
      });
    }
    
    _initMeasurementFields();
  }
  
  void _initMeasurementFields() {
    final fields = _getMeasurementFieldsForGender(_selectedGender);
    for (final field in fields) {
      if (!_measurementControllers.containsKey(field)) {
        _measurementControllers[field] = TextEditingController();
      }
    }
  }
  
  List<String> _getMeasurementFieldsForGender(String gender) {
    final schema = SettingsRepository().getMeasurementSchema();
    if (schema.isNotEmpty) {
      return schema;
    }
    // Fallback if settings are not set
    if (gender.toLowerCase() == 'male') {
      return ['height', 'chest', 'waist', 'hip', 'shoulder', 'neck', 'sleeve_length'];
    }
    // Female or default
    return ['height', 'bust', 'waist', 'hip', 'shoulder', 'sleeve_length'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    for (var c in _measurementControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  bool hasUnsavedChanges() {
    return _nameController.text != (widget.customer?.name ?? '') ||
           _phoneController.text != (widget.customer?.phone ?? '');
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerDialog.show(context);
    if (source == null) return;
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
    
    if (pickedFile == null) return;
    if (!mounted) return;
    
    final croppedBytes = await ImageCropDialog.show(context, File(pickedFile.path));
    if (croppedBytes == null) return;
    
    setState(() {
      _photoPath = base64Encode(croppedBytes);
    });
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Parse measurements
    final Map<String, double> measurements = {};
    _measurementControllers.forEach((key, controller) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        final val = double.tryParse(text);
        if (val != null) {
          measurements[key] = val;
        }
      }
    });

    final customer = Customer(
      id: widget.customer?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      role: _selectedRole,
      location: _locationController.text.trim(),
      photoPath: _photoPath,
      measurements: measurements.isEmpty ? null : measurements,
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = Provider.of<CustomerProvider>(context, listen: false);
    if (widget.customer == null) {
      await provider.addCustomer(customer);
    } else {
      await provider.updateCustomer(customer);
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate success
    }
  }
  
  String _formatMeasurementLabel(String key) {
    return key.split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges(),
      onPopInvoked: (didPop) {
        if (!didPop) {
          handleWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, color: theme.textPrimary),
            onPressed: () {
              if (hasUnsavedChanges()) {
                handleWillPop();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(widget.customer == null ? 'Add New Customer' : 'Edit Customer', style: headingStyle),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _saveCustomer,
              child: Text(
                'Save'.t(context),
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: theme.fontSize,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 24),
            children: [
              // Photo Upload
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.accentLight,
                      borderRadius: theme.cornerRadius,
                      border: Border.all(color: theme.accentColor, width: 2),
                      image: _photoPath != null
                          ? DecorationImage(image: MemoryImage(base64Decode(_photoPath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photoPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: theme.accentColor, size: 32),
                              SizedBox(height: 4),
                              Text('Upload'.t(context), style: TextStyle(fontSize: theme.fontSize * 0.75, color: theme.accentColor, fontFamily: theme.fontFamily)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text('Full Name *'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              AdaptiveTextField(
                controller: _nameController,
                label: '',
                hint: 'e.g. Jane Muthoni'.t(context),
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text('Phone *'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              AdaptiveTextField(
                controller: _phoneController,
                label: '',
                hint: 'e.g. 0712 345 678'.t(context),
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text('Email (Optional)'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              AdaptiveTextField(
                controller: _emailController,
                label: '',
                hint: 'e.g. jane@email.com'.t(context),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text('Gender *'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'male', label: Text('Male'.t(context)), icon: Icon(Icons.male)),
                    ButtonSegment(value: 'female', label: Text('Female'.t(context)), icon: Icon(Icons.female)),
                  ],
                  selected: {_selectedGender.toLowerCase() == 'male' ? 'male' : 'female'},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedGender = newSelection.first;
                      _initMeasurementFields();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return theme.accentColor;
                        }
                        return theme.cardColor;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return theme.onAccent;
                        }
                        return theme.textPrimary;
                      },
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text('Role / Status'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: theme.cornerRadius),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: theme.cornerRadius,
                      borderSide: BorderSide(color: theme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: theme.cornerRadius,
                      borderSide: BorderSide(color: theme.accentColor, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'regular', child: Text('Regular'.t(context))),
                    DropdownMenuItem(value: 'vip', child: Text('VIP'.t(context))),
                    DropdownMenuItem(value: 'loyal', child: Text('Loyal'.t(context))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedRole = val);
                    }
                  },
                ),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text('Location (Optional)'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.81, fontFamily: theme.fontFamily)),
              ),
              AdaptiveTextField(
                controller: _locationController,
                label: '',
                hint: 'e.g. Nairobi CBD'.t(context),
                prefixIcon: Icons.location_on_outlined,
              ),
              
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: theme.borderColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Default Measurements (Optional)'.t(context), style: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.75, fontFamily: theme.fontFamily)),
                    ),
                    Expanded(child: Divider(color: theme.borderColor)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              _buildMeasurementGrid(),
              
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMeasurementGrid() {
    final fields = _getMeasurementFieldsForGender(_selectedGender);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          return TextField(
            controller: _measurementControllers[field],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              labelText: _formatMeasurementLabel(field),
              labelStyle: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.88, fontFamily: theme.fontFamily),
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
              enabledBorder: OutlineInputBorder(
                borderRadius: theme.cornerRadius,
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: theme.cornerRadius,
                borderSide: BorderSide(color: theme.accentColor, width: 2),
              ),
              suffixText: 'cm', // Or fetch from settings
              suffixStyle: TextStyle(color: theme.textSecondary, fontSize: theme.fontSize * 0.75, fontFamily: theme.fontFamily),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}
