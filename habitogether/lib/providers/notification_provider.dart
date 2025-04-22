import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;

  // Getter
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  // Đếm số thông báo chưa đọc
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Khởi tạo dữ liệu mẫu
  NotificationProvider() {
    _initSampleData();
  }

  // Khởi tạo dữ liệu mẫu
  void _initSampleData() {
    // Thêm một số thông báo mẫu
    _notifications.add(
      AppNotification(
        id: '1',
        title: 'Bài tập hàng ngày',
        message: 'Bạn còn 3 bài tập chưa hoàn thành hôm nay!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.workout,
      ),
    );

    _notifications.add(
      AppNotification(
        id: '2',
        title: 'Thú cưng đã tiến hóa!',
        message: 'Chúc mừng! Chalamander của bạn đã tiến hóa thành Charmeleon!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.pet,
        imageUrl: 'assets/pets/dragon/evolution_2.gif',
      ),
    );

    _notifications.add(
      AppNotification(
        id: '3',
        title: 'Chào mừng đến với ứng dụng',
        message:
            'Chào mừng bạn đến với Fitleveling, hãy bắt đầu thói quen luyện tập ngay!',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.system,
      ),
    );
  }

  // Đánh dấu thông báo đã đọc
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWithRead(true);
      notifyListeners();
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWithRead(true);
    }
    notifyListeners();
  }

  // Thêm thông báo mới
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Xóa thông báo
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Xóa tất cả thông báo
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
