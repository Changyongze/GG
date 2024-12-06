import 'package:get/get.dart';
import '../../models/notification.dart';
import '../../services/auth_service.dart';
import '../../api/notification_api.dart';

class NotificationsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final NotificationApi _notificationApi = NotificationApi();
  
  final isLoading = false.obs;
  final notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await _notificationApi.getNotifications();
      notifications.value = response;
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  void showNotificationDetail(AppNotification notification) async {
    if (!notification.isRead) {
      try {
        await _notificationApi.markAsRead(notification.id);
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = AppNotification(
            id: notification.id,
            title: notification.title,
            content: notification.content,
            type: notification.type,
            createdAt: notification.createdAt,
            isRead: true,
            data: notification.data,
          );
        }
      } catch (e) {
        print('标记已读失败: $e');
      }
    }

    // 根据通知类型处理跳转
    if (notification.data != null) {
      switch (notification.type) {
        case 'ad':
          if (notification.data!['ad_id'] != null) {
            Get.toNamed(Routes.AD_DETAIL, arguments: notification.data!['ad_id']);
          }
          break;
        case 'points':
          Get.toNamed(Routes.POINTS_HISTORY);
          break;
        default:
          _showNotificationDialog(notification);
      }
    } else {
      _showNotificationDialog(notification);
    }
  }

  void _showNotificationDialog(AppNotification notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationApi.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationApi.markAllAsRead();
      notifications.value = notifications.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        content: n.content,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
        data: n.data,
      )).toList();
      Get.snackbar('提示', '已全部标记为已读');
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }
} 