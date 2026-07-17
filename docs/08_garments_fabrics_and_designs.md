# ICHITO -- Garments, Fabrics & Designs

**Document**: 08 of 14
**Covers**: Garment library, fabric catalog, design gallery, add/edit dialogs, image handling pipeline, categorization, measurement field templates, grid density options

---

## 1. Garment Library

### 1.1 Purpose
The garment library defines all types of clothing items that can be ordered. Each garment type specifies which body measurements are needed, allowing the order wizard to dynamically generate measurement input fields.

### 1.2 Garment List Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Garments                  [+ Add]  [Stats] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search garments...                     │
│                                                      │
│  [All]  [Men]  [Women]  [Unisex]                    │
│  (filter chips by category)                          │
│                                                      │
│  View: [GridIcon | ListIcon]                        │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │[Checkroom]│  │[Checkroom]│  │[Checkroom]│          │
│  │ Trousers │  │  Shirt   │  │  Jacket  │          │
│  │ 6 meas.  │  │ 5 meas.  │  │ 6 meas.  │          │
│  │ Men      │  │ Men      │  │ Men      │          │
│  │ 15 orders│  │ 12 orders│  │ 8 orders │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │[Checkroom]│  │[Checkroom]│  │[Checkroom]│          │
│  │  Dress   │  │  Blouse  │  │  Skirt   │          │
│  │ 5 meas.  │  │ 4 meas.  │  │ 4 meas.  │          │
│  │ Women    │  │ Women    │  │ Women    │          │
│  │ 12 orders│  │ 8 orders │  │ 6 orders │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  Total: 13 Garment Types                            │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 1.3 Garment Card Widget

```dart
class GarmentCard extends StatelessWidget {
  final Garment garment;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Garment icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.checkroom_outlined, color: theme.accentColor, size: 28),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              garment.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Measurement count
            Text(
              '${garment.measurementFields.length} measurements',
              style: TextStyle(fontSize: 11, color: theme.textSecondary),
            ),
            // Category badge
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _getCategoryColor(garment.category).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _capitalize(garment.category),
                style: TextStyle(
                  fontSize: 10,
                  color: _getCategoryColor(garment.category),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Usage count
            Text(
              '${garment.usageCount} orders',
              style: TextStyle(fontSize: 10, color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'men': return const Color(0xFF2196F3);
      case 'women': return const Color(0xFFE91E63);
      case 'unisex': return const Color(0xFF4CAF50);
      default: return const Color(0xFF9E9E9E);
    }
  }
}
```

### 1.4 Garment Detail Screen

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Trousers               [Edit]  [Delete]    │
├─────────────────────────────────────────────────────┤
│                                                      │
│  [CheckroomIcon - 64px, in accent circle]            │
│                                                      │
│  Trousers                                            │
│  Category: Men                                       │
│  Description: Casual trousers with belt loops        │
│  Default Price: KES 2,000                            │
│  Used in: 15 orders                                  │
│                                                      │
│  ┌── Measurement Fields ────────────────────────────┐│
│  │  1. Waist                                       ││
│  │  2. Inseam                                      ││
│  │  3. Hip                                         ││
│  │  4. Thigh                                       ││
│  │  5. Knee                                        ││
│  │  6. Length                                       ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Created: 01/01/2026                                │
│  Last Updated: 15/07/2026                            │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 1.5 Add/Edit Garment Dialog

```
┌─────────────────────────────────────────────────────┐
│  Add New Garment                                     │
├─────────────────────────────────────────────────────┤
│  Garment Name *                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  Trousers                                       ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Description                                         │
│  ┌──────────────────────────────────────────────────┐│
│  │  Casual trousers with belt loops                ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Category *                                          │
│  [MaleIcon Men]  [FemaleIcon Women]  [Unisex]       │
│  (segmented control)                                 │
│                                                      │
│  Measurement Fields *                                │
│  ┌──────────────────────────────────────────────────┐│
│  │  [Waist]     [x]                                ││
│  │  [Inseam]    [x]                                ││
│  │  [Hip]       [x]                                ││
│  │  [Thigh]     [x]                                ││
│  │  [Knee]      [x]                                ││
│  │  [Length]     [x]                                ││
│  │  [+ Add Measurement Field]                      ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Default Price                                       │
│  ┌──────────────────────────────────────────────────┐│
│  │  2,000                                  KES     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [Cancel]                     [Save Garment]         │
└─────────────────────────────────────────────────────┘
```

**Measurement Field Management**:
- Pre-populated suggestions when adding: waist, inseam, hip, thigh, knee, length, bust, shoulder, chest, neck, sleeve_length, back_width, shirt_length, dress_length, skirt_length, gown_length
- Tap "+ Add" shows a dropdown of common measurement names or a text field for custom names
- Each field can be removed with the [x] button (minimum 1 field required)
- Fields are reorderable via drag handles

**Validation**:
- Name required, 2-100 characters
- Category required
- At least 1 measurement field
- Default price optional, must be > 0 if provided

**Deletion Rules**:
- Cannot delete a garment that is used in existing orders (FK RESTRICT)
- Show error: "This garment is used in X orders. Remove or reassign those orders before deleting."

---

## 2. Fabric Catalog

### 2.1 Purpose
The fabric catalog manages all fabric materials available. Each fabric has a name, price, optional image, and category. Fabrics can be selected during order creation.

### 2.2 Fabric List Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Fabrics                   [+ Add]  [Stats] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search fabrics...                      │
│                                                      │
│  Sort: [Name v]  [Price v]  [Date v]  [Popular v]   │
│  Grid Density: [4] [8] [16] [32]                    │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │ Cotton   │  │  Silk    │  │  Denim   │          │
│  │ Print    │  │  Satin   │  │  Blue    │          │
│  │ KES 500  │  │ KES 1200 │  │ KES 800  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │  Linen   │  │  Wool    │  │Polyester │          │
│  │ Natural  │  │ Blended  │  │ Premium  │          │
│  │ KES 900  │  │ KES 1500 │  │ KES 600  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  Total: 125 Fabrics                                  │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 2.3 Grid Density

Users can configure how many items per row in the grid:

| Density | Columns | Card Size | Image Size | Shows |
|---------|---------|-----------|------------|-------|
| 4 | 2 | Large | 120x120 | Image, name, description, price |
| 8 | 3 | Medium | 80x80 | Image, name, price |
| 16 | 4 | Small | 60x60 | Image, name, price (small text) |
| 32 | 5+ | Tiny | 48x48 | Image only (name on tap) |

The grid density is a horizontal selector below the sort controls:

```dart
Row(
  children: [
    Text('Grid:', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
    const SizedBox(width: 8),
    ...['4', '8', '16', '32'].map((density) =>
      GestureDetector(
        onTap: () => setState(() => _gridDensity = int.parse(density)),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _gridDensity == int.parse(density)
              ? theme.accentColor
              : theme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            density,
            style: TextStyle(
              fontSize: 12,
              color: _gridDensity == int.parse(density)
                ? theme.onAccent
                : theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  ],
)
```

### 2.4 Fabric Card Widget

```dart
class FabricCard extends StatelessWidget {
  final Fabric fabric;
  final int gridDensity;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showFullImage(context, fabric.imagePath),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: theme.cornerRadius.topLeft,
                  topRight: theme.cornerRadius.topRight,
                ),
                child: fabric.imagePath != null
                  ? Image.file(
                      File(fabric.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.surfaceColor,
                      child: Icon(
                        Icons.texture_outlined,
                        color: theme.textSecondary.withOpacity(0.3),
                        size: gridDensity <= 8 ? 32 : 20,
                      ),
                    ),
              ),
            ),
            // Info (hidden at density 32)
            if (gridDensity < 32)
              Padding(
                padding: EdgeInsets.all(gridDensity <= 8 ? 8 : 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fabric.name,
                      style: TextStyle(
                        fontSize: gridDensity <= 8 ? 12 : 10,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gridDensity <= 4 && fabric.description != null)
                      Text(
                        fabric.description!,
                        style: TextStyle(fontSize: 10, color: theme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      language.formatCurrency(fabric.pricePerUnit),
                      style: TextStyle(
                        fontSize: gridDensity <= 8 ? 11 : 9,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
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
```

### 2.5 Add/Edit Fabric Dialog

```
┌─────────────────────────────────────────────────────┐
│  Add New Fabric                                      │
├─────────────────────────────────────────────────────┤
│  [CameraIcon] Upload Image                          │
│  (Tap to pick from camera/gallery, then crop)       │
│                                                      │
│  Fabric Name *                                       │
│  ┌──────────────────────────────────────────────────┐│
│  │  Cotton Print                                   ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Description                                         │
│  ┌──────────────────────────────────────────────────┐│
│  │  Light cotton with floral print                 ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Price per Unit *                                    │
│  ┌──────────────────────────────────────────────────┐│
│  │  500                                    KES     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Unit *                                              │
│  [Meter]  [Foot]  [Yard]                            │
│  (segmented control, default: Meter)                 │
│                                                      │
│  Category                                            │
│  [Cotton] [Silk] [Synthetic] [Linen] [Wool]         │
│  [Denim] [Polyester] [Other]                        │
│  (horizontal chip selector)                          │
│                                                      │
│  Color                                               │
│  [Color circle]  [Select Color]                      │
│  (Opens color picker, saves as hex string)           │
│                                                      │
│  [Cancel]                       [Save Fabric]        │
└─────────────────────────────────────────────────────┘
```

**Image Handling**:
- Tap the image area to open image source selector (Camera / Gallery)
- After selection, open cropper with free aspect ratio (fabric samples are often rectangular)
- Compress to max 800x800, quality 85
- Save to `{appDocDir}/images/fabrics/{uuid}.jpg`
- If editing and image changes, delete old image file

**Validation**:
- Name required, 2-100 characters
- Price required, must be > 0
- Unit required (default: meter)
- Category optional
- Color optional

### 2.6 Fabric Detail Screen

Tapping a fabric card shows the detail screen with:
- Full-size image (tap to zoom/pinch)
- Name, description, price, unit, category, color
- Usage count (how many orders use this fabric)
- Created/updated dates
- Edit and delete actions in app bar

### 2.7 Fabric Deletion

- Fabrics can be deleted even if used in orders (FK SET NULL)
- Show warning: "This fabric is referenced in X orders. Those orders will retain their data but the fabric link will be removed."
- Delete the associated image file on deletion

---

## 3. Design Gallery

### 3.1 Purpose
The design gallery manages visual references and pattern designs that can be associated with orders. Designs are primarily image-based -- users capture or import reference photos of desired clothing patterns.

### 3.2 Design List Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Designs                   [+ Add]  [Stats] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search designs...                      │
│                                                      │
│  Sort: [Name v]  [Date v]  [Popularity v]           │
│  Grid Density: [4] [8] [16] [32]                    │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │  Floral  │  │Geometric │  │ Abstract │          │
│  │  Dress   │  │ Pattern  │  │   Art    │          │
│  │ 12 used  │  │  8 used  │  │  6 used  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │ African  │  │  Modern  │  │ Vintage  │          │
│  │  Print   │  │ Minimal  │  │ Classic  │          │
│  │ 15 used  │  │ 10 used  │  │  5 used  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  Total: 68 Designs                                   │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 3.3 Design Card Widget

Same structure as FabricCard but with:
- Icon fallback: `Icons.palette_outlined` (instead of texture)
- Shows usage count instead of price
- Category badge from design categories

### 3.4 Add/Edit Design Dialog

```
┌─────────────────────────────────────────────────────┐
│  Add New Design                                      │
├─────────────────────────────────────────────────────┤
│  [CameraIcon] Upload Image                          │
│  (Tap to pick from camera/gallery, then crop)       │
│                                                      │
│  Design Name *                                       │
│  ┌──────────────────────────────────────────────────┐│
│  │  Floral Dress Design                            ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Description                                         │
│  ┌──────────────────────────────────────────────────┐│
│  │  Floral pattern with roses on light background  ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Category                                            │
│  [Floral] [Geometric] [Abstract] [African]          │
│  [Modern] [Vintage] [Traditional] [Other]            │
│  (horizontal chip selector)                          │
│                                                      │
│  [Cancel]                       [Save Design]        │
└─────────────────────────────────────────────────────┘
```

**Validation**:
- Name required, 2-100 characters
- Category optional
- Image optional (but encouraged)

### 3.5 Design Deletion

Same rules as fabrics -- FK SET NULL on orders, warning about affected orders, image file cleanup.

---

## 4. Image Handling Pipeline

### 4.1 Image Flow

```
User Action (Camera/Gallery)
        │
        ▼
ImagePicker.pickImage()
  maxWidth: 1200
  maxHeight: 1200
        │
        ▼
ImageCropper.cropImage()
  aspectRatio: varies by context
  uiSettings: accent-colored toolbar
        │
        ▼
FlutterImageCompress.compressAndGetFile()
  quality: 85
  maxWidth: 800 (fabric/design) or 400 (avatar)
  maxHeight: 800 (fabric/design) or 400 (avatar)
  format: JPEG
        │
        ▼
Save to {appDocDir}/images/{category}/{uuid}.jpg
        │
        ▼
Store path in entity model
```

### 4.2 Image Storage Paths

| Category | Path | Max Size | Aspect Ratio |
|----------|------|----------|--------------|
| Customer avatars | `images/customers/{uuid}.jpg` | 400x400 | 1:1 (square) |
| Fabric samples | `images/fabrics/{uuid}.jpg` | 800x800 | Free |
| Design references | `images/designs/{uuid}.jpg` | 800x800 | Free |
| Thumbnails | `images/thumbnails/{uuid}_thumb.jpg` | 200x200 | Same as source |

### 4.3 Thumbnail Generation

For list views, generate thumbnails on first load and cache them:

```dart
Future<String> generateThumbnail(String sourcePath) async {
  final thumbDir = '${appDocDir.path}/images/thumbnails';
  await Directory(thumbDir).create(recursive: true);
  
  final fileName = path.basenameWithoutExtension(sourcePath);
  final thumbPath = '$thumbDir/${fileName}_thumb.jpg';
  
  // Check cache
  if (await File(thumbPath).exists()) return thumbPath;
  
  // Generate
  final result = await FlutterImageCompress.compressAndGetFile(
    sourcePath,
    thumbPath,
    quality: 70,
    minWidth: 200,
    minHeight: 200,
  );
  
  return result?.path ?? sourcePath;
}
```

### 4.4 Image Cleanup Service

Periodically or on demand (from Settings > Storage), clean up orphaned images:

```dart
Future<void> cleanupOrphanedImages() async {
  final allImagePaths = <String>{};
  
  // Collect all referenced image paths
  final customers = await customerRepo.getAll();
  final fabrics = await fabricRepo.getAll();
  final designs = await designRepo.getAll();
  
  for (final c in customers) if (c.photoPath != null) allImagePaths.add(c.photoPath!);
  for (final f in fabrics) if (f.imagePath != null) allImagePaths.add(f.imagePath!);
  for (final d in designs) if (d.imagePath != null) allImagePaths.add(d.imagePath!);
  
  // Scan image directories
  final imageDir = Directory('${appDocDir.path}/images');
  if (!await imageDir.exists()) return;
  
  await for (final entity in imageDir.list(recursive: true)) {
    if (entity is File && !allImagePaths.contains(entity.path)) {
      // Skip thumbnails subdirectory cleanup for now
      if (!entity.path.contains('/thumbnails/')) {
        await entity.delete();
      }
    }
  }
  
  // Clear all thumbnails (they'll regenerate on demand)
  final thumbDir = Directory('${appDocDir.path}/images/thumbnails');
  if (await thumbDir.exists()) {
    await thumbDir.delete(recursive: true);
  }
}
```

---

## 5. Inline Creation During Order Wizard

During the order wizard, users can create new garments, fabrics, or designs without leaving the wizard flow.

### 5.1 Flow

1. User is on Step 2 (Garment Selection) or Step 4 (Materials)
2. Taps "+ Add New Garment/Fabric/Design"
3. A dialog/bottom sheet opens with the add form
4. User fills in the form and saves
5. The new entity is created in the database
6. The dialog closes
7. The wizard auto-selects the newly created entity
8. The wizard remains on the same step

### 5.2 Implementation

```dart
// In StepGarmentSelection
void _addNewGarment() async {
  final newGarment = await showDialog<Garment>(
    context: context,
    builder: (context) => GarmentFormDialog(),
  );
  
  if (newGarment != null) {
    // Refresh garment list and auto-select
    await _loadGarments();
    widget.onSelect(newGarment);
  }
}
```

---

## 6. Sort Options

### 6.1 Garment Sort

| Option | Query |
|--------|-------|
| Name A-Z | `ORDER BY name ASC` |
| Name Z-A | `ORDER BY name DESC` |
| Most Used | `ORDER BY usage_count DESC` |
| Newest | `ORDER BY created_at DESC` |

### 6.2 Fabric Sort

| Option | Query |
|--------|-------|
| Name A-Z | `ORDER BY name ASC` |
| Price Low-High | `ORDER BY price_per_unit ASC` |
| Price High-Low | `ORDER BY price_per_unit DESC` |
| Most Used | `ORDER BY usage_count DESC` |
| Newest | `ORDER BY created_at DESC` |

### 6.3 Design Sort

| Option | Query |
|--------|-------|
| Name A-Z | `ORDER BY name ASC` |
| Most Used | `ORDER BY usage_count DESC` |
| Newest | `ORDER BY created_at DESC` |

---

## 7. Full-Size Image Preview

Long-pressing any fabric or design card with an image opens a full-screen, dismissible preview:

```dart
void _showFullImage(BuildContext context, String? imagePath) {
  if (imagePath == null) return;
  
  Navigator.push(context, PageRouteBuilder(
    opaque: false,
    pageBuilder: (_, __, ___) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black87,
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    ),
  ));
}
```

Features:
- Pinch to zoom (0.5x to 4.0x)
- Pan when zoomed
- Tap anywhere to dismiss
- Dark scrim background

---

## 8. Statistics Overlay

Each library screen (Garments, Fabrics, Designs) has a stats icon in the app bar that shows aggregate information:

### Garment Stats
```
Total Types: 13 (7 Men, 5 Women, 1 Unisex)
Most Popular: Trousers (15 orders)
Least Used: Jumpsuit (0 orders)
Average Measurements/Garment: 5.2
```

### Fabric Stats
```
Total Fabrics: 125
Price Range: KES 300 - KES 2,500
Average Price: KES 850/meter
Most Used: Cotton Print (28 orders)
Categories: Cotton (45), Silk (20), Synthetic (30), Other (30)
```

### Design Stats
```
Total Designs: 68
Most Used: African Print (15 orders)
Categories: Floral (12), Geometric (8), African (15), Modern (10), Other (23)
```

---

*This is Document 08 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
