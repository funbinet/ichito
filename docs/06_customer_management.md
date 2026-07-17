# ICHITO -- Customer Management

**Document**: 06 of 14
**Covers**: Customer list (grid/list views), customer detail, add/edit customer, search/filter/sort, loyalty tiers, analytics per customer, measurement templates, photo handling

---

## 1. Customer List Screen

### 1.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Customers                 [+ Add]  [Stats] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search customers...                    │
│                                                      │
│  [All] [Male] [Female] [VIP] [New] [Frequent]       │
│  (horizontal scrollable filter chips)                │
│                                                      │
│  View: [GridIcon | ListIcon]    Sort: [Name v]       │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Avatar] │  │ [Avatar] │  │ [Avatar] │          │
│  │  Jane    │  │  John    │  │  Mary    │          │
│  │ Muthoni  │  │  Smith   │  │ Johnson  │          │
│  │ [Star]5  │  │ [Star]3  │  │ [Star]1  │          │
│  │   VIP    │  │  Loyal   │  │   New    │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Avatar] │  │ [Avatar] │  │ [Avatar] │          │
│  │  Peter   │  │  Grace   │  │  James   │          │
│  │ Ochieng  │  │  Akinyi  │  │ Kariuki  │          │
│  │ [Star]4  │  │ [Star]2  │  │ [Star]1  │          │
│  │  Loyal   │  │ Regular  │  │   New    │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  Total: 89 Customers                                 │
│                                                      │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 1.2 App Bar

```dart
AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text('Customers'),
  actions: [
    IconButton(
      icon: Icon(Icons.add),
      onPressed: () => Navigator.pushNamed(context, Routes.customerForm),
    ),
    IconButton(
      icon: Icon(Icons.bar_chart_outlined),
      onPressed: () => _showCustomerStats(),
    ),
  ],
)
```

### 1.3 Search Bar

```dart
Container(
  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
  child: AdaptiveTextField(
    label: '',
    hint: 'Search by name or phone...',
    prefixIcon: Icons.search,
    onChanged: (query) {
      _debounce(() => _searchCustomers(query));
    },
  ),
)
```

**Search behavior**:
- Debounced by 300ms to avoid excessive queries
- Searches `name` and `phone` fields using LIKE with wildcards
- Results replace the grid/list in real-time
- Shows "No customers found" empty state if no results

### 1.4 Filter Chips

| Filter | Behavior |
|--------|----------|
| All | Show all customers (default) |
| Male | `WHERE gender = 'male'` |
| Female | `WHERE gender = 'female'` |
| VIP | Customers with `totalSpent > 50000` |
| New | Customers with `totalOrders <= 1` |
| Frequent | Customers with `totalOrders >= 5` |

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: filters.map((filter) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(filter.label),
          selected: _activeFilter == filter,
          onSelected: (selected) {
            setState(() => _activeFilter = selected ? filter : FilterType.all);
            _applyFilter();
          },
          selectedColor: theme.accentLight,
          checkmarkColor: theme.accentColor,
          side: BorderSide(
            color: _activeFilter == filter ? theme.accentColor : theme.borderColor,
          ),
          shape: RoundedRectangleBorder(borderRadius: theme.chipRadius),
        ),
      ),
    ).toList(),
  ),
)
```

### 1.5 View Mode Toggle

Toggle between grid (3 columns) and list view. Default is grid (configurable in settings).

```dart
Row(
  children: [
    Text('View:', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
    const SizedBox(width: 8),
    IconButton(
      icon: Icon(
        Icons.grid_view_outlined,
        color: _viewMode == ViewMode.grid ? theme.accentColor : theme.textSecondary,
      ),
      onPressed: () => setState(() => _viewMode = ViewMode.grid),
      iconSize: 20,
    ),
    IconButton(
      icon: Icon(
        Icons.view_list_outlined,
        color: _viewMode == ViewMode.list ? theme.accentColor : theme.textSecondary,
      ),
      onPressed: () => setState(() => _viewMode = ViewMode.list),
      iconSize: 20,
    ),
    const Spacer(),
    // Sort dropdown
    DropdownButton<SortOption>(
      value: _sortOption,
      underline: const SizedBox(),
      style: TextStyle(fontSize: 12, color: theme.textSecondary),
      items: [
        DropdownMenuItem(value: SortOption.name, child: Text('Name')),
        DropdownMenuItem(value: SortOption.orders, child: Text('Orders')),
        DropdownMenuItem(value: SortOption.spent, child: Text('Spent')),
        DropdownMenuItem(value: SortOption.recent, child: Text('Recent')),
      ],
      onChanged: (option) {
        setState(() => _sortOption = option!);
        _applySort();
      },
    ),
  ],
)
```

### 1.6 Customer Grid Card

```dart
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
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
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.accentLight,
              backgroundImage: customer.photoPath != null
                ? FileImage(File(customer.photoPath!))
                : null,
              child: customer.photoPath == null
                ? Text(
                    customer.initials,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              customer.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Orders + loyalty
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outlined, size: 14, color: theme.accentColor),
                const SizedBox(width: 2),
                Text(
                  '${customer.totalOrders}',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Loyalty badge
            LoyaltyBadge(status: customer.loyaltyStatus),
          ],
        ),
      ),
    );
  }
}
```

### 1.7 Customer List Tile (List View)

```dart
class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.accentLight,
              backgroundImage: customer.photoPath != null
                ? FileImage(File(customer.photoPath!)) : null,
              child: customer.photoPath == null
                ? Text(customer.initials,
                    style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold))
                : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: theme.textSecondary),
                      const SizedBox(width: 4),
                      Text(customer.phone,
                        style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            // Loyalty + orders
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LoyaltyBadge(status: customer.loyaltyStatus),
                const SizedBox(height: 4),
                Text('${customer.totalOrders} orders',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 1.8 Loyalty Badge

```dart
class LoyaltyBadge extends StatelessWidget {
  final String status;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    Color badgeColor;
    IconData badgeIcon;
    switch (status) {
      case 'VIP':
        badgeColor = const Color(0xFFFFD700); // Gold
        badgeIcon = Icons.workspace_premium_outlined;
        break;
      case 'Regular':
        badgeColor = const Color(0xFF4CAF50); // Green
        badgeIcon = Icons.star_outlined;
        break;
      case 'Loyal':
        badgeColor = const Color(0xFF2196F3); // Blue
        badgeIcon = Icons.star_outlined;
        break;
      default: // New
        badgeColor = theme.textSecondary;
        badgeIcon = Icons.star_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
```

### 1.9 Long Press Quick Actions

When a customer card is long-pressed, a popup menu appears:

| Action | Icon | Route |
|--------|------|-------|
| View Profile | `Icons.person_outlined` | Navigate to customer detail |
| Call | `Icons.phone_outlined` | Launch phone dialer with customer phone |
| New Order | `Icons.add_shopping_cart_outlined` | Navigate to order wizard with customer pre-selected |
| Edit | `Icons.edit_outlined` | Navigate to customer form with customer data |
| Delete | `Icons.delete_outlined` | Show delete confirmation dialog |

---

## 2. Customer Detail Screen

### 2.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Jane Muthoni          [Edit] [Delete] [Share]│
├─────────────────────────────────────────────────────┤
│  SCROLLABLE CONTENT                                  │
│                                                      │
│  ┌── Profile Header ────────────────────────────────┐│
│  │  [Avatar - 64dp]                                ││
│  │  Jane Muthoni                                   ││
│  │                                                 ││
│  │  [PhoneIcon] 0712 345 678        [Call] [SMS]   ││
│  │  [EmailIcon] jane@email.com      [Email]        ││
│  │  [LocationIcon] Nairobi CBD                     ││
│  │  [GenderIcon] Female  |  5 Orders  |  3 Years   ││
│  │  [LoyaltyBadge: VIP]                           ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Customer Analytics ────────────────────────────┐│
│  │  Total Spent         KES 42,500                 ││
│  │  Average Order       KES 8,500                  ││
│  │  Most Ordered        Dresses (3)                ││
│  │  [WalletIcon]  [ChartIcon]  [CheckroomIcon]    ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Default Measurements ──────────── [Edit] ──────┐│
│  │  ┌────────────┬──────────┐                      ││
│  │  │ Bust       │  92 cm   │                      ││
│  │  │ Waist      │  70 cm   │                      ││
│  │  │ Hip        │  98 cm   │                      ││
│  │  │ Shoulder   │  40 cm   │                      ││
│  │  │ Height     │  165 cm  │                      ││
│  │  └────────────┴──────────┘                      ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Order History (5) ──────────── [View All] ─────┐│
│  │  [StatusDot:Green]  #ICHITO-2026-07-042         ││
│  │  Dress - KES 2,500 - Completed                  ││
│  │  ─────────────────────────────────────────────  ││
│  │  [StatusDot:Yellow] #ICHITO-2026-06-031         ││
│  │  Blouse - KES 1,800 - In Progress               ││
│  │  ─────────────────────────────────────────────  ││
│  │  [StatusDot:Blue]   #ICHITO-2026-05-022         ││
│  │  Skirt - KES 2,200 - Pending                    ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Financial Summary ─────────────────────────────┐│
│  │  Total Billed:    KES 8,500                     ││
│  │  Total Paid:      KES 5,000                     ││
│  │  Outstanding:     KES 3,500                     ││
│  │  [View Payment Details]                         ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Created: 15/01/2024                                │
│  Last Order: 10/07/2026                             │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 2.2 Profile Header Actions

| Action | Icon | Behavior |
|--------|------|----------|
| Call | `Icons.phone_outlined` | Launch dialer with `tel:{phone}` URI |
| SMS | `Icons.sms_outlined` | Launch SMS with `sms:{phone}` URI |
| Email | `Icons.email_outlined` | Launch email with `mailto:{email}` URI |
| Edit | `Icons.edit_outlined` | Navigate to customer form with pre-filled data |
| Delete | `Icons.delete_outlined` | Show confirmation dialog, then delete if no orders |
| Share | `Icons.share_outlined` | Share customer contact info as text |

### 2.3 Measurement Table

```dart
class MeasurementTable extends StatelessWidget {
  final Map<String, double> measurements;
  final String unit; // 'cm' or 'inches'
  final bool editable;
  final ValueChanged<Map<String, double>>? onChanged;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    if (measurements.isEmpty) {
      return EmptyState(
        icon: Icons.straighten_outlined,
        title: 'No Measurements',
        message: 'Default measurements have not been recorded yet.',
        actionLabel: 'Add Measurements',
        onAction: () => _showMeasurementEditor(context),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.borderColor),
        borderRadius: theme.cornerRadius,
      ),
      child: Column(
        children: measurements.entries.map((entry) {
          final isLast = entry.key == measurements.keys.last;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(color: theme.borderColor, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _formatMeasurementName(entry.key),
                  style: TextStyle(fontSize: 14, color: theme.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${entry.value} $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                if (editable) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, size: 16, color: theme.textSecondary),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _formatMeasurementName(String key) {
    // Convert snake_case to Title Case
    return key.split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
```

### 2.4 Data Loading

```dart
Future<void> _loadCustomerData() async {
  final customer = await _customerRepo.getById(widget.customerId);
  if (customer == null) {
    Navigator.pop(context);
    return;
  }
  
  final stats = await _customerRepo.getCustomerStats(widget.customerId);
  final orders = await _orderRepo.getByCustomer(widget.customerId);
  
  setState(() {
    _customer = customer;
    _customer!.totalOrders = stats['total_orders'] ?? 0;
    _customer!.totalSpent = stats['total_spent'] ?? 0;
    _customer!.averageOrderValue = stats['average_order_value'] ?? 0;
    _customer!.lastOrderDate = stats['last_order_date'];
    _customer!.preferredGarments = stats['preferred_garments'] ?? [];
    _orders = orders;
    _isLoading = false;
  });
}
```

---

## 3. Add/Edit Customer Form

### 3.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Close]  Add New Customer           [Save]          │
├─────────────────────────────────────────────────────┤
│  SCROLLABLE CONTENT                                  │
│                                                      │
│           ┌──────────────────┐                       │
│           │   [Camera Icon]  │                       │
│           │   Upload Photo   │                       │
│           │   (optional)     │                       │
│           └──────────────────┘                       │
│                                                      │
│  Full Name *                                         │
│  ┌─────────────────────────────────────────────────┐│
│  │ [PersonIcon]  Jane Muthoni                      ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Phone *                                             │
│  ┌─────────────────────────────────────────────────┐│
│  │ [PhoneIcon]  0712 345 678                       ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Email                                               │
│  ┌─────────────────────────────────────────────────┐│
│  │ [EmailIcon]  jane@email.com                     ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Gender *                                            │
│  [MaleIcon Male]    [FemaleIcon Female]              │
│  (segmented control, one must be selected)           │
│                                                      │
│  Location                                            │
│  ┌─────────────────────────────────────────────────┐│
│  │ [LocationIcon]  Nairobi CBD                     ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ── Default Measurements (Optional) ─────────────── │
│                                                      │
│  ┌────────────────┐  ┌────────────────┐             │
│  │ Height  [   ]  │  │ Bust    [   ]  │             │
│  └────────────────┘  └────────────────┘             │
│  ┌────────────────┐  ┌────────────────┐             │
│  │ Waist   [   ]  │  │ Hip     [   ]  │             │
│  └────────────────┘  └────────────────┘             │
│  ┌────────────────┐  ┌────────────────┐             │
│  │ Shoulder[   ]  │  │ Sleeve  [   ]  │             │
│  └────────────────┘  └────────────────┘             │
│                                                      │
│  (Measurement fields change based on gender:         │
│   Male: height, chest, waist, hip, shoulder, neck    │
│   Female: height, bust, waist, hip, shoulder)        │
│                                                      │
│  ┌─────────────────────────────────────────────────┐│
│  │  [Cancel]              [Save Customer]          ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 3.2 Gender-Specific Measurement Fields

| Gender | Default Measurement Fields |
|--------|--------------------------|
| Male | height, chest, waist, hip, shoulder, neck, sleeve_length |
| Female | height, bust, waist, hip, shoulder, sleeve_length |

When the gender selection changes, the measurement fields update accordingly.

### 3.3 Photo Handling

The photo upload circle:
1. Tap to show image source bottom sheet (Camera / Gallery)
2. After picking, open cropper with 1:1 aspect ratio (square, for circular display)
3. Compress to max 400x400, quality 85
4. Save to `{appDocDir}/images/customers/{uuid}.jpg`
5. Store the path in `customer.photoPath`

If the customer already has a photo (edit mode), show the existing photo with a pencil overlay icon.

### 3.4 Form Validation

| Field | Validation | Error Message |
|-------|-----------|---------------|
| Name | Required, 2-100 chars | "Name is required" / "Name must be at least 2 characters" |
| Phone | Required, Kenyan format | "Phone number is required" / "Enter a valid Kenyan phone number" |
| Email | Optional, valid format | "Enter a valid email address" |
| Gender | Required (one must be selected) | "Please select a gender" |
| Location | Optional, max 200 chars | "Location must be under 200 characters" |
| Measurements | Optional, each > 0 and < 500 | "Enter a valid measurement" / "Measurement seems too large" |

### 3.5 Save Flow

```dart
Future<void> _saveCustomer() async {
  if (!_formKey.currentState!.validate()) return;
  
  // Check for duplicate phone
  final existing = await _customerRepo.findByPhone(_phoneController.text);
  if (existing != null && existing.id != widget.customer?.id) {
    _showError('A customer with this phone number already exists');
    return;
  }
  
  final customer = Customer(
    id: widget.customer?.id,
    name: _nameController.text.trim(),
    phone: _phoneController.text.trim(),
    email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    gender: _selectedGender!,
    location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    photoPath: _photoPath,
    measurements: _measurements,
    createdAt: widget.customer?.createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  if (widget.customer == null) {
    // Create
    await _customerRepo.insert(customer);
    _showSuccess('Customer added successfully');
  } else {
    // Update
    await _customerRepo.update(customer);
    _showSuccess('Customer updated successfully');
  }
  
  Navigator.pop(context, true); // Return true to signal list should refresh
}
```

---

## 4. Loyalty System

### 4.1 Loyalty Tiers

| Tier | Criteria | Badge Color | Icon |
|------|----------|-------------|------|
| **VIP** | Total spent > KES 50,000 | Gold `#FFD700` | `Icons.workspace_premium_outlined` |
| **Regular** | Total spent > KES 20,000 | Green `#4CAF50` | `Icons.star_outlined` |
| **Loyal** | Total orders > 3 | Blue `#2196F3` | `Icons.star_outlined` |
| **New** | Default (none of the above) | Grey `textSecondary` | `Icons.star_outlined` |

Evaluation order: VIP > Regular > Loyal > New. A customer who meets both VIP and Loyal criteria is classified as VIP.

### 4.2 Loyalty Calculation

```dart
String get loyaltyStatus {
  if (totalSpent > 50000) return 'VIP';
  if (totalSpent > 20000) return 'Regular';
  if (totalOrders > 3) return 'Loyal';
  return 'New';
}
```

### 4.3 Customer Statistics Widget

On the customer detail screen, show a summary card:

```dart
class CustomerAnalyticsCard extends StatelessWidget {
  final Customer customer;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return AdaptiveCard(
      child: Column(
        children: [
          _StatRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Spent',
            value: language.formatCurrency(customer.totalSpent),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.bar_chart_outlined,
            label: 'Average Order',
            value: language.formatCurrency(customer.averageOrderValue),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.checkroom_outlined,
            label: 'Most Ordered',
            value: customer.preferredGarments.isNotEmpty
              ? '${customer.preferredGarments.first} (${customer.totalOrders})'
              : 'N/A',
            theme: theme,
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Measurement Intelligence

### 5.1 Auto-Suggest from History

When creating a new order for an existing customer, the measurement step can auto-fill from:

1. **Customer's default measurements** (stored in customer profile)
2. **Most recent order measurements** for the same garment type
3. **Manual entry** (always available)

Priority: Most recent same-garment > Customer defaults > Empty

### 5.2 Measurement Comparison

If measurements differ significantly (>20%) from the customer's stored defaults, show a warning:

```
[WarningIcon] This waist measurement (38 cm) differs significantly
from the customer's default (32 cm). Continue?
```

### 5.3 Updating Defaults

After completing an order, offer to update the customer's default measurements:

```
"Update Jane Muthoni's default measurements with the
measurements from this order?"
[Keep Current]  [Update Defaults]
```

---

## 6. Customer Deletion Rules

### 6.1 Deletion Conditions

| Condition | Behavior |
|-----------|----------|
| Customer has no orders | Delete immediately after confirmation |
| Customer has completed orders only | Warn that order history will be affected, require double confirmation |
| Customer has active orders (pending/in_progress/trial) | **BLOCKED** -- show error: "Cannot delete a customer with active orders. Complete or cancel all orders first." |

### 6.2 Deletion Cascade

When a customer is deleted:
1. Customer record removed from `customers` table
2. Customer photo file deleted from disk (if exists)
3. All order records referencing this customer become orphaned (RESTRICT prevents this -- deletion is blocked if orders exist)

### 6.3 Confirmation Dialog

```dart
showDialog(
  context: context,
  builder: (context) => AdaptiveDialog(
    title: 'Delete Customer',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Are you sure you want to delete ${customer.name}?'),
        const SizedBox(height: 8),
        Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: Text('Delete'),
      ),
    ],
  ),
);
```

---

## 7. Customer Stats Overlay

Tapping the stats icon on the customer list app bar shows aggregate customer statistics:

```
┌─────────────────────────────────────────────────────┐
│  Customer Overview                                   │
│                                                      │
│  Total Customers:     89                             │
│  Male:                42  |  Female: 47              │
│  VIP:                 8                              │
│  Regular:             15                             │
│  Loyal:               22                             │
│  New:                 44                             │
│                                                      │
│  Average Orders/Customer:  3.2                       │
│  Average Spend/Customer:   KES 12,500                │
│                                                      │
│  Most Active Customer:  Jane Muthoni (5 orders)      │
│  Top Spender:           Peter Ochieng (KES 65,000)   │
│                                                      │
│  [Close]                                             │
└─────────────────────────────────────────────────────┘
```

---

*This is Document 06 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
