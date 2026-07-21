import 'package:ichito/shared/providers/language_provider.dart';
import 'package:flutter/material.dart';
import '../../../../../shared/mixins/theme_aware_mixin.dart';
import '../../../../../core/widgets/ichito_scaffold.dart';
import '../../../../../shared/data/local/settings_repository.dart';

class MeasurementTypesScreen extends StatefulWidget {
  const MeasurementTypesScreen({super.key});

  @override
  State<MeasurementTypesScreen> createState() => _MeasurementTypesScreenState();
}

class _MeasurementTypesScreenState extends State<MeasurementTypesScreen> with ThemeAwareMixin {
  final _settings = SettingsRepository();
  List<String> _types = [];
  final _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  void _loadTypes() {
    setState(() {
      _types = _settings.getMeasurementSchema();
    });
  }

  Future<void> _saveTypes() async {
    await _settings.setMeasurementSchema(_types);
  }

  void _addType() {
    final type = _typeController.text.trim();
    if (type.isNotEmpty && !_types.contains(type)) {
      setState(() {
        _types.add(type);
      });
      _typeController.clear();
      _saveTypes();
    }
  }

  void _removeType(String type) {
    setState(() {
      _types.remove(type);
    });
    _saveTypes();
  }

  void _editType(int index, String newType) {
    if (newType.isNotEmpty && !_types.contains(newType)) {
      setState(() {
        _types[index] = newType;
      });
      _saveTypes();
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IchitoScaffold(
      showRadialMenu: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Measurement Types'.t(context), style: headingStyle.copyWith(fontSize: theme.fontSize * 1.12)),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _typeController,
                    style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
                    decoration: InputDecoration(
                      hintText: 'e.g. Chest, Waist, Length'.t(context),
                      hintStyle: TextStyle(color: theme.textSecondary),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: theme.cornerRadius),
                    ),
                    onSubmitted: (_) => _addType(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addType,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                    padding: EdgeInsets.all(16),
                  ),
                  child: Icon(Icons.add, color: theme.onAccent),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _types.isEmpty
                  ? Center(
                      child: Text('No measurement types added yet.'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
                    )
                  : ListView.builder(
                      itemCount: _types.length,
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        return Card(
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
                          child: ListTile(
                            title: Text(type, style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.textSecondary),
                                  onPressed: () => _showEditDialog(index, type),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeType(type),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index, String currentType) {
    final controller = TextEditingController(text: currentType);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: theme.cornerRadius),
          title: Text('Edit Type'.t(context), style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: theme.textPrimary, fontFamily: theme.fontFamily),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.backgroundColor,
              border: OutlineInputBorder(borderRadius: theme.cornerRadius),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.t(context), style: TextStyle(color: theme.textSecondary, fontFamily: theme.fontFamily)),
            ),
            ElevatedButton(
              onPressed: () {
                _editType(index, controller.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentColor,
                shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
              ),
              child: Text('Save'.t(context), style: TextStyle(color: theme.onAccent, fontFamily: theme.fontFamily)),
            ),
          ],
        );
      },
    );
  }
}
