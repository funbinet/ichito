import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../data/models/fabric.dart';

class FabricCard extends StatelessWidget  {
  final Fabric fabric;
  final VoidCallback onTap;

  const FabricCard({
    super.key,
    required this.fabric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.borderColor,
            width: 1,
          ),
          boxShadow: theme.enableShadows ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildImage(context, theme),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fabric.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        lang.formatCurrency(fabric.pricePerUnit),
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                          fontSize: theme.fontSize * 0.9,
                        ),
                      ),
                      Text(
                        ' / ${fabric.unit}',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          color: theme.textSecondary,
                          fontSize: theme.fontSize * 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeProvider theme) {
    if (fabric.imagePath != null && fabric.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(fabric.imagePath!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // invalid base64
      }
    }
    
    return Container(
      color: theme.accentColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.texture_outlined,
          size: 40,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

class FabricListTile extends StatefulWidget {
  final Fabric fabric;
  final VoidCallback onTap;
  
  const FabricListTile({
    super.key,
    required this.fabric,
    required this.onTap,
  });

  @override
  State<FabricListTile> createState() => _FabricListTileState();
}

class _FabricListTileState extends State<FabricListTile> {
  bool _isExpanded = false;

  void _showImagePreview(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.memory(base64Decode(base64Image), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.fabric.imagePath != null && widget.fabric.imagePath!.isNotEmpty
                        ? () => _showImagePreview(context, widget.fabric.imagePath!) 
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.accentLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.borderColor, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.fabric.imagePath != null && widget.fabric.imagePath!.isNotEmpty
                          ? Image.memory(
                              base64Decode(widget.fabric.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(Icons.texture_outlined, color: theme.accentColor),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fabric.name,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600, 
                            color: theme.textPrimary, 
                            fontFamily: theme.fontFamily
                          )
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              lang.formatCurrency(widget.fabric.pricePerUnit),
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                              ),
                            ),
                            Text(
                              ' / ${widget.fabric.unit}',
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                color: theme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withOpacity(0.5),
                  border: Border(top: BorderSide(color: theme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit: ${widget.fabric.unit}', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                        if (widget.fabric.color != null) ...[
                          const SizedBox(height: 4),
                          Text('Color: ${widget.fabric.color}', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                        ],
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onTap,
                      icon: Icon(Icons.edit_outlined, size: 16, color: theme.accentColor),
                      label: Text('Edit/View', style: TextStyle(color: theme.accentColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.accentColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}
