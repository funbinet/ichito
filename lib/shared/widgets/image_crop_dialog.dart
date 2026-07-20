import 'package:ichito/shared/providers/language_provider.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// A popup dialog for cropping and rotating an image.
/// 
/// Displays the image inside a circular mask with zoom/pan support
/// and rotation controls. Returns the cropped image as Uint8List bytes.
class ImageCropDialog extends StatefulWidget {
  final File imageFile;
  final bool isCircularPreview;

  const ImageCropDialog({
    super.key, 
    required this.imageFile,
    this.isCircularPreview = false,
  });

  /// Shows the crop dialog and returns cropped image bytes, or null if cancelled.
  static Future<Uint8List?> show(BuildContext context, File imageFile, {bool isCircularPreview = false}) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ImageCropDialog(imageFile: imageFile, isCircularPreview: isCircularPreview),
    );
  }

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  double _rotation = 0.0; // in radians
  final TransformationController _transformController = TransformationController();
  bool _isSaving = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _rotateLeft() {
    setState(() {
      _rotation -= math.pi / 2;
    });
  }

  void _rotateRight() {
    setState(() {
      _rotation += math.pi / 2;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      if (mounted) Navigator.pop(context, bytes);
    } catch (e) {
      if (mounted) Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final cropSize = MediaQuery.of(context).size.width * 0.65;

    return Dialog(
      backgroundColor: theme.cardColor,
      insetPadding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: theme.cornerRadius,
        side: BorderSide(color: theme.accentColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crop Photo'.t(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pinch to zoom, drag to position'.t(context),
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
                fontFamily: theme.fontFamily,
              ),
            ),
            SizedBox(height: 16),

            // Crop area with circular mask
            RepaintBoundary(
              key: _repaintKey,
              child: widget.isCircularPreview
                  ? ClipOval(
                      child: _buildCropContainer(cropSize, theme),
                    )
                  : ClipRRect(
                      borderRadius: theme.cornerRadius,
                      child: _buildCropContainer(cropSize, theme),
                    ),
            ),

            SizedBox(height: 16),

            // Rotation controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _rotateLeft,
                  icon: Icon(Icons.rotate_left, color: theme.accentColor, size: 28),
                  tooltip: 'Rotate Left'.t(context),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.accentLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _rotation = 0;
                      _transformController.value = Matrix4.identity();
                    });
                  },
                  icon: Icon(Icons.refresh, color: theme.textSecondary, size: 24),
                  tooltip: 'Reset'.t(context),
                ),
                SizedBox(width: 24),
                IconButton(
                  onPressed: _rotateRight,
                  icon: Icon(Icons.rotate_right, color: theme.accentColor, size: 28),
                  tooltip: 'Rotate Right'.t(context),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.accentLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.accentColor.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context, null),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: theme.buttonRadius,
                        side: BorderSide(color: theme.borderColor),
                      ),
                    ),
                    child: Text(
                      'Cancel'.t(context),
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _isSaving ? null : _save,
                    style: TextButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: theme.buttonRadius,
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.onAccent,
                            ),
                          )
                        : Text(
                            'Save'.t(context),
                            style: TextStyle(
                              color: theme.onAccent,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropContainer(double cropSize, ThemeProvider theme) {
    return Container(
      width: cropSize,
      height: cropSize,
      color: theme.backgroundColor,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.5,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: Transform.rotate(
          angle: _rotation,
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.cover,
            width: cropSize,
            height: cropSize,
          ),
        ),
      ),
    );
  }
}
