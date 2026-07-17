# ICHITO -- Data Models & Database

**Document**: 02 of 14
**Covers**: All entity models with complete field specs, SQLite schema DDL, relationships, foreign keys, indexes, migrations, seed data, CRUD operations, data integrity constraints

---

## 1. Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│   Customer   │       │    Order     │       │   Garment    │
│──────────────│       │──────────────│       │──────────────│
│ id (PK)      │◄──1:N─┤ customer_id  │  N:1──►│ id (PK)      │
│ name         │       │ garment_id   ├───────►│ name         │
│ phone        │       │ fabric_id    │       │ category     │
│ email        │       │ design_id    │       │ measurements │
│ gender       │       │ status       │       └──────────────┘
│ location     │       │ total_amount │
│ photo_path   │       │ paid_amount  │       ┌──────────────┐
│ measurements │       │ due_date     │  N:1──►│   Fabric     │
│ created_at   │       │ trial_date   ├───────►│──────────────│
│ updated_at   │       │ measurements │       │ id (PK)      │
└──────────────┘       │ notes        │       │ name         │
                       │ created_at   │       │ price_per_unit│
                       │ updated_at   │       │ category     │
                       └──────┬───────┘       │ image_path   │
                              │               └──────────────┘
                              │
                         1:N  │               ┌──────────────┐
                              │          N:1──►│   Design     │
                       ┌──────┴───────┐       │──────────────│
                       │   Payment    │       │ id (PK)      │
                       │──────────────│       │ name         │
                       │ id (PK)      │       │ category     │
                       │ order_id     │       │ image_path   │
                       │ amount       │       └──────────────┘
                       │ date         │
                       │ method       │       ┌──────────────┐
                       │ notes        │       │    Note      │
                       └──────────────┘       │──────────────│
                                              │ id (PK)      │
┌──────────────────┐                          │ title        │
│ OrderStatusLog   │                          │ content      │
│──────────────────│                          │ type         │
│ id (PK)          │                          │ speaker      │
│ order_id (FK)    │                          │ bible_verses │
│ from_status      │                          │ meeting_date │
│ to_status        │                          │ members      │
│ changed_at       │                          │ contributions│
│ notes            │                          │ recipient    │
└──────────────────┘                          └──────────────┘
```

---

## 2. Complete Data Models

### 2.1 Customer Model

```dart
class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String gender;             // 'male' | 'female'
  final String? location;
  final String? photoPath;
  final Map<String, double> measurements;  // Key: measurement name, Value: value in cm
  final DateTime createdAt;
  final DateTime updatedAt;

  // --- Computed (not stored, calculated from orders) ---
  int totalOrders;                 // Count of related orders
  double totalSpent;               // Sum of all order total_amounts
  double averageOrderValue;        // totalSpent / totalOrders
  DateTime? lastOrderDate;         // Most recent order date
  List<String> preferredGarments;  // Top 3 garment names by frequency
  List<String> preferredFabrics;   // Top 3 fabric names by frequency

  String get loyaltyStatus {
    if (totalSpent > 50000) return 'VIP';
    if (totalSpent > 20000) return 'Regular';
    if (totalOrders > 3) return 'Loyal';
    return 'New';
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  // Serialization
  Map<String, dynamic> toMap() { /* ... */ }
  factory Customer.fromMap(Map<String, dynamic> map) { /* ... */ }
  Customer copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `name` | `String` | Yes | 2-100 characters, not empty |
| `phone` | `String` | Yes | Valid Kenyan format: `(+254|0)\d{9}` |
| `email` | `String?` | No | Valid email format if provided |
| `gender` | `String` | Yes | Enum: `'male'` or `'female'` |
| `location` | `String?` | No | Max 200 characters |
| `photoPath` | `String?` | No | Absolute file path to compressed JPEG |
| `measurements` | `Map<String, double>` | No | Stored as JSON string. Values > 0, < 500 |
| `createdAt` | `DateTime` | Auto | Set on insert, ISO 8601 string in SQLite |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

### 2.2 Order Model

```dart
class Order {
  final int? id;
  final String orderNumber;        // Auto: ICHITO-YYYY-MM-XXX
  final int customerId;
  final int garmentId;
  final int? fabricId;
  final int? designId;
  final DateTime orderDate;
  final DateTime dueDate;
  final DateTime? trialDate;
  final String status;             // 'pending' | 'in_progress' | 'trial' | 'completed' | 'cancelled'
  final double totalAmount;
  final double paidAmount;         // Sum of all payments
  final Map<String, double> measurements;  // Snapshot of measurements at order time
  final String? notes;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  // --- Computed ---
  double get remainingBalance => totalAmount - paidAmount;
  bool get isFullyPaid => remainingBalance <= 0;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != 'completed' && status != 'cancelled';
  
  int get daysUntilDue {
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff;
  }
  
  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'trial': return 'Trial/Fitting';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  // Relationships (loaded separately)
  Customer? customer;
  Garment? garment;
  Fabric? fabric;
  Design? design;
  List<Payment> payments;
  List<OrderStatusLog> statusHistory;

  Map<String, dynamic> toMap() { /* ... */ }
  factory Order.fromMap(Map<String, dynamic> map) { /* ... */ }
  Order copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `orderNumber` | `String` | Auto | Format: `ICHITO-YYYY-MM-XXX`, unique |
| `customerId` | `int` | Yes | FK to customers.id, must exist |
| `garmentId` | `int` | Yes | FK to garments.id, must exist |
| `fabricId` | `int?` | No | FK to fabrics.id if selected |
| `designId` | `int?` | No | FK to designs.id if selected |
| `orderDate` | `DateTime` | Auto | Defaults to now on creation |
| `dueDate` | `DateTime` | Yes | Must be after orderDate |
| `trialDate` | `DateTime?` | No | Must be between orderDate and dueDate if set |
| `status` | `String` | Yes | Enum: `pending`, `in_progress`, `trial`, `completed`, `cancelled` |
| `totalAmount` | `double` | Yes | Must be > 0 |
| `paidAmount` | `double` | Auto | Calculated from sum of payments, >= 0 |
| `measurements` | `Map<String, double>` | Yes | JSON string, all values > 0 |
| `notes` | `String?` | No | Max 1000 characters |
| `specialInstructions` | `String?` | No | Max 500 characters |
| `createdAt` | `DateTime` | Auto | Set on insert |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

### 2.3 Garment Model

```dart
class Garment {
  final int? id;
  final String name;
  final String? description;
  final String category;           // 'men' | 'women' | 'unisex'
  final List<String> measurementFields;  // e.g., ['waist', 'inseam', 'hip', 'thigh', 'knee', 'length']
  final double? defaultPrice;
  final String? imagePath;
  final int usageCount;            // How many orders use this garment
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() { /* ... */ }
  factory Garment.fromMap(Map<String, dynamic> map) { /* ... */ }
  Garment copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `name` | `String` | Yes | 2-100 characters, unique within category |
| `description` | `String?` | No | Max 500 characters |
| `category` | `String` | Yes | Enum: `'men'`, `'women'`, `'unisex'` |
| `measurementFields` | `List<String>` | Yes | JSON array, at least 1 field |
| `defaultPrice` | `double?` | No | Must be > 0 if provided |
| `imagePath` | `String?` | No | Absolute file path |
| `usageCount` | `int` | Auto | Incremented when used in orders, >= 0 |
| `createdAt` | `DateTime` | Auto | Set on insert |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

**Default Measurement Fields by Garment**:

| Garment | Category | Measurement Fields |
|---------|----------|-------------------|
| Trousers | Men | waist, inseam, hip, thigh, knee, length |
| Shirt | Men | neck, chest, shoulder, sleeve_length, shirt_length |
| Jacket | Men | chest, shoulder, sleeve_length, jacket_length, waist, back_width |
| Blazer | Men | chest, shoulder, sleeve_length, blazer_length, waist |
| Vest | Men | chest, shoulder, vest_length, waist |
| Shorts | Men | waist, hip, thigh, shorts_length |
| Suit | Men | chest, shoulder, sleeve_length, jacket_length, waist, inseam, trouser_length |
| Dress | Women | bust, waist, hip, shoulder, dress_length |
| Blouse | Women | bust, waist, shoulder, sleeve_length |
| Skirt | Women | waist, hip, skirt_length, knee |
| Gown | Women | bust, waist, hip, shoulder, gown_length, sleeve_length |
| Jumpsuit | Women | bust, waist, hip, inseam, shoulder |
| Kitenge Dress | Women | bust, waist, hip, shoulder, dress_length, sleeve_length |

### 2.4 Fabric Model

```dart
class Fabric {
  final int? id;
  final String name;
  final String? description;
  final double pricePerUnit;
  final String unit;               // 'meter' | 'foot' | 'yard'
  final String? category;         // 'cotton' | 'silk' | 'synthetic' | 'linen' | 'wool' | 'denim' | 'polyester' | 'other'
  final String? color;
  final String? imagePath;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get priceDisplay => 'KES ${pricePerUnit.toStringAsFixed(0)}/${unit}';

  Map<String, dynamic> toMap() { /* ... */ }
  factory Fabric.fromMap(Map<String, dynamic> map) { /* ... */ }
  Fabric copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `name` | `String` | Yes | 2-100 characters |
| `description` | `String?` | No | Max 500 characters |
| `pricePerUnit` | `double` | Yes | Must be > 0 |
| `unit` | `String` | Yes | Enum: `'meter'`, `'foot'`, `'yard'` |
| `category` | `String?` | No | Enum set |
| `color` | `String?` | No | Hex color string (e.g., `#FF5733`) |
| `imagePath` | `String?` | No | Absolute file path |
| `usageCount` | `int` | Auto | >= 0 |
| `createdAt` | `DateTime` | Auto | Set on insert |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

### 2.5 Design Model

```dart
class Design {
  final int? id;
  final String name;
  final String? description;
  final String? category;          // 'floral' | 'geometric' | 'abstract' | 'african' | 'modern' | 'vintage' | 'traditional' | 'other'
  final String? imagePath;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() { /* ... */ }
  factory Design.fromMap(Map<String, dynamic> map) { /* ... */ }
  Design copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `name` | `String` | Yes | 2-100 characters |
| `description` | `String?` | No | Max 500 characters |
| `category` | `String?` | No | Enum set |
| `imagePath` | `String?` | No | Absolute file path |
| `usageCount` | `int` | Auto | >= 0 |
| `createdAt` | `DateTime` | Auto | Set on insert |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

### 2.6 Note Model

```dart
class Note {
  final int? id;
  final String title;
  final String content;
  final String type;               // 'normal' | 'church' | 'chama'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Church-specific fields (null for other types)
  final String? speaker;
  final List<String>? bibleVerses;

  // Chama-specific fields (null for other types)
  final DateTime? meetingDate;
  final List<String>? members;
  final Map<String, double>? contributions;  // Key: member name, Value: amount
  final double? totalCollected;
  final double? expectedTotal;
  final String? recipient;

  // Computed
  double? get shortfall {
    if (expectedTotal == null || totalCollected == null) return null;
    final diff = expectedTotal! - totalCollected!;
    return diff > 0 ? diff : 0;
  }

  bool get isChurchNote => type == 'church';
  bool get isChamaNote => type == 'chama';
  bool get isNormalNote => type == 'normal';

  Map<String, dynamic> toMap() { /* ... */ }
  factory Note.fromMap(Map<String, dynamic> map) { /* ... */ }
  Note copyWith({ /* all fields */ }) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `title` | `String` | Yes* | *Auto-generated as date/time for normal notes if left empty |
| `content` | `String` | Yes | Min 1 character |
| `type` | `String` | Yes | Enum: `'normal'`, `'church'`, `'chama'` |
| `speaker` | `String?` | Church only | Required for church notes, max 100 chars |
| `bibleVerses` | `List<String>?` | No | JSON array, each verse max 50 chars |
| `meetingDate` | `DateTime?` | Chama only | Required for chama notes |
| `members` | `List<String>?` | Chama only | JSON array of member names |
| `contributions` | `Map<String, double>?` | Chama only | JSON map, values >= 0 |
| `totalCollected` | `double?` | Chama auto | Sum of contributions |
| `expectedTotal` | `double?` | Chama only | Expected total >= totalCollected |
| `recipient` | `String?` | No | Name of the chama round recipient |
| `createdAt` | `DateTime` | Auto | Set on insert |
| `updatedAt` | `DateTime` | Auto | Set on insert and update |

### 2.7 Payment Model

```dart
class Payment {
  final int? id;
  final int orderId;
  final double amount;
  final DateTime date;
  final String method;             // 'cash' | 'mpesa' | 'bank'
  final String? notes;
  final DateTime createdAt;

  String get methodDisplay {
    switch (method) {
      case 'cash': return 'Cash';
      case 'mpesa': return 'M-Pesa';
      case 'bank': return 'Bank Transfer';
      default: return method;
    }
  }

  Map<String, dynamic> toMap() { /* ... */ }
  factory Payment.fromMap(Map<String, dynamic> map) { /* ... */ }
}
```

**Field Constraints**:

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `int?` | Auto | Auto-increment primary key |
| `orderId` | `int` | Yes | FK to orders.id, must exist |
| `amount` | `double` | Yes | Must be > 0 |
| `date` | `DateTime` | Yes | Cannot be in the future |
| `method` | `String` | Yes | Enum: `'cash'`, `'mpesa'`, `'bank'` |
| `notes` | `String?` | No | Max 500 characters |
| `createdAt` | `DateTime` | Auto | Set on insert |

### 2.8 OrderStatusLog Model

```dart
class OrderStatusLog {
  final int? id;
  final int orderId;
  final String fromStatus;
  final String toStatus;
  final DateTime changedAt;
  final String? notes;

  Map<String, dynamic> toMap() { /* ... */ }
  factory OrderStatusLog.fromMap(Map<String, dynamic> map) { /* ... */ }
}
```

---

## 3. SQLite Schema (DDL)

### 3.1 Database Configuration

```dart
// Database name and version
static const String _databaseName = 'ichito.db';
static const int _databaseVersion = 1;
```

### 3.2 Table Definitions

```sql
-- =====================================================
-- CUSTOMERS TABLE
-- =====================================================
CREATE TABLE customers (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  phone           TEXT    NOT NULL,
  email           TEXT,
  gender          TEXT    NOT NULL CHECK (gender IN ('male', 'female')),
  location        TEXT,
  photo_path      TEXT,
  measurements    TEXT    DEFAULT '{}',   -- JSON map
  created_at      TEXT    NOT NULL,       -- ISO 8601
  updated_at      TEXT    NOT NULL        -- ISO 8601
);

CREATE INDEX idx_customers_name ON customers(name);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_gender ON customers(gender);
CREATE INDEX idx_customers_created_at ON customers(created_at);

-- =====================================================
-- GARMENTS TABLE
-- =====================================================
CREATE TABLE garments (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  name                TEXT    NOT NULL,
  description         TEXT,
  category            TEXT    NOT NULL CHECK (category IN ('men', 'women', 'unisex')),
  measurement_fields  TEXT    NOT NULL DEFAULT '[]',  -- JSON array of strings
  default_price       REAL,
  image_path          TEXT,
  usage_count         INTEGER NOT NULL DEFAULT 0,
  created_at          TEXT    NOT NULL,
  updated_at          TEXT    NOT NULL
);

CREATE INDEX idx_garments_category ON garments(category);
CREATE INDEX idx_garments_name ON garments(name);
CREATE INDEX idx_garments_usage_count ON garments(usage_count DESC);

-- =====================================================
-- FABRICS TABLE
-- =====================================================
CREATE TABLE fabrics (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  description     TEXT,
  price_per_unit  REAL    NOT NULL CHECK (price_per_unit > 0),
  unit            TEXT    NOT NULL CHECK (unit IN ('meter', 'foot', 'yard')),
  category        TEXT,
  color           TEXT,
  image_path      TEXT,
  usage_count     INTEGER NOT NULL DEFAULT 0,
  created_at      TEXT    NOT NULL,
  updated_at      TEXT    NOT NULL
);

CREATE INDEX idx_fabrics_name ON fabrics(name);
CREATE INDEX idx_fabrics_category ON fabrics(category);
CREATE INDEX idx_fabrics_price ON fabrics(price_per_unit);

-- =====================================================
-- DESIGNS TABLE
-- =====================================================
CREATE TABLE designs (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  description     TEXT,
  category        TEXT,
  image_path      TEXT,
  usage_count     INTEGER NOT NULL DEFAULT 0,
  created_at      TEXT    NOT NULL,
  updated_at      TEXT    NOT NULL
);

CREATE INDEX idx_designs_name ON designs(name);
CREATE INDEX idx_designs_category ON designs(category);
CREATE INDEX idx_designs_usage_count ON designs(usage_count DESC);

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE orders (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  order_number          TEXT    NOT NULL UNIQUE,
  customer_id           INTEGER NOT NULL,
  garment_id            INTEGER NOT NULL,
  fabric_id             INTEGER,
  design_id             INTEGER,
  order_date            TEXT    NOT NULL,
  due_date              TEXT    NOT NULL,
  trial_date            TEXT,
  status                TEXT    NOT NULL DEFAULT 'pending'
                                CHECK (status IN ('pending', 'in_progress', 'trial', 'completed', 'cancelled')),
  total_amount          REAL    NOT NULL CHECK (total_amount > 0),
  paid_amount           REAL    NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  measurements          TEXT    NOT NULL DEFAULT '{}',  -- JSON map
  notes                 TEXT,
  special_instructions  TEXT,
  created_at            TEXT    NOT NULL,
  updated_at            TEXT    NOT NULL,

  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
  FOREIGN KEY (garment_id)  REFERENCES garments(id)  ON DELETE RESTRICT,
  FOREIGN KEY (fabric_id)   REFERENCES fabrics(id)   ON DELETE SET NULL,
  FOREIGN KEY (design_id)   REFERENCES designs(id)   ON DELETE SET NULL
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_due_date ON orders(due_date);
CREATE INDEX idx_orders_order_date ON orders(order_date DESC);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_garment_id ON orders(garment_id);

-- =====================================================
-- PAYMENTS TABLE
-- =====================================================
CREATE TABLE payments (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id    INTEGER NOT NULL,
  amount      REAL    NOT NULL CHECK (amount > 0),
  date        TEXT    NOT NULL,
  method      TEXT    NOT NULL CHECK (method IN ('cash', 'mpesa', 'bank')),
  notes       TEXT,
  created_at  TEXT    NOT NULL,

  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_date ON payments(date DESC);
CREATE INDEX idx_payments_method ON payments(method);

-- =====================================================
-- ORDER STATUS LOG TABLE
-- =====================================================
CREATE TABLE order_status_log (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id    INTEGER NOT NULL,
  from_status TEXT    NOT NULL,
  to_status   TEXT    NOT NULL,
  changed_at  TEXT    NOT NULL,
  notes       TEXT,

  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX idx_status_log_order_id ON order_status_log(order_id);

-- =====================================================
-- NOTES TABLE
-- =====================================================
CREATE TABLE notes (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  title           TEXT    NOT NULL,
  content         TEXT    NOT NULL DEFAULT '',
  type            TEXT    NOT NULL CHECK (type IN ('normal', 'church', 'chama')),
  speaker         TEXT,
  bible_verses    TEXT,             -- JSON array of strings
  meeting_date    TEXT,
  members         TEXT,             -- JSON array of strings
  contributions   TEXT,             -- JSON map: name -> amount
  total_collected REAL,
  expected_total  REAL,
  recipient       TEXT,
  created_at      TEXT    NOT NULL,
  updated_at      TEXT    NOT NULL
);

CREATE INDEX idx_notes_type ON notes(type);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);

-- =====================================================
-- SETTINGS TABLE (Key-Value Store in SQLite)
-- =====================================================
CREATE TABLE settings (
  key   TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
);
```

### 3.3 Trigger for Paid Amount Sync

```sql
-- Automatically update orders.paid_amount when payments change
CREATE TRIGGER update_paid_amount_on_insert
AFTER INSERT ON payments
BEGIN
  UPDATE orders
  SET paid_amount = (
    SELECT COALESCE(SUM(amount), 0)
    FROM payments
    WHERE order_id = NEW.order_id
  ),
  updated_at = datetime('now')
  WHERE id = NEW.order_id;
END;

CREATE TRIGGER update_paid_amount_on_delete
AFTER DELETE ON payments
BEGIN
  UPDATE orders
  SET paid_amount = (
    SELECT COALESCE(SUM(amount), 0)
    FROM payments
    WHERE order_id = OLD.order_id
  ),
  updated_at = datetime('now')
  WHERE id = OLD.order_id;
END;

-- Automatically increment garment/fabric/design usage_count when order is created
CREATE TRIGGER increment_garment_usage
AFTER INSERT ON orders
BEGIN
  UPDATE garments SET usage_count = usage_count + 1 WHERE id = NEW.garment_id;
  UPDATE fabrics SET usage_count = usage_count + 1 WHERE id = NEW.fabric_id AND NEW.fabric_id IS NOT NULL;
  UPDATE designs SET usage_count = usage_count + 1 WHERE id = NEW.design_id AND NEW.design_id IS NOT NULL;
END;
```

---

## 4. Foreign Key Relationships

| Parent Table | Child Table | FK Column | On Delete | On Update |
|-------------|-------------|-----------|-----------|-----------|
| `customers` | `orders` | `customer_id` | RESTRICT | CASCADE |
| `garments` | `orders` | `garment_id` | RESTRICT | CASCADE |
| `fabrics` | `orders` | `fabric_id` | SET NULL | CASCADE |
| `designs` | `orders` | `design_id` | SET NULL | CASCADE |
| `orders` | `payments` | `order_id` | CASCADE | CASCADE |
| `orders` | `order_status_log` | `order_id` | CASCADE | CASCADE |

**RESTRICT** means: You cannot delete a customer or garment that has orders referencing it. The user must first reassign or delete those orders.

**SET NULL** means: If a fabric or design is deleted, existing orders retain their data but the FK becomes NULL.

**CASCADE** on payments: If an order is deleted, all its payments are also deleted.

---

## 5. Database Initialization

```dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, 'ichito.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key enforcement
    await db.execute('PRAGMA foreign_keys = ON');
    // Enable WAL mode for better concurrent read performance
    await db.execute('PRAGMA journal_mode = WAL');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Execute all CREATE TABLE statements
    await db.execute(createCustomersTable);
    await db.execute(createGarmentsTable);
    await db.execute(createFabricsTable);
    await db.execute(createDesignsTable);
    await db.execute(createOrdersTable);
    await db.execute(createPaymentsTable);
    await db.execute(createOrderStatusLogTable);
    await db.execute(createNotesTable);
    await db.execute(createSettingsTable);

    // Create all indexes
    await _createIndexes(db);

    // Create triggers
    await _createTriggers(db);

    // Seed default garments
    await _seedDefaultGarments(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic for future schema changes
    // Each version bump adds migration steps
    if (oldVersion < 2) {
      // await _migrateV1ToV2(db);
    }
  }
}
```

---

## 6. Seed Data -- Default Garments

The app ships with pre-configured garment types so users can start immediately:

```dart
Future<void> _seedDefaultGarments(Database db) async {
  final defaultGarments = [
    // Men's Garments
    {
      'name': 'Trousers',
      'category': 'men',
      'measurement_fields': '["waist","inseam","hip","thigh","knee","length"]',
      'default_price': 2000.0,
    },
    {
      'name': 'Shirt',
      'category': 'men',
      'measurement_fields': '["neck","chest","shoulder","sleeve_length","shirt_length"]',
      'default_price': 1500.0,
    },
    {
      'name': 'Jacket',
      'category': 'men',
      'measurement_fields': '["chest","shoulder","sleeve_length","jacket_length","waist","back_width"]',
      'default_price': 5000.0,
    },
    {
      'name': 'Blazer',
      'category': 'men',
      'measurement_fields': '["chest","shoulder","sleeve_length","blazer_length","waist"]',
      'default_price': 4500.0,
    },
    {
      'name': 'Vest',
      'category': 'men',
      'measurement_fields': '["chest","shoulder","vest_length","waist"]',
      'default_price': 2000.0,
    },
    {
      'name': 'Shorts',
      'category': 'men',
      'measurement_fields': '["waist","hip","thigh","shorts_length"]',
      'default_price': 1200.0,
    },
    {
      'name': 'Suit (Full)',
      'category': 'men',
      'measurement_fields': '["chest","shoulder","sleeve_length","jacket_length","waist","inseam","trouser_length"]',
      'default_price': 8000.0,
    },
    // Women's Garments
    {
      'name': 'Dress',
      'category': 'women',
      'measurement_fields': '["bust","waist","hip","shoulder","dress_length"]',
      'default_price': 2500.0,
    },
    {
      'name': 'Blouse',
      'category': 'women',
      'measurement_fields': '["bust","waist","shoulder","sleeve_length"]',
      'default_price': 1800.0,
    },
    {
      'name': 'Skirt',
      'category': 'women',
      'measurement_fields': '["waist","hip","skirt_length","knee"]',
      'default_price': 1500.0,
    },
    {
      'name': 'Gown',
      'category': 'women',
      'measurement_fields': '["bust","waist","hip","shoulder","gown_length","sleeve_length"]',
      'default_price': 6000.0,
    },
    {
      'name': 'Jumpsuit',
      'category': 'women',
      'measurement_fields': '["bust","waist","hip","inseam","shoulder"]',
      'default_price': 3500.0,
    },
    {
      'name': 'Kitenge Dress',
      'category': 'women',
      'measurement_fields': '["bust","waist","hip","shoulder","dress_length","sleeve_length"]',
      'default_price': 3000.0,
    },
  ];

  final batch = db.batch();
  final now = DateTime.now().toIso8601String();
  for (final garment in defaultGarments) {
    batch.insert('garments', {
      ...garment,
      'usage_count': 0,
      'created_at': now,
      'updated_at': now,
    });
  }
  await batch.commit(noResult: true);
}
```

---

## 7. Repository Methods

### 7.1 CustomerRepository

| Method | Signature | SQL Operation | Description |
|--------|-----------|---------------|-------------|
| `insert` | `Future<int> insert(Customer customer)` | `INSERT INTO customers` | Create new customer, return ID |
| `update` | `Future<int> update(Customer customer)` | `UPDATE customers SET ... WHERE id = ?` | Update customer, return affected rows |
| `delete` | `Future<int> delete(int id)` | `DELETE FROM customers WHERE id = ?` | Delete customer (fails if orders exist) |
| `getById` | `Future<Customer?> getById(int id)` | `SELECT * FROM customers WHERE id = ?` | Get single customer with computed stats |
| `getAll` | `Future<List<Customer>> getAll({...})` | `SELECT * FROM customers ORDER BY ...` | Get paginated, sorted customer list |
| `search` | `Future<List<Customer>> search(String query)` | `WHERE name LIKE ? OR phone LIKE ?` | Search by name or phone |
| `getByGender` | `Future<List<Customer>> getByGender(String gender)` | `WHERE gender = ?` | Filter by gender |
| `getVIPCustomers` | `Future<List<Customer>> getVIPCustomers()` | Complex query with order totals | Customers with totalSpent > 50000 |
| `getFrequentCustomers` | `Future<List<Customer>> getFrequentCustomers(int minOrders)` | `HAVING COUNT(orders.id) >= ?` | Customers with N+ orders |
| `getRecentCustomers` | `Future<List<Customer>> getRecentCustomers(int limit)` | `ORDER BY (last order date) DESC LIMIT ?` | Recently active customers |
| `count` | `Future<int> count()` | `SELECT COUNT(*) FROM customers` | Total customer count |
| `getCustomerStats` | `Future<Map<String, dynamic>> getCustomerStats(int id)` | JOIN with orders, payments | Full analytics for one customer |

### 7.2 OrderRepository

| Method | Signature | SQL Operation | Description |
|--------|-----------|---------------|-------------|
| `insert` | `Future<int> insert(Order order)` | `INSERT INTO orders` + status log | Create order with initial status log |
| `update` | `Future<int> update(Order order)` | `UPDATE orders SET ...` | Update order details |
| `delete` | `Future<int> delete(int id)` | `DELETE FROM orders WHERE id = ?` | Delete order (cascades to payments) |
| `getById` | `Future<Order?> getById(int id)` | Join with customer, garment, fabric, design | Full order with relationships |
| `getAll` | `Future<List<Order>> getAll({...})` | `SELECT * FROM orders ORDER BY ...` | Paginated order list |
| `getByStatus` | `Future<List<Order>> getByStatus(String status)` | `WHERE status = ?` | Filter by status |
| `getByCustomer` | `Future<List<Order>> getByCustomer(int customerId)` | `WHERE customer_id = ?` | Orders for specific customer |
| `getOverdue` | `Future<List<Order>> getOverdue()` | `WHERE due_date < ? AND status NOT IN (...)` | Orders past due date |
| `getUpcomingTrials` | `Future<List<Order>> getUpcomingTrials(int days)` | `WHERE trial_date BETWEEN ? AND ?` | Trials in next N days |
| `updateStatus` | `Future<void> updateStatus(int id, String newStatus, {String? notes})` | `UPDATE` + `INSERT` status log | Change status with audit trail |
| `search` | `Future<List<Order>> search(String query)` | Join search on order#, customer name | Search across order data |
| `getNextOrderNumber` | `Future<String> getNextOrderNumber()` | `SELECT MAX(...)` | Generate next ICHITO-YYYY-MM-XXX |
| `count` | `Future<int> count({String? status})` | `SELECT COUNT(*)` | Count with optional status filter |
| `getRecentOrders` | `Future<List<Order>> getRecentOrders(int limit)` | `ORDER BY created_at DESC LIMIT ?` | Most recent orders |

### 7.3 PaymentRepository

| Method | Signature | SQL Operation | Description |
|--------|-----------|---------------|-------------|
| `insert` | `Future<int> insert(Payment payment)` | `INSERT INTO payments` | Add payment (trigger updates order) |
| `delete` | `Future<int> delete(int id)` | `DELETE FROM payments WHERE id = ?` | Remove payment |
| `getByOrder` | `Future<List<Payment>> getByOrder(int orderId)` | `WHERE order_id = ? ORDER BY date DESC` | All payments for an order |
| `getTotalPaid` | `Future<double> getTotalPaid(int orderId)` | `SELECT SUM(amount)` | Sum of payments for order |
| `getByMethod` | `Future<List<Payment>> getByMethod(String method, DateTime start, DateTime end)` | `WHERE method = ? AND date BETWEEN` | Payments by method in period |
| `getRevenueForPeriod` | `Future<double> getRevenueForPeriod(DateTime start, DateTime end)` | `SELECT SUM(amount) WHERE date BETWEEN` | Total revenue in date range |

### 7.4 GarmentRepository, FabricRepository, DesignRepository

These follow the same pattern as CustomerRepository with standard CRUD + search + sort + filter by category + count. Each also has:

| Method | Description |
|--------|-------------|
| `getByCategory(String category)` | Filter by men/women/unisex (garments) or fabric/design category |
| `getMostUsed(int limit)` | Top N by usage_count |
| `incrementUsageCount(int id)` | Bump usage counter (also done by trigger) |

### 7.5 NoteRepository

| Method | Signature | Description |
|--------|-----------|-------------|
| `insert` | `Future<int> insert(Note note)` | Create note |
| `update` | `Future<int> update(Note note)` | Update note |
| `delete` | `Future<int> delete(int id)` | Delete note |
| `getById` | `Future<Note?> getById(int id)` | Get single note |
| `getAll` | `Future<List<Note>> getAll({String? type})` | All notes, optionally filtered by type |
| `getByType` | `Future<List<Note>> getByType(String type)` | Filter by normal/church/chama |
| `search` | `Future<List<Note>> search(String query)` | Search title and content |
| `count` | `Future<int> count({String? type})` | Count with optional type filter |

---

## 8. Order Number Generation

```dart
class IdGenerator {
  static Future<String> generateOrderNumber(Database db) async {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final prefix = 'ICHITO-$year-$month-';

    // Find the highest existing number for this month
    final result = await db.rawQuery(
      "SELECT order_number FROM orders "
      "WHERE order_number LIKE ? "
      "ORDER BY order_number DESC LIMIT 1",
      ['$prefix%'],
    );

    int nextNumber = 1;
    if (result.isNotEmpty) {
      final lastNumber = result.first['order_number'] as String;
      final lastSeq = int.tryParse(lastNumber.split('-').last) ?? 0;
      nextNumber = lastSeq + 1;
    }

    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }
}
```

---

## 9. Order Status State Machine

```
                    ┌────────────┐
                    │  PENDING   │
                    │ (initial)  │
                    └─────┬──────┘
                          │
              ┌───────────┼───────────┐
              │           │           │
              ▼           │           ▼
      ┌──────────────┐   │   ┌──────────────┐
      │ IN_PROGRESS  │   │   │  CANCELLED   │
      │              │   │   │  (terminal)  │
      └──────┬───────┘   │   └──────────────┘
             │           │           ▲
             ▼           │           │
      ┌──────────────┐   │           │
      │    TRIAL     │   │           │
      │  (fitting)   │───┘───────────┘
      └──────┬───────┘
             │
             ▼
      ┌──────────────┐
      │  COMPLETED   │
      │  (terminal)  │
      └──────────────┘
```

**Valid Transitions**:

| From | To | Conditions |
|------|----|------------|
| `pending` | `in_progress` | Work has started |
| `pending` | `cancelled` | Order cancelled before work starts |
| `in_progress` | `trial` | Ready for fitting |
| `in_progress` | `completed` | No trial needed, work finished |
| `in_progress` | `cancelled` | Order cancelled mid-work |
| `trial` | `in_progress` | Adjustments needed after fitting |
| `trial` | `completed` | Fitting approved, order done |
| `trial` | `cancelled` | Customer rejects after fitting |

**Invalid Transitions** (throw error):
- `completed` to any status (terminal state)
- `cancelled` to any status (terminal state)
- `pending` to `trial` (must go through `in_progress` first)
- `pending` to `completed` (must go through `in_progress` first)

---

## 10. Data Integrity Rules

### 10.1 Cascade Rules

| Action | Rule |
|--------|------|
| Delete customer with orders | **BLOCKED** -- must delete/reassign orders first |
| Delete garment used in orders | **BLOCKED** -- must delete orders using it first |
| Delete fabric used in orders | **ALLOWED** -- fabric_id set to NULL in orders |
| Delete design used in orders | **ALLOWED** -- design_id set to NULL in orders |
| Delete order | **CASCADES** -- all payments and status logs for that order are deleted |
| Delete payment | **ALLOWED** -- triggers update of order.paid_amount |

### 10.2 Validation on Insert/Update

| Entity | Rule |
|--------|------|
| Customer | Phone must be unique (no duplicate phone numbers) |
| Customer | Name must be 2+ characters |
| Order | total_amount must be > 0 |
| Order | due_date must be >= order_date |
| Order | trial_date (if set) must be >= order_date and <= due_date |
| Order | Status change must follow valid transitions |
| Payment | amount must be > 0 |
| Payment | Sum of payments for an order should not exceed total_amount (warn, don't block) |
| Garment | measurement_fields must have at least 1 field |
| Fabric | price_per_unit must be > 0 |
| Note (church) | speaker field required |
| Note (chama) | meeting_date required |

### 10.3 Soft Warnings (Not Blocking)

| Scenario | Warning Message |
|----------|----------------|
| Payment exceeds remaining balance | "This payment will result in an overpayment of KES X" |
| Measurement value differs >20% from customer default | "This measurement differs significantly from the customer's saved defaults" |
| Due date is less than 2 days from now | "The due date is very close. Are you sure?" |
| Customer has no phone number format match | "Phone number doesn't match expected Kenyan format" |

---

## 11. Database Migration Strategy

### Migration Principles
1. Each migration is a sequential version bump (v1 -> v2 -> v3)
2. Migrations are idempotent -- running the same migration twice has no effect
3. Migrations never delete user data
4. New columns added with DEFAULT values so existing rows are valid

### Migration Template

```dart
Future<void> _migrateV1ToV2(Database db) async {
  // Example: Adding a 'priority' column to orders
  await db.execute('ALTER TABLE orders ADD COLUMN priority TEXT DEFAULT "normal"');
  
  // Example: Creating a new table
  await db.execute('CREATE TABLE IF NOT EXISTS tags (...)');
  
  // Example: Creating a new index
  await db.execute('CREATE INDEX IF NOT EXISTS idx_orders_priority ON orders(priority)');
}
```

---

## 12. Query Patterns

### 12.1 Customer with Computed Analytics

```sql
SELECT
  c.*,
  COUNT(o.id) as total_orders,
  COALESCE(SUM(o.total_amount), 0) as total_spent,
  CASE
    WHEN COUNT(o.id) > 0
    THEN COALESCE(SUM(o.total_amount), 0) / COUNT(o.id)
    ELSE 0
  END as average_order_value,
  MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE c.id = ?
GROUP BY c.id;
```

### 12.2 Dashboard Statistics

```sql
-- Orders this month
SELECT COUNT(*) as count
FROM orders
WHERE order_date >= ? AND order_date < ?;

-- Revenue this month
SELECT COALESCE(SUM(amount), 0) as revenue
FROM payments
WHERE date >= ? AND date < ?;

-- Active customers this month
SELECT COUNT(DISTINCT customer_id) as active
FROM orders
WHERE order_date >= ? AND order_date < ?;

-- Popular garment this month
SELECT g.name, COUNT(o.id) as order_count
FROM orders o
JOIN garments g ON g.id = o.garment_id
WHERE o.order_date >= ? AND o.order_date < ?
GROUP BY g.id
ORDER BY order_count DESC
LIMIT 1;
```

### 12.3 Unified Search

```sql
-- Search across customers, orders, garments, fabrics, designs, notes
-- Return results with entity type and relevance info

-- Customers matching
SELECT 'customer' as entity_type, id, name as title, phone as subtitle
FROM customers
WHERE name LIKE ? OR phone LIKE ?

UNION ALL

-- Orders matching
SELECT 'order' as entity_type, o.id, o.order_number as title, c.name as subtitle
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.order_number LIKE ? OR c.name LIKE ?

UNION ALL

-- Garments matching
SELECT 'garment' as entity_type, id, name as title, category as subtitle
FROM garments
WHERE name LIKE ?

UNION ALL

-- Fabrics matching
SELECT 'fabric' as entity_type, id, name as title, category as subtitle
FROM fabrics
WHERE name LIKE ?

UNION ALL

-- Notes matching
SELECT 'note' as entity_type, id, title, SUBSTR(content, 1, 50) as subtitle
FROM notes
WHERE title LIKE ? OR content LIKE ?

ORDER BY title
LIMIT 20;
```

---

## 13. Backup & Restore

### Backup Process
1. Close active database connections
2. Copy `ichito.db` file to user-selected location or `{appDocDir}/backups/`
3. Copy entire `images/` directory alongside the database
4. Generate a manifest JSON with backup metadata:
   ```json
   {
     "app_version": "1.0.0",
     "backup_date": "2026-07-18T00:00:00Z",
     "database_version": 1,
     "customer_count": 89,
     "order_count": 142,
     "total_size_bytes": 45000000
   }
   ```
5. Optionally compress into a single `.ichito_backup` file (ZIP format)

### Restore Process
1. Verify backup manifest compatibility (database version)
2. Close active database
3. Replace current `ichito.db` with backup
4. Replace `images/` directory with backup images
5. Reinitialize database connections
6. Reload all providers

**See**: [Settings & Preferences](10_settings_and_preferences.md) -- Storage Management section.

---

*This is Document 02 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
