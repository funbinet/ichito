# ICHITO -- Analytics & Reporting

**Document**: 13 of 14
**Covers**: Dashboard statistics, financial reports, customer analytics, garment popularity, PDF export structures

---

## 1. Analytics Overview

ICHITO provides tailors with actionable insights into their business performance. Since the app is offline-first, all analytics are calculated locally using SQLite aggregate functions.

---

## 2. Dashboard Quick Stats

The home screen displays three key metrics at the top:

### 2.1 Revenue (This Month)
- **Calculation**: Sum of all `payments.amount` where `date` is in the current month.
- **Comparison**: Percentage change vs. previous month.
- **Query**:
  ```sql
  SELECT SUM(amount) FROM payments 
  WHERE strftime('%Y-%m', date) = strftime('%Y-%m', 'now');
  ```

### 2.2 Active Orders
- **Calculation**: Count of orders where `status` IN ('pending', 'in_progress', 'trial').
- **Query**:
  ```sql
  SELECT COUNT(*) FROM orders 
  WHERE status IN ('pending', 'in_progress', 'trial');
  ```

### 2.3 Outstanding Balances
- **Calculation**: Sum of `(total_amount - paid_amount)` for all non-cancelled orders where `total_amount > paid_amount`.
- **Query**:
  ```sql
  SELECT SUM(total_amount - paid_amount) FROM orders 
  WHERE status != 'cancelled' AND total_amount > paid_amount;
  ```

---

## 3. Financial Reports

Accessible via a dedicated "Reports" screen (radial menu action).

### 3.1 Revenue Timeline Chart
- Shows revenue grouped by day/week/month.
- Uses `fl_chart` for rendering smooth line or bar charts.
- **SQL Aggregation**:
  ```sql
  SELECT strftime('%Y-%m', date) as period, SUM(amount) as total
  FROM payments
  GROUP BY period
  ORDER BY period DESC
  LIMIT 12;
  ```

### 3.2 Expected vs. Collected
- Compares total billed (`orders.total_amount`) vs total collected (`payments.amount`) for a given period.
- Helps identify collection efficiency.

### 3.3 Payment Method Breakdown
- Pie chart showing distribution of cash vs M-Pesa vs Bank.
- **SQL Aggregation**:
  ```sql
  SELECT method, SUM(amount) as total
  FROM payments
  WHERE date >= ? AND date <= ?
  GROUP BY method;
  ```

---

## 4. Customer & Garment Analytics

### 4.1 Top Customers
- List of customers sorted by `total_spent` or `total_orders`.
- Shown on the Customers screen stats overlay.

### 4.2 Garment Popularity
- Pie/Bar chart showing most frequently ordered garments.
- **SQL Aggregation**:
  ```sql
  SELECT g.name, COUNT(o.id) as order_count
  FROM orders o
  JOIN garments g ON o.garment_id = g.id
  GROUP BY g.id
  ORDER BY order_count DESC
  LIMIT 10;
  ```

### 4.3 Conversion Rate (New vs Return)
- Ratio of orders from first-time customers vs returning customers in a given period.

---

## 5. Export and Reporting

ICHITO allows users to export data for external accounting or backup purposes.

### 5.1 CSV Export

Users can export raw data to CSV files (saved to device downloads folder or shared via share sheet):
- `customers_export.csv`: ID, Name, Phone, Email, Gender, TotalOrders, TotalSpent, LoyaltyStatus
- `orders_export.csv`: OrderNumber, CustomerName, GarmentName, Status, OrderDate, DueDate, TotalAmount, PaidAmount
- `payments_export.csv`: Date, OrderNumber, CustomerName, Amount, Method, Notes

### 5.2 PDF Invoice/Receipt Generation

When viewing an order, users can generate a PDF receipt to share via WhatsApp or print. Uses the `pdf` and `printing` packages.

**Receipt Structure**:
```
[BUSINESS NAME]
[Business Phone | Location]
--------------------------------
RECEIPT
Date: [Current Date]
Order #: [ICHITO-YYYY-MM-XXX]
--------------------------------
Customer: [Customer Name]
Phone: [Customer Phone]
--------------------------------
Item: [Garment Name] - [Fabric Name]
Total Amount:    KES [Total]
--------------------------------
PAYMENT HISTORY:
[Date] - [Method] - KES [Amount]
[Date] - [Method] - KES [Amount]

Total Paid:      KES [Paid]
--------------------------------
BALANCE DUE:     KES [Remaining]
--------------------------------
[Due Date if not fully paid]
Thank you for your business!
```

---

## 6. Chama Analytics (Notes)

For Chama notes, the app can generate a summary report across multiple meetings:

- **Total Group Savings**: Sum of all collected amounts across all Chama notes.
- **Member Contribution History**: A matrix showing members (rows) and meeting dates (columns) with their contribution status.
- **Query Logic**: Done in Dart by parsing the JSON `contributions` maps across multiple `Note` records.

---

*This is Document 13 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
