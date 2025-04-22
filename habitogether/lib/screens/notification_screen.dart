import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                onPressed: () {
                  _showClearAllDialog(context, notificationProvider);
                },
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF281B30), Color(0xFF1D1340)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child:
              notificationProvider.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF9F43),
                      ),
                    ),
                  )
                  : notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(notifications, notificationProvider),
        ),
      ),
    );
  }

  // Hiển thị danh sách thông báo
  Widget _buildNotificationList(
    List<AppNotification> notifications,
    NotificationProvider provider,
  ) {
    // Nhóm thông báo theo ngày
    final Map<String, List<AppNotification>> groupedNotifications = {};

    for (final notification in notifications) {
      final date = DateFormat('dd/MM/yyyy').format(notification.createdAt);
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedNotifications.length,
          itemBuilder: (context, index) {
            final date = groupedNotifications.keys.elementAt(index);
            final dateNotifications = groupedNotifications[date]!;

            // Tính toán độ trễ cho mỗi nhóm
            final delayFactor = index / (groupedNotifications.length);
            final delayedAnimation =
                _animationController.value - delayFactor * 0.3;
            final opacity = (delayedAnimation * 3.0).clamp(0.0, 1.0);
            final slideOffset = (1.0 - opacity) * 50;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, slideOffset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9F43),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getDateLabel(date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...dateNotifications.map((notification) {
                      // Thêm độ trễ để hiệu ứng cascade
                      final itemIndex = dateNotifications.indexOf(notification);
                      final itemDelayFactor =
                          itemIndex / (dateNotifications.length * 3);
                      final itemOpacity =
                          ((delayedAnimation - itemDelayFactor) * 2.0).clamp(
                            0.0,
                            1.0,
                          );

                      return Opacity(
                        opacity: itemOpacity,
                        child: Transform.translate(
                          offset: Offset(0, (1 - itemOpacity) * 30),
                          child: _buildNotificationItem(notification, provider),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Tạo nhãn ngày
  String _getDateLabel(String date) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final yesterday = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now().subtract(const Duration(days: 1)));

    if (date == today) return 'Hôm nay';
    if (date == yesterday) return 'Hôm qua';
    return date;
  }

  // Widget hiển thị một thông báo
  Widget _buildNotificationItem(
    AppNotification notification,
    NotificationProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.markAsRead(notification.id);
            _showNotificationDetail(notification);
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: _getNotificationColor(
            notification.type,
          ).withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  notification.isRead
                      ? Colors.white.withOpacity(0.07)
                      : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    notification.isRead
                        ? Colors.white.withOpacity(0.1)
                        : _getNotificationColor(
                          notification.type,
                        ).withOpacity(0.5),
                width: 1,
              ),
              boxShadow:
                  notification.isRead
                      ? null
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon loại thông báo
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Nội dung thông báo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                      notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Nút đánh dấu đã đọc
                            if (!notification.isRead)
                              InkWell(
                                onTap: () {
                                  provider.markAsRead(notification.id);
                                },
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(
                                      notification.type,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getNotificationColor(
                                          notification.type,
                                        ).withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(notification.createdAt),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            if (notification.imageUrl != null &&
                                notification.imageUrl!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.image,
                                    size: 12,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Có hình ảnh',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Format thời gian
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Lấy màu dựa trên loại thông báo
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return const Color(0xFF81C784); // Xanh lá
      case NotificationType.pet:
        return const Color(0xFFFFD54F); // Vàng
      case NotificationType.system:
        return const Color(0xFF64B5F6); // Xanh dương
    }
  }

  // Lấy icon dựa trên loại thông báo
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return FontAwesomeIcons.dumbbell;
      case NotificationType.pet:
        return FontAwesomeIcons.paw;
      case NotificationType.system:
        return FontAwesomeIcons.bell;
    }
  }

  // Widget hiển thị khi không có thông báo
  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: Transform.scale(
            scale: 0.5 + (_animationController.value * 0.5),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.bellSlash,
                size: 60,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Các thông báo của bạn sẽ xuất hiện ở đây',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị dialog chi tiết thông báo
  void _showNotificationDetail(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A236A), Color(0xFF2C1D56)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor(
                                    notification.type,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getNotificationIcon(notification.type),
                                  color: _getNotificationColor(
                                    notification.type,
                                  ),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(notification.createdAt),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Hiển thị hình ảnh nếu có
                          if (notification.imageUrl != null &&
                              notification.imageUrl!.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  notification.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FontAwesomeIcons
                                                  .circleExclamation,
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              size: 40,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Không thể tải hình ảnh',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ),
                              ),
                            ),

                          // Nội dung thông báo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              notification.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Nút đóng
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9F43),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFFFF9F43,
                                ).withOpacity(0.3),
                              ),
                              child: const Text(
                                'Đóng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Hiển thị dialog xóa tất cả thông báo
  void _showClearAllDialog(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF2C1D56),
            title: Row(
              children: [
                Icon(FontAwesomeIcons.trash, color: Colors.red, size: 24),
                SizedBox(width: 12),
                const Text(
                  'Xóa tất cả thông báo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xóa tất cả thông báo không?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.clearAllNotifications();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
