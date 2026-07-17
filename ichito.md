# ICHITO - Complete Tailor Management System

## Revolutionary Implementation Plan & Complete UI/UX Specification

---

## 📋 Table of Contents
1. [Project Philosophy & Vision](#project-philosophy--vision)
2. [The Name "Ichito"](#the-name-ichito)
3. [Core Features](#core-features)
4. [Technical Architecture](#technical-architecture)
5. [Complete App Structure & Navigation](#complete-app-structure--navigation)
6. [Detailed Screen Specifications](#detailed-screen-specifications)
7. [Data Models](#data-models)
8. [Local Storage Strategy](#local-storage-strategy)
9. [Advanced Theming & Customization](#advanced-theming--customization)
10. [Language & Localization](#language--localization)
11. [Implementation Phases](#implementation-phases)
12. [Testing Strategy](#testing-strategy)
13. [Future Enhancements](#future-enhancements)

---

## 🎯 Project Philosophy & Vision

**Ichito** (pronounced *ee-CHEE-toh*) is not just an application—it's a revolutionary paradigm shift in how tailoring businesses operate in the digital age. Named after the Sheng word meaning "to work" or "to do" , Ichito empowers tailors with a complete, offline-first management solution that combines premium aesthetics with powerful functionality.

### Guiding Principles

- **Zero-Compromise Offline-First**: Every feature functions flawlessly without internet. Users expect apps to work anywhere, anytime, and local data access provides blazing speed and instant gratification.

- **Adaptive Intelligence**: The system learns from patterns—identifying loyal customers, popular garments, and business trends to provide actionable insights.

- **Fluid Aesthetics**: A dynamic interface where every element responds to the global accent color, creating a cohesive visual language that feels alive and premium.

- **Cultural Resonance**: By incorporating Kenyan Sheng alongside English, Ichito speaks the language of its users—the vibrant, dynamic slang that has evolved as a distinct linguistic phenomenon in Kenya.

---

## 🏷️ The Name "Ichito"

**Ichito** (pronounced *ee-CHEE-toh*) draws inspiration from Kenyan Sheng, where it is commonly used to mean "work" or "get to work" . The name embodies:

- **Action**: The drive to get things done
- **Productivity**: The focus on efficient work
- **Craftsmanship**: The dedication to the tailoring craft
- **Cultural Identity**: A name that resonates with the Kenyan user base

The phonetic simplicity ensures easy recall while the cultural authenticity creates an immediate connection with the target audience. In a market where Sheng has become the language of pop culture, the marketplace, and youth expression, Ichito positions itself as a product of and for the community it serves.

---

## 🚀 Core Features

### Intelligent Customer Management
- **Profile Ecosystem**: Comprehensive customer profiles with photo, contact details, and gender-specific measurement templates
- **Analytics Integration**: Tracks customer loyalty, order frequency, and spending patterns
- **Measurement Intelligence**: Automatically suggests measurements based on previous orders and garment types

### Revolutionary Order Management
- **Fluid Creation Wizard**: A 6-step journey with real-time validation and intelligent defaults
- **Smart Garment Selection**: Auto-populates measurement fields based on garment type (e.g., trousers show waist/inseam, blouses show bust/shoulder)
- **Payment Tracking**: Real-time payment status with automatic remaining balance calculation
- **Trial Date Management**: Built-in reminders for fitting appointments

### Advanced Garment System
- **Dynamic Measurement Types**: Each garment has its own measurement profile
- **Gender-Specific Categorization**: Separate measurement templates for men and women
- **Reusable Templates**: Create garment templates that can be applied to multiple orders

### Fabric & Design Library
- **Visual Catalog**: Grid/list views with image support for fabrics and designs
- **Smart Organization**: Sort by name, price, or date added
- **Quick Selection**: Add new fabrics/designs mid-order without leaving the workflow

### Multi-Dimensional Notes System
- **Normal Notes**: Auto-title with date/time for quick journaling
- **Church Notes**: Speaker tracking with Bible verse tagging
- **Chama Notes**: Group contribution tracking for women's circles

---

## 🏗️ Technical Architecture

### Revolutionary Technology Stack

```
Frontend: Flutter (Dart) - For 60fps+ smooth animations and custom painting
Database: SQLite (sqflite) - Reliable offline data storage
State Management: Provider + Mixins for centralized UI behavior
Local Storage: Hive for caching, SharedPreferences for settings
Image Handling: ImagePicker + ImageCropper with compression
Localization: intl package with custom Sheng translations
```

### Architectural Innovation: Mixin-Based UI Behavior

Leveraging Dart mixins for reusable UI behavior provides significant advantages for consistency and offline handling:

```dart
mixin OfflineUIMixin<T extends StatefulWidget> on State<T> {
  void showOfflineBanner() {
    // Consistent offline indicator across all screens
  }
  
  void handleSyncStatus() {
    // Uniform sync state management
  }
}

mixin ThemeAwareMixin<T extends StatefulWidget> on State<T> {
  Color get accentColor => Provider.of<ThemeProvider>(context).accentColor;
  
  // All widgets adapt to global theme changes automatically
}
```

### Project Structure
```
lib/
├── main.dart
├── core/
│   ├── mixins/
│   │   ├── offline_ui_mixin.dart
│   │   ├── theme_aware_mixin.dart
│   │   └── navigation_mixin.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── image_service.dart
│   │   └── sync_service.dart
│   └── providers/
│       ├── theme_provider.dart
│       ├── language_provider.dart
│       └── order_provider.dart
├── screens/
│   ├── splash/
│   ├── home/
│   ├── customers/
│   ├── orders/
│   ├── garments/
│   ├── fabrics/
│   ├── designs/
│   ├── notes/
│   └── settings/
├── widgets/
│   ├── adaptive/
│   │   ├── adaptive_card.dart
│   │   ├── adaptive_button.dart
│   │   └── adaptive_icon.dart
│   └── layout/
│       ├── radial_menu.dart
│       └── gesture_navigation.dart
├── models/
│   ├── customer.dart
│   ├── order.dart
│   ├── garment.dart
│   └── settings.dart
└── utils/
    ├── constants.dart
    ├── sheng_translations.dart
    └── validators.dart
```

---

## 📱 Complete App Structure & Navigation

### Revolutionary Navigation Paradigm

**Radial Menu Navigation**: Inspired by modern UI innovations that prioritize thumb-friendly navigation, Ichito implements a radial menu system that replaces traditional bottom navigation.

```
                    ┌─────────────┐
                    │  👤 Profile  │
                    │             │
    ┌───────────────┤             ├───────────────┐
    │  📊 Statistics │  🏠 Home   │  👥 Customers │
    └───────────────┤             ├───────────────┘
                    │  ✨ New     │
                    │  Order      │
                    └─────────────┘
                         │
                    ┌────┴────┐
                    │ 📦 Orders│
                    │ 📝 Notes │
                    │ ⚙️ Settings│
                    └─────────┘
```

### Screen Hierarchy with Fluid Transitions

```
Home (Dashboard)
├── Statistics Carousel (Animated)
│   ├── Orders This Month
│   ├── Revenue This Month
│   ├── Active Customers
│   └── Popular Garment
├── Quick Action Grid (4x4)
│   ├── New Order → Order Wizard
│   ├── Customers → Customer Management
│   ├── Garments → Garment Library
│   ├── Fabrics → Fabric Catalog
│   ├── Designs → Design Gallery
│   ├── Notes → Notes Hub
│   └── Reports → Analytics Dashboard
└── Activity Feed (Real-time)
    ├── Recent Orders
    ├── Upcoming Fittings
    └── Payment Reminders
```

---

## 📐 Detailed Screen Specifications

### 1️⃣ Splash Screen

```
┌─────────────────────────────────────────────────────┐
│  🟣                               [Status Bar]     │
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
│                    ┌───────┐                       │
│                    │  ⚡   │                       │
│                    │ ICHITO│                       │
│                    └───────┘                       │
│                                                     │
│              "Work. Create. Thrive."                │
│                                                     │
│                                                     │
│              Loading Animation...                   │
│              ━━━━━━━━━━━━━━━━ 85%                  │
│                                                     │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Version 1.0.0  |  Ichito Studios                  │
│  funbinet@gmail.com                                │
└─────────────────────────────────────────────────────┘
```

**Implementation:**

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
    
    // Navigate to home after animation
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KamuuTheme.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo - Using the provided icon
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [KamuuTheme.accentColor, KamuuTheme.accentColor.withOpacity(0.5)],
                    ),
                  ),
                  child: Icon(
                    Icons.cut_outlined,
                    size: 64.w,
                    color: KamuuTheme.backgroundColor,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'ICHITO',
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    color: KamuuTheme.accentColor,
                    letterSpacing: 4.w,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Work. Create. Thrive.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: KamuuTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 40.h),
                // Progress
                Container(
                  width: 200.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: KamuuTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                KamuuTheme.accentColor,
                                KamuuTheme.accentColor.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: KamuuTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2️⃣ Home Dashboard

```
┌─────────────────────────────────────────────────────┐
│  📍 ICHITO                       🔔 (3)  👤       │
│  "Welcome back, Mama Rachel"                      │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐ │
│  │  📊 Monthly Statistics                       │ │
│  │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐  │ │
│  │  │ Orders │ │Revenue│ │Fabric │ │Design │  │ │
│  │  │  47    │ │ 142K  │ │  89   │ │  68   │  │ │
│  │  │  ↑12%  │ │  ↑8%  │ │  ↑5%  │ │  ↑10% │  │ │
│  │  └───────┘ └───────┘ └───────┘ └───────┘  │ │
│  └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │ ✨ New    │ │ 👤 Clients│ │ 👔 Garments│ │ 🧵 Fabrics││
│  │  Order    │ │  89 Active│ │  45 Types │ │  125     ││
│  │  ━━━━━━━━ │ │ ━━━━━━━━ │ │ ━━━━━━━━ │ │ ━━━━━━━━ ││
│  │  Create   │ │  Manage   │ │  Manage   │ │  Manage  ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │ 🎨 Design │ │ 📝 Notes  │ │ 📊 Stats  │ │ ⚙️Settings││
│  │  68       │ │  12       │ │  View    │ │  Custom  ││
│  │  ━━━━━━━━ │ │ ━━━━━━━━ │ │ ━━━━━━━━ │ │ ━━━━━━━━ ││
│  │  Gallery  │ │  Write    │ │  Reports  │ │  Configure││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
├─────────────────────────────────────────────────────┤
│  📋 Recent Activity                                │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🟢 • #I001 - Jane Muthoni                    │ │
│  │     Dress - KES 2,500 - 2 hours ago           │ │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ │
│  │  🟡 • #I002 - John Smith                      │ │
│  │     Trousers - KES 3,200 - 4 hours ago       │ │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ │
│  │  🔴 • #I003 - Mary Johnson                    │ │
│  │     Blouse - KES 1,800 - 6 hours ago         │ │
│  └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  🔗 Quick Actions                                  │
│  [🌐] [🎨] [🔒] [📱] [💡]                       │
│  (Language, Theme, Lock, Backup, Tips)            │
└─────────────────────────────────────────────────────┘
```

### 3️⃣ Order Creation Wizard - Complete 6 Steps

#### Step 1: Client Selection

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 1/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 16%            │
│                                                    │
│  Step 1: Select Client                             │
├─────────────────────────────────────────────────────┤
│  🔍 Search by name, phone or email...              │
│                                                     │
│  [Recent] [All] [Frequent] [VIP]                   │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  👤 Jane Muthoni                              │ │
│  │     📱 0712 345 678                          │ │
│  │     ⭐ 5 orders · VIP Client                  │ │
│  │     🎯 Last order: 15/01/2024                │ │
│  │  ──────────────────────────────────────────── │ │
│  │  👤 John Smith                                │ │
│  │     📱 0723 456 789                          │ │
│  │     ⭐ 3 orders · Loyal Client                │ │
│  │     🎯 Last order: 10/01/2024                │ │
│  │  ──────────────────────────────────────────── │ │
│  │  👤 Mary Johnson                              │ │
│  │     📱 0734 567 890                          │ │
│  │     ⭐ 1 order · New Client                   │ │
│  │     🎯 Last order: 05/01/2024                │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ➕ [Add New Client]                                │
│                                                     │
│  Selected: Jane Muthoni ✓                          │
├─────────────────────────────────────────────────────┤
│  [Cancel]                  [Next Step →]           │
└─────────────────────────────────────────────────────┘
```

#### Step 2: Garment Selection

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 2/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 33%            │
│                                                    │
│  Step 2: Select Garment                            │
├─────────────────────────────────────────────────────┤
│  🔍 Search garments...                             │
│                                                     │
│  [👔 Men]  [👗 Women]  [All]                       │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👔       │ │ 👔       │ │ 👔       │          │
│  │ Trousers │ │ Shirt    │ │ Jacket   │          │
│  │ 6 meas.  │ │ 5 meas.  │ │ 6 meas.  │          │
│  │ Popular  │ │ Classic  │ │ Premium  │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👔       │ │ 👔       │ │ 👔       │          │
│  │ Blazer   │ │ Vest     │ │ Shorts   │          │
│  │ 5 meas.  │ │ 4 meas.  │ │ 4 meas.  │          │
│  │ Formal   │ │ Casual   │ │ Summer   │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  ➕ [Add New Garment]                               │
│                                                     │
│  Selected: Trousers ✓                              │
├─────────────────────────────────────────────────────┤
│  [← Back]                  [Next Step →]           │
└─────────────────────────────────────────────────────┘
```

#### Step 3: Measurements

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 3/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 50%            │
│                                                    │
│  Step 3: Enter Measurements                        │
├─────────────────────────────────────────────────────┤
│  👔 Trousers (Men)                                 │
│  📏 Unit: [cm ▼]  [Load Default]                  │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Waist        [  32  ] cm  [━━━━┅━━━]       │ │
│  │  Inseam       [  34  ] cm  [━━━━┅━━━]       │ │
│  │  Hip          [  38  ] cm  [━━━━┅━━━]       │ │
│  │  Thigh        [  24  ] cm  [━━━━┅━━━]       │ │
│  │  Knee         [  16  ] cm  [━━━━┅━━━]       │ │
│  │  Length       [  40  ] cm  [━━━━┅━━━]       │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  📝 Notes:                                         │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Loose fit at waist...                        │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  [Save as Default for Client] [Save as Template]   │
├─────────────────────────────────────────────────────┤
│  [← Back]                  [Next Step →]           │
└─────────────────────────────────────────────────────┘
```

#### Step 4: Materials Selection

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 4/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 66%            │
│                                                    │
│  Step 4: Select Materials                          │
├─────────────────────────────────────────────────────┤
│  Fabrics (Select one or more)                     │
│  🔍 Search fabrics...                             │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🧵       │ │ 🧵       │ │ 🧵       │          │
│  │ Cotton   │ │ Silk     │ │ Denim    │          │
│  │ ✓ Selected│ │          │ │          │          │
│  │ KES 500   │ │ KES 1200 │ │ KES 800  │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  ➕ [Add New Fabric]                                │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  Designs (Select one)                              │
│  🔍 Search designs...                              │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🎨       │ │ 🎨       │ │ 🎨       │          │
│  │ Floral   │ │ Geometric│ │ Abstract │          │
│  │ ✓ Selected│ │          │ │          │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  ➕ [Add New Design]                                │
├─────────────────────────────────────────────────────┤
│  [← Back]                  [Next Step →]           │
└─────────────────────────────────────────────────────┘
```

#### Step 5: Pricing & Details

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 5/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 83%            │
│                                                    │
│  Step 5: Pricing & Details                         │
├─────────────────────────────────────────────────────┤
│  💰 Financial Summary                              │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Fabric Cost:   KES 2,500   [✏️]             │ │
│  │  Labor Cost:    KES 1,500   [✏️]             │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Total:         KES 4,000                    │ │
│  │  Deposit:       KES 1,000   [✏️]             │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Remaining:     KES 3,000                    │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  📅 Due Date: [15/02/2024] 🗓️                    │
│                                                     │
│  📅 Trial Date: [12/02/2024] 🗓️                   │
│                                                     │
│  📝 Special Instructions:                          │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Pleats at front, belt loops...              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ✅ [Require Client Confirmation]                   │
│  💬 [Send SMS Notification]                        │
├─────────────────────────────────────────────────────┤
│  [← Back]                  [Next Step →]           │
└─────────────────────────────────────────────────────┘
```

#### Step 6: Review & Confirm

```
┌─────────────────────────────────────────────────────┐
│  ✨ New Order                    Progress: 6/6     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%           │
│                                                    │
│  Step 6: Review Order                              │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐ │
│  │  👤 Client Information          [✏️]          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Name: Jane Muthoni                          │ │
│  │  Phone: 0712 345 678                        │ │
│  │  Email: jane@email.com                      │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  👔 Garment & Measurements      [✏️]          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Type: Trousers (Men)                        │ │
│  │  Waist: 32cm   Inseam: 34cm   Hip: 38cm     │ │
│  │  Thigh: 24cm   Knee: 16cm    Length: 40cm   │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🧵 Materials                   [✏️]          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Fabric: Cotton Print                        │ │
│  │  Design: Floral Dress Design                 │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  💰 Financial Summary            [✏️]          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Total: KES 4,000    Paid: KES 1,000         │ │
│  │  Remaining: KES 3,000                         │ │
│  │  Due: 15/02/2024    Trial: 12/02/2024       │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ✅ [Create Order]  🗑️ [Discard Order]            │
└─────────────────────────────────────────────────────┘
```

### 4️⃣ Order Detail Screen

```
┌─────────────────────────────────────────────────────┐
│  📦 Order #I001                   [✏️] [🗑️]       │
│  Status: In Progress 🔄                            │
│  ⏳ Due in 3 days                                  │
│  💰 Remaining: KES 3,000                           │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐ │
│  │  👤 Client Information        [📞] [✉️]       │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Name: Jane Muthoni                          │ │
│  │  Phone: 0712 345 678                        │ │
│  │  Email: jane@email.com                      │ │
│  │  Location: Nairobi CBD                      │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  👔 Garment Details            [✏️]           │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Type: Trousers (Men)                        │ │
│  │  Category: Casual Wear                       │ │
│  │  Measurements:                               │ │
│  │  Waist: 32cm   Inseam: 34cm   Hip: 38cm     │ │
│  │  Thigh: 24cm   Knee: 16cm    Length: 40cm   │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🧵 Materials                   [📷]          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Fabric: Cotton Print                        │ │
│  │  Design: Floral Dress Design                 │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  💰 Payment Tracking          [+ Add Payment] │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Total: KES 4,000                            │ │
│  │  Paid: KES 1,000                             │ │
│  │  Remaining: KES 3,000                        │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Payment History:                            │ │
│  │  ✅ 15/01/2024 - KES 1,000                  │ │
│  │  ✅ 10/01/2024 - KES 500                    │ │
│  │  ──────────────────────────────────────────   │ │
│  │  [Mark as Fully Paid]                        │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  🕐 Created: 15/01/2024 10:30 AM                   │
│  📝 Notes: Loose fit at waist...                   │
└─────────────────────────────────────────────────────┘
```

### 5️⃣ Customer Management Screen

```
┌─────────────────────────────────────────────────────┐
│  👥 Customers                     [+ Add] [📊]     │
├─────────────────────────────────────────────────────┤
│  🔍 Search customers...                            │
│                                                     │
│  [All] [Male] [Female] [VIP] [New] [Frequent]     │
│                                                     │
│  View: [Grid] [List]                               │
│  Sort: [Name ▼] [Orders ▼] [Spent ▼]             │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👤       │ │ 👤       │ │ 👤       │          │
│  │ Jane     │ │ John     │ │ Mary     │          │
│  │ Muthoni  │ │ Smith    │ │ Johnson  │          │
│  │ ⭐⭐ 5   │ │ ⭐ 3     │ │ 💫 1     │          │
│  │ VIP      │ │ Loyal    │ │ New      │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👤       │ │ 👤       │ │ 👤       │          │
│  │ Peter    │ │ Grace    │ │ James    │          │
│  │ Ochieng  │ │ Akinyi   │ │ Kariuki  │          │
│  │ ⭐ 4     │ │ ⭐ 2     │ │ ⭐ 1     │          │
│  │ Loyal    │ │ Regular  │ │ New      │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  Total: 89 Customers                               │
└─────────────────────────────────────────────────────┘
```

### 6️⃣ Customer Detail Screen

```
┌─────────────────────────────────────────────────────┐
│  👤 Jane Muthoni           [✏️] [🗑️] [📤]        │
├─────────────────────────────────────────────────────┤
│  📱 0712 345 678                                   │
│  📧 jane@email.com                                 │
│  📍 Nairobi CBD                                    │
│  🏷️ Female · 5 Orders · 3 Years                  │
│  ⭐ Loyalty: VIP                                   │
│  ┌─────────────────────────────────────────────────┐ │
│  │  💰 Total Spent: KES 42,500                   │ │
│  │  📊 Average Order: KES 8,500                  │ │
│  │  🏆 Most Ordered: Dresses (3)                 │ │
│  └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  📏 Measurements (Default)                         │
│  ┌─────────────┬──────────┐                       │
│  │ Bust        │ 92 cm    │  ✏️                  │ │
│  │ Waist       │ 70 cm    │  ✏️                  │ │
│  │ Hip         │ 98 cm    │  ✏️                  │ │
│  │ Shoulder    │ 40 cm    │  ✏️                  │ │
│  └─────────────┴──────────┘                       │
├─────────────────────────────────────────────────────┤
│  📋 Order History (5)                              │
│  ┌─────────────────────────────────────────────────┐ │
│  │  #I001 - Dress - KES 2,500                    │ │
│  │  Due: 15/02/24 ● ✅ Completed                  │ │
│  ├─────────────────────────────────────────────────┤ │
│  │  #I002 - Blouse - KES 1,800                   │ │
│  │  Due: 20/02/24 ● 🔄 In Progress               │ │
│  ├─────────────────────────────────────────────────┤ │
│  │  #I003 - Skirt - KES 2,200                    │ │
│  │  Due: 25/02/24 ● ⏳ Pending                   │ │
│  └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  💰 Financial Summary                              │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Total: KES 8,500 · Paid: KES 5,000           │ │
│  │  Remaining: KES 3,500                         │ │
│  │  [View Details →]                             │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### 7️⃣ Add Customer Dialog

```
┌─────────────────────────────────────────────────────┐
│  ➕ Add New Customer                                │
├─────────────────────────────────────────────────────┤
│  📷 [Upload Photo]                                 │
│                                                     │
│  Full Name: [Jane Muthoni]                         │
│  Phone: [0712 345 678]                             │
│  Email: [jane@email.com]                          │
│  Gender: [👤 Male]  [👩 Female]                   │
│  Location: [Nairobi CBD]                           │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  📏 Default Measurements (Optional)                │
│                                                     │
│  Height: [165] cm  Bust: [92] cm                   │
│  Waist: [70] cm    Hip: [98] cm                    │
│  Shoulder: [40] cm  Sleeve: [20] cm               │
│                                                     │
│  [Cancel]                  [Save Customer]         │
└─────────────────────────────────────────────────────┘
```

### 8️⃣ Fabrics Screen

```
┌─────────────────────────────────────────────────────┐
│  🧵 Fabrics                      [+ Add] [📊]      │
├─────────────────────────────────────────────────────┤
│  🔍 Search fabrics...                              │
│                                                     │
│  Sort: [Name ▼] [Price ▼] [Date ▼]                │
│  Grid: [4] [8] [16] [32]                           │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🧵       │ │ 🧵       │ │ 🧵       │          │
│  │ Cotton   │ │ Silk     │ │ Denim    │          │
│  │ Print    │ │ Satin    │ │ Blue     │          │
│  │ KES 500  │ │ KES 1200 │ │ KES 800  │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🧵       │ │ 🧵       │ │ 🧵       │          │
│  │ Linen    │ │ Wool     │ │ Polyester│          │
│  │ Natural  │ │ Blended  │ │ Premium  │          │
│  │ KES 900  │ │ KES 1500 │ │ KES 600  │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  Total: 125 Fabrics                                │
└─────────────────────────────────────────────────────┘
```

### 9️⃣ Add Fabric Dialog

```
┌─────────────────────────────────────────────────────┐
│  ➕ Add New Fabric                                  │
├─────────────────────────────────────────────────────┤
│  📷 [Upload Image] ✏️ (Camera/Gallery/Crop)       │
│                                                     │
│  Fabric Name: [Cotton Print]                       │
│  Description: [Light cotton with floral print]    │
│                                                     │
│  Price per Meter: [500] KES                        │
│  Unit: [Meter ▼] [Foot ▼] [Yard ▼]               │
│                                                     │
│  Category: [Cotton] [Silk] [Synthetic] [Other]    │
│                                                     │
│  Color: [🎨 Select Color]                         │
│                                                     │
│  [Cancel]                  [Save Fabric]           │
└─────────────────────────────────────────────────────┘
```

### 🔟 Designs Screen

```
┌─────────────────────────────────────────────────────┐
│  🎨 Designs                      [+ Add] [📊]      │
├─────────────────────────────────────────────────────┤
│  🔍 Search designs...                              │
│                                                     │
│  Sort: [Name ▼] [Date ▼] [Popularity ▼]           │
│  Grid: [4] [8] [16] [32]                           │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🎨       │ │ 🎨       │ │ 🎨       │          │
│  │ Floral   │ │ Geometric│ │ Abstract │          │
│  │ Dress    │ │ Pattern  │ │ Art      │          │
│  │ 12 used   │ │ 8 used   │ │ 6 used   │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 🎨       │ │ 🎨       │ │ 🎨       │          │
│  │ African  │ │ Modern   │ │ Vintage  │          │
│  │ Print    │ │ Minimal  │ │ Classic  │          │
│  │ 15 used   │ │ 10 used   │ │ 5 used   │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  Total: 68 Designs                                 │
└─────────────────────────────────────────────────────┘
```

### 1️⃣1️⃣ Notes Screen

```
┌─────────────────────────────────────────────────────┐
│  📝 Notes                       [+ Add] [📊]       │
├─────────────────────────────────────────────────────┤
│  [All] [📝 Normal] [✝️ Church] [💃 Chama]        │
│                                                     │
│  🔍 Search notes...                                │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📝 Monday Meeting                            │ │
│  │  Today 10:30 AM                               │ │
│  │  Client follow-up meeting with Jane...       │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │  ✝️ Sunday Service                            │ │
│  │  Yesterday 9:00 AM                            │ │
│  │  Pastor John: "Faith in Action"...            │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │  💃 Chama Meeting                            │ │
│  │  15/01/2024 2:00 PM                          │ │
│  │  Members: 12 · Total: KES 6,000              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  Total: 12 Notes                                   │
└─────────────────────────────────────────────────────┘
```

### 1️⃣2️⃣ Normal Note Editor

```
┌─────────────────────────────────────────────────────┐
│  📝 Edit Note                        [Save] [🗑️]   │
├─────────────────────────────────────────────────────┤
│  Title: [Monday Meeting]                           │
│  (Auto-filled with date/time if empty)             │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │                                               │ │
│  │  Client follow-up meeting with Jane...       │ │
│  │  Discussed measurements and fabric...        │ │
│  │                                               │ │
│  │  Next appointment: 20/01/2024               │ │
│  │                                               │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  🕐 Created: 15/01/2024 10:30 AM                   │
│  ✏️ Last edited: 15/01/2024 11:45 AM              │
│                                                     │
│  [Cancel]                  [Save Note]             │
└─────────────────────────────────────────────────────┘
```

### 1️⃣3️⃣ Church Note Editor

```
┌─────────────────────────────────────────────────────┐
│  ✝️ Edit Church Note                 [Save] [🗑️]   │
├─────────────────────────────────────────────────────┤
│  Topic: [Sunday Service]                           │
│  Speaker: [Pastor John Ochieng]                    │
│                                                     │
│  Bible Verses:                                     │
│  [John 3:16] [✕] [Psalm 23] [✕] [Romans 8:28]    │
│  [✕] [+ Add Verse]                                │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │                                               │ │
│  │  Sermon notes on faith and action...         │ │
│  │  Key points:                                 │ │
│  │  1. Faith requires action                    │ │
│  │  2. Trust in God's promises                  │ │
│  │  3. Live out your faith daily                │ │
│  │                                               │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  🕐 Created: 14/01/2024 9:00 AM                    │
│                                                     │
│  [Cancel]                  [Save Note]             │
└─────────────────────────────────────────────────────┘
```

### 1️⃣4️⃣ Chama Note Editor

```
┌─────────────────────────────────────────────────────┐
│  💃 Edit Chama Note                  [Save] [🗑️]   │
├─────────────────────────────────────────────────────┤
│  Meeting Date: [15/01/2024] 🗓️                    │
│  Meeting Title: [Monthly Chama Meeting]            │
│                                                     │
│  Members Present:                                   │
│  [Grace] [Mary] [Jane] [Sarah] [Susan]             │
│  [✕] [✕] [✕] [✕] [✕] [+ Add Member]             │
│                                                     │
│  Contributions:                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Grace      KES 1,000  ✅                    │ │
│  │  Mary       KES 1,000  ✅                    │ │
│  │  Jane       KES 1,000  ✅                    │ │
│  │  Sarah      KES   500  ⚠️  (Partial)         │ │
│  │  Susan      KES 1,000  ✅                    │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  Total Collected: KES 4,500                         │
│  Expected: KES 5,000                               │
│  Shortfall: KES 500                                 │
│                                                     │
│  Recipient: [Grace]                                │
│                                                     │
│  📝 Notes:                                         │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Grace to receive this month's contribution   │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  [Cancel]                  [Save Note]             │
└─────────────────────────────────────────────────────┘
```

### 1️⃣5️⃣ Advanced Settings Screen

```
┌─────────────────────────────────────────────────────┐
│  ⚙️ Settings                                       │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐ │
│  │  👤 Profile Settings                          │ │
│  │  ──────────────────────────────────────────   │ │
│  │  [Profile Picture]                           │ │
│  │  Mama Rachel                                 │ │
│  │  Tailor · Ichito User                       │ │
│  │  [Edit Profile]                              │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Email: funbinet@gmail.com                   │ │
│  │  Version: 1.0.0                              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🎨 Theme & Appearance                        │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Theme Mode: [AMOLED Black ▼]                │ │
│  │  Accent Color: [🎨 #FFD700]                  │ │
│  │  Corner Style: [Rounded ▼]                   │ │
│  │  Shadows: [Enable ▼]                         │ │
│  │  Shadow Intensity: [━━━━┅━━━]               │ │
│  │  Font: [Roboto ▼]   Size: [16]              │ │
│  │  [Preview Theme]                              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🌍 Language & Region                         │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Language: [English ▼] [Sheng ▼]             │ │
│  │  Measurement Unit: [cm ▼] [inches ▼]         │ │
│  │  Currency: [KES ▼] [USD ▼] [EUR ▼]           │ │
│  │  Date Format: [DD/MM/YYYY ▼]                 │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🔐 Security & Privacy                        │ │
│  │  ──────────────────────────────────────────   │ │
│  │  App Lock: [OFF] [ON]                        │ │
│  │  [Change PIN]                                │ │
│  │  Biometrics: [Enable] 👆                     │ │
│  │  Security Codes: [View/Edit]                 │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Data Encryption: [Enable]                   │ │
│  │  Auto-Lock Timer: [5 min ▼]                 │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🎯 Preferences                               │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Default View: [Grid ▼]                     │ │
│  │  Auto-Save Notes: [Enable]                   │ │
│  │  Default Garment Category: [All ▼]           │ │
│  │  Order Number Format: [Auto ▼]               │ │
│  │  Confirmation Dialogs: [Enable]              │ │
│  │  Haptic Feedback: [Enable]                   │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📊 Business Settings                         │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Business Name: [Mama Rachel Tailors]        │ │
│  │  Business Location: [Nairobi CBD]             │ │
│  │  Tax Rate: [16%]                             │ │
│  │  Default Labor Cost: [KES 1,000]             │ │
│  │  [Reset Defaults]                             │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  💾 Storage Management                        │ │
│  │  ──────────────────────────────────────────   │ │
│  │  Storage Used: 45MB / 256MB                  │ │
│  │  [Clear Cache]  [Delete Temporary Files]     │ │
│  │  [Export Data]  [Import Data]                │ │
│  │  [Backup Now]  [Restore from Backup]         │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📱 Advanced Features                         │ │
│  │  ──────────────────────────────────────────   │ │
│  │  [Developer Options]                          │ │
│  │  [Enable Debug Logs]                         │ │
│  │  [Performance Mode]                          │ │
│  │  [Experimental Features]                     │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  ❓ Help & Support                            │ │
│  │  ──────────────────────────────────────────   │ │
│  │  [User Guide]                                │ │
│  │  [Tutorials]                                 │ │
│  │  [Contact Support] (funbinet@gmail.com)      │ │
│  │  [About Ichito]                              │ │
│  │  [Rate this App]                             │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  🔄 Version 1.0.0                                  │
│  [Check for Updates]                               │
└─────────────────────────────────────────────────────┘
```

### 1️⃣6️⃣ App Lock Screen

```
┌─────────────────────────────────────────────────────┐
│  🔐 Enter PIN to Unlock                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│              ⚡ ICHITO                             │
│                                                     │
│              🔒                                    │
│                                                     │
│              [●] [●] [●] [●]                       │
│                                                     │
│              [1] [2] [3]                           │
│              [4] [5] [6]                           │
│              [7] [8] [9]                           │
│              [🔒] [0] [⌫]                        │
│                                                     │
│              [Use Biometrics] 👆                   │
│              [Forgot PIN?]                         │
└─────────────────────────────────────────────────────┘
```

### 1️⃣7️⃣ Security Code Popup

```
┌─────────────────────────────────────────────────────┐
│  🔐 Security Code Verification                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ⚠️ Enter your security code to reset PIN          │
│                                                     │
│  [●] [●] [●] [●] [●] [●] [●] [●] [●] [●]         │
│                                                     │
│  [1] [2] [3] [4] [5] [6] [7] [8] [9] [0]         │
│                                                     │
│  [Cancel]                  [Verify]                │
└─────────────────────────────────────────────────────┘
```

### 1️⃣8️⃣ Statistics Dashboard

```
┌─────────────────────────────────────────────────────┐
│  📊 Analytics Dashboard                            │
├─────────────────────────────────────────────────────┤
│  📅 [This Month ▼] [2024 ▼]                       │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📈 Revenue Overview                          │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  💰 Total Revenue: KES 142,000        │ │ │
│  │  │  📈 Growth: +12% from last month       │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📊 Key Metrics                               │ │
│  │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐  │ │
│  │  │Orders  │ │Revenue│ │Clients│ │Garments│  │ │
│  │  │  47    │ │ 142K  │ │  89   │ │  45   │  │ │
│  │  │  ↑12%  │ │  ↑8%  │ │  ↑5%  │ │  ↑10% │  │ │
│  │  └───────┘ └───────┘ └───────┘ └───────┘  │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  📈 Monthly Trends                            │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  [Bar Chart: Orders by Month]           │ │ │
│  │  │  ████████░░░░  Jan                       │ │ │
│  │  │  ████████████  Feb                       │ │ │
│  │  │  ███████████░  Mar                       │ │ │
│  │  │  ████████████  Apr                       │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🏆 Top Performers                           │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  1. Jane Muthoni - 5 orders            │ │ │
│  │  │  2. John Smith - 3 orders              │ │ │
│  │  │  3. Mary Johnson - 2 orders            │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  🧵 Popular Garments                          │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  Trousers - 15 orders                  │ │ │
│  │  │  Dresses - 12 orders                   │ │ │
│  │  │  Shirts - 8 orders                     │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  [Export Report] [Print Report]                    │
└─────────────────────────────────────────────────────┘
```

### 1️⃣9️⃣ Add Payment Popup

```
┌─────────────────────────────────────────────────────┐
│  💳 Add Payment                                    │
├─────────────────────────────────────────────────────┤
│  Amount: [  1,000  ] KES                          │
│                                                     │
│  Date: [15/01/2024] 🗓️                            │
│                                                     │
│  Payment Method:                                   │
│  [💵 Cash]  [💳 M-Pesa]  [🏦 Bank]               │
│                                                     │
│  📝 Notes:                                         │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Deposit payment...                          │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  Remaining after payment: KES 2,000               │
│                                                     │
│  [Cancel]                  [Add Payment]           │
└─────────────────────────────────────────────────────┘
```

### 2️⃣0️⃣ Success Confirmation

```
┌─────────────────────────────────────────────────────┐
│  ✅ Order Created!                                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│              ✅                                    │
│                                                     │
│  Order #I001 has been created                      │
│  successfully!                                     │
│                                                     │
│  🧾 Order Summary:                                 │
│  Client: Jane Muthoni                              │
│  Garment: Trousers (Men)                          │
│  Total: KES 4,000                                 │
│  Due: 15/02/2024                                  │
│                                                     │
│  [View Order]          [Create Another]            │
└─────────────────────────────────────────────────────┘
```

### 2️⃣1️⃣ Garments Screen

```
┌─────────────────────────────────────────────────────┐
│  👔 Garments                     [+ Add] [📊]      │
├─────────────────────────────────────────────────────┤
│  🔍 Search garments...                             │
│                                                     │
│  [All] [Men] [Women]                               │
│                                                     │
│  View: [Grid] [List]                               │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👔       │ │ 👔       │ │ 👔       │          │
│  │ Trousers │ │ Shirt    │ │ Jacket   │          │
│  │ 6 meas.  │ │ 5 meas.  │ │ 6 meas.  │          │
│  │ Men      │ │ Men      │ │ Men      │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ 👗       │ │ 👗       │ │ 👗       │          │
│  │ Dress    │ │ Blouse   │ │ Skirt    │          │
│  │ 5 meas.  │ │ 4 meas.  │ │ 4 meas.  │          │
│  │ Women    │ │ Women    │ │ Women    │          │
│  └──────────┘ └──────────┘ └──────────┘          │
│                                                     │
│  Total: 45 Garment Types                           │
└─────────────────────────────────────────────────────┘
```

### 2️⃣2️⃣ Add Garment Dialog

```
┌─────────────────────────────────────────────────────┐
│  ➕ Add New Garment                                 │
├─────────────────────────────────────────────────────┤
│  Garment Name: [Trousers]                          │
│  Description: [Casual trousers with belt loops]    │
│                                                     │
│  Category: [Men] [Women] [Unisex]                  │
│                                                     │
│  Measurement Fields:                               │
│  ┌─────────────────────────────────────────────────┐ │
│  │  [Waist]    [Inseam]    [Hip]                 │ │
│  │  [Thigh]    [Knee]      [Length]              │ │
│  │  [+ Add Measurement]                          │ │
│  └─────────────────────────────────────────────────┘ │
│                                                     │
│  Default Price: [KES 2,000]                        │
│                                                     │
│  [Cancel]                  [Save Garment]          │
└─────────────────────────────────────────────────────┘
```

---

## 💾 Data Models with Intelligence

### Customer Model
```dart
class Customer {
  int id;
  String name;
  String phone;
  String email;
  String gender; // 'male' | 'female'
  String location;
  String photoPath;
  Map<String, double> measurements; // Gender-specific measurements
  
  // Smart Analytics
  int totalOrders;
  double totalSpent;
  double averageOrderValue;
  DateTime lastOrderDate;
  List<String> preferredGarments;
  List<String> preferredFabrics;
  
  // Relationship Data
  List<Order> orders;
  
  // Calculated Properties
  String get loyaltyStatus {
    if (totalSpent > 50000) return 'VIP';
    if (totalSpent > 20000) return 'Regular';
    if (totalOrders > 3) return 'Loyal';
    return 'New';
  }
}
```

### Order Model
```dart
class Order {
  int id;
  String orderNumber; // Auto-generated: ICHITO-YYYY-MM-XXX
  int customerId;
  int garmentId;
  DateTime orderDate;
  DateTime dueDate;
  DateTime? trialDate;
  String status; // 'pending' | 'in_progress' | 'trial' | 'completed' | 'cancelled'
  
  // Financial Intelligence
  double totalAmount;
  double paidAmount;
  List<Payment> payments;
  double get remainingBalance => totalAmount - paidAmount;
  bool get isFullyPaid => remainingBalance <= 0;
  
  // Measurement Data
  Map<String, double> measurements;
  int fabricId;
  int designId;
  
  // Notes & Special Instructions
  String notes;
  List<String> specialRequests;
  
  // Tracking
  DateTime createdAt;
  DateTime updatedAt;
  List<OrderStatusLog> statusHistory;
}
```

### Garment Model
```dart
class Garment {
  int id;
  String name;
  String description;
  String category; // 'men' | 'women' | 'unisex'
  List<String> measurementFields;
  double defaultPrice;
  String imagePath;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Fabric Model
```dart
class Fabric {
  int id;
  String name;
  String description;
  double pricePerUnit;
  String unit; // 'meter' | 'foot' | 'yard'
  String category; // 'cotton' | 'silk' | 'synthetic' | 'other'
  String color;
  String imagePath;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Design Model
```dart
class Design {
  int id;
  String name;
  String description;
  String category; // 'floral' | 'geometric' | 'abstract' | 'african' | 'modern' | 'vintage'
  String imagePath;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Note Model
```dart
class Note {
  int id;
  String title;
  String content;
  NoteType type; // 'normal' | 'church' | 'chama'
  DateTime createdAt;
  DateTime updatedAt;
  
  // Church Notes
  String? speaker;
  List<String>? bibleVerses;
  
  // Chama Notes
  DateTime? meetingDate;
  List<String>? members;
  Map<String, double>? contributions;
  double? totalCollected;
  String? recipient;
}
```

### Payment Model
```dart
class Payment {
  int id;
  int orderId;
  double amount;
  DateTime date;
  PaymentMethod method; // 'cash' | 'mpesa' | 'bank'
  String notes;
  DateTime createdAt;
}
```

---

## 🎨 Advanced Theming & Customization

### Global Accent System

Ichito introduces a revolutionary accent system where every visual element adapts to the user's chosen color:

**Primary Components Affected:**
- App bar and headers
- Navigation indicators
- Buttons and toggles
- Selection highlights
- Progress indicators
- Icons and dividers
- Shadow colors

**Accent Color Options:**
- **Solid Colors**: 30 curated colors (Gold, Emerald, Ruby, Sapphire, etc.)
- **Gradients**: 15 pre-designed gradient combinations
- **Custom**: Full color picker with HEX/RGB input

### Corner Style System (15+ Options)

Each corner style transforms the entire app's personality:

1. **Rounded** (Default): Soft, friendly, approachable
2. **Sharp**: Professional, modern, minimalist
3. **Pill**: Ultra-modern, playful
4. **Notched**: Unique, attention-grabbing
5. **Teardrop**: Elegant, sophisticated
6. **Scooped**: Organic, natural
7. **Beveled**: Premium, luxurious
8. **Asymmetric**: Dynamic, artistic
9. **Cascading**: Fluid, animated
10. **Crystal**: Sharp geometric beauty
11. **Soft Rounded**: Gentle, accessible
12. **Oblique**: Progressive, forward-looking
13. **Angular**: Bold, dramatic
14. **Hybrid**: Custom combination
15. **Responsive**: Adapts to device size

### Shadow Intelligence

Shadows adapt their color based on the global accent, creating a cohesive look:

- **Dark Theme**: Shadow hue matches accent color with varying opacity
- **Light Theme**: Shadow hue matches accent color with lower opacity
- **AMOLED**: Deep blacks with accent-colored shadow glows

### Font System

Custom font options for complete typography control:

```dart
enum FontFamily {
  roboto,
  poppins,
  montserrat,
  inter,
  sfProDisplay,
  playfairDisplay,
  openSans,
  lato,
  raleway,
  merriweather,
}
```

### Theme Implementation

```dart
class IchitoTheme {
  // Core theme properties
  static Color _accentColor = const Color(0xFFFFD700); // Gold default
  static Color _backgroundColor = const Color(0xFF000000); // AMOLED Black
  static Color _surfaceColor = const Color(0xFF1A1A1A);
  static Color _cardColor = const Color(0xFF1E1E1E);
  static Color _textPrimary = const Color(0xFFFFFFFF);
  static Color _textSecondary = const Color(0xFFB0B0B0);
  static Color _textAccent = const Color(0xFFFFD700);
  static CornerStyle _cornerStyle = CornerStyle.rounded;
  static bool _enableShadows = true;
  static double _shadowIntensity = 0.15;
  static FontFamily _fontFamily = FontFamily.roboto;
  static double _fontSize = 16.0;
  static bool _isDarkMode = true;
  static ThemeMode _themeMode = ThemeMode.dark;

  // Getters
  static Color get accentColor => _accentColor;
  static Color get backgroundColor => _backgroundColor;
  static Color get surfaceColor => _surfaceColor;
  static Color get cardColor => _cardColor;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
  static Color get textAccent => _accentColor;
  static CornerStyle get cornerStyle => _cornerStyle;
  static bool get enableShadows => _enableShadows;
  static double get shadowIntensity => _shadowIntensity;
  static FontFamily get fontFamily => _fontFamily;
  static double get fontSize => _fontSize;

  // Setters with rebuild triggers
  static void setAccentColor(Color color) {
    _accentColor = color;
    _textAccent = color;
    ThemeManager.notifyListeners();
  }

  static void setCornerStyle(CornerStyle style) {
    _cornerStyle = style;
    ThemeManager.notifyListeners();
  }

  static void setFontFamily(FontFamily family) {
    _fontFamily = family;
    ThemeManager.notifyListeners();
  }

  static void setShadowIntensity(double intensity) {
    _shadowIntensity = intensity;
    ThemeManager.notifyListeners();
  }

  static void toggleShadows() {
    _enableShadows = !_enableShadows;
    ThemeManager.notifyListeners();
  }

  static void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    ThemeManager.notifyListeners();
  }

  // Theme data generation
  static ThemeData getThemeData() {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _accentColor,
      primarySwatch: _createMaterialColor(_accentColor),
      backgroundColor: _backgroundColor,
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _cardColor,
      dividerColor: _accentColor.withOpacity(0.3),
      fontFamily: _getFontFamilyString(),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      cardTheme: _buildCardTheme(),
      buttonTheme: _buildButtonTheme(),
      inputDecorationTheme: _buildInputTheme(),
      iconTheme: _buildIconTheme(),
      colorScheme: ColorScheme(
        primary: _accentColor,
        secondary: _accentColor,
        surface: _surfaceColor,
        background: _backgroundColor,
        error: Colors.red[400]!,
        onPrimary: _backgroundColor,
        onSecondary: _backgroundColor,
        onSurface: _textPrimary,
        onBackground: _textPrimary,
        onError: _backgroundColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static ColorSwatch _createMaterialColor(Color color) {
    return ColorSwatch(
      color.value,
      const <int, Color>{
        50: Color(0xFFFFF8E1),
        100: Color(0xFFFFECB3),
        200: Color(0xFFFFE082),
        300: Color(0xFFFFD54F),
        400: Color(0xFFFFCA28),
        500: Color(0xFFFFC107),
        600: Color(0xFFFFB300),
        700: Color(0xFFFFA000),
        800: Color(0xFFFF8F00),
        900: Color(0xFFFF6F00),
      },
    );
  }

  static String _getFontFamilyString() {
    switch (_fontFamily) {
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.poppins:
        return 'Poppins';
      case FontFamily.montserrat:
        return 'Montserrat';
      case FontFamily.inter:
        return 'Inter';
      case FontFamily.sfProDisplay:
        return 'SF Pro Display';
      case FontFamily.playfairDisplay:
        return 'Playfair Display';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.lato:
        return 'Lato';
      case FontFamily.raleway:
        return 'Raleway';
      case FontFamily.merriweather:
        return 'Merriweather';
    }
  }
}
```

---

## 🌍 Language & Localization

### Language Options

Ichito supports two language modes:
1. **English**: Formal, professional communication
2. **Sheng (Kenyan)**: Authentic, relatable, culturally resonant

### Sheng Localization

```json
{
  "appTitle": "Ichito",
  "greeting": "Shukran, {name}",
  "home": "Nyumba",
  "orders": "Oda",
  "customers": "Wateja",
  "fabrics": "Vitambaa",
  "designs": "Mipango",
  "notes": "Maelezo",
  "settings": "Mipangilio",
  "createOrder": "Fanya Oda Mpya",
  "dueDate": "Tarehe ya Malipo",
  "measurements": "Vipimo",
  "search": "Tafuta",
  "save": "Hifadhi",
  "cancel": "Ghairi",
  "confirm": "Thibitisha",
  "delete": "Futa",
  "edit": "Hariri",
  "discard": "Tupa",
  "completed": "Imekamilika",
  "inProgress": "Inaendelea",
  "pending": "Inasubiri",
  "paid": "Imelipwa",
  "remaining": "Inabaki",
  "total": "Jumla",
  "payment": "Malipo",
  "customer": "Mteja",
  "garment": "Vazi",
  "fabric": "Kitambaa",
  "design": "Mpango",
  "profile": "Wasifu",
  "help": "Msaada",
  "logout": "Toka",
  "clearCache": "Ondoa Cache",
  "appLock": "Funga App",
  "biometrics": "Biometria",
  "securityCode": "Nambari ya Usalama",
  "preferences": "Mapendeleo",
  "language": "Lugha",
  "theme": "Mada",
  "cornerStyle": "Mtindo wa Pembeni",
  "shadows": "Vivuli",
  "fontSize": "Ukubwa wa Herufi",
  "measurementUnit": "Kitengo cha Vipimo"
}
```

---

## 🔄 Implementation Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup with modular architecture
- [ ] SQLite database with advanced schema
- [ ] Mixin-based UI behavior system
- [ ] Centralized theme and accent system
- [ ] Radial navigation menu implementation

### Phase 2: Core Intelligence (Week 3-4)
- [ ] Customer CRUD with analytics tracking
- [ ] Intelligent garment measurement system
- [ ] Order wizard with smart defaults
- [ ] Fabric and design management with image cropping
- [ ] Image optimization and storage

### Phase 3: Advanced Features (Week 5-6)
- [ ] Payment tracking and financial intelligence
- [ ] Customer loyalty system
- [ ] Notes ecosystem (Normal, Church, Chama)
- [ ] Advanced search, filter, sorting
- [ ] Statistics dashboard with trends

### Phase 4: Customization & Localization (Week 7-8)
- [ ] Complete settings with all accent/theme options
- [ ] 15+ corner styles implementation
- [ ] Font system with 10 custom fonts
- [ ] Full Sheng localization
- [ ] App lock with biometrics support

### Phase 5: Polish & Optimization (Week 9-10)
- [ ] UI polish with micro-interactions
- [ ] Performance optimization
- [ ] Offline sync with fallback UIs
- [ ] Help & guide screens
- [ ] Comprehensive testing
- [ ] Release preparation

---

## 🧪 Testing Strategy

### Unit Testing
- Data model validation
- Business logic (calculations, validations)
- Translation accuracy

### Widget Testing
- Screen rendering with different themes
- User interactions and gestures
- Form validation and error states

### Integration Testing
- Complete order creation flow
- Customer management lifecycle
- Settings application across all screens
- Navigation transitions

### Localization Testing
- English version accuracy
- Sheng version cultural authenticity
- UI adaptation for text length differences

### Device Testing
- Android (multiple versions)
- Offline functionality verification
- Image handling performance
- Memory and battery optimization

---

## 🚀 Future Enhancements

1. **AI-Powered Recommendations**: Suggest garments based on customer history
2. **Voice Input**: Voice-controlled measurement entry
3. **Augmented Reality**: Virtual fitting previews
4. **Cloud Backup**: Optional encrypted cloud sync
5. **Wearable Integration**: Smartwatch measurement tracking
6. **Print-Ready Reports**: Professional invoice and report generation
7. **SMS Integration**: Automated order status updates
8. **Multi-User Support**: Team accounts for growing businesses
9. **Social Media Integration**: Share designs and promotions
10. **Advanced Analytics**: Business insights and forecasting

---

## 📝 Final Thoughts

**Ichito** represents a paradigm shift in tailoring business management. By combining offline-first reliability, intelligent design, and cultural authenticity, it creates an experience that is both powerful and personal.

The app's revolutionary approach to theming—where every element adapts to the user's chosen accent color—ensures that no two Ichito installations look alike. The 15+ corner styles provide unprecedented customization, allowing each user to tailor the app's visual identity to their personal taste and brand.

The inclusion of full Sheng localization reflects a deep understanding of the target audience. Sheng is not merely a translation option—it's a statement of cultural relevance, connecting with users in the language of their daily lives.

Ichito is more than an app. It's a tool for empowerment, helping tailors manage their businesses with confidence and style. It's a celebration of Kenyan culture through technology. It's the future of tailoring, delivered today.

---

## 📱 Repository Information

- **GitHub**: https://github.com/funbinet/ichito
- **Codeberg**: https://codeberg.org/funbinet/ichito
- **Email**: funbinet@gmail.com

---

*"Ichito" - Work. Create. Thrive. Revolutionizing tailoring, one order at a time.*