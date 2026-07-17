# ICHITO -- Master Blueprint Index

**Version**: 1.0.0
**Last Updated**: 2026-07-18
**Status**: Definitive Engineering Reference
**Contact**: funbinet@gmail.com

---

## 1. What Is This Document Set

This collection of 14 blueprint documents is the single source of truth for the ICHITO tailor management system. Every screen, every data field, every interaction, every animation, every icon, every color token, every database query, and every business rule is specified here. A developer picking up any one of these documents should be able to implement that component fully, correctly, and consistently with the rest of the system -- without guessing.

**ICHITO** (pronounced *ee-CHEE-toh*) is an offline-first, Flutter/Dart mobile application for managing tailoring businesses. The name comes from Kenyan Sheng meaning "to work" or "get to work."

**Tagline**: *"Work. Create. Thrive."*

---

## 2. Document Map

| # | Document | File | Scope |
|---|----------|------|-------|
| 00 | **Master Index** (this file) | `00_ichito_master_index.md` | Conventions, glossary, icon policy, cross-references |
| 01 | **Architecture & Project Structure** | `01_architecture_and_project_structure.md` | Tech stack, project layout, dependency graph, mixin system, provider architecture, service layer, build configuration, folder conventions |
| 02 | **Data Models & Database** | `02_data_models_and_database.md` | All entity models with complete field specs, SQLite schema DDL, relationships, foreign keys, indexes, migrations, seed data, CRUD operations, data integrity constraints |
| 03 | **Navigation & Routing** | `03_navigation_and_routing.md` | Navigation paradigm, named routes, transition animations, deep linking, back-stack management, gesture navigation, route guards |
| 04 | **Theming & Design System** | `04_theming_and_design_system.md` | Accent system, 15+ corner styles, shadow intelligence, font system, color palettes, dark/light/AMOLED modes, design tokens, spacing scale, component styling rules, adaptive UI |
| 05 | **Screens: Home & Dashboard** | `05_screens_home_and_dashboard.md` | Splash screen, home dashboard, statistics carousel, quick action grid, activity feed, notification indicators, welcome header |
| 06 | **Customer Management** | `06_customer_management.md` | Customer list (grid/list views), customer detail, add/edit customer, search/filter/sort, loyalty tiers, analytics per customer, measurement templates, photo handling |
| 07 | **Order Management & Wizard** | `07_order_management_and_wizard.md` | Complete 6-step order creation wizard, order list, order detail, status lifecycle state machine, payment tracking, payment history, order editing, cancellation, validation rules |
| 08 | **Garments, Fabrics & Designs** | `08_garments_fabrics_and_designs.md` | Garment library, fabric catalog, design gallery, add/edit dialogs, image handling pipeline, categorization, measurement field templates, grid density options |
| 09 | **Notes System** | `09_notes_system.md` | Normal notes with auto-title, church notes with speaker/verse tagging, chama notes with contribution tracking, note editors, search, filtering |
| 10 | **Settings & Preferences** | `10_settings_and_preferences.md` | Profile settings, theme & appearance config, language & region, security & privacy toggles, preferences, business settings, storage management, advanced features, help & support |
| 11 | **Security & App Lock** | `11_security_and_app_lock.md` | PIN creation/verification, biometric authentication, security codes, auto-lock timer, data encryption, forgot PIN flow, brute-force protection, session management |
| 12 | **Localization & Accessibility** | `12_localization_and_accessibility.md` | English/Sheng dual-language system, all translation keys, cultural adaptation, intl package integration, accessibility standards, responsive typography, screen reader support |
| 13 | **Analytics & Reporting** | `13_analytics_and_reporting.md` | Statistics dashboard, revenue overview, key metrics cards, monthly trend charts, top performers, popular garments, date filtering, export/print functionality |

---

## 3. Absolute Rules

These rules apply across the entire ICHITO system without exception.

### 3.1 NO EMOJIS -- OUTLINE ICONS ONLY

> **CRITICAL**: The ICHITO application must NEVER use emojis as icons. Every icon in every screen, button, menu, card, dialog, and indicator MUST be a Material Design outline icon (`Icons.*_outlined` in Flutter). This is non-negotiable.

**Why**: Emojis render differently across devices and OS versions, breaking visual consistency. Outline icons from Material Design are vector-based, scale perfectly, adapt to the accent color system, and maintain a professional, premium look.

**Enforcement**:
- Every icon reference in the blueprints uses the format: `Icons.icon_name_outlined`
- The only exception is the ICHITO sewing machine logo, which is a custom asset (not an emoji, not a Material icon)
- Status indicators use colored dots (`Container` with `BoxDecoration` circles), not emoji dots

### 3.2 Icon Reference Table

This is the definitive mapping of all icons used in ICHITO. Every blueprint document references this table.

| Context | Icon | Flutter Reference | Notes |
|---------|------|-------------------|-------|
| **Navigation & Global** | | | |
| Home | House | `Icons.home_outlined` | Dashboard tab |
| Customers | People | `Icons.people_outlined` | Customer list |
| Orders | Shopping bag | `Icons.shopping_bag_outlined` | Order list |
| Garments | Checkroom | `Icons.checkroom_outlined` | Garment library |
| Fabrics | Texture | `Icons.texture_outlined` | Fabric catalog |
| Designs | Palette | `Icons.palette_outlined` | Design gallery |
| Notes | Note | `Icons.note_outlined` | Notes hub |
| Settings | Settings gear | `Icons.settings_outlined` | Settings screen |
| Statistics | Bar chart | `Icons.bar_chart_outlined` | Analytics |
| Profile | Person | `Icons.person_outlined` | User profile |
| Notifications | Bell | `Icons.notifications_outlined` | Alert bell |
| **Actions** | | | |
| Add / Create new | Add | `Icons.add` | FAB and add buttons |
| Edit | Edit | `Icons.edit_outlined` | Edit actions |
| Delete | Delete | `Icons.delete_outlined` | Delete actions |
| Save | Save | `Icons.save_outlined` | Save actions |
| Cancel | Close | `Icons.close` | Cancel/dismiss |
| Search | Search | `Icons.search` | Search bars |
| Filter | Filter list | `Icons.filter_list_outlined` | Filter menus |
| Sort | Sort | `Icons.sort_outlined` | Sort controls |
| Share / Export | Share | `Icons.share_outlined` | Export/share |
| Camera | Camera | `Icons.camera_alt_outlined` | Photo capture |
| Gallery | Photo library | `Icons.photo_library_outlined` | Photo gallery pick |
| Crop | Crop | `Icons.crop_outlined` | Image cropping |
| Back | Arrow back | `Icons.arrow_back` | Navigation back |
| Forward / Next | Arrow forward | `Icons.arrow_forward` | Next step |
| **Order & Status** | | | |
| New order | Add shopping cart | `Icons.add_shopping_cart_outlined` | Create order |
| Order complete | Check circle | `Icons.check_circle_outlined` | Completed status |
| Order in progress | Sync | `Icons.sync_outlined` | In progress status |
| Order pending | Hourglass | `Icons.hourglass_empty_outlined` | Pending status |
| Order cancelled | Cancel | `Icons.cancel_outlined` | Cancelled status |
| Order trial | Event | `Icons.event_outlined` | Trial/fitting date |
| Due date | Calendar today | `Icons.calendar_today_outlined` | Due dates |
| **Financial** | | | |
| Money / Payment | Payments | `Icons.payments_outlined` | Payment actions |
| Cash | Money | `Icons.money_outlined` | Cash payment |
| M-Pesa | Phone Android | `Icons.phone_android_outlined` | Mobile payment |
| Bank | Account balance | `Icons.account_balance_outlined` | Bank payment |
| Total / Revenue | Account balance wallet | `Icons.account_balance_wallet_outlined` | Totals |
| Deposit | Savings | `Icons.savings_outlined` | Deposit amounts |
| **Measurements** | | | |
| Ruler / Measure | Straighten | `Icons.straighten_outlined` | Measurements |
| Unit toggle | Swap horiz | `Icons.swap_horiz_outlined` | Unit switching |
| **Customer** | | | |
| Male | Male | `Icons.male_outlined` | Gender male |
| Female | Female | `Icons.female_outlined` | Gender female |
| Phone | Phone | `Icons.phone_outlined` | Phone number |
| Email | Email | `Icons.email_outlined` | Email address |
| Location | Location on | `Icons.location_on_outlined` | Address/location |
| Star / Loyalty | Star | `Icons.star_outlined` | Loyalty indicator |
| VIP | Workspace premium | `Icons.workspace_premium_outlined` | VIP status |
| **Notes** | | | |
| Normal note | Note | `Icons.note_outlined` | Regular notes |
| Church note | Church | `Icons.church_outlined` | Church notes |
| Chama note | Groups | `Icons.groups_outlined` | Group/chama notes |
| Bible verse | Menu book | `Icons.menu_book_outlined` | Bible references |
| Speaker | Record voice over | `Icons.record_voice_over_outlined` | Speaker name |
| **Settings** | | | |
| Theme | Color lens | `Icons.color_lens_outlined` | Theme settings |
| Language | Language | `Icons.language_outlined` | Language toggle |
| Lock | Lock | `Icons.lock_outlined` | Security/lock |
| Unlock | Lock open | `Icons.lock_open_outlined` | Unlocked state |
| Fingerprint | Fingerprint | `Icons.fingerprint` | Biometrics |
| PIN | Pin | `Icons.pin_outlined` | PIN entry |
| Font | Text fields | `Icons.text_fields_outlined` | Font settings |
| Backup | Backup | `Icons.backup_outlined` | Data backup |
| Restore | Restore | `Icons.restore_outlined` | Data restore |
| Storage | Storage | `Icons.storage_outlined` | Storage info |
| Info | Info | `Icons.info_outlined` | About/info |
| Help | Help | `Icons.help_outlined` | Help & support |
| Feedback | Feedback | `Icons.feedback_outlined` | Rate/feedback |
| Business | Business | `Icons.business_outlined` | Business settings |
| **Charts & Analytics** | | | |
| Trend up | Trending up | `Icons.trending_up_outlined` | Positive trend |
| Trend down | Trending down | `Icons.trending_down_outlined` | Negative trend |
| Pie chart | Pie chart | `Icons.pie_chart_outlined` | Pie charts |
| Timeline | Timeline | `Icons.timeline_outlined` | Trend lines |
| Leaderboard | Leaderboard | `Icons.leaderboard_outlined` | Rankings |
| Print | Print | `Icons.print_outlined` | Print report |
| Download | Download | `Icons.download_outlined` | Download/export |
| **Misc** | | | |
| Visibility | Visibility | `Icons.visibility_outlined` | Show/view |
| Visibility off | Visibility off | `Icons.visibility_off_outlined` | Hide |
| Expand more | Expand more | `Icons.expand_more` | Dropdown |
| Check | Check | `Icons.check` | Selection check |
| Warning | Warning | `Icons.warning_outlined` | Warning states |
| Error | Error | `Icons.error_outlined` | Error states |
| Success | Check circle | `Icons.check_circle_outlined` | Success states |
| Refresh | Refresh | `Icons.refresh` | Refresh/reload |
| More options | More vert | `Icons.more_vert` | Overflow menu |
| Grid view | Grid view | `Icons.grid_view_outlined` | Grid layout |
| List view | View list | `Icons.view_list_outlined` | List layout |
| Copy | Content copy | `Icons.content_copy_outlined` | Copy action |
| Backspace | Backspace | `Icons.backspace_outlined` | PIN keypad delete |

### 3.3 The ICHITO Logo

The ICHITO logo is a **sewing machine silhouette**. It exists as two asset files:

- `assets/images/logo_black.png` -- Black sewing machine on transparent background (for light surfaces)
- `assets/images/logo_white.png` -- White sewing machine on transparent background (for dark surfaces)

The logo is used in:
- Splash screen (centered, with scale animation)
- App bar (small, left-aligned on home screen)
- About screen
- Settings profile section

The logo must NEVER be replaced with an emoji or a Material icon. It is a custom brand asset.

### 3.4 App Name Convention

The application name is always written as **ICHITO** in all-caps in the UI. In code, filenames, and package names, it is lowercase: `ichito`. In documentation body text, it is **ICHITO** in bold caps.

### 3.5 Currency

The default currency is **KES** (Kenyan Shilling). The currency symbol is displayed as `KES` prefix, e.g., `KES 4,000`. Number formatting uses comma separators for thousands. The system supports configurable currency via settings.

### 3.6 Date Format

Default date format: `DD/MM/YYYY`. Configurable via settings. Time format: `HH:MM AM/PM` (12-hour).

### 3.7 Color Reference (Defaults)

| Token | Hex | Usage |
|-------|-----|-------|
| `accentColor` | `#FFD700` | Gold -- primary accent, buttons, highlights, active states |
| `backgroundColor` | `#000000` | AMOLED black -- main background |
| `surfaceColor` | `#1A1A1A` | Elevated surfaces, cards |
| `cardColor` | `#1E1E1E` | Card backgrounds |
| `textPrimary` | `#FFFFFF` | Primary text |
| `textSecondary` | `#B0B0B0` | Secondary/subtitle text |
| `statusGreen` | `#4CAF50` | Completed, paid, success |
| `statusYellow` | `#FFC107` | In progress, partial payment |
| `statusRed` | `#F44336` | Overdue, error, cancelled |
| `statusBlue` | `#2196F3` | Pending, informational |

All colors adapt when the user changes the accent color in settings. The accent color propagates to buttons, icons, dividers, shadows, selection highlights, progress indicators, and active navigation states.

---

## 4. Glossary

| Term | Definition |
|------|------------|
| **Accent Color** | The user-selected color that propagates across all UI elements. Default: Gold (#FFD700) |
| **AMOLED** | A display type. ICHITO's default theme uses pure black (#000000) to save battery on AMOLED screens |
| **Chama** | A Kenyan informal cooperative savings group, typically among women. Members contribute money and take turns receiving the pooled amount |
| **Corner Style** | The border-radius treatment applied globally to cards, buttons, inputs, and dialogs. 15+ presets available |
| **Customer** | A person who orders tailoring services. Has a profile with contact info, measurements, and order history |
| **Design** | A visual pattern or reference image for a tailored garment (e.g., floral, geometric, African print) |
| **Fabric** | A material used in tailoring, with name, price, category, color, and optional image |
| **Garment** | A type of clothing item (e.g., trousers, dress, shirt). Each garment type defines which measurement fields are needed |
| **Loyalty Status** | An automatically calculated tier based on customer spending: New / Loyal / Regular / VIP |
| **Measurement** | A body dimension (e.g., waist, inseam, bust) recorded in cm or inches for a specific garment order |
| **Mixin** | A Dart language feature used in ICHITO to share UI behaviors (theming, offline handling, navigation) across screens without inheritance |
| **M-Pesa** | A mobile money transfer service widely used in Kenya. One of the payment method options |
| **Order** | A tailoring job for a customer, encompassing garment type, measurements, materials, pricing, and delivery date |
| **Order Wizard** | The 6-step flow for creating a new order: Client -> Garment -> Measurements -> Materials -> Pricing -> Review |
| **Provider** | A Flutter state management pattern used in ICHITO for centralized, reactive state (theme, language, order data) |
| **Sheng** | A Swahili/English-based slang spoken widely in Kenya, particularly in urban areas. ICHITO offers Sheng as a language option |
| **SQLite** | The local relational database engine used for all data storage. Fully offline, no server required |
| **Trial Date** | A scheduled fitting appointment where the customer tries on a partially completed garment for adjustments |

---

## 5. File Naming Conventions

### Blueprint Documents
- Prefix with two-digit number: `00_`, `01_`, ... `13_`
- Use snake_case: `01_architecture_and_project_structure.md`
- All files in `/docs/` directory

### Source Code (Dart)
- Files: `snake_case.dart` (e.g., `customer_detail_screen.dart`)
- Classes: `PascalCase` (e.g., `CustomerDetailScreen`)
- Variables/methods: `camelCase` (e.g., `totalSpent`, `calculateRemaining()`)
- Constants: `camelCase` with `k` prefix for app-level constants (e.g., `kDefaultAccentColor`)
- Enums: `PascalCase` with `camelCase` values (e.g., `OrderStatus.inProgress`)

### Assets
- Images: `snake_case.png` in `assets/images/`
- Fonts: `FontName-Weight.ttf` in `assets/fonts/`

---

## 6. Cross-Reference Conventions

When one blueprint document references another, it uses this format:

> **See**: [Document Title](filename.md) -- Section Name

Example:
> **See**: [Data Models & Database](02_data_models_and_database.md) -- Customer Model

---

## 7. Status Indicator Colors

Status indicators throughout the app use small colored circles (8px diameter `Container` with circular `BoxDecoration`), never emojis:

| Status | Color | Hex |
|--------|-------|-----|
| Completed / Paid | Green | `#4CAF50` |
| In Progress / Partial | Yellow/Amber | `#FFC107` |
| Overdue / Unpaid / Error | Red | `#F44336` |
| Pending / New | Blue | `#2196F3` |
| Cancelled | Grey | `#9E9E9E` |

---

## 8. Order Number Format

Orders are automatically numbered using the pattern:

```
ICHITO-YYYY-MM-XXX
```

Where:
- `YYYY` = Year (e.g., 2026)
- `MM` = Month (e.g., 07)
- `XXX` = Sequential counter within that month, zero-padded (e.g., 001, 002, ... 999)

Example: `ICHITO-2026-07-042` means the 42nd order created in July 2026.

---

## 9. Supported Platforms

- **Primary**: Android (API 21+ / Android 5.0 Lollipop and above)
- **Secondary**: iOS (future consideration, architecture supports it)
- **Architecture**: ARM64 primary, ARM32 supported

---

## 10. Repository & Contact

- **GitHub**: https://github.com/funbinet/ichito
- **Codeberg**: https://codeberg.org/funbinet/ichito
- **Email**: funbinet@gmail.com

---

*This is Document 00 of 14 in the ICHITO Blueprint Documentation Set.*
