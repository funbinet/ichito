# ICHITO -- Theming & Design System

**Document**: 04 of 14
**Covers**: Accent system, 15+ corner styles, shadow intelligence, font system, color palettes, dark/light/AMOLED modes, design tokens, spacing scale, component styling rules, adaptive UI

---

## 1. Design Philosophy

ICHITO's visual identity is built on a single principle: **every visual element adapts to one accent color**. When a user changes their accent color from Gold to Emerald, every button, icon highlight, progress bar, shadow glow, divider, selection state, and active indicator across the entire app transforms simultaneously. This creates a deeply personal, premium experience where no two ICHITO installations look exactly alike.

---

## 2. Theme Modes

ICHITO supports three visual modes:

### 2.1 AMOLED Dark (Default)

Pure black backgrounds for maximum contrast and AMOLED battery savings.

| Token | Value | Hex |
|-------|-------|-----|
| `backgroundColor` | Pure Black | `#000000` |
| `surfaceColor` | Near Black | `#1A1A1A` |
| `cardColor` | Dark Grey | `#1E1E1E` |
| `textPrimary` | Pure White | `#FFFFFF` |
| `textSecondary` | Light Grey | `#B0B0B0` |
| `dividerColor` | Accent @ 30% opacity | `accentColor.withOpacity(0.3)` |
| `borderColor` | Accent @ 20% opacity | `accentColor.withOpacity(0.2)` |

### 2.2 Dark Mode

Softer dark theme for users who find AMOLED too harsh.

| Token | Value | Hex |
|-------|-------|-----|
| `backgroundColor` | Dark Blue-Grey | `#121212` |
| `surfaceColor` | Slightly Lighter | `#1E1E2E` |
| `cardColor` | Card Dark | `#252540` |
| `textPrimary` | Off White | `#F0F0F0` |
| `textSecondary` | Muted | `#A0A0B0` |
| `dividerColor` | Accent @ 25% | `accentColor.withOpacity(0.25)` |
| `borderColor` | Accent @ 15% | `accentColor.withOpacity(0.15)` |

### 2.3 Light Mode

Bright theme for daytime/outdoor use.

| Token | Value | Hex |
|-------|-------|-----|
| `backgroundColor` | Off White | `#FAFAFA` |
| `surfaceColor` | White | `#FFFFFF` |
| `cardColor` | Pure White | `#FFFFFF` |
| `textPrimary` | Near Black | `#1A1A1A` |
| `textSecondary` | Grey | `#666666` |
| `dividerColor` | Accent @ 20% | `accentColor.withOpacity(0.2)` |
| `borderColor` | Grey @ 15% | `#E0E0E0` |

---

## 3. Accent Color System

### 3.1 How Accent Color Propagates

When the accent color changes, the following elements update globally:

| Element | Usage |
|---------|-------|
| **Buttons** (ElevatedButton) | Background color = accent |
| **Buttons** (OutlinedButton) | Border color = accent, text = accent |
| **Buttons** (TextButton) | Text color = accent |
| **FAB** | Background = accent |
| **AppBar actions** | Active/selected icon tint = accent |
| **Progress indicators** | Bar color = accent |
| **Switches/toggles** | Active track/thumb = accent |
| **Checkboxes** | Checked fill = accent |
| **Radio buttons** | Selected fill = accent |
| **Text selection** | Cursor, handles, highlight = accent |
| **Input fields** | Focused border = accent, label = accent |
| **Tabs** | Active tab indicator = accent |
| **Filter chips** | Selected background = accent @ 15%, border = accent |
| **Badges** | Background = accent |
| **Dividers** | Color = accent @ 30% |
| **Card shadows** | Shadow color = accent @ shadowIntensity |
| **Status bar** | Not changed (stays system default) |
| **Snackbars** | Action button text = accent |
| **Scroll overscroll glow** | Color = accent |
| **Slider** | Track = accent |
| **Date picker** | Selected date = accent |
| **Bottom sheet handle** | Color = accent @ 50% |
| **Radial menu items** | Icon highlight on hover/press = accent |
| **Loyalty badges** | Border = accent |
| **Wizard progress bar** | Filled portion = accent |

### 3.2 Curated Accent Color Presets

30 curated colors organized in categories:

**Warm Tones**:

| Name | Hex | Preview Description |
|------|-----|---------------------|
| Gold (Default) | `#FFD700` | Warm, premium, craftsmanship |
| Amber | `#FFC107` | Bright, energetic |
| Tangerine | `#FF9800` | Vibrant, bold |
| Coral | `#FF7043` | Warm, inviting |
| Sunset | `#FF5722` | Dramatic, passionate |
| Rose | `#E91E63` | Elegant, feminine |

**Cool Tones**:

| Name | Hex |
|------|-----|
| Sapphire | `#2196F3` |
| Ocean | `#0097A7` |
| Teal | `#009688` |
| Sky | `#03A9F4` |
| Indigo | `#3F51B5` |
| Lavender | `#7C4DFF` |

**Nature Tones**:

| Name | Hex |
|------|-----|
| Emerald | `#4CAF50` |
| Forest | `#2E7D32` |
| Lime | `#8BC34A` |
| Mint | `#26A69A` |
| Sage | `#66BB6A` |
| Olive | `#689F38` |

**Neutral Tones**:

| Name | Hex |
|------|-----|
| Silver | `#9E9E9E` |
| Steel | `#607D8B` |
| Graphite | `#455A64` |
| Slate | `#546E7A` |
| Pearl | `#B0BEC5` |
| Platinum | `#78909C` |

**Bold Tones**:

| Name | Hex |
|------|-----|
| Ruby | `#D32F2F` |
| Magenta | `#C2185B` |
| Purple | `#9C27B0` |
| Electric Blue | `#1565C0` |
| Crimson | `#B71C1C` |
| Violet | `#6A1B9A` |

### 3.3 Custom Color Picker

Beyond presets, users can pick any color via:
- **Color wheel** -- Full HSL color picker
- **HEX input** -- Direct hex code entry (e.g., `#FF5733`)
- **RGB sliders** -- Individual R, G, B channel sliders
- **Recent colors** -- Last 10 custom colors are saved

### 3.4 Accent Color Application in Code

```dart
class ThemeProvider extends ChangeNotifier {
  Color _accentColor = const Color(0xFFFFD700);
  
  Color get accentColor => _accentColor;
  
  // Derived accent variants
  Color get accentLight => _accentColor.withOpacity(0.15);
  Color get accentMedium => _accentColor.withOpacity(0.3);
  Color get accentSubtle => _accentColor.withOpacity(0.08);
  Color get accentOnSurface => _isLightMode ? _accentColor : _accentColor;
  
  // For text on accent backgrounds
  Color get onAccent {
    // Calculate luminance to determine if text should be black or white
    return _accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  void setAccentColor(Color color) {
    _accentColor = color;
    _saveToHive('accent_color', color.value);
    notifyListeners();
  }
}
```

---

## 4. Corner Style System

15+ corner styles that transform the entire app's personality. Every card, button, input field, dialog, chip, and container respects the active corner style.

### 4.1 Corner Style Definitions

```dart
enum CornerStyle {
  rounded,      // Default
  sharp,
  pill,
  notched,
  teardrop,
  scooped,
  beveled,
  asymmetric,
  cascading,
  crystal,
  softRounded,
  oblique,
  angular,
  hybrid,
  responsive,
}
```

### 4.2 Border Radius Mapping

| Style | Card Radius | Button Radius | Input Radius | Dialog Radius | Chip Radius | Description |
|-------|-------------|---------------|--------------|---------------|-------------|-------------|
| `rounded` | `12` | `8` | `8` | `16` | `20` | Soft, friendly, approachable |
| `sharp` | `0` | `0` | `0` | `0` | `4` | Professional, minimalist |
| `pill` | `24` | `24` | `24` | `24` | `24` | Ultra-modern, playful |
| `notched` | `12, 0, 12, 0` | `8, 0, 8, 0` | `8, 0, 8, 0` | `16, 0, 16, 0` | `12` | Unique, diagonal |
| `teardrop` | `24, 4, 24, 4` | `16, 4, 16, 4` | `16, 4, 16, 4` | `24, 4, 24, 4` | `16` | Elegant, sophisticated |
| `scooped` | `16` (concave top) | `12` | `12` | `20` | `16` | Organic, natural |
| `beveled` | `BeveledRectangleBorder(12)` | `Beveled(8)` | `Beveled(8)` | `Beveled(16)` | `Beveled(8)` | Premium, luxurious |
| `asymmetric` | `24, 4, 4, 24` | `16, 4, 4, 16` | `12, 4, 4, 12` | `24, 4, 4, 24` | `16, 4` | Dynamic, artistic |
| `cascading` | `4, 8, 16, 24` | `4, 8, 12, 16` | `4, 6, 8, 12` | `8, 12, 20, 28` | `4, 12` | Flowing, animated feel |
| `crystal` | `0, 16, 0, 16` | `0, 12, 0, 12` | `0, 8, 0, 8` | `0, 20, 0, 20` | `0, 12` | Sharp geometric beauty |
| `softRounded` | `20` | `16` | `14` | `24` | `24` | Extra gentle, accessible |
| `oblique` | `16, 2, 16, 2` | `12, 2, 12, 2` | `10, 2, 10, 2` | `20, 2, 20, 2` | `14, 2` | Progressive, forward |
| `angular` | `2, 16, 2, 16` | `2, 12, 2, 12` | `2, 8, 2, 8` | `2, 20, 2, 20` | `2, 12` | Bold, dramatic |
| `hybrid` | `16, 0, 16, 0` | `12, 0, 12, 0` | `8, 0, 8, 0` | `20, 0, 20, 0` | `12, 0` | Custom combination |
| `responsive` | Varies by screen width | Varies | Varies | Varies | Varies | Adapts to device |

### 4.3 Corner Style Implementation

```dart
class CornerStyleResolver {
  static BorderRadius getCardRadius(CornerStyle style) {
    switch (style) {
      case CornerStyle.rounded:
        return BorderRadius.circular(12);
      case CornerStyle.sharp:
        return BorderRadius.zero;
      case CornerStyle.pill:
        return BorderRadius.circular(24);
      case CornerStyle.notched:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.zero,
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(12),
        );
      case CornerStyle.teardrop:
        return const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(4),
        );
      case CornerStyle.asymmetric:
        return const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(24),
        );
      case CornerStyle.cascading:
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(24),
        );
      case CornerStyle.crystal:
        return const BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.circular(16),
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(16),
        );
      case CornerStyle.softRounded:
        return BorderRadius.circular(20);
      case CornerStyle.oblique:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(2),
        );
      case CornerStyle.angular:
        return const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(16),
        );
      case CornerStyle.hybrid:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.zero,
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.zero,
        );
      case CornerStyle.beveled:
        return BorderRadius.circular(12); // Use BeveledRectangleBorder separately
      case CornerStyle.scooped:
        return BorderRadius.circular(16);
      case CornerStyle.responsive:
        return BorderRadius.circular(12); // Default, adjusted by screen size
    }
  }
  
  static BorderRadius getButtonRadius(CornerStyle style) {
    // Same pattern, smaller values
    final cardRadius = getCardRadius(style);
    // Scale down by ~0.67 for buttons
    return _scaleRadius(cardRadius, 0.67);
  }
  
  static BorderRadius getInputRadius(CornerStyle style) {
    return _scaleRadius(getCardRadius(style), 0.67);
  }
  
  static BorderRadius getDialogRadius(CornerStyle style) {
    return _scaleRadius(getCardRadius(style), 1.33);
  }
  
  static BorderRadius getChipRadius(CornerStyle style) {
    return _scaleRadius(getCardRadius(style), 1.67);
  }
  
  // For beveled style, use ShapeBorder instead of BorderRadius
  static ShapeBorder? getCardShape(CornerStyle style) {
    if (style == CornerStyle.beveled) {
      return const BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );
    }
    return null; // Use BorderRadius for all other styles
  }
}
```

---

## 5. Shadow Intelligence

Shadows in ICHITO are not just visual depth cues -- they adapt their color to the accent color, creating a cohesive glow effect.

### 5.1 Shadow Properties

| Property | Configurable | Default | Range |
|----------|-------------|---------|-------|
| `enableShadows` | Yes (toggle) | `true` | on/off |
| `shadowIntensity` | Yes (slider) | `0.15` | `0.0` to `0.5` |
| `shadowColor` | Auto (derived) | `accentColor.withOpacity(intensity)` | N/A |
| `shadowBlurRadius` | Fixed | `12.0` | N/A |
| `shadowOffset` | Fixed | `Offset(0, 4)` | N/A |

### 5.2 Shadow Variants by Theme Mode

```dart
BoxShadow? getCardShadow() {
  if (!enableShadows) return null;
  
  switch (themeMode) {
    case IchitoThemeMode.amoledDark:
      // Accent-colored glow on pure black
      return BoxShadow(
        color: accentColor.withOpacity(shadowIntensity * 0.8),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 1,
      );
    case IchitoThemeMode.dark:
      // Softer accent glow
      return BoxShadow(
        color: accentColor.withOpacity(shadowIntensity * 0.5),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      );
    case IchitoThemeMode.light:
      // Traditional grey shadow with slight accent tint
      return BoxShadow(
        color: Color.lerp(Colors.black, accentColor, 0.2)!.withOpacity(shadowIntensity),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      );
  }
}
```

### 5.3 Shadow Usage

| Component | Has Shadow | Notes |
|-----------|-----------|-------|
| Cards | Yes | Standard card shadow |
| FAB (Radial menu trigger) | Yes | Elevated shadow |
| Elevated buttons | Yes | Subtle shadow |
| App bar | Yes (on scroll) | Appears when content scrolls behind |
| Bottom sheet | Yes | Top edge shadow |
| Dialogs | Yes | All-around shadow |
| Dropdown menus | Yes | Subtle elevation |
| Search bar | Yes | When focused |
| Quick action tiles (home) | Yes | Standard card shadow |
| Stat cards (dashboard) | Yes | Standard card shadow |
| Input fields | No | Use border instead |
| Chips | No | Flat by design |
| List tiles | No | Flat, rely on dividers |

---

## 6. Font System

### 6.1 Available Font Families

```dart
enum FontFamily {
  roboto,           // Default -- clean, neutral, Google standard
  poppins,          // Geometric, modern, friendly
  montserrat,       // Elegant, sophisticated
  inter,            // Optimized for screens, excellent readability
  sfProDisplay,     // Apple-inspired, premium feel
  playfairDisplay,  // Serif, editorial, luxury
  openSans,         // Humanist, highly readable
  lato,             // Warm, stable, professional
  raleway,          // Thin, elegant, modern
  merriweather,     // Serif, pleasant reading
}
```

### 6.2 Typography Scale

All font sizes are relative to the user's base font size setting (default: 16.0). The scale uses a modular ratio of 1.25 (Major Third).

| Token | Scale Factor | Default Size | Usage |
|-------|-------------|--------------|-------|
| `displayLarge` | 2.441x | 39.06 | Not used in mobile (reserved) |
| `displayMedium` | 1.953x | 31.25 | Splash screen "ICHITO" text |
| `displaySmall` | 1.563x | 25.0 | Section headers on dashboard |
| `headlineLarge` | 1.25x | 20.0 | Screen titles, card titles |
| `headlineMedium` | 1.0x | 16.0 | Subtitles, list tile titles |
| `bodyLarge` | 1.0x | 16.0 | Primary body text |
| `bodyMedium` | 0.875x | 14.0 | Secondary body text, descriptions |
| `bodySmall` | 0.8x | 12.8 | Captions, timestamps |
| `labelLarge` | 0.875x | 14.0 | Button text |
| `labelMedium` | 0.8x | 12.8 | Chip text, badge text |
| `labelSmall` | 0.64x | 10.24 | Smallest labels, legal text |

### 6.3 Typography Implementation

```dart
TextTheme buildTextTheme() {
  final family = _getFontFamilyString();
  final base = fontSize; // User-configurable, default 16.0
  
  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: family,
      fontSize: base * 2.441,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontFamily: family,
      fontSize: base * 1.953,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: 4.0,  // Wide letter spacing for "ICHITO"
    ),
    headlineLarge: TextStyle(
      fontFamily: family,
      fontSize: base * 1.25,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: family,
      fontSize: base,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: family,
      fontSize: base,
      fontWeight: FontWeight.normal,
      color: textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: family,
      fontSize: base * 0.875,
      fontWeight: FontWeight.normal,
      color: textSecondary,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: family,
      fontSize: base * 0.8,
      fontWeight: FontWeight.normal,
      color: textSecondary,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontFamily: family,
      fontSize: base * 0.875,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontFamily: family,
      fontSize: base * 0.8,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: family,
      fontSize: base * 0.64,
      fontWeight: FontWeight.normal,
      color: textSecondary,
      letterSpacing: 0.5,
    ),
  );
}
```

### 6.4 Font Size Adjustment

Users can adjust the base font size:

| Setting | Min | Default | Max | Step |
|---------|-----|---------|-----|------|
| Base font size | 12.0 | 16.0 | 24.0 | 1.0 |

The slider in Settings shows a live preview of text at the selected size.

---

## 7. Spacing Scale

Consistent spacing using a 4px base unit:

| Token | Value | Usage |
|-------|-------|-------|
| `spacing_xs` | 4px | Tight gaps between inline elements |
| `spacing_sm` | 8px | Gap between related elements |
| `spacing_md` | 12px | Internal card padding |
| `spacing_lg` | 16px | Standard padding, gaps between cards |
| `spacing_xl` | 24px | Section gaps |
| `spacing_2xl` | 32px | Major section separators |
| `spacing_3xl` | 48px | Page-level vertical spacing |

### Spacing Application Rules

| Context | Spacing |
|---------|---------|
| Card internal padding | `16px` all sides |
| Card-to-card gap (in grid) | `12px` |
| Section title to content | `12px` |
| Section to section | `24px` |
| Screen edge padding | `16px` horizontal |
| List item vertical padding | `12px` top/bottom |
| Input field internal padding | `12px horizontal, 16px vertical` |
| Button internal padding | `12px horizontal, 16px vertical` |
| Dialog content padding | `24px` |
| App bar content padding | `16px horizontal` |
| Between form fields | `16px` |
| FAB from bottom edge | `16px` |

---

## 8. Icon Sizing Scale

| Context | Size | Usage |
|---------|------|-------|
| App bar action icons | 24px | Standard toolbar icons |
| Navigation menu icons | 28px | Radial menu items |
| Card inline icons | 20px | Icons within cards/list tiles |
| FAB icon | 28px | Floating action button |
| Large feature icons | 48px | Empty state illustrations |
| Extra large icons | 64px | Splash screen, lock screen |
| Status indicator dots | 8px diameter | Order/payment status |
| Badge icons | 16px | Inside badge chips |
| Input prefix icons | 20px | Before input fields |
| Bottom sheet action icons | 24px | Bottom sheet list tiles |

All icons use accent color for active/selected states and `textSecondary` for inactive states.

---

## 9. Adaptive Component Specifications

### 9.1 AdaptiveCard

The foundation component for all card-based UI elements.

```dart
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool elevated;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: elevated && theme.cardShadow != null
            ? [theme.cardShadow!]
            : null,
          border: elevated
            ? null
            : Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}
```

### 9.2 AdaptiveButton

```dart
class AdaptiveButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : theme.accentColor,
          foregroundColor: theme.onAccent,
          shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: theme.enableShadows ? 2 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive ? Colors.red : theme.accentColor,
        side: BorderSide(color: isDestructive ? Colors.red : theme.accentColor),
        shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
```

### 9.3 AdaptiveTextField

```dart
class AdaptiveTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: theme.fontFamily,
        fontSize: theme.fontSize,
        color: theme.textPrimary,
      ),
      cursorColor: theme.accentColor,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: theme.textSecondary),
        hintStyle: TextStyle(color: theme.textSecondary.withOpacity(0.5)),
        prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: theme.textSecondary, size: 20)
          : null,
        filled: true,
        fillColor: theme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: theme.inputRadius,
          borderSide: BorderSide(color: theme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: theme.inputRadius,
          borderSide: BorderSide(color: theme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: theme.inputRadius,
          borderSide: BorderSide(color: theme.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: theme.inputRadius,
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
```

### 9.4 AdaptiveDialog

```dart
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: theme.dialogRadius),
      elevation: theme.enableShadows ? 8 : 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineLarge),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 10. Status Colors (Independent of Accent)

These colors remain constant regardless of accent color selection. They communicate semantic meaning.

| Status | Color | Hex | Icon |
|--------|-------|-----|------|
| Completed / Paid / Success | Green | `#4CAF50` | `Icons.check_circle_outlined` |
| In Progress / Partial | Amber | `#FFC107` | `Icons.sync_outlined` |
| Overdue / Error / Unpaid | Red | `#F44336` | `Icons.error_outlined` |
| Pending / Informational | Blue | `#2196F3` | `Icons.hourglass_empty_outlined` |
| Cancelled / Disabled | Grey | `#9E9E9E` | `Icons.cancel_outlined` |
| Warning | Orange | `#FF9800` | `Icons.warning_outlined` |

### Status Indicator Widget

```dart
class StatusDot extends StatelessWidget {
  final String status;
  final double size;
  
  const StatusDot({required this.status, this.size = 8});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (status) {
      case 'completed': return const Color(0xFF4CAF50);
      case 'in_progress': return const Color(0xFFFFC107);
      case 'pending': return const Color(0xFF2196F3);
      case 'trial': return const Color(0xFF2196F3);
      case 'cancelled': return const Color(0xFF9E9E9E);
      case 'overdue': return const Color(0xFFF44336);
      case 'paid': return const Color(0xFF4CAF50);
      case 'partial': return const Color(0xFFFFC107);
      case 'unpaid': return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }
}
```

---

## 11. Animation Tokens

| Animation | Duration | Curve | Usage |
|-----------|----------|-------|-------|
| Card press feedback | 100ms | easeIn | Scale to 0.98 on press |
| Card release feedback | 150ms | easeOut | Scale back to 1.0 |
| Theme color transition | 300ms | easeInOut | When accent color changes |
| List item appearance | 200ms | easeOutCubic | Staggered list animation |
| FAB expand (radial menu) | 350ms | easeOutBack | Menu opening |
| FAB collapse | 250ms | easeIn | Menu closing |
| Page transition | 300ms | easeOutCubic | Route transitions |
| Modal slide up | 350ms | easeOutCubic | Bottom sheet/wizard |
| Progress bar fill | 300ms | easeInOut | Wizard progress |
| Skeleton shimmer | 1500ms | linear (repeat) | Loading placeholders |
| Snackbar appear | 250ms | easeOutCubic | Slide up from bottom |
| Snackbar dismiss | 200ms | easeIn | Slide down |
| Splash logo scale | 800ms | elasticOut | Logo entrance on splash |
| Splash fade | 500ms | easeIn | Text fade in on splash |

---

## 12. Responsive Breakpoints

| Breakpoint | Width | Layout Adjustments |
|-----------|-------|-------------------|
| Compact | < 360px | Single column, smaller cards, reduced padding (12px) |
| Standard | 360-410px | Default layout, standard padding (16px) |
| Large | 410-600px | Slightly wider cards, more breathing room |
| Tablet (future) | > 600px | Two-column layouts, side navigation |

### Grid Column Rules

| Screen | Compact | Standard | Large |
|--------|---------|----------|-------|
| Home quick actions | 2 columns | 4 columns | 4 columns |
| Customer grid | 2 columns | 3 columns | 3 columns |
| Garment grid | 2 columns | 3 columns | 4 columns |
| Fabric grid | 2 columns | 3 columns | 4 columns |
| Design grid | 2 columns | 3 columns | 4 columns |

---

## 13. ThemeProvider Complete Implementation

```dart
class ThemeProvider extends ChangeNotifier {
  // === STORED STATE ===
  Color _accentColor = const Color(0xFFFFD700);
  IchitoThemeMode _themeMode = IchitoThemeMode.amoledDark;
  CornerStyle _cornerStyle = CornerStyle.rounded;
  FontFamily _fontFamily = FontFamily.roboto;
  double _fontSize = 16.0;
  bool _enableShadows = true;
  double _shadowIntensity = 0.15;
  
  // === GETTERS ===
  Color get accentColor => _accentColor;
  IchitoThemeMode get themeMode => _themeMode;
  CornerStyle get cornerStyle => _cornerStyle;
  FontFamily get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get enableShadows => _enableShadows;
  double get shadowIntensity => _shadowIntensity;
  
  // === DERIVED COLORS ===
  Color get backgroundColor => _resolveBackground();
  Color get surfaceColor => _resolveSurface();
  Color get cardColor => _resolveCard();
  Color get textPrimary => _resolveTextPrimary();
  Color get textSecondary => _resolveTextSecondary();
  Color get borderColor => _resolveBorder();
  Color get accentLight => _accentColor.withOpacity(0.15);
  Color get onAccent => _accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  
  // === DERIVED SHAPES ===
  BorderRadius get cornerRadius => CornerStyleResolver.getCardRadius(_cornerStyle);
  BorderRadius get buttonRadius => CornerStyleResolver.getButtonRadius(_cornerStyle);
  BorderRadius get inputRadius => CornerStyleResolver.getInputRadius(_cornerStyle);
  BorderRadius get dialogRadius => CornerStyleResolver.getDialogRadius(_cornerStyle);
  BorderRadius get chipRadius => CornerStyleResolver.getChipRadius(_cornerStyle);
  
  // === SHADOW ===
  BoxShadow? get cardShadow => _resolveShadow();
  
  // === FONT ===
  String get fontFamilyString => _resolveFontFamily();
  
  // === THEME DATA ===
  ThemeData get themeData => _buildThemeData();
  
  // === SETTERS ===
  void setAccentColor(Color color) {
    _accentColor = color;
    _persist('accent_color', color.value);
    notifyListeners();
  }
  
  void setThemeMode(IchitoThemeMode mode) {
    _themeMode = mode;
    _persist('theme_mode', mode.index);
    notifyListeners();
  }
  
  void setCornerStyle(CornerStyle style) {
    _cornerStyle = style;
    _persist('corner_style', style.index);
    notifyListeners();
  }
  
  void setFontFamily(FontFamily family) {
    _fontFamily = family;
    _persist('font_family', family.index);
    notifyListeners();
  }
  
  void setFontSize(double size) {
    _fontSize = size.clamp(12.0, 24.0);
    _persist('font_size', _fontSize);
    notifyListeners();
  }
  
  void toggleShadows() {
    _enableShadows = !_enableShadows;
    _persist('enable_shadows', _enableShadows);
    notifyListeners();
  }
  
  void setShadowIntensity(double intensity) {
    _shadowIntensity = intensity.clamp(0.0, 0.5);
    _persist('shadow_intensity', _shadowIntensity);
    notifyListeners();
  }
  
  // === PERSISTENCE ===
  Future<void> loadSavedSettings() async {
    final box = await Hive.openBox('theme_settings');
    _accentColor = Color(box.get('accent_color', defaultValue: 0xFFFFD700));
    _themeMode = IchitoThemeMode.values[box.get('theme_mode', defaultValue: 0)];
    _cornerStyle = CornerStyle.values[box.get('corner_style', defaultValue: 0)];
    _fontFamily = FontFamily.values[box.get('font_family', defaultValue: 0)];
    _fontSize = box.get('font_size', defaultValue: 16.0);
    _enableShadows = box.get('enable_shadows', defaultValue: true);
    _shadowIntensity = box.get('shadow_intensity', defaultValue: 0.15);
    notifyListeners();
  }
  
  Future<void> _persist(String key, dynamic value) async {
    final box = await Hive.openBox('theme_settings');
    await box.put(key, value);
  }
}
```

---

## 14. Theme Preview

Settings includes a live "Preview Theme" feature that shows a mini preview card demonstrating the current theme configuration:

```
┌─────────────────────────────────────┐
│  Theme Preview                      │
│  ┌─────────────────────────────────┐│
│  │  [Accent-colored header bar]   ││
│  │  ┌───────┐  ┌───────┐         ││
│  │  │ Card  │  │ Card  │         ││
│  │  │ with  │  │ with  │         ││
│  │  │shadow │  │shadow │         ││
│  │  └───────┘  └───────┘         ││
│  │  [Button]  [Outlined Button]   ││
│  │  [Input field.............]    ││
│  │  Sample text in chosen font    ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

This preview updates in real-time as the user adjusts theme settings.

---

*This is Document 04 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
