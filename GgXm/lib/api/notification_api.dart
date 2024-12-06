import 'package:get/get.dart';
import '../models/notification.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';

class NotificationApi {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<AppNotification>> getNotifications() async {
    final response = await _httpService.get<List<dynamic>>(
      ApiConstants.notifications,
    );
    
    return response.map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _httpService.post(
      '${ApiConstants.notifications}/$id/read',
    );
  }

  Future<void> markAllAsRead() async {
    await _httpService.post(
      ApiConstants.markAllNotificationsAsRead,
    );
  }

  Future<void> deleteNotification(String id) async {
    await _httpService.delete(
      '${ApiConstants.notifications}/$id',
    );
  }
} 