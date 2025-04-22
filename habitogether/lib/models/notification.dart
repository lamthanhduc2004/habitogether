enum NotificationType { workout, pet, system }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final String? imageUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.imageUrl,
  });

  // Tạo từ JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.system,
      ),
      imageUrl: json['imageUrl'],
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
    };
  }

  // Tạo bản sao với trạng thái đã đọc
  AppNotification copyWithRead(bool read) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: read,
      type: type,
      imageUrl: imageUrl,
    );
  }
}
