# ICHITO -- Screens: Home & Dashboard

**Document**: 05 of 14
**Covers**: Splash screen, home dashboard, statistics carousel, quick action grid, activity feed, notification indicators, welcome header

---

## 1. Splash Screen

### 1.1 Purpose
The splash screen is the first thing users see. It serves three purposes:
1. Brand impression (logo + tagline)
2. Database initialization (happens behind the animation)
3. Settings loading (theme, language, app state)

### 1.2 Layout Specification

```
┌─────────────────────────────────────────────────────┐
│                    [Status Bar]                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│                                                      │
│                                                      │
│                                                      │
│            ┌──────────────────────┐                  │
│            │                      │                  │
│            │   [Sewing Machine    │                  │
│            │    Logo Image]       │                  │
│            │   120x120 dp         │                  │
│            │                      │                  │
│            └──────────────────────┘                  │
│                                                      │
│                  24dp gap                            │
│                                                      │
│                 I C H I T O                          │
│            (displayMedium, accent, spacing: 4dp)     │
│                                                      │
│                  8dp gap                             │
│                                                      │
│            "Work. Create. Thrive."                   │
│           (bodyMedium, textSecondary, italic)         │
│                                                      │
│                  40dp gap                            │
│                                                      │
│            ┌──────────────────────┐                  │
│            │  [Progress Bar]      │                  │
│            │  200dp wide, 4dp tall│                  │
│            │  accent gradient fill│                  │
│            └──────────────────────┘                  │
│                                                      │
│                  8dp gap                             │
│                                                      │
│               "Loading..."                           │
│           (bodySmall, textSecondary)                  │
│                                                      │
│                                                      │
│                                                      │
├─────────────────────────────────────────────────────┤
│  Version 1.0.0  |  Ichito Studios                   │
│  (labelSmall, textSecondary, centered)               │
└─────────────────────────────────────────────────────┘
```

### 1.3 Animation Sequence

| Time | Element | Animation | Curve |
|------|---------|-----------|-------|
| 0ms | Logo | Scale from 0.8 to 1.0 | elasticOut |
| 0ms | Logo | Fade from 0.0 to 1.0 | easeIn |
| 200ms | "ICHITO" text | Fade in | easeIn |
| 400ms | Tagline | Fade in | easeIn |
| 0-2500ms | Progress bar | Width from 0% to 100% | easeOut |
| 0ms | Version text | Already visible (no animation) | N/A |
| 2500ms | Entire screen | Fade out | easeInOut |
| 3000ms | Navigate to Home or PIN Lock | N/A | N/A |

### 1.4 Logo Container

```dart
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accentColor,
        accentColor.withOpacity(0.5),
      ],
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Image.asset(
      'assets/images/logo_white.png',  // Always white logo on accent circle
      fit: BoxFit.contain,
    ),
  ),
)
```

### 1.5 Initialization Logic

```dart
@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(milliseconds: 2500),
    vsync: this,
  );
  
  _controller.forward();
  
  // Parallel initialization
  _initialize().then((_) {
    // Wait for animation to finish if it hasn't
    Future.delayed(
      Duration(milliseconds: max(0, 3000 - _elapsedMs)),
      () => _navigate(),
    );
  });
}

Future<void> _initialize() async {
  await DatabaseService.instance.initialize();
  // Theme and language are already loaded in main.dart
}

void _navigate() {
  final appState = Provider.of<AppStateProvider>(context, listen: false);
  
  if (appState.isAppLockEnabled && !appState.isAuthenticated) {
    Navigator.pushReplacementNamed(context, Routes.pinLock);
  } else {
    Navigator.pushReplacementNamed(context, Routes.home);
  }
}
```

---

## 2. Home Dashboard

### 2.1 Purpose
The central hub of ICHITO. Shows at-a-glance business status, quick actions, and recent activity. Everything a tailor needs to start their day.

### 2.2 Layout Specification

```
┌─────────────────────────────────────────────────────┐
│  [Status Bar - system]                               │
├─────────────────────────────────────────────────────┤
│  ICHITO     [Logo]            [Bell:3] [Avatar]     │
│  "Welcome back, {userName}"                         │
│  (bodyMedium, textSecondary)                        │
├─────────────────────────────────────────────────────┤
│  SCROLLABLE CONTENT                                  │
│                                                      │
│  ┌─ Statistics Carousel ──────────────────────────┐ │
│  │  ◄  [Stat Card 1]  [Stat Card 2]  ►          │ │
│  │     Horizontally scrollable, page indicator    │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  16dp gap                                            │
│                                                      │
│  Quick Actions                                       │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │ New  │ │Client│ │Garme-│ │Fabri-│              │
│  │Order │ │  s   │ │ nts  │ │ cs   │              │
│  └──────┘ └──────┘ └──────┘ └──────┘              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │Desig-│ │Notes │ │Stats │ │Setti-│              │
│  │ ns   │ │      │ │      │ │ ngs  │              │
│  └──────┘ └──────┘ └──────┘ └──────┘              │
│                                                      │
│  24dp gap                                            │
│                                                      │
│  Recent Activity                 [View All]          │
│  ┌────────────────────────────────────────────────┐ │
│  │  [StatusDot] #ICHITO-2026-07-042               │ │
│  │  Jane Muthoni - Dress - KES 2,500              │ │
│  │  2 hours ago                                   │ │
│  ├────────────────────────────────────────────────┤ │
│  │  [StatusDot] #ICHITO-2026-07-041               │ │
│  │  John Smith - Trousers - KES 3,200             │ │
│  │  4 hours ago                                   │ │
│  ├────────────────────────────────────────────────┤ │
│  │  [StatusDot] #ICHITO-2026-07-040               │ │
│  │  Mary Johnson - Blouse - KES 1,800             │ │
│  │  6 hours ago                                   │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  24dp gap                                            │
│                                                      │
│  Upcoming Fittings              [View All]           │
│  ┌────────────────────────────────────────────────┐ │
│  │  [EventIcon] Jane Muthoni                      │ │
│  │  Dress fitting - Tomorrow 10:00 AM             │ │
│  ├────────────────────────────────────────────────┤ │
│  │  [EventIcon] Peter Ochieng                     │ │
│  │  Suit fitting - 20/07/2026                     │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  24dp gap                                            │
│                                                      │
│  Payment Reminders              [View All]           │
│  ┌────────────────────────────────────────────────┐ │
│  │  [WarningIcon] Jane Muthoni                    │ │
│  │  KES 3,000 remaining - Due 25/07/2026          │ │
│  ├────────────────────────────────────────────────┤ │
│  │  [WarningIcon] Grace Akinyi                    │ │
│  │  KES 1,500 remaining - Overdue!                │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  80dp bottom padding (for radial menu clearance)     │
│                                                      │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 2.3 Welcome Header

```dart
class WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final appState = Provider.of<AppStateProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Logo + App name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    theme.isLightMode
                      ? 'assets/images/logo_black.png'
                      : 'assets/images/logo_white.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ICHITO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${language.t("greeting")}, ${appState.userName}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.textSecondary,
                ),
                onPressed: () => _showNotifications(context),
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: TextStyle(
                        color: theme.onAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Profile avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.settings),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.accentLight,
              backgroundImage: appState.profilePhotoPath != null
                ? FileImage(File(appState.profilePhotoPath!))
                : null,
              child: appState.profilePhotoPath == null
                ? Icon(Icons.person_outlined, color: theme.accentColor, size: 20)
                : null,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.4 Notifications

The notification bell shows a count of actionable items:
- Overdue orders (status != completed/cancelled AND due_date < today)
- Upcoming trial dates (trial_date within next 2 days)
- Orders with outstanding payments > 30 days

Tapping the bell shows a dropdown list of these items. Tapping an item navigates to the relevant order detail.

---

## 3. Statistics Carousel

### 3.1 Layout

A horizontally scrollable `PageView` of stat cards. Shows 2 cards visible at a time with peek of the next card.

```
┌──────────────────────────────────────────────────────┐
│  ┌──────────────────┐  ┌──────────────────┐  ┌──   │
│  │  [Icon: bag]     │  │  [Icon: wallet] │  │     │
│  │  Orders          │  │  Revenue         │  │ Ac  │
│  │  This Month      │  │  This Month      │  │ ti  │
│  │                  │  │                  │  │ ve  │
│  │  47              │  │  KES 142,000     │  │ ..  │
│  │  [TrendUp] +12%  │  │  [TrendUp] +8%   │  │     │
│  └──────────────────┘  └──────────────────┘  └──   │
│                 ● ● ○                                │
└──────────────────────────────────────────────────────┘
```

### 3.2 Stat Cards Data

| Card | Icon | Title | Value Source | Trend Calculation |
|------|------|-------|-------------|-------------------|
| Orders This Month | `Icons.shopping_bag_outlined` | "Orders This Month" | Count of orders where `order_date` is in current month | Compare with previous month count |
| Revenue This Month | `Icons.account_balance_wallet_outlined` | "Revenue This Month" | Sum of `payments.amount` where `date` is in current month | Compare with previous month |
| Active Customers | `Icons.people_outlined` | "Active Customers" | Count of distinct `customer_id` in orders this month | Compare with previous month |
| Popular Garment | `Icons.checkroom_outlined` | "Top Garment" | Garment name with most orders this month | Show order count |

### 3.3 Stat Card Widget

```dart
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double? trendPercentage;  // null if not applicable
  final bool trendPositive;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
          Icon(icon, color: theme.accentColor, size: 28),
          const SizedBox(height: 12),
          Text(title,
            style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            )),
          if (trendPercentage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trendPositive
                    ? Icons.trending_up_outlined
                    : Icons.trending_down_outlined,
                  size: 16,
                  color: trendPositive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                ),
                const SizedBox(width: 4),
                Text(
                  '${trendPositive ? "+" : ""}${trendPercentage!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendPositive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

### 3.4 Page Indicator

Small dots below the carousel indicating the current page:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(
    (statCards.length / 2).ceil(),  // 2 cards per page
    (index) => Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentPage
          ? theme.accentColor
          : theme.textSecondary.withOpacity(0.3),
      ),
    ),
  ),
)
```

---

## 4. Quick Action Grid

### 4.1 Layout

A 4-column, 2-row grid of action tiles. Each tile navigates to a primary section of the app.

### 4.2 Action Tiles

| Position | Label | Icon | Route | Subtitle |
|----------|-------|------|-------|----------|
| Row 1, Col 1 | New Order | `Icons.add_shopping_cart_outlined` | `Routes.orderWizard` | "Create" |
| Row 1, Col 2 | Customers | `Icons.people_outlined` | `Routes.customerList` | "{count} Active" |
| Row 1, Col 3 | Garments | `Icons.checkroom_outlined` | `Routes.garmentList` | "{count} Types" |
| Row 1, Col 4 | Fabrics | `Icons.texture_outlined` | `Routes.fabricList` | "{count}" |
| Row 2, Col 1 | Designs | `Icons.palette_outlined` | `Routes.designList` | "{count}" |
| Row 2, Col 2 | Notes | `Icons.note_outlined` | `Routes.notesList` | "{count}" |
| Row 2, Col 3 | Statistics | `Icons.bar_chart_outlined` | `Routes.statistics` | "View" |
| Row 2, Col 4 | Settings | `Icons.settings_outlined` | `Routes.settings` | "Configure" |

### 4.3 Quick Action Tile Widget

```dart
class QuickActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: theme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.4 Grid Layout

```dart
GridView.count(
  crossAxisCount: 4,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 0.85,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  children: [
    QuickActionTile(
      label: language.t('newOrder'),
      subtitle: language.t('create'),
      icon: Icons.add_shopping_cart_outlined,
      onTap: () => Navigator.pushNamed(context, Routes.orderWizard),
    ),
    // ... 7 more tiles
  ],
)
```

---

## 5. Activity Feed

### 5.1 Sections

The activity feed is divided into three sections, each collapsible:

1. **Recent Orders** -- Last 5 orders sorted by `created_at` DESC
2. **Upcoming Fittings** -- Orders with `trial_date` in next 7 days
3. **Payment Reminders** -- Orders with `remaining_balance > 0` sorted by urgency

### 5.2 Activity Feed Item

```
┌──────────────────────────────────────────────────────┐
│  [StatusDot] [OrderIcon]  #ICHITO-2026-07-042        │
│                           Jane Muthoni               │
│                           Dress - KES 2,500          │
│                           2 hours ago      [Arrow>]  │
└──────────────────────────────────────────────────────┘
```

```dart
class ActivityFeedItem extends StatelessWidget {
  final Order order;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        Routes.orderDetail,
        arguments: order.id,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Status dot
            StatusDot(status: order.status),
            const SizedBox(width: 12),
            
            // Order icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: theme.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    order.customer?.name ?? '',
                    style: TextStyle(fontSize: 13, color: theme.textSecondary),
                  ),
                  Text(
                    '${order.garment?.name ?? ""} - ${language.formatCurrency(order.totalAmount)}',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Time ago + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimeAgo(order.createdAt),
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
                const SizedBox(height: 4),
                Icon(Icons.arrow_forward, size: 16, color: theme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5.3 Section Header

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 6. Empty States

When there's no data to show (first launch or empty sections):

### 6.1 Dashboard Empty State (No Orders Yet)

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│            [Sewing Machine Icon - 64px]              │
│                                                      │
│            Welcome to ICHITO!                        │
│                                                      │
│     Start by adding your first customer              │
│     and creating your first order.                   │
│                                                      │
│     [Add Customer]  [Create Order]                   │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### 6.2 Empty State Widget

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: theme.onAccent,
                  shape: RoundedRectangleBorder(borderRadius: theme.buttonRadius),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Data Loading

### 7.1 Loading Skeleton

While data loads, show shimmering skeleton placeholders instead of spinners:

```dart
class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.cornerRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 80, height: 14, theme: theme),
          const SizedBox(height: 8),
          _shimmerBox(width: double.infinity, height: 20, theme: theme),
          const SizedBox(height: 4),
          _shimmerBox(width: 120, height: 14, theme: theme),
        ],
      ),
    );
  }
  
  Widget _shimmerBox({required double width, required double height, required ThemeProvider theme}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    // Wrap with shimmer animation controller for the shine effect
  }
}
```

### 7.2 Data Refresh

Pull-to-refresh on the home screen reloads all dashboard data:

```dart
RefreshIndicator(
  color: theme.accentColor,
  backgroundColor: theme.cardColor,
  onRefresh: () async {
    await _loadDashboardData();
  },
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      children: [
        WelcomeHeader(),
        StatsCarousel(stats: _stats),
        QuickActionGrid(counts: _counts),
        ActivityFeed(
          recentOrders: _recentOrders,
          upcomingFittings: _upcomingFittings,
          paymentReminders: _paymentReminders,
        ),
        const SizedBox(height: 80), // Radial menu clearance
      ],
    ),
  ),
)
```

---

## 8. Home Screen Data Requirements

| Data | Source | Query |
|------|--------|-------|
| User name | AppStateProvider | In-memory |
| Notification count | AnalyticsService | Count overdue + upcoming trials + old unpaid |
| Orders this month | OrderRepository | `count(WHERE order_date >= firstOfMonth)` |
| Revenue this month | PaymentRepository | `sum(amount WHERE date >= firstOfMonth)` |
| Active customers this month | OrderRepository | `countDistinct(customer_id WHERE order_date >= firstOfMonth)` |
| Popular garment this month | AnalyticsService | `topGarment(firstOfMonth, now)` |
| Trend percentages | AnalyticsService | Compare current month vs previous month |
| Customer count | CustomerRepository | `count()` |
| Garment count | GarmentRepository | `count()` |
| Fabric count | FabricRepository | `count()` |
| Design count | DesignRepository | `count()` |
| Note count | NoteRepository | `count()` |
| Recent orders (5) | OrderRepository | `getRecentOrders(5)` with customer + garment joins |
| Upcoming fittings | OrderRepository | `getUpcomingTrials(7)` |
| Payment reminders | OrderRepository | `WHERE remaining > 0 ORDER BY due_date` |

---

## 9. Home Screen Lifecycle

```dart
class _HomeScreenState extends State<HomeScreen>
    with ThemeAwareMixin, NavigationMixin {
  
  // Dashboard data
  Map<String, dynamic>? _stats;
  Map<String, int>? _counts;
  List<Order>? _recentOrders;
  List<Order>? _upcomingFittings;
  List<Order>? _paymentReminders;
  int _notificationCount = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final firstOfLastMonth = DateTime(now.year, now.month - 1, 1);
      
      // Load all data in parallel
      final results = await Future.wait([
        _analyticsService.getMonthlyStats(firstOfMonth, now),
        _analyticsService.getMonthlyStats(firstOfLastMonth, firstOfMonth),
        _loadEntityCounts(),
        _orderRepo.getRecentOrders(5),
        _orderRepo.getUpcomingTrials(7),
        _orderRepo.getOrdersWithOutstandingPayments(),
        _analyticsService.getNotificationCount(),
      ]);
      
      setState(() {
        _stats = _buildStatsWithTrend(results[0], results[1]);
        _counts = results[2];
        _recentOrders = results[3];
        _upcomingFittings = results[4];
        _paymentReminders = results[5];
        _notificationCount = results[6];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error snackbar
    }
  }
}
```

---

*This is Document 05 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
