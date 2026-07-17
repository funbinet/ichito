# ICHITO -- Settings & Preferences

**Document**: 10 of 14
**Covers**: Complete settings screen with all 9 sections, profile management, theme configuration, language and localization, security settings, user preferences, business configuration, storage management, advanced options, help and about

---

## 1. Settings Screen Structure

The settings screen is a single scrollable page organized into expandable sections. Each section header shows the section name and an expand/collapse chevron.

### 1.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Settings                                    │
├─────────────────────────────────────────────────────┤
│  SCROLLABLE CONTENT                                  │
│                                                      │
│  ┌── Profile ──────────────────────────────── [>] ──┐│
│  │  [Avatar] Duncan                                ││
│  │           duncan@email.com                      ││
│  │           Ichito Studios                        ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Appearance ────────────────────────────── [v] ──┐│
│  │  Theme Mode: [AMOLED Dark v]                    ││
│  │  Accent Color: [Gold swatch] [Change]           ││
│  │  Corner Style: [Rounded v]                      ││
│  │  Font: [Roboto v]                               ││
│  │  Font Size: [──●────] 16                        ││
│  │  Shadows: [Toggle ON]                           ││
│  │  Shadow Intensity: [──●────] 0.15               ││
│  │  [Live Preview Card]                            ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Language & Format ─────────────────────── [>] ──┐│
│  │  Language: English                              ││
│  │  Measurement Unit: cm                           ││
│  │  Currency: KES                                  ││
│  │  Date Format: DD/MM/YYYY                        ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Security ──────────────────────────────── [>] ──┐│
│  │  App Lock: [Toggle OFF]                         ││
│  │  Biometric: [Toggle OFF]                        ││
│  │  Change PIN                                     ││
│  │  Security Code                                  ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Preferences ───────────────────────────── [>] ──┐│
│  │  Default View: Grid                             ││
│  │  Auto-save Notes: [Toggle ON]                   ││
│  │  Haptic Feedback: [Toggle ON]                   ││
│  │  Confirm Deletions: [Toggle ON]                 ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Business ──────────────────────────────── [>] ──┐│
│  │  Business Name: Ichito Studios                  ││
│  │  Location: Nairobi, Kenya                       ││
│  │  Default Labor Cost: KES 1,500                  ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Storage ───────────────────────────────── [>] ──┐│
│  │  Database: 2.4 MB                               ││
│  │  Images: 45.2 MB                                ││
│  │  Cache: 8.1 MB                                  ││
│  │  [Backup] [Restore] [Clear Cache]               ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Advanced ──────────────────────────────── [>] ──┐│
│  │  Performance Mode: [Toggle OFF]                 ││
│  │  Debug Logging: [Toggle OFF]                    ││
│  │  Export Data                                    ││
│  │  Factory Reset                                  ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Help & About ─────────────────────────── [>] ──┐│
│  │  User Guide                                     ││
│  │  Contact Support                                ││
│  │  Privacy Policy                                 ││
│  │  About ICHITO  (v1.0.0)                         ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

---

## 2. Profile Section

### 2.1 Display

Shows the user's profile information with an edit capability:

```
[Avatar 48dp]  Duncan
               duncan@email.com
               Ichito Studios
                              [Edit Profile ->]
```

### 2.2 Edit Profile Dialog

```
┌─────────────────────────────────────────────────────┐
│  Edit Profile                                        │
├─────────────────────────────────────────────────────┤
│  [Avatar - tap to change]                           │
│                                                      │
│  Name                                                │
│  ┌──────────────────────────────────────────────────┐│
│  │  Duncan                                         ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Email                                               │
│  ┌──────────────────────────────────────────────────┐│
│  │  duncan@email.com                               ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Phone                                               │
│  ┌──────────────────────────────────────────────────┐│
│  │  0712 345 678                                   ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [Cancel]                       [Save]               │
└─────────────────────────────────────────────────────┘
```

Profile data stored in `AppStateProvider` and persisted to Hive.

---

## 3. Appearance Section (Theme)

### 3.1 Theme Mode Selector

A segmented control or dropdown with three options:

| Mode | Description |
|------|-------------|
| AMOLED Dark (default) | Pure black backgrounds |
| Dark | Softer dark with blue-grey undertones |
| Light | Bright mode for outdoor use |

### 3.2 Accent Color Selector

Shows the current accent color as a circular swatch with its name. Tapping opens a full-screen color picker:

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Choose Accent Color                         │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Warm Tones                                          │
│  [Gold●] [Amber●] [Tangerine●] [Coral●] [Sunset●]  │
│  [Rose●]                                            │
│                                                      │
│  Cool Tones                                          │
│  [Sapphire●] [Ocean●] [Teal●] [Sky●] [Indigo●]    │
│  [Lavender●]                                        │
│                                                      │
│  Nature Tones                                        │
│  [Emerald●] [Forest●] [Lime●] [Mint●] [Sage●]     │
│  [Olive●]                                           │
│                                                      │
│  Neutral Tones                                       │
│  [Silver●] [Steel●] [Graphite●] [Slate●] [Pearl●]  │
│  [Platinum●]                                        │
│                                                      │
│  Bold Tones                                          │
│  [Ruby●] [Magenta●] [Purple●] [ElectricBlue●]      │
│  [Crimson●] [Violet●]                              │
│                                                      │
│  ── Custom Color ─────────────────────────────────── │
│  [Color Wheel]  or  [HEX Input: #_____]             │
│                                                      │
│  Recent: [●] [●] [●] [●] [●]                       │
│                                                      │
│  [Cancel]                       [Apply]              │
└─────────────────────────────────────────────────────┘
```

Each preset swatch is a 40dp circle filled with the color, with the active color having a white checkmark overlay.

**See**: [Theming & Design System](04_theming_and_design_system.md) -- Section 3 for complete accent color specs.

### 3.3 Corner Style Selector

A scrollable grid of visual previews:

```
[Rounded]    [Sharp]      [Pill]       [Notched]
  ╭──╮         ┌──┐        ╭──╮         ╭──┐
  │  │         │  │        │  │         │  │
  ╰──╯         └──┘        ╰──╯         └──╯

[Teardrop]   [Beveled]   [Asymmetric] [Cascading]
  ╭──╮         ╱──╲        ╭──╮         ╭──╮
  │  │        │    │       │  │         │  │
  ╰──╯         ╲──╱        ╰──╯         ╰──╯
```

Each preview is a mini card (48x48dp) with the corner style applied and the style name below. Selected style has accent border.

**See**: [Theming & Design System](04_theming_and_design_system.md) -- Section 4 for all 15 corner styles.

### 3.4 Font Selector

A dropdown or scrollable list where each option is rendered in its own font:

```
Roboto        (rendered in Roboto)
Poppins       (rendered in Poppins)
Montserrat    (rendered in Montserrat)
Inter         (rendered in Inter)
Playfair Display (rendered in Playfair Display)
...
```

### 3.5 Font Size Slider

```dart
Row(
  children: [
    Text('Font Size:', style: TextStyle(fontSize: 14)),
    Expanded(
      child: Slider(
        value: theme.fontSize,
        min: 12.0,
        max: 24.0,
        divisions: 12,
        activeColor: theme.accentColor,
        onChanged: (value) => theme.setFontSize(value),
      ),
    ),
    Text('${theme.fontSize.toInt()}', 
      style: TextStyle(fontSize: theme.fontSize, fontWeight: FontWeight.bold)),
  ],
)
```

### 3.6 Live Preview Card

A small preview card that updates in real-time as theme settings change:

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: theme.cardColor,
    borderRadius: theme.cornerRadius,
    boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
    border: Border.all(color: theme.borderColor, width: 0.5),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Preview', style: TextStyle(
        fontFamily: theme.fontFamilyString,
        fontSize: theme.fontSize * 1.25,
        fontWeight: FontWeight.bold,
        color: theme.textPrimary,
      )),
      const SizedBox(height: 8),
      Text('This is how your cards will look.', style: TextStyle(
        fontFamily: theme.fontFamilyString,
        fontSize: theme.fontSize * 0.875,
        color: theme.textSecondary,
      )),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
        ),
        child: Text('Button Preview'),
      ),
    ],
  ),
)
```

---

## 4. Language & Format Section

### 4.1 Language

| Setting | Options | Default |
|---------|---------|---------|
| Language | English, Sheng | English |

Changing language reloads all UI strings from the active translation file.

### 4.2 Measurement Unit

| Setting | Options | Default |
|---------|---------|---------|
| Unit | cm, inches | cm |

Affects: measurement display in customer profiles, order details, and measurement input hints.

### 4.3 Currency

| Setting | Options | Default |
|---------|---------|---------|
| Currency | KES, USD, EUR, GBP, TZS, UGX | KES |

Affects: all monetary displays throughout the app.

### 4.4 Date Format

| Setting | Options | Default |
|---------|---------|---------|
| Date Format | DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD | DD/MM/YYYY |

Affects: all date displays throughout the app.

---

## 5. Security Section

### 5.1 Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| App Lock | Toggle | OFF | Enable PIN lock on app launch |
| Biometric | Toggle | OFF | Allow fingerprint/face unlock (requires App Lock ON) |
| Auto-Lock Timer | Dropdown | 5 min | Time before auto-lock after backgrounding |
| Change PIN | Button | N/A | Opens PIN setup flow |
| Set Security Code | Button | N/A | Set/change the security recovery code |
| Encryption | Toggle | OFF | Encrypt database file (advanced) |

### 5.2 Auto-Lock Timer Options

| Option | Value |
|--------|-------|
| Immediately | 0 min |
| 1 minute | 1 min |
| 5 minutes (default) | 5 min |
| 15 minutes | 15 min |
| 30 minutes | 30 min |
| Never | -1 (disabled) |

**See**: [Security & App Lock](11_security_and_app_lock.md) -- for complete security specification.

---

## 6. Preferences Section

### 6.1 Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Default View | Dropdown | Grid | Grid or List for entity lists |
| Default Grid Density | Dropdown | 8 | 4, 8, 16, or 32 items for fabric/design grids |
| Auto-Save Notes | Toggle | ON | Auto-save notes after 3 seconds of inactivity |
| Auto-Save Interval | Dropdown | 3 sec | 1, 3, 5, or 10 seconds |
| Haptic Feedback | Toggle | ON | Vibration on button taps and interactions |
| Confirm Deletions | Toggle | ON | Show confirmation dialog before deleting |
| Show Order Number on Cards | Toggle | ON | Display full order number or short version |
| Default Sort (Customers) | Dropdown | Name | Name, Orders, Spent, Recent |
| Default Sort (Orders) | Dropdown | Date | Date, Due, Amount, Status |
| Default Sort (Notes) | Dropdown | Newest | Newest, Oldest, Title |

---

## 7. Business Section

### 7.1 Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Business Name | Text | "" | Displayed in profile and about section |
| Business Location | Text | "" | For reference |
| Business Phone | Text | "" | Contact phone |
| Business Email | Text | "" | Contact email |
| Default Labor Cost | Number | 1500 | Pre-filled in order wizard pricing step |
| Tax Rate | Number | 0% | Applied to order totals (0 = disabled) |
| Order Prefix | Text | "ICHITO" | Prefix for order numbers |

### 7.2 Order Prefix

Users can customize the order number prefix:

| Prefix | Example Order Number |
|--------|---------------------|
| ICHITO (default) | ICHITO-2026-07-042 |
| Custom (e.g., "TLR") | TLR-2026-07-042 |

---

## 8. Storage Section

### 8.1 Storage Usage Display

```
Database Size:    2.4 MB    [████████░░] 24%
Images:          45.2 MB    [████████████████░] 85%
Cache:            8.1 MB    [██████░░░░] 15%
Total:           55.7 MB
```

### 8.2 Actions

| Action | Description | Confirmation |
|--------|-------------|-------------|
| **Backup** | Export database + images to `.ichito_backup` file | Shows backup summary before export |
| **Restore** | Import from `.ichito_backup` file | Warning: "This will replace all current data" |
| **Clear Image Cache** | Delete all thumbnail cache files | Simple confirmation |
| **Clean Orphaned Images** | Delete unreferenced images | Shows count of orphaned files before deletion |
| **Export to CSV** | Export customers, orders to CSV files | Shows export options |

### 8.3 Backup Flow

```
User taps "Backup"
    │
    ▼
Show backup summary dialog:
  - Database size
  - Number of customers, orders, notes
  - Image count and size
  - Total backup size estimate
    │
    ▼ (User confirms)
    │
Close database connection
    │
    ▼
Copy ichito.db to temp directory
Copy images/ directory to temp directory
Generate manifest.json
    │
    ▼
Compress into ichito_backup_{date}.zip
    │
    ▼
Open share sheet / file picker for save location
    │
    ▼
Reopen database connection
    │
    ▼
Show success snackbar
```

### 8.4 Restore Flow

```
User taps "Restore"
    │
    ▼
Show warning dialog:
  "Restoring from backup will REPLACE all current data.
   This action cannot be undone."
  [Cancel] [Continue]
    │
    ▼ (User confirms)
    │
Open file picker (filter: .ichito_backup)
    │
    ▼
Validate backup file:
  - Check manifest.json exists
  - Check database version compatibility
  - Show backup details (date, record counts)
    │
    ▼ (User confirms details)
    │
Close database connection
    │
    ▼
Delete current ichito.db and images/
    │
    ▼
Extract backup database and images
    │
    ▼
Reopen database connection
    │
    ▼
Reload all providers (theme, language, app state)
    │
    ▼
Show success dialog + navigate to Home
```

---

## 9. Advanced Section

### 9.1 Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Performance Mode | Toggle | OFF | Reduces animations for older devices |
| Debug Logging | Toggle | OFF | Enable detailed debug logs |
| View Debug Logs | Button | N/A | Opens log file viewer |
| Export Data (JSON) | Button | N/A | Export all data as JSON files |
| Export Data (CSV) | Button | N/A | Export key tables as CSV |
| Factory Reset | Button | N/A | Delete ALL data and reset to defaults |

### 9.2 Performance Mode

When enabled:
- All transition animations reduced to 0ms
- Card press feedback disabled
- Skeleton loading replaced with simple spinner
- Shadow rendering disabled
- Image thumbnails used exclusively (never full-size in lists)
- Reduced blur effects

### 9.3 Debug Log Viewer

Opens a read-only text view of the most recent log file with search capability.

### 9.4 Factory Reset

Triple confirmation:
1. "This will delete ALL data including customers, orders, notes, and images. This CANNOT be undone."
2. "Type 'RESET' to confirm"
3. "Last chance. All data will be permanently deleted."

After reset:
- Delete database
- Delete all images
- Clear all Hive boxes
- Clear shared preferences
- Navigate to splash screen (fresh start)

---

## 10. Help & About Section

### 10.1 User Guide

Opens an in-app guide with sections:
1. Getting Started
2. Managing Customers
3. Creating Orders
4. Using the Order Wizard
5. Managing Garments, Fabrics & Designs
6. Taking Notes
7. Understanding Statistics
8. Customizing Your Theme
9. Security & App Lock
10. Backup & Restore

Each section is a collapsible accordion with text and inline illustrations (using Material icons for visual aid).

### 10.2 Contact Support

Shows:
- Email: support@ichito.app
- Opens email client with pre-filled subject "ICHITO Support - v1.0.0"

### 10.3 About ICHITO

```
┌─────────────────────────────────────────────────────┐
│                                                      │
│  [Logo - 80dp, accent circle]                       │
│                                                      │
│  ICHITO                                              │
│  Version 1.0.0 (Build 1)                            │
│                                                      │
│  "Work. Create. Thrive."                             │
│                                                      │
│  The complete tailor management system.              │
│  Built with care for tailors everywhere.             │
│                                                      │
│  "Ichito" means "to work" or "work/job"              │
│  in Sheng (Kenyan slang).                            │
│                                                      │
│  Powered by Flutter                                  │
│                                                      │
│  [Licenses]  [Privacy Policy]                        │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 11. Settings Persistence

All settings are persisted using Hive boxes:

| Box Name | Data |
|----------|------|
| `theme_settings` | accent_color, theme_mode, corner_style, font_family, font_size, enable_shadows, shadow_intensity |
| `language_settings` | language, measurement_unit, currency, date_format |
| `security_settings` | app_lock_enabled, biometric_enabled, auto_lock_minutes |
| `preference_settings` | default_view, grid_density, auto_save, haptic, confirm_deletions, sort defaults |
| `business_settings` | business_name, location, phone, email, labor_cost, tax_rate, order_prefix |
| `profile_settings` | user_name, user_email, user_phone, profile_photo_path |
| `app_state` | is_first_launch, last_active_time |

Each setting change:
1. Updates the in-memory provider value
2. Writes to the Hive box
3. Calls `notifyListeners()` on the provider
4. All dependent widgets rebuild automatically

---

*This is Document 10 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
