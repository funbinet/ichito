import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ichito.db');
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        gender TEXT NOT NULL,
        role TEXT DEFAULT 'regular',
        location TEXT,
        photo_path TEXT,
        measurements TEXT, -- JSON
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Garments Table
    await db.execute('''
      CREATE TABLE garments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        measurement_fields TEXT NOT NULL, -- JSON array
        default_price REAL,
        usage_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Fabrics Table
    await db.execute('''
      CREATE TABLE fabrics (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price_per_unit REAL NOT NULL,
        unit TEXT NOT NULL,
        category TEXT,
        color TEXT,
        image_path TEXT,
        usage_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 4. Designs Table
    await db.execute('''
      CREATE TABLE designs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        image_path TEXT,
        usage_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 5. Orders Table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL UNIQUE,
        customer_id TEXT NOT NULL,
        garment_id TEXT NOT NULL,
        fabric_id TEXT,
        design_id TEXT,
        order_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        trial_date TEXT,
        status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        measurements TEXT NOT NULL, -- JSON
        notes TEXT,
        special_instructions TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE RESTRICT,
        FOREIGN KEY (garment_id) REFERENCES garments (id) ON DELETE RESTRICT,
        FOREIGN KEY (fabric_id) REFERENCES fabrics (id) ON DELETE SET NULL,
        FOREIGN KEY (design_id) REFERENCES designs (id) ON DELETE SET NULL
      )
    ''');

    // 6. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        method TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // 7. Order Status Logs Table
    await db.execute('''
      CREATE TABLE order_status_logs (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        from_status TEXT NOT NULL,
        to_status TEXT NOT NULL,
        changed_at TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // 8. Notes Table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        type TEXT NOT NULL,
        speaker TEXT,
        bible_verses TEXT, -- JSON array
        meeting_date TEXT,
        members TEXT, -- JSON array
        contributions TEXT, -- JSON map
        total_collected REAL,
        expected_total REAL,
        recipient TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 9. App Settings Table (key-value store, replaces Hive)
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // 10. Business Profile Table (single row)
    await db.execute('''
      CREATE TABLE business_profile (
        id INTEGER PRIMARY KEY DEFAULT 1,
        business_name TEXT NOT NULL DEFAULT '',
        owner_name TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT '',
        email TEXT DEFAULT '',
        location TEXT DEFAULT '',
        default_labor_cost REAL DEFAULT 1500.0,
        profile_photo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 11. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        action TEXT NOT NULL DEFAULT 'Unknown',
        reference_id TEXT,
        client_id TEXT,
        order_id TEXT,
        client_name TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Triggers for auto-updating usage_count
    await _createTriggers(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for v2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS business_profile (
          id INTEGER PRIMARY KEY DEFAULT 1,
          business_name TEXT NOT NULL DEFAULT '',
          owner_name TEXT NOT NULL DEFAULT '',
          phone TEXT NOT NULL DEFAULT '',
          email TEXT DEFAULT '',
          location TEXT DEFAULT '',
          default_labor_cost REAL DEFAULT 1500.0,
          profile_photo TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          type TEXT NOT NULL,
          reference_id TEXT,
          is_read INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      // For existing users upgrading from v1, mark onboarding as complete
      // since they already went through it. Also set sensible defaults.
      await db.insert('app_settings', {'key': 'onboardingComplete', 'value': '1'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.insert('app_settings', {'key': 'themeMode', 'value': 'amoledDark'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.insert('app_settings', {'key': 'language', 'value': 'english'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.insert('app_settings', {'key': 'currency', 'value': 'KES'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.insert('app_settings', {'key': 'measurementUnit', 'value': 'cm'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await db.insert('app_settings', {'key': 'dateFormat', 'value': 'DD/MM/YYYY'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE customers ADD COLUMN role TEXT DEFAULT "regular"');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE notifications ADD COLUMN action TEXT DEFAULT "Unknown"');
      await db.execute('ALTER TABLE notifications ADD COLUMN client_id TEXT');
      await db.execute('ALTER TABLE notifications ADD COLUMN order_id TEXT');
      await db.execute('ALTER TABLE notifications ADD COLUMN client_name TEXT');
    }
  }

  Future _createTriggers(Database db) async {
    await db.execute('''
      CREATE TRIGGER increment_garment_usage AFTER INSERT ON orders
      BEGIN
        UPDATE garments SET usage_count = usage_count + 1 WHERE id = NEW.garment_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER increment_fabric_usage AFTER INSERT ON orders
      WHEN NEW.fabric_id IS NOT NULL
      BEGIN
        UPDATE fabrics SET usage_count = usage_count + 1 WHERE id = NEW.fabric_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER increment_design_usage AFTER INSERT ON orders
      WHEN NEW.design_id IS NOT NULL
      BEGIN
        UPDATE designs SET usage_count = usage_count + 1 WHERE id = NEW.design_id;
      END;
    ''');
    
    // Auto-update paid_amount on orders when payment is inserted
    await db.execute('''
      CREATE TRIGGER update_order_paid_amount_insert AFTER INSERT ON payments
      BEGIN
        UPDATE orders SET paid_amount = paid_amount + NEW.amount WHERE id = NEW.order_id;
      END;
    ''');
    
    // Auto-update paid_amount on orders when payment is deleted
    await db.execute('''
      CREATE TRIGGER update_order_paid_amount_delete AFTER DELETE ON payments
      BEGIN
        UPDATE orders SET paid_amount = paid_amount - OLD.amount WHERE id = OLD.order_id;
      END;
    ''');
  }
}
