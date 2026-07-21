class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'Client', 'Order', 'Fabric', 'Design', 'Garment', 'System'
  final String action; // 'Create', 'Read', 'Update', 'Delete'
  final String? referenceId; // General entity id
  final String? clientId;
  final String? orderId;
  final String? clientName;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.action,
    this.referenceId,
    this.clientId,
    this.orderId,
    this.clientName,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'action': action,
      'reference_id': referenceId,
      'client_id': clientId,
      'order_id': orderId,
      'client_name': clientName,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: map['type'],
      action: map['action'] ?? 'Unknown',
      referenceId: map['reference_id'],
      clientId: map['client_id'],
      orderId: map['order_id'],
      clientName: map['client_name'],
      isRead: (map['is_read'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      action: action,
      referenceId: referenceId,
      clientId: clientId,
      orderId: orderId,
      clientName: clientName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
