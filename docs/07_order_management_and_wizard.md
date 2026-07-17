# ICHITO -- Order Management & Wizard

**Document**: 07 of 14
**Covers**: Complete 6-step order creation wizard, order list, order detail, status lifecycle state machine, payment tracking, payment history, order editing, cancellation, validation rules

---

## 1. Order List Screen

### 1.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Orders                 [+ New] [FilterIcon] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search orders...                       │
│                                                      │
│  [All] [Pending] [In Progress] [Trial] [Completed]  │
│  [Cancelled] [Overdue]                               │
│  (horizontal scrollable filter chips)                │
│                                                      │
│  Sort: [Date v] [Due v] [Amount v] [Status v]       │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │ [StatusDot:Yellow]                               ││
│  │ #ICHITO-2026-07-042           KES 4,000          ││
│  │ Jane Muthoni - Trousers      In Progress         ││
│  │ Due: 25/07/2026              Paid: KES 1,000     ││
│  │                              Remaining: KES 3,000││
│  └──────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────┐│
│  │ [StatusDot:Blue]                                 ││
│  │ #ICHITO-2026-07-041           KES 2,500          ││
│  │ John Smith - Dress            Pending             ││
│  │ Due: 20/07/2026              Paid: KES 500       ││
│  │                              Remaining: KES 2,000││
│  └──────────────────────────────────────────────────┘│
│  ┌──────────────────────────────────────────────────┐│
│  │ [StatusDot:Red]                                  ││
│  │ #ICHITO-2026-07-040           KES 3,200          ││
│  │ Mary Johnson - Blouse         OVERDUE             ││
│  │ Due: 15/07/2026              Paid: KES 0         ││
│  │                              Remaining: KES 3,200││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Total: 47 Orders                                    │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 1.2 Order Card Widget

```dart
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: order.isOverdue
            ? Border.all(color: const Color(0xFFF44336), width: 1)
            : Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            // Top row: status dot, order number, amount
            Row(
              children: [
                StatusDot(status: order.isOverdue ? 'overdue' : order.status),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  language.formatCurrency(order.totalAmount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Middle row: customer, garment, status
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.customer?.name ?? "Unknown"} - ${order.garment?.name ?? "Unknown"}',
                    style: TextStyle(fontSize: 13, color: theme.textSecondary),
                  ),
                ),
                StatusBadge(
                  label: order.isOverdue ? 'OVERDUE' : order.statusDisplay,
                  status: order.isOverdue ? 'overdue' : order.status,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom row: due date, payment info
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: theme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Due: ${language.formatDate(order.dueDate)}',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
                const Spacer(),
                Text(
                  'Remaining: ${language.formatCurrency(order.remainingBalance)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: order.isFullyPaid
                      ? const Color(0xFF4CAF50)
                      : order.remainingBalance > 0
                        ? const Color(0xFFF44336)
                        : theme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 1.3 Status Badge Widget

```dart
class StatusBadge extends StatelessWidget {
  final String label;
  final String status;
  
  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return const Color(0xFF4CAF50);
      case 'in_progress': return const Color(0xFFFFC107);
      case 'pending': return const Color(0xFF2196F3);
      case 'trial': return const Color(0xFF2196F3);
      case 'cancelled': return const Color(0xFF9E9E9E);
      case 'overdue': return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }
}
```

### 1.4 Filter Options

| Filter | Query |
|--------|-------|
| All | No filter |
| Pending | `WHERE status = 'pending'` |
| In Progress | `WHERE status = 'in_progress'` |
| Trial | `WHERE status = 'trial'` |
| Completed | `WHERE status = 'completed'` |
| Cancelled | `WHERE status = 'cancelled'` |
| Overdue | `WHERE due_date < date('now') AND status NOT IN ('completed', 'cancelled')` |

### 1.5 Sort Options

| Sort | Query |
|------|-------|
| Date (newest) | `ORDER BY created_at DESC` (default) |
| Due date | `ORDER BY due_date ASC` |
| Amount | `ORDER BY total_amount DESC` |
| Status | `ORDER BY CASE status WHEN 'pending' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'trial' THEN 3 WHEN 'completed' THEN 4 WHEN 'cancelled' THEN 5 END` |

### 1.6 Swipe Actions

Left swipe on an order card reveals:
- **Change Status** (`Icons.sync_outlined`) -- Show status change options
- **Add Payment** (`Icons.payments_outlined`) -- Open add payment dialog
- **View** (`Icons.visibility_outlined`) -- Navigate to order detail

---

## 2. Order Creation Wizard (6 Steps)

### 2.1 Wizard Overview

The order wizard is a multi-step form using `PageView` with controlled navigation. The user progresses through 6 sequential steps.

**See**: [Navigation & Routing](03_navigation_and_routing.md) -- Section 8 for wizard navigation implementation.

### 2.2 Step 1: Client Selection

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 1/6      │
│  [========================================-----] 17% │
│                                                      │
│  Step 1: Select Client                               │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search by name or phone...             │
│                                                      │
│  [Recent] [All] [Frequent] [VIP]                    │
│  (filter tabs)                                       │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  [Avatar] Jane Muthoni                          ││
│  │           [PhoneIcon] 0712 345 678              ││
│  │           [StarIcon] 5 orders  |  VIP Client    ││
│  │           Last order: 10/07/2026                ││
│  │                                    [CheckIcon]  ││
│  ├──────────────────────────────────────────────────┤│
│  │  [Avatar] John Smith                            ││
│  │           [PhoneIcon] 0723 456 789              ││
│  │           [StarIcon] 3 orders  |  Loyal Client  ││
│  │           Last order: 05/07/2026                ││
│  ├──────────────────────────────────────────────────┤│
│  │  [Avatar] Mary Johnson                          ││
│  │           [PhoneIcon] 0734 567 890              ││
│  │           [StarIcon] 1 order   |  New Client    ││
│  │           Last order: 01/07/2026                ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [+ Add New Client]                                  │
│                                                      │
│  Selected: Jane Muthoni  [CheckCircleIcon]           │
├─────────────────────────────────────────────────────┤
│                                  [Next Step ->]      │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Search filters the list in real-time (debounced 300ms)
- Filter tabs: Recent (last 30 days), All, Frequent (5+ orders), VIP
- Tap a customer to select (highlight with accent border + check icon)
- "Add New Client" opens customer form as a bottom sheet; on save, auto-selects the new customer
- "Next" button enabled only when a customer is selected

**Data**: Load customers with computed stats (totalOrders, loyaltyStatus, lastOrderDate)

### 2.3 Step 2: Garment Selection

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 2/6      │
│  [===========================================--] 33% │
│                                                      │
│  Step 2: Select Garment                              │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search garments...                     │
│                                                      │
│  [MaleIcon Men]  [FemaleIcon Women]  [All]          │
│  (Auto-selects based on customer gender)             │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Icon]   │  │ [Icon]   │  │ [Icon]   │          │
│  │ Trousers │  │ Shirt    │  │ Jacket   │          │
│  │ 6 meas.  │  │ 5 meas.  │  │ 6 meas.  │          │
│  │ Men      │  │ Men      │  │ Men      │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Icon]   │  │ [Icon]   │  │ [Icon]   │          │
│  │ Blazer   │  │ Vest     │  │ Shorts   │          │
│  │ 5 meas.  │  │ 4 meas.  │  │ 4 meas.  │          │
│  │ Men      │  │ Men      │  │ Men      │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  [+ Add New Garment]                                 │
│                                                      │
│  Selected: Trousers  [CheckCircleIcon]               │
├─────────────────────────────────────────────────────┤
│  [<- Back]                       [Next Step ->]      │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Auto-filters garments based on selected customer's gender
- Shows garment name, measurement count, and category
- Selected garment highlighted with accent border
- "Add New Garment" opens garment form dialog; on save, auto-selects
- Icon for all garments: `Icons.checkroom_outlined`

### 2.4 Step 3: Measurements

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 3/6      │
│  [======================================-------] 50% │
│                                                      │
│  Step 3: Enter Measurements                          │
├─────────────────────────────────────────────────────┤
│  [CheckroomIcon] Trousers (Men)                      │
│  [RulerIcon] Unit: [cm v]     [Load Default]        │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  Waist          [    32    ] cm                  ││
│  │  ────────────────────────────────────────────    ││
│  │  Inseam         [    34    ] cm                  ││
│  │  ────────────────────────────────────────────    ││
│  │  Hip            [    38    ] cm                  ││
│  │  ────────────────────────────────────────────    ││
│  │  Thigh          [    24    ] cm                  ││
│  │  ────────────────────────────────────────────    ││
│  │  Knee           [    16    ] cm                  ││
│  │  ────────────────────────────────────────────    ││
│  │  Length          [    40    ] cm                  ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Notes:                                              │
│  ┌──────────────────────────────────────────────────┐│
│  │  Loose fit at waist...                          ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [Save as Default for Client]  [Save as Template]    │
├─────────────────────────────────────────────────────┤
│  [<- Back]                       [Next Step ->]      │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Measurement fields are dynamically generated based on selected garment's `measurementFields`
- "Load Default" button loads customer's saved measurements (if they exist for this garment type)
- If the customer has previous orders for the same garment type, offer to load those measurements
- Unit toggle switches between cm and inches (conversion: 1 inch = 2.54 cm)
- Each field validates: required, numeric, > 0, < 500
- "Save as Default for Client" updates the customer's `measurements` map
- Notes field for special fitting instructions

**Measurement Intelligence**:
- If customer has saved defaults, pre-fill fields and show a subtle indicator: "Loaded from customer defaults"
- If measurements differ >20% from saved defaults, show a warning badge next to the field
- Numeric keyboard for all measurement inputs

### 2.5 Step 4: Materials Selection

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 4/6      │
│  [==========================================---] 67% │
│                                                      │
│  Step 4: Select Materials                            │
├─────────────────────────────────────────────────────┤
│  Fabric (Select one or more)                         │
│  [SearchIcon] Search fabrics...                      │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │ Cotton   │  │ Silk     │  │ Denim    │          │
│  │ KES 500  │  │ KES 1200 │  │ KES 800  │          │
│  │ [Check]  │  │          │  │          │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  [+ Add New Fabric]                                  │
│                                                      │
│  ─────────────────────────────────────────────────── │
│                                                      │
│  Design (Select one - optional)                      │
│  [SearchIcon] Search designs...                      │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ [Image]  │  │ [Image]  │  │ [Image]  │          │
│  │ Floral   │  │Geometric │  │ Abstract │          │
│  │ [Check]  │  │          │  │          │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  [+ Add New Design]                                  │
├─────────────────────────────────────────────────────┤
│  [<- Back]                       [Next Step ->]      │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Fabric and design selections are optional (can proceed without)
- Fabric cards show image (if available), name, price per unit
- Selected items have accent border + check overlay
- "Add New" buttons open respective form dialogs inline
- Search filters the grid in real-time

### 2.6 Step 5: Pricing & Details

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 5/6      │
│  [============================================-] 83% │
│                                                      │
│  Step 5: Pricing & Details                           │
├─────────────────────────────────────────────────────┤
│  [WalletIcon] Financial Summary                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  Fabric Cost:    [    2,500    ] KES  [EditIcon] ││
│  │  Labor Cost:     [    1,500    ] KES  [EditIcon] ││
│  │  ─────────────────────────────────────────────── ││
│  │  Total:          KES 4,000                      ││
│  │  Deposit:        [    1,000    ] KES  [EditIcon] ││
│  │  ─────────────────────────────────────────────── ││
│  │  Remaining:      KES 3,000                      ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [CalendarIcon] Due Date *                           │
│  ┌──────────────────────────────────────────────────┐│
│  │  25/07/2026                      [CalendarIcon] ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [EventIcon] Trial Date (optional)                   │
│  ┌──────────────────────────────────────────────────┐│
│  │  22/07/2026                      [CalendarIcon] ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  [NoteIcon] Special Instructions                     │
│  ┌──────────────────────────────────────────────────┐│
│  │  Pleats at front, belt loops...                 ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
├─────────────────────────────────────────────────────┤
│  [<- Back]                       [Next Step ->]      │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Fabric cost auto-populated from selected fabric price (editable)
- Labor cost defaults from settings `defaultLaborCost` (editable)
- Total = Fabric Cost + Labor Cost (auto-calculated)
- Deposit (optional) -- if entered, creates initial payment on order creation
- Remaining = Total - Deposit (auto-calculated, displayed only)
- Due date required, opens date picker, must be >= today
- Trial date optional, must be >= today and <= due date
- Special instructions is a multi-line text field (max 500 chars)

**Validation**:
- Total amount must be > 0
- Due date must be set
- If deposit > total, show warning: "Deposit exceeds total amount"

### 2.7 Step 6: Review & Confirm

```
┌─────────────────────────────────────────────────────┐
│  [Close]  New Order              Progress: 6/6      │
│  [================================================] 100%│
│                                                      │
│  Step 6: Review Order                                │
├─────────────────────────────────────────────────────┤
│  ┌── Client Information ──────────── [EditIcon] ────┐│
│  │  Name: Jane Muthoni                             ││
│  │  Phone: 0712 345 678                            ││
│  │  Email: jane@email.com                          ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Garment & Measurements ──────── [EditIcon] ────┐│
│  │  Type: Trousers (Men)                           ││
│  │  Waist: 32cm  Inseam: 34cm  Hip: 38cm          ││
│  │  Thigh: 24cm  Knee: 16cm   Length: 40cm         ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Materials ───────────────────── [EditIcon] ────┐│
│  │  Fabric: Cotton Print                           ││
│  │  Design: Floral Dress Design                    ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Financial Summary ──────────── [EditIcon] ─────┐│
│  │  Total: KES 4,000   Deposit: KES 1,000          ││
│  │  Remaining: KES 3,000                           ││
│  │  Due: 25/07/2026   Trial: 22/07/2026            ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
├─────────────────────────────────────────────────────┤
│  [DiscardIcon Discard]      [CheckIcon Create Order] │
└─────────────────────────────────────────────────────┘
```

**Behavior**:
- Read-only summary of all data from steps 1-5
- Each section has an [EditIcon] that navigates back to the corresponding step
- "Discard" shows confirmation dialog, then returns to home
- "Create Order" performs the creation flow

### 2.8 Order Creation Flow

```dart
Future<void> _createOrder() async {
  setState(() => _isCreating = true);
  
  try {
    // 1. Generate order number
    final orderNumber = await IdGenerator.generateOrderNumber(db);
    
    // 2. Create order
    final order = Order(
      orderNumber: orderNumber,
      customerId: _selectedCustomer!.id!,
      garmentId: _selectedGarment!.id!,
      fabricId: _selectedFabric?.id,
      designId: _selectedDesign?.id,
      orderDate: DateTime.now(),
      dueDate: _dueDate!,
      trialDate: _trialDate,
      status: 'pending',
      totalAmount: _totalAmount,
      paidAmount: 0,
      measurements: _measurements,
      notes: _notes,
      specialInstructions: _specialInstructions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final orderId = await _orderRepo.insert(order);
    
    // 3. Create initial payment (deposit) if provided
    if (_depositAmount > 0) {
      final payment = Payment(
        orderId: orderId,
        amount: _depositAmount,
        date: DateTime.now(),
        method: 'cash', // Default, user can change later
        notes: 'Initial deposit',
        createdAt: DateTime.now(),
      );
      await _paymentRepo.insert(payment);
    }
    
    // 4. Log initial status
    await _statusLogRepo.insert(OrderStatusLog(
      orderId: orderId,
      fromStatus: '',
      toStatus: 'pending',
      changedAt: DateTime.now(),
      notes: 'Order created',
    ));
    
    // 5. Optionally update customer's default measurements
    // (already handled if user clicked "Save as Default" in step 3)
    
    // 6. Show success dialog
    final action = await _showSuccessDialog(orderId, orderNumber);
    
    if (action == 'view') {
      Navigator.pushReplacementNamed(context, Routes.orderDetail, arguments: orderId);
    } else {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  } catch (e) {
    setState(() => _isCreating = false);
    _showError('Failed to create order: $e');
  }
}
```

### 2.9 Success Dialog

```
┌─────────────────────────────────────────────────────┐
│  Order Created!                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│           [CheckCircleIcon - 64px, green]            │
│                                                      │
│  Order #ICHITO-2026-07-042 has been                  │
│  created successfully!                               │
│                                                      │
│  Order Summary:                                      │
│  Client: Jane Muthoni                                │
│  Garment: Trousers (Men)                            │
│  Total: KES 4,000                                   │
│  Due: 25/07/2026                                    │
│                                                      │
│  [View Order]            [Create Another]            │
└─────────────────────────────────────────────────────┘
```

---

## 3. Order Detail Screen

### 3.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Order #ICHITO-2026-07-042   [Edit] [Delete]│
│  Status: In Progress [StatusBadge]                   │
│  [HourglassIcon] Due in 3 days                      │
│  [WalletIcon] Remaining: KES 3,000                   │
├─────────────────────────────────────────────────────┤
│  SCROLLABLE CONTENT                                  │
│                                                      │
│  ┌── Status Timeline ───────────────────────────────┐│
│  │  [DotFilled] Pending     15/07/2026 10:30        ││
│  │  |                                               ││
│  │  [DotFilled] In Progress 16/07/2026 09:00        ││
│  │  |                                               ││
│  │  [DotEmpty]  Trial       (Scheduled: 22/07)      ││
│  │  |                                               ││
│  │  [DotEmpty]  Completed   --                      ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  [Change Status: v]                                  │
│                                                      │
│  ┌── Client Information ──── [PhoneIcon] [SMSIcon] ─┐│
│  │  Name: Jane Muthoni                             ││
│  │  Phone: 0712 345 678                            ││
│  │  Email: jane@email.com                          ││
│  │  Location: Nairobi CBD                          ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Garment Details ──────── [EditIcon] ───────────┐│
│  │  Type: Trousers (Men)                           ││
│  │  Category: Casual Wear                          ││
│  │  Measurements:                                  ││
│  │  Waist: 32cm  Inseam: 34cm  Hip: 38cm          ││
│  │  Thigh: 24cm  Knee: 16cm   Length: 40cm         ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Materials ─────────────────────────────────────┐│
│  │  Fabric: Cotton Print                           ││
│  │  Design: Floral Dress Design                    ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  ┌── Payment Tracking ──────── [+ Add Payment] ────┐│
│  │  Total: KES 4,000                              ││
│  │  Paid:  KES 1,000                              ││
│  │  Remaining: KES 3,000                           ││
│  │  ────────────────────────────────────────────── ││
│  │  Payment History:                               ││
│  │  [CheckCircle] 15/07/2026 - KES 1,000          ││
│  │                Cash - "Initial deposit"          ││
│  │  ────────────────────────────────────────────── ││
│  │  [Mark as Fully Paid]                           ││
│  └─────────────────────────────────────────────────┘│
│                                                      │
│  Created: 15/07/2026 10:30 AM                        │
│  Notes: Loose fit at waist...                        │
│  Special Instructions: Pleats at front, belt loops   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 3.2 Status Timeline Widget

```dart
class StatusTimeline extends StatelessWidget {
  final List<OrderStatusLog> statusHistory;
  final String currentStatus;
  final DateTime? trialDate;
  
  // Renders a vertical timeline with dots and lines
  // Filled dots for past statuses, empty dots for future
  // Shows timestamp next to each filled dot
}
```

### 3.3 Status Change

Tapping "Change Status" shows a dropdown/bottom sheet with valid next statuses:

```dart
void _showStatusChangeOptions() {
  final validTransitions = _getValidTransitions(order.status);
  
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Change Status', style: headingStyle()),
          ...validTransitions.map((status) => ListTile(
            leading: StatusDot(status: status),
            title: Text(_statusDisplayName(status)),
            onTap: () {
              Navigator.pop(context);
              _confirmStatusChange(status);
            },
          )),
        ],
      ),
    ),
  );
}
```

**See**: [Data Models & Database](02_data_models_and_database.md) -- Section 9 for the complete state machine.

---

## 4. Payment Tracking

### 4.1 Add Payment Dialog

```
┌─────────────────────────────────────────────────────┐
│  Add Payment                                         │
├─────────────────────────────────────────────────────┤
│  Amount *                                            │
│  ┌──────────────────────────────────────────────────┐│
│  │ [PaymentIcon]  1,000                    KES     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Date *                                              │
│  ┌──────────────────────────────────────────────────┐│
│  │  15/07/2026                      [CalendarIcon] ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Payment Method *                                    │
│  [MoneyIcon Cash]  [PhoneIcon M-Pesa]  [BankIcon Bank]│
│  (segmented control, one must be selected)           │
│                                                      │
│  Notes                                               │
│  ┌──────────────────────────────────────────────────┐│
│  │  Deposit payment...                             ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Remaining after payment: KES 2,000                  │
│  (auto-calculated: current remaining - entered amount)│
│                                                      │
│  [Cancel]                         [Add Payment]      │
└─────────────────────────────────────────────────────┘
```

**Validation**:
- Amount required, > 0
- Date required, cannot be in the future
- Payment method required (one of cash/mpesa/bank)
- If amount > remaining: show warning "This payment exceeds the remaining balance by KES X. The order will show as overpaid."

### 4.2 Mark as Fully Paid

Shortcut that creates a payment for the exact remaining balance:

```dart
void _markAsFullyPaid() {
  showDialog(
    context: context,
    builder: (context) => AdaptiveDialog(
      title: 'Mark as Fully Paid',
      content: Text(
        'This will record a payment of ${language.formatCurrency(order.remainingBalance)}. '
        'Which payment method was used?',
      ),
      actions: [
        TextButton(onPressed: () => _recordFullPayment('cash'), child: Text('Cash')),
        TextButton(onPressed: () => _recordFullPayment('mpesa'), child: Text('M-Pesa')),
        TextButton(onPressed: () => _recordFullPayment('bank'), child: Text('Bank')),
      ],
    ),
  );
}
```

### 4.3 Payment History List

```dart
class PaymentHistoryList extends StatelessWidget {
  final List<Payment> payments;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final language = Provider.of<LanguageProvider>(context);
    
    return Column(
      children: payments.map((payment) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.check_circle_outlined, size: 16, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${language.formatDate(payment.date)} - ${language.formatCurrency(payment.amount)}',
                    style: TextStyle(fontSize: 13, color: theme.textPrimary),
                  ),
                  Text(
                    '${payment.methodDisplay}${payment.notes != null ? " - ${payment.notes}" : ""}',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
            // Delete payment button
            IconButton(
              icon: Icon(Icons.delete_outlined, size: 18, color: theme.textSecondary),
              onPressed: () => _confirmDeletePayment(payment),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
```

---

## 5. Order Editing

### 5.1 What Can Be Edited

| Field | Editable When | Conditions |
|-------|--------------|------------|
| Measurements | Any non-terminal status | Always |
| Notes | Any non-terminal status | Always |
| Special instructions | Any non-terminal status | Always |
| Due date | Any non-terminal status | Must be >= today |
| Trial date | Any non-terminal status | Must be between today and due date |
| Total amount | Any non-terminal status | Must be >= paid amount |
| Fabric | Any non-terminal status | Pick from fabric list |
| Design | Any non-terminal status | Pick from design list |
| Customer | **Never** | Cannot change after creation |
| Garment | **Never** | Cannot change after creation |
| Status | Via status change only | Must follow valid transitions |

### 5.2 Edit Flow

Tapping [Edit] on the order detail screen opens an edit form pre-filled with current values. Only editable fields are shown. Saving updates the order and refreshes the detail screen.

---

## 6. Order Deletion

### 6.1 Deletion Rules

| Condition | Behavior |
|-----------|----------|
| Order has payments | Warn: "This order has X payments totaling KES Y. Deleting will remove all payment records." |
| Order is completed | Warn: "This order has been completed. Are you sure you want to delete it?" |
| Order is pending (no payments) | Simple confirmation |

### 6.2 Deletion Cascade

When an order is deleted:
1. All payments for this order are deleted (FK CASCADE)
2. All status log entries are deleted (FK CASCADE)
3. Garment, fabric, design usage counts are NOT decremented (they represent historical usage)
4. Order record removed

---

## 7. Order Notifications

### 7.1 Upcoming Due Date

Orders due within 3 days appear in the dashboard's "Payment Reminders" section with a warning indicator.

### 7.2 Upcoming Trial

Orders with a trial date within 2 days appear in the dashboard's "Upcoming Fittings" section.

### 7.3 Overdue Orders

Orders past their due date that are not completed/cancelled are highlighted in red throughout the app:
- Red border on order cards in the list
- "OVERDUE" status badge instead of normal status
- Red text for remaining balance
- Appear in notification bell count

---

*This is Document 07 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
