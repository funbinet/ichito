import 'dart:convert';

class Order {
  final String? id;
  final String orderNumber;
  final String customerId;
  final String garmentId;
  final String? fabricId;
  final String? designId;
  final DateTime orderDate;
  final DateTime dueDate;
  final DateTime? trialDate;
  final String status;
  final double totalAmount;
  final double paidAmount;
  final Map<String, double> measurements;
  final String? notes;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined properties for UI convenience
  String? customerName;
  String? garmentName;
  String? fabricName;

  Order({
    this.id,
    required this.orderNumber,
    required this.customerId,
    required this.garmentId,
    this.fabricId,
    this.designId,
    required this.orderDate,
    required this.dueDate,
    this.trialDate,
    required this.status,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.measurements,
    this.notes,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.garmentName,
    this.fabricName,
  });

  double get balance => totalAmount - paidAmount;
  bool get isFullyPaid => balance <= 0;
  bool get isOverdue => status != 'completed' && status != 'cancelled' && DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'garment_id': garmentId,
      'fabric_id': fabricId,
      'design_id': designId,
      'order_date': orderDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'trial_date': trialDate?.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'measurements': jsonEncode(measurements),
      'notes': notes,
      'special_instructions': specialInstructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map['measurements']) as Map<String, dynamic>;
    final parsedMeasurements = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return Order(
      id: map['id'],
      orderNumber: map['order_number'],
      customerId: map['customer_id'],
      garmentId: map['garment_id'],
      fabricId: map['fabric_id'],
      designId: map['design_id'],
      orderDate: DateTime.parse(map['order_date']),
      dueDate: DateTime.parse(map['due_date']),
      trialDate: map['trial_date'] != null ? DateTime.parse(map['trial_date']) : null,
      status: map['status'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'] ?? 0,
      measurements: parsedMeasurements,
      notes: map['notes'],
      specialInstructions: map['special_instructions'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      customerName: map['customerName'], // From JOIN
      garmentName: map['garmentName'], // From JOIN
    );
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? garmentId,
    String? fabricId,
    String? designId,
    DateTime? orderDate,
    DateTime? dueDate,
    DateTime? trialDate,
    String? status,
    double? totalAmount,
    double? paidAmount,
    Map<String, double>? measurements,
    String? notes,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? garmentName,
    String? fabricName,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      garmentId: garmentId ?? this.garmentId,
      fabricId: fabricId ?? this.fabricId,
      designId: designId ?? this.designId,
      orderDate: orderDate ?? this.orderDate,
      dueDate: dueDate ?? this.dueDate,
      trialDate: trialDate ?? this.trialDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      measurements: measurements ?? this.measurements,
      notes: notes ?? this.notes,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      garmentName: garmentName ?? this.garmentName,
      fabricName: fabricName ?? this.fabricName,
    );
  }
}

class Payment {
  final String? id;
  final String orderId;
  final double amount;
  final DateTime date;
  final String method; // 'cash', 'mpesa', 'bank'
  final String? notes;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.orderId,
    required this.amount,
    required this.date,
    required this.method,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      orderId: map['order_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      method: map['method'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class StatusLog {
  final String? id;
  final String orderId;
  final String fromStatus;
  final String toStatus;
  final DateTime changedAt;
  final String? notes;

  StatusLog({
    this.id,
    required this.orderId,
    required this.fromStatus,
    required this.toStatus,
    required this.changedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'from_status': fromStatus,
      'to_status': toStatus,
      'changed_at': changedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory StatusLog.fromMap(Map<String, dynamic> map) {
    return StatusLog(
      id: map['id'],
      orderId: map['order_id'],
      fromStatus: map['from_status'],
      toStatus: map['to_status'],
      changedAt: DateTime.parse(map['changed_at']),
      notes: map['notes'],
    );
  }
}
