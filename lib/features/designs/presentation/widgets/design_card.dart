import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/design.dart';

class DesignCard extends StatelessWidget  {
  final Design design;
  final VoidCallback onTap;

  const DesignCard({
    super.key,
    required this.design,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
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
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: theme.fontSize,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (design.category != null && design.category!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      design.category!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: theme.fontSize * 0.8,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeProvider theme) {
    if (design.imagePath != null && design.imagePath!.isNotEmpty) {
      try {
        final bytes = base64Decode(design.imagePath!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // Handle invalid base64 silently
      }
    }
    
    return Container(
      color: theme.accentColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.palette_outlined,
          size: 40,
          color: theme.accentColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

class DesignListTile extends StatefulWidget {
  final Design design;
  final VoidCallback onTap;
  
  const DesignListTile({
    super.key,
    required this.design,
    required this.onTap,
  });

  @override
  State<DesignListTile> createState() => _DesignListTileState();
}

class _DesignListTileState extends State<DesignListTile> {
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
                    onTap: widget.design.imagePath != null && widget.design.imagePath!.isNotEmpty
                        ? () => _showImagePreview(context, widget.design.imagePath!) 
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
                      child: widget.design.imagePath != null && widget.design.imagePath!.isNotEmpty
                          ? Image.memory(
                              base64Decode(widget.design.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(Icons.palette_outlined, color: theme.accentColor),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.design.name,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600, 
                            color: theme.textPrimary, 
                            fontFamily: theme.fontFamily
                          )
                        ),
                        if (widget.design.category != null && widget.design.category!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.design.category!,
                            style: TextStyle(
                              fontFamily: theme.fontFamily,
                              color: theme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.design.description != null && widget.design.description!.isNotEmpty)
                            Text(widget.design.description!, style: TextStyle(fontSize: 13, color: theme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis)
                          else
                            Text('No description', style: TextStyle(fontSize: 13, color: theme.textSecondary, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
