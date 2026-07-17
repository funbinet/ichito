# ICHITO -- Future Features & Expansion

**Document**: 14 of 14
**Covers**: Planned version 2.0 features, cloud sync strategy, multi-device support, customer facing app, supplier management

---

## 1. Vision for Version 2.0+

ICHITO v1.0 is strictly offline-first, targeting independent tailors who need a robust, reliable tool without recurring subscription fees or constant internet requirements.

As the app scales, the architecture (Repository pattern, Clean Architecture) allows for seamless integration of cloud features in subsequent versions without breaking the core offline functionality.

---

## 2. Cloud Sync Strategy (v2.0)

### 2.1 Local-First Architecture
The app will transition from offline-only to local-first.
- The local SQLite database remains the source of truth for immediate UI rendering.
- All reads/writes happen against the local DB instantly (zero latency).

### 2.2 Synchronization Engine
- Integration with Firebase Firestore or Supabase.
- A background worker (`workmanager` package) queues local changes (CRUD operations) into a local `sync_queue` table.
- When an internet connection is detected, the queue is processed against the cloud database.
- Cloud changes are pulled down via real-time listeners and merged into SQLite.
- **Conflict Resolution**: Last-write-wins based on `updated_at` timestamps.

---

## 3. Multi-Device & Collaboration (v2.0)

Once Cloud Sync is established, tailor shops with multiple employees can collaborate:
- **Roles**: Admin (Owner), Tailor, Receptionist.
- **Shop ID**: Data is scoped to a Shop ID rather than a single user.
- **Task Assignment**: Orders can be assigned to specific tailors within the shop.
- **Audit Logs**: Track who created an order or recorded a payment.

---

## 4. Supplier & Expense Management (v3.0)

Expanding beyond revenue tracking to full profitability analysis:
- **Supplier Directory**: Manage contacts for fabric stores and haberdasheries.
- **Expense Tracking**: Record purchases of thread, electricity, rent, and machine maintenance.
- **Profit & Loss Reports**: Combine Order Revenue and Expenses to generate true P&L statements.
- **Inventory Light**: Track basic stock levels of frequently used materials.

---

## 5. Customer-Facing Web Portal / App (v4.0)

A read-only interface for the tailor's customers:
- Customers receive an SMS with a unique link (e.g., `ichito.app/track/ORD-1234`).
- They can view their order status (Pending, In Progress, Ready for Trial).
- They can view their payment history and outstanding balance.
- They can update their basic contact info or view their measurement profile.

---

## 6. AI Measurement Assistant (R&D)

Exploring computer vision for measurement validation:
- Tailor takes a photo of the customer against a known reference object (e.g., holding a standard A4 paper).
- On-device ML model estimates key measurements.
- Acts as a secondary check against manual tape measurements to catch gross errors (e.g., recording 32 inches as 32 cm).

---

## 7. SMS & WhatsApp Integration

Deepening communication capabilities:
- **Automated SMS API**: Integration with Twilio or Africa's Talking to automatically send SMS when order status changes to "Completed" or "Trial".
- **WhatsApp Business API**: Sending PDF receipts directly to a customer's WhatsApp programmatically rather than relying on the manual share sheet.

---

*This is Document 14 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
